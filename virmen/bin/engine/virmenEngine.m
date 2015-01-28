function err = virmenEngine(exper)
% Virmen engine

% No error by default
err = -1;

% Define variables used by text boxes
global vr aspectRatio textBoundaries %#ok<*REDEF>
vr = struct;
aspectRatio = [];
textBoundaries = zeros(0,4);
screenSize = get(0,'screensize');

% Load experiment
vr.exper = exper;
vr.code = exper.experimentCode(); %#ok<*STRNU>
vr.antialiasing = vr.exper.antialiasing;
[letterGrid letterFont letterAspectRatio] = virmenLoadFont;

% Load worlds
vr.worlds = struct([]);
for wNum = 1:length(vr.exper.worlds)
    vr.worlds{wNum} = loadVirmenWorld(vr.exper.worlds{wNum});
end

% Initialize parameters
vr.experimentEnded = false;
vr.currentWorld = 1;
vr.position = vr.worlds{vr.currentWorld}.startLocation;
vr.velocity = [0 0 0 0];
vr.dt = NaN;
vr.dp = NaN(1,4);
vr.collision = false;
vr.text = struct('string',{},'position',{},'size',{},'color',{});
vr.plot = struct('x',{},'y',{},'color',{});
vr.textClicked = NaN;
vr.keyPressed = NaN;
vr.iterations = 0;
vr.timeStarted = NaN;

% Load OpenGL .NET assemblies
mfile = mfilename('fullpath');
path = fileparts(mfile);
try
    NET.addAssembly([path filesep 'OpenTK.dll']);
    NET.addAssembly([path filesep 'OpenTK.GLControl.dll']);
catch ME
    err = struct;
    err.net = true;
    err.message = ME.message;
    err.stack = ME.stack(1:end-1);
    return
end
import  OpenTK.Graphics.OpenGL.*;

% Load .NET assemblies for using Windows system forms
NET.addAssembly('System');
NET.addAssembly('System.Windows.Forms');

% Start a Windows system form
vr.window = System.Windows.Forms.Form;
vr.window.Visible = true;
vr.window.WindowState = System.Windows.Forms.FormWindowState.Maximized;
vr.window.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
vr.window.TopMost = true;

% Add a cancel button
cancelSize = [25 45];
cancelButton = System.Windows.Forms.Button;
cancelButton.Width = cancelSize(2);
cancelButton.Height = cancelSize(1);
cancelButton.Text = 'X';
cancelButton.Left = vr.window.Right-cancelSize(2);
cancelButton.Top = 0;
vr.window.Controls.Add(cancelButton);
addlistener(cancelButton,'MouseClick',@clickCancel);

% Start an OpenGL control and assign it to the Windows system form
vr.oglControl = OpenTK.GLControl;
vr.oglControl.Size = vr.window.Size;
vr.oglControl.VSync = true; % synchronize screen update to monitor refresh
vr.window.Controls.Add(vr.oglControl);

% Add listeners to respond to mouse clicks and button presses in the window
addlistener(vr.oglControl,'MouseClick',@mouseClick);
addlistener(vr.oglControl,'KeyPress',@keyPress);
addlistener(vr.window,'KeyPress',@keyPress);

% Activate the Windows system form
vr.window.Activate;

% Initialize OpenGL properties
aspectRatio = double(vr.oglControl.Size.Width)/double(vr.oglControl.Size.Height);
GL.Ortho(-aspectRatio,aspectRatio,-1,1,-1e3,0); % orthographic projection
GL.Enable(EnableCap.DepthTest); % enable depth (for object occlusion)
GL.ClearDepth(-1);
GL.DepthFunc(DepthFunction.Gequal);
GL.ShadeModel(ShadingModel.Flat); % uniform coloring of each polygon
GL.ClearColor(0,0,0,0); % background color
currentBG = [0 0 0];

% Enable the use of arrays to specify coordinates and colors
GL.EnableClientState(EnableCap.VertexArray);
GL.EnableClientState(EnableCap.ColorArray);


