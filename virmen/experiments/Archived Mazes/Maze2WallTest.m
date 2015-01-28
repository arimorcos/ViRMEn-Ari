function code = Maze2WallTest
% Maze2   Code for the ViRMEn experiment Maze2.
%   code = Maze2   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT



% --- INITIALIZATION code: executes before the ViRMEN engine starts.
function vr = initializationCodeFun(vr)

vr.debugMode = true;

path = ['C:\DATA\Ari\Current Mice\AM' vr.exper.variables.mouseNumber];
tempPath = 'C:\DATA\Ari\Temporary';
if ~exist(tempPath,'dir');
    mkdir(tempPath);
end
if ~exist(path,'dir')
    mkdir(path);
end
vr.filenameTempMat = 'tempStorage.mat';
vr.filenameTempDat = 'tempStorage.dat';
vr.filenameMat = ['AM',vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'.mat'];
vr.filenameDat = ['AM',vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'.dat'];
fileIndex = 0;
fileList = what(path);
while sum(strcmp(fileList.mat,vr.filenameMat)) > 0
    fileIndex = fileIndex + 1;
    vr.filenameMat = ['AM',vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'_',num2str(fileIndex),'.mat'];
    vr.filenameDat = ['AM',vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'_',num2str(fileIndex),'.dat'];
    fileList = what(path);
end
exper = copyVirmenObject(vr.exper); %#ok<NASGU>
vr.pathTempMat = [tempPath,'\',vr.filenameTempMat];
vr.pathTempDat = [tempPath,'\',vr.filenameTempDat];
vr.pathMat = [path,'\',vr.filenameMat];
vr.pathDat = [path, '\',vr.filenameDat];
save(vr.pathTempMat,'exper');
vr.fid = fopen(vr.pathTempDat,'w+');

% Start the DAQ acquisition
if ~vr.debugMode
    daqreset; %reset DAQ in case it's still in use by a previous Matlab program
    vr.ai = analoginput('nidaq','dev1'); % connect to the DAQ card
    addchannel(vr.ai,0:1); % start channels 0 and 1
    set(vr.ai,'samplerate',1000,'samplespertrigger',1e7); % define buffer
    start(vr.ai); % start acquisition

    vr.ao = analogoutput('nidaq','dev1');
    addchannel(vr.ao,0:3);
    set(vr.ao,'samplerate',10000);
end

vr.inITI = 0;
vr.isReward = 0;
vr.cuePos = randi(2);
if vr.cuePos == 1
    vr.currentWorld = 1;
elseif vr.cuePos == 2
    vr.currentWorld = 2;
else
    error('No World');
end
vr.outITI = false;

vr.text(1).string = '0';
vr.text(1).position = [1 .8];
vr.text(1).size = .03;
vr.text(1).color = [1 0 1];
vr.startTime = now;

vr.text(2).string = '0';
vr.text(2).position = [1 .7];
vr.text(2).size = .03;
vr.text(2).color = [1 1 0];
vr.numTrials = 0;

vr.text(3).string = '0';
vr.text(3).position = [1 .6];
vr.text(3).size = .03;
vr.text(3).color = [0 1 1];
vr.numRewards = 0;
vr.correct = false;
vr.length = str2double(vr.exper.variables.MazeLengthAhead);
vr.longCoord = [vr.exper.items.BackWall(1).x(1) vr.exper.items.BackWall(1).y(1)...
    vr.exper.items.BackWall(1).x(2) vr.exper.items.BackWall(1).y(2)];
vr.shortCoord = vr.longCoord;
vr.shortCoord(2:2:4) = vr.shortCoord(2:2:4) + vr.length/2;
vr.backInd = vr.worlds{1}.objects.indices.BackWall;

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

% putsample(vr.ao,[0,vr.position(4),vr.position(1),vr.position(2)/100]);

if vr.inITI == 0 && abs(vr.position(1)) > eval(vr.exper.variables.armLength)/2 && vr.position(2) > eval(vr.exper.variables.MazeLengthAhead)
    if vr.position(1) < 0 && vr.cuePos == 1
        vr.isReward = 1;
        if ~vr.debugMode
            putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
            start(vr.ao);
            stop(vr.ao);
        end
        vr.itiDur = 2;
        vr.numRewards = vr.numRewards + 1;
        vr.correct = true;
    elseif  vr.position(1) > 0 && vr.cuePos == 2
        vr.isReward = 1;
        if ~vr.debugMode
            putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
            start(vr. ao);
            stop(vr.ao);
        end
        vr.itiDur = 2;
        vr.numRewards = vr.numRewards + 1;
        vr.correct = true;
    else
        vr.isReward = 0;
        vr.itiDur = 4;
        vr.correct = false;
    end
    
    vr.worlds{1}.surface.colors(4,:) = 0;
    vr.worlds{2}.surface.colors(4,:) = 0;
    vr.itiStartTime = tic;
    vr.inITI = 1;
    vr.numTrials = vr.numTrials + 1;
else
    vr.isReward = 0;
end

if vr.inITI == 1
    vr.itiTime = toc(vr.itiStartTime);
    if vr.itiTime > vr.itiDur
        vr.inITI = 0;
        vr.cuePos = randi(2);
        if vr.cuePos == 1
            vr.currentWorld = 1;
            vr.worlds{1}.surface.colors(4,:) = 1;
            if vr.correct
                vr.position = vr.worlds{1}.startLocation;
                vr.position(2) = vr.position(2) + vr.length/2;
                vr.worlds{1}.edges.endpoints(vr.backInd,:) = vr.shortCoord;
            else
                vr.position = vr.worlds{1}.startLocation;
                vr.worlds{1}.edges.endpoints(vr.backInd,:) = vr.longCoord;
            end
        elseif vr.cuePos == 2
            vr.currentWorld = 2;
            vr.worlds{2}.surface.colors(4,:) = 1;
            if vr.correct
                vr.position = vr.worlds{2}.startLocation;
                vr.position(2) = vr.position(2) + vr.length/2;
                vr.worlds{2}.edges.endpoints(vr.backInd,:) = vr.shortCoord;
            else
                vr.position = vr.worlds{2}.startLocation;
                vr.worlds{2}.edges.endpoints(vr.backInd,:) = vr.longCoord;
            end
        else 
            error('No World');
        end
        vr.outITI = true;
    end
end

vr.text(1).string = ['TIME ' datestr(now-vr.startTime,'HH.MM.SS')];
vr.text(2).string = ['TRIALS ', num2str(vr.numTrials)];
vr.text(3).string = ['REWARDS ',num2str(vr.numRewards)];

fwrite(vr.fid,[rem(now,1) vr.position([1:2,4]) vr.velocity(1:2) vr.cuePos vr.isReward vr.inITI],'float');


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
fclose all;
copyfile(vr.pathTempMat,vr.pathMat);
copyfile(vr.pathTempDat,vr.pathDat);
delete(vr.pathTempMat,vr.pathTempDat);
fid = fopen(vr.pathDat);
data = fread(fid,'float');
data = reshape(data,9,numel(data)/9);
assignin('base','data',data);
save(vr.pathMat,'data','-append');
fclose all; 