function code = integrationMaze5
% integrationMaze1   Code for the ViRMEn experiment integrationMaze1.
%   code = integrationMaze1   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT



% --- INITIALIZATION code: executes before the ViRMEN engine starts.
function vr = initializationCodeFun(vr)

path = ['C:\DATA\Chris\ch' vr.exper.variables.mouseNumber];
if ~exist(path,'dir')
    mkdir(path);
end
vr.filenameMat = ['ch',vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'.mat'];
vr.filenameDat = ['ch',vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'.dat'];
fileIndex = 0;
fileList = what(path);
while sum(strcmp(fileList.mat,vr.filenameMat)) > 0
    fileIndex = fileIndex + 1;
    vr.filenameMat = ['ch',vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'_',num2str(fileIndex),'.mat'];
    vr.filenameDat = ['ch',vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'_',num2str(fileIndex),'.dat'];
    fileList = what(path);
end
exper = copyVirmenObject(vr.exper); %#ok<NASGU>
vr.pathMat = [path,'\',vr.filenameMat];
vr.pathDat = [path, '\',vr.filenameDat];
save(vr.pathMat,'exper');
vr.fid = fopen(vr.pathDat,'w');

% Start the DAQ acquisition
daqreset; %reset DAQ in case it's still in use by a previous Matlab program
vr.ai = analoginput('nidaq','dev1'); % connect to the DAQ card
addchannel(vr.ai,0:1); % start channels 0 and 1
set(vr.ai,'samplerate',1000,'samplespertrigger',1e7); % define buffer
start(vr.ai); % start acquisition

vr.ao = analogoutput('nidaq','dev1');
addchannel(vr.ao,0:3);
set(vr.ao,'samplerate',10000);

vr.inITI = 0;
vr.isReward = 0;
vr.outITI = false;
vr.mazeDesign = [];

vr.indLeftNoDots = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.stemLeftWall_noDots,:);
vr.indLeftDots = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.stemLeftWall_dots,:);
vr.indRightNoDots = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.stemRightWall_noDots,:);
vr.indRightDots = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.stemRightWall_dots,:);

% numLeft = 4;
% while numLeft > 2 && numLeft < 6
%     numLeft = randi([0 8],1);
numLeft = 5;
% end
vr.leftDots = sort(randsample(8,numLeft));
warning('off','MATLAB:colon:nonIntegerIndex')
vr.worlds{1}.surface.visible(:) = 1;
for i = 1:8
    if ~isempty(find(vr.leftDots == i,1))
        vr.worlds{1}.surface.visible(vr.indLeftNoDots(1)+(vr.indLeftNoDots(2)-vr.indLeftNoDots(1))/8*(i-1):vr.indLeftNoDots(1)+(vr.indLeftNoDots(2)-vr.indLeftNoDots(1))/8*(i)) = 0;
        vr.worlds{1}.surface.visible(vr.indRightDots(1)+(vr.indRightDots(2)-vr.indRightDots(1))/8*(i-1):vr.indRightDots(1)+(vr.indRightDots(2)-vr.indRightDots(1))/8*(i)) = 0;
    else
        vr.worlds{1}.surface.visible(vr.indLeftDots(1)+(vr.indLeftDots(2)-vr.indLeftDots(1))/8*(i-1):vr.indLeftDots(1)+(vr.indLeftDots(2)-vr.indLeftDots(1))/8*(i)) = 0;
        vr.worlds{1}.surface.visible(vr.indRightNoDots(1)+(vr.indRightNoDots(2)-vr.indRightNoDots(1))/8*(i-1):vr.indRightNoDots(1)+(vr.indRightNoDots(2)-vr.indRightNoDots(1))/8*(i)) = 0;
    end
end

if length(vr.leftDots) > 4
    vr.rewPos = 1;
elseif length(vr.leftDots) < 4
    vr.rewPos = 2;
elseif length(vr.leftDots) == 4
    vr.rewPos = randi(2,1);