% Run initialization code
try
    vr = vr.code.initialization(vr); %#ok<*NASGU>
catch ME
    vr.window.Dispose;
    err = struct;
    err.message = ME.message;
    err.stack = ME.stack(1:end-1);
    return
end

% Move mouse pointer to the corner of the screen
set(0,'pointerlocation',screenSize(3:4));

% Initialize engine
oldWorld = 0;
oldAntialiasing = NaN;
vr.timeStarted = now;
windowSize = double([vr.window.Right screenSize(4)-vr.window.Top]);

% Run engine
while ~vr.experimentEnded    
    % Update the number of iterations
    vr.iterations = vr.iterations + 1;
    
    % Determine cancel button visibility
    offs = get(0,'pointerlocation')-windowSize;
    if offs(1) >= -cancelSize(2) && offs(2) >= -cancelSize(1) && all(offs <= 0)
        if ~cancelButton.Visible
            cancelButton.Show;
        end
    else
        if cancelButton.Visible;
            cancelButton.Hide;
        end
    end
    
    % Switch worlds, if necessary
    if vr.currentWorld ~= oldWorld
        oldWorld = vr.currentWorld;
        
        % Set transparency options
        if size(vr.worlds{vr.currentWorld}.surface.colors,1)==4
            enableTransparency = any(~isnan(vr.worlds{vr.currentWorld}.surface.colors(4,:)));
        else
            enableTransparency = false;
        end
        if enableTransparency
            GL.Enable(EnableCap.Blend);
            GL.BlendFunc(BlendingFactorSrc.SrcAlpha,BlendingFactorDest.OneMinusSrcAlpha);
            vr.worlds{vr.currentWorld}.surface.colors(4,isnan(vr.worlds{vr.currentWorld}.surface.colors(4,:))) = 1-eps;
        else
            GL.Disable(EnableCap.Blend);
            if size(vr.worlds{vr.currentWorld}.surface.colors,1) == 4
                vr.worlds{vr.currentWorld}.surface.colors(4,:) = [];
            end
        end
        colorSize = int32(size(vr.worlds{vr.currentWorld}.surface.colors,1));
    end
    
    % Change antialiasing, if necessary
    if vr.antialiasing ~= oldAntialiasing
        jitter = virmenJitterGrid(vr.antialiasing); %#ok<*NODEF>
        jitter = jitter*2/double(vr.oglControl.Size.Height); % normalize jitter values to pixel size
    end
    
    % Set world background color
    if ~all(currentBG==vr.worlds{vr.currentWorld}.backgroundColor)
        GL.ClearColor(vr.worlds{vr.currentWorld}.backgroundColor(1), ...
            vr.worlds{vr.currentWorld}.backgroundColor(2),vr.worlds{vr.currentWorld}.backgroundColor(3),0);
        currentBG = vr.worlds{vr.currentWorld}.backgroundColor;
    end
    
    % Input movement information
    try
        vr.velocity = vr.exper.movementFunction(vr);
    catch ME
        vr.window.Dispose;
        err = struct;
        err.message = ME.message;
        err.stack = ME.stack(1:end-1);
        return
    end
    
    % Calculate displacement
    if vr.iterations == 1
        vr.dt = 0; % Don't move on the first time step
    else
        vr.dt = toc(iterationStart); % End timer to determine time step duration
    end
    vr.dp = vr.velocity*vr.dt;
    iterationStart = tic; % Start timer for the next time step
    
    % Detect collisions with edges (continuous-time collision detection)
    [vr.dp(1:2) vr.collision] = virmenDetectCollisions(vr.position(1:2),vr.dp(1:2), ...
        vr.worlds{vr.currentWorld}.edges.endpoints,vr.worlds{vr.currentWorld}.edges.radius);
    
    % Set world background color
    GL.ClearColor(vr.worlds{vr.currentWorld}.backgroundColor(1), ...
        vr.worlds{vr.currentWorld}.backgroundColor(2), ...
        vr.worlds{vr.currentWorld}.backgroundColor(3),1);
    
    % Clear the screen (depth and color buffers)
    GL.Clear(ClearBufferMask.DepthBufferBit);
    GL.Clear(ClearBufferMask.ColorBufferBit);
    
    % Run custom code on each engine iteration
    try
        vr = vr.code.runtime(vr);
    catch ME
        vr.window.Dispose;
        err = struct;
        err.message = ME.message;
        err.stack = ME.stack(1:end-1);
        return
    end
    
    % End the experiment if the cancel button has been clicked of Esc pressed
    if double(vr.keyPressed) == 27
        vr.experimentEnded = true;
        break
    end
    
    % Reset textbox click and key pressed states
    vr.textClicked = NaN;
    vr.keyPressed = NaN;
    
    % Determine text position boundaries
    textBoundaries = zeros(length(vr.text),4);
    for ndx = 1:length(vr.text)
        textBoundaries(ndx,:) = [vr.text(ndx).position ...
            vr.text(ndx).position(1)+vr.text(ndx).size*length(vr.text(ndx).string) ...
            vr.text(ndx).position(2)+vr.text(ndx).size*letterAspectRatio];
    end
    
    % Update position
    vr.position = vr.position+vr.dp;    
    
    % Translate coordinates
    vertexArray = virmenTranslate(vr.worlds{oldWorld}.surface.vertices,vr.position);
    
    % Rotate coordinates
    if vr.position(4) ~= 0
        vertexArray = virmenRotate(vertexArray,vr.position(4));
    end
    
    % Calculate z-order of all coordinates
    z_new = virmenZOrder(vertexArray);
    
    % Transform 3D coordinates to 2D screen coordinates
    try
        vertexArray = vr.exper.transformationFunction(vertexArray);
    catch ME
        vr.window.Dispose;
        err = struct;
        err.message = ME.message;
        err.stack = ME.stack(1:end-1);
        return
    end
    
    % Determine triangle visibility
    visible = virmenTriangleVisibility(vr.worlds{oldWorld}.surface.triangulation,vertexArray,vr.worlds{oldWorld}.surface.visible);
    
    % Set z-order
    vertexArray(3,:) = z_new;
    
    % Extract visible triangles
    triangles = vr.worlds{oldWorld}.surface.triangulation(:,visible==1);
    
    % Sort triangles from back to front
    if enableTransparency
        [~, ord] = sort(min(z_new(triangles+1),[],1),2,'descend');
        triangles = triangles(:,ord);
    end
    
    % Obtain memory pointers for use by OpenGL
    memV = virmenMemoryAddress(vertexArray);
    memC = virmenMemoryAddress(vr.worlds{oldWorld}.surface.colors);
    memI = virmenMemoryAddress(triangles);
        
    % Clear the accumulation buffer (for anti-aliasing)
    if size(jitter,1) > 1
        GL.Clear(ClearBufferMask.AccumBufferBit);
    end
    
    % Anti-aliasing
    for j = 1:size(jitter,1)
        % Clear the screen (color and depth buffers)
        if j > 1
            GL.Clear(ClearBufferMask.DepthBufferBit);
            GL.Clear(ClearBufferMask.ColorBufferBit);
        end
        
        % Jitter all coordinates by a sub-pixel amount
        if size(jitter,1)>1
            GL.PushMatrix;
            GL.Translate(jitter(j,1),jitter(j,2),0);
        end
        
        % Setup pointers to vertex and color arrays
        GL.VertexPointer(int32(3),VertexPointerType.Double,int32(0),memV);
        GL.ColorPointer(colorSize,ColorPointerType.Double,int32(0),memC);
        
        % Render polygons
        GL.DrawElements(BeginMode.Triangles, ...
            int32(numel(triangles)), ...
            DrawElementsType.UnsignedInt,memI);
        
        % Add the rendered image to the accumulation buffer
        if size(jitter,1)>1
            GL.PopMatrix;
            GL.Accum(AccumOp.Accum,1/size(jitter,1));
        end
    end
    
    % Read image from the accumulation buffer
    if size(jitter,1)>1
        GL.Accum(AccumOp.Return,1);
    end
    
    % Flush queue so that ViRMEn responds to the mouse and keyboard
    drawnow;
    
    % Create text boxes and plots
    if ~isempty(vr.text) || ~isempty(vr.plot)
        % Determine the total number of line segments to draw
        tot = 0;
        for ndx = 1:length(vr.text)
            for s = 1:length(vr.text(ndx).string)
                tot = tot+length(letterFont{double(vr.text(ndx).string(s))});
            end
        end
        colors = zeros(6,tot);
        coords = zeros(4,tot);
        
        % Create arrays of coordinates and colors
        cnt = 0;
        for ndx = 1:length(vr.text)
            for s = 1:length(vr.text(ndx).string)
                virmenCreateLetters(coords,colors,cnt,letterGrid,letterFont{double(vr.text(ndx).string(s))},vr.text(ndx).size,vr.text(ndx).position,s,vr.text(ndx).color);
            end
        end
                
        % Attach plots to the arrays of coordinates and colors
        for ndx = 1:length(vr.plot)
            sz = size(coords,2);
            coords(:,sz+1:sz+length(vr.plot(ndx).x)-1) = ...
                [vr.plot(ndx).x(1:end-1); vr.plot(ndx).y(1:end-1); vr.plot(ndx).x(2:end); vr.plot(ndx).y(2:end)];
            colors([1 4],sz+1:sz+length(vr.plot(ndx).x)-1) = vr.plot(ndx).color(1);
            colors([2 5],sz+1:sz+length(vr.plot(ndx).x)-1) = vr.plot(ndx).color(2);
            colors([3 6],sz+1:sz+length(vr.plot(ndx).x)-1) = vr.plot(ndx).color(3);
        end

        % Create an array of indices
        indices = int32(0:2*size(coords,2)-1);
        
        % Obtain memory pointers for use by OpenGL
        memC = virmenMemoryAddress(colors);
        memV = virmenMemoryAddress(coords);
        memI = virmenMemoryAddress(indices);
        
        % Setup pointers to vertex and color arrays for the line segments
        GL.ColorPointer(int32(3),ColorPointerType.Double,int32(0),memC);
        GL.VertexPointer(int32(2),VertexPointerType.Double,int32(0),memV);
        
        % Draw line segments
        GL.DrawElements(BeginMode.Lines,int32(numel(indices)),DrawElementsType.UnsignedInt,memI);
    end
    
    % Update display
    if vr.oglControl.IsDisposed
        vr.experimentEnded = true;
        continue
    end
    vr.oglControl.SwapBuffers
end

% Display engine runtime information
totalTime = (now-vr.timeStarted)*60*60*24;
disp(['Ran ' num2str(vr.iterations) ' iterations in ' num2str(totalTime,4) ...
    ' s (' num2str(totalTime*1000/vr.iterations,3) ' ms/frame refresh time).']);

% Run termination code
try
    vr.code.termination(vr);
catch ME
    vr.window.Dispose;
    err = struct;
    err.message = ME.message;
    err.stack = ME.stack(1:end-1);
    return
end

% Close the window used by ViRMEn
try
    vr.window.Dispose;
catch ME %#ok<NASGU>
    % Window already disposed
end


function mouseClick(~,evt)
% Runs whenever the mouse is clicked inside the window


global vr aspectRatio textBoundaries

x = 2*double(evt.X)/double(vr.oglControl.Size.Height)-aspectRatio;
y = 1-2*double(evt.Y)/double(vr.oglControl.Size.Height);
for t = 1:length(vr.text)
    if x >= textBoundaries(t,1) && x <= textBoundaries(t,3) && ...
            y >= textBoundaries(t,2) && y <= textBoundaries(t,4)
        vr.textClicked = t;
    end
end

function keyPress(~,evt)
% Runs whenever a key is pressed inside the window

global vr
vr.keyPressed = evt.KeyChar;

function clickCancel(varargin)

global vr
vr.experimentEnded = true;