%     vr.rewPos = 2;
end


% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

% putsample(vr.ao,[0,vr.position(4),vr.position(1),vr.position(2)/100]);

if vr.inITI == 0 && abs(vr.position(1)) > eval(vr.exper.variables.armLength)/2 && vr.position(2) > eval(vr.exper.variables.mazeLength)
    if vr.position(1) < 0 && vr.rewPos == 1
        vr.isReward = 1;
        putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
        start(vr.ao);
        stop(vr.ao);
        vr.itiDur = 2;
    elseif  vr.position(1) > 0 && vr.rewPos == 2
        vr.isReward = 1;
        putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
        start(vr. ao);
        stop(vr.ao);
        vr.itiDur = 2;
    else
        vr.isReward = 0;
        vr.itiDur = 6;
    end
    
    vr.worlds{1}.surface.visible(:) = 0;
    vr.itiStartTime = tic;
    vr.inITI = 1;
    
    mazeDes = zeros(8,3);
    mazeDes(vr.leftDots,1) = 1;
    mazeDes(setdiff(1:8,vr.leftDots),2) = 1;
    mazeDes(1,3) = vr.isReward;
    mazeDes(2,3) = vr.rewPos;
    vr.mazeDesign = cat(3,vr.mazeDesign,mazeDes);

else
    vr.isReward = 0;
end  

if vr.inITI == 1
    vr.itiTime = toc(vr.itiStartTime);
    if vr.itiTime > vr.itiDur
        vr.inITI = 0;
        vr.position = vr.worlds{1}.startLocation;
%         numLeft = 4;
%         while numLeft > 2 && numLeft < 6
            numLeft = randi([0 8],1);
%         end
        vr.leftDots = sort(randsample(8,numLeft));
        
        vr.worlds{1}.surface.visible(:) = 1;
        for i = 1:8
            if ~isempty(find(vr.leftDots == i,1))
                vr.worlds{1}.surface.visible(vr.indLeftNoDots(1)+(vr.indLeftNoDots(2)-vr.indLeftNoDots(1))/8*(i-1):vr.indLeftNoDots(1)+(vr.indLeftNoDots(2)-vr.indLeftNoDots(1))/8*(i)) = 0;
                vr.worlds{1}.surface.visible(vr.indRightDots(1)+(vr.indRightDots(2)-vr.indRightDots(1))/8*(i-1):vr.indRightDots(1)+(vr.indRightDots(2)-vr.indRightDots(1))/8*(i)) = 0;
            else
                vr.worlds{1}.surface.visible(vr.indLeftDots(1)+(vr.indLeftDots(2)-vr.indLeftDots(1))/8*(i-1):vr.indLeftDots(1)+(vr.indLeftDots(2)-vr.indLeftDots(1))/8*(i)) = 0;
                vr.worlds{1}.surface.visible(vr.indRightNoDots(1)+(vr.indRightNoDots(2)-vr.indRightNoDots(1))/8*(i-1):vr.indRightNoDots(1)+(vr.indRightNoDots(2)-vr.indRightNoDots(1))/8*(i)) = 0;
            end
        end
        
        if length(vr.leftDots) > 4
            vr.rewPos = 1;
        elseif length(vr.leftDots) < 4
            vr.rewPos = 2;
        elseif length(vr.leftDots) == 4
            vr.rewPos = randi(2,1);
%             vr.rewPos = 2;
        end

        vr.outITI = true;
    end
end

fwrite(vr.fid,[rem(now,1) vr.position([1:2,4]) vr.velocity(1:2) vr.rewPos vr.isReward vr.inITI],'float');



% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)

% save('temp.mat','vr');

fclose all;
fid = fopen(vr.pathDat);
data = fread(fid,'float');
data = reshape(data,9,numel(data)/9);
assignin('base','data',data);
save(vr.pathMat,'data','-append');
mazeDesign = vr.mazeDesign;
save(vr.pathMat,'mazeDesign','-append');
fclose all; 

