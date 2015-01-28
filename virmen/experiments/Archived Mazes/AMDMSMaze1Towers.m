function code = AMDMSMaze1Towers
% AMDMSMaze1Towers   Code for the ViRMEn experiment AMDMSMaze1Towers.
%   codgbce = AMDMSMaze1Towers   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT



% --- INITIALIZATION code: executes before the ViRMEN engine starts.
function vr = initializationCodeFun(vr)

path = ['C:\DATA\Ari\Current Mice\AM' vr.exper.variables.mouseNumber];
if ~exist(path,'dir')
    mkdir(path);
end
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
vr.pathMat = [path,'\',vr.filenameMat];
vr.pathDat = [path, '\',vr.filenameDat];
save(vr.pathMat,'exper');
vr.fid = fopen(vr.pathDat,'w');

% % Start the DAQ acquisition
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
vr.cuePos = randi(4);
vr.currentWorld = vr.cuePos;
vr.outITI = false;
vr.transIndRew = 0;
vr.transUp = .1;
vr.transDown = .025;
vr.numRewTotVis = 40;
vr.transTower = 0;

%define distractTowers 
vr.distractTower(1,:) = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.endTowerLeftNonCue,:);
vr.distractTower(2,:) = vr.worlds{2}.objects.vertices(vr.worlds{2}.objects.indices.endTowerRightNonCue,:);
vr.distractTower(3,:) = vr.worlds{3}.objects.vertices(vr.worlds{3}.objects.indices.endTowerRightNonCue,:);
vr.distractTower(4,:) = vr.worlds{4}.objects.vertices(vr.worlds{4}.objects.indices.endTowerLeftNonCue,:);

%define correctTowers
vr.endCueTower(1,:) = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.endTowerRightCue,:);
vr.endCueTower(2,:) = vr.worlds{2}.objects.vertices(vr.worlds{2}.objects.indices.endTowerLeftCue,:);
vr.endCueTower(3,:) = vr.worlds{3}.objects.vertices(vr.worlds{3}.objects.indices.endTowerLeftCue,:);
vr.endCueTower(4,:) = vr.worlds{4}.objects.vertices(vr.worlds{4}.objects.indices.endTowerRightCue,:);

%define cueTowers
vr.rightCueTower(1,:) = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.rightCueTower,:);
vr.rightCueTower(2,:) = vr.worlds{2}.objects.vertices(vr.worlds{2}.objects.indices.rightCueTower,:);
vr.rightCueTower(3,:) = vr.worlds{3}.objects.vertices(vr.worlds{3}.objects.indices.rightCueTower,:);
vr.rightCueTower(4,:) = vr.worlds{4}.objects.vertices(vr.worlds{4}.objects.indices.rightCueTower,:);
vr.leftCueTower(1,:) = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.leftCueTower,:);
vr.leftCueTower(2,:) = vr.worlds{2}.objects.vertices(vr.worlds{2}.objects.indices.leftCueTower,:);
vr.leftCueTower(3,:) = vr.worlds{3}.objects.vertices(vr.worlds{3}.objects.indices.leftCueTower,:);
vr.leftCueTower(4,:) = vr.worlds{4}.objects.vertices(vr.worlds{4}.objects.indices.leftCueTower,:);

%set transparency of distractTowers to 0 
vr.worlds{1}.surface.colors(4,vr.distractTower(1,1):vr.distractTower(1,2)) = vr.transTower;
vr.worlds{2}.surface.colors(4,vr.distractTower(2,1):vr.distractTower(2,2)) = vr.transTower;
vr.worlds{3}.surface.colors(4,vr.distractTower(3,1):vr.distractTower(3,2)) = vr.transTower;
vr.worlds{4}.surface.colors(4,vr.distractTower(4,1):vr.distractTower(4,2)) = vr.transTower;
                                              
% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

% putsample(vr.ao,[0,vr.position(4),vr.position(1),vr.position(2)/100]);

if vr.inITI == 0 && vr.position(2) <= eval(vr.exper.variables.MazeLengthAhead)/2 %if before cue tower
    %turn off end towers
    vr.worlds{1}.surface.colors(4,vr.distractTower(1,1):vr.distractTower(1,2)) = 0;
    vr.worlds{2}.surface.colors(4,vr.distractTower(2,1):vr.distractTower(2,2)) = 0;
    vr.worlds{3}.surface.colors(4,vr.distractTower(3,1):vr.distractTower(3,2)) = 0;
    vr.worlds{4}.surface.colors(4,vr.distractTower(4,1):vr.distractTower(4,2)) = 0;
    vr.worlds{1}.surface.colors(4,vr.endCueTower(1,1):vr.endCueTower(1,2)) = 0;
    vr.worlds{2}.surface.colors(4,vr.endCueTower(2,1):vr.endCueTower(2,2)) = 0;
    vr.worlds{3}.surface.colors(4,vr.endCueTower(3,1):vr.endCueTower(3,2)) = 0;
    vr.worlds{4}.surface.colors(4,vr.endCueTower(4,1):vr.endCueTower(4,2)) = 0;
    
    %turn on cue towers
    vr.worlds{1}.surface.colors(4,vr.leftCueTower(1,1):vr.leftCueTower(1,2)) = 1;
    vr.worlds{2}.surface.colors(4,vr.leftCueTower(2,1):vr.leftCueTower(2,2)) = 1;
    vr.worlds{3}.surface.colors(4,vr.leftCueTower(3,1):vr.leftCueTower(3,2)) = 1;
    vr.worlds{4}.surface.colors(4,vr.leftCueTower(4,1):vr.leftCueTower(4,2)) = 1;
    vr.worlds{1}.surface.colors(4,vr.rightCueTower(1,1):vr.rightCueTower(1,2)) = 1;
    vr.worlds{2}.surface.colors(4,vr.rightCueTower(2,1):vr.rightCueTower(2,2)) = 1;
    vr.worlds{3}.surface.colors(4,vr.rightCueTower(3,1):vr.rightCueTower(3,2)) = 1;
    vr.worlds{4}.surface.colors(4,vr.rightCueTower(4,1):vr.rightCueTower(4,2)) = 1;

elseif vr.inITI == 0 && vr.position(2) > eval(vr.exper.variables.MazeLengthAhead)/2 %if after cue tower
    %turn on towers to proper transparencies
    vr.worlds{1}.surface.colors(4,vr.distractTower(1,1):vr.distractTower(1,2)) = vr.transTower;
    vr.worlds{2}.surface.colors(4,vr.distractTower(2,1):vr.distractTower(2,2)) = vr.transTower;
    vr.worlds{3}.surface.colors(4,vr.distractTower(3,1):vr.distractTower(3,2)) = vr.transTower;
    vr.worlds{4}.surface.colors(4,vr.distractTower(4,1):vr.distractTower(4,2)) = vr.transTower;
    vr.worlds{1}.surface.colors(4,vr.endCueTower(1,1):vr.endCueTower(1,2)) = 1;
    vr.worlds{2}.surface.colors(4,vr.endCueTower(2,1):vr.endCueTower(2,2)) = 1;
    vr.worlds{3}.surface.colors(4,vr.endCueTower(3,1):vr.endCueTower(3,2)) = 1;
    vr.worlds{4}.surface.colors(4,vr.endCueTower(4,1):vr.endCueTower(4,2)) = 1;
    
    %turn off cue towers
    vr.worlds{1}.surface.colors(4,vr.leftCueTower(1,1):vr.leftCueTower(1,2)) = 0;
    vr.worlds{2}.surface.colors(4,vr.leftCueTower(2,1):vr.leftCueTower(2,2)) = 0;
    vr.worlds{3}.surface.colors(4,vr.leftCueTower(3,1):vr.leftCueTower(3,2)) = 0;
    vr.worlds{4}.surface.colors(4,vr.leftCueTower(4,1):vr.leftCueTower(4,2)) = 0;
    vr.worlds{1}.surface.colors(4,vr.rightCueTower(1,1):vr.rightCueTower(1,2)) = 0;
    vr.worlds{2}.surface.colors(4,vr.rightCueTower(2,1):vr.rightCueTower(2,2)) = 0;
    vr.worlds{3}.surface.colors(4,vr.rightCueTower(3,1):vr.rightCueTower(3,2)) = 0;
    vr.worlds{4}.surface.colors(4,vr.rightCueTower(4,1):vr.rightCueTower(4,2)) = 0;

end

if vr.inITI == 0 && abs(vr.position(1)) > eval(vr.exper.variables.armLength)/2 && vr.position(2) > eval(vr.exper.variables.MazeLengthAhead)
    if vr.position(1) < 0 && (vr.cuePos == 2 || vr.cuePos == 3)
        vr.isReward = 1;
        putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
        start(vr.ao);
        stop(vr.ao);
        vr.itiDur = 2;
        vr.transIndRew = vr.transIndRew + vr.transUp*vr.numRewTotVis;
    elseif  vr.position(1) > 0 && (vr.cuePos == 1 || vr.cuePos == 4)
        vr.isReward = 1;
        putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
        start(vr.ao);
        stop(vr.ao);
        vr.itiDur = 2;
        vr.transIndRew = vr.transIndRew + vr.transUp*vr.numRewTotVis;
    else
        vr.isReward = 0;
        vr.itiDur = 4;
        vr.transIndRew = vr.transIndRew - vr.transDown*vr.numRewTotVis;
    end
    
    vr.worlds{1}.surface.colors(4,:) = 0;
    vr.worlds{2}.surface.colors(4,:) = 0;
    vr.worlds{3}.surface.colors(4,:) = 0;
    vr.worlds{4}.surface.colors(4,:) = 0;
    vr.itiStartTime = tic;
    vr.inITI = 1;
else
    vr.isReward = 0;
end

%In case out of bounds, reset to start position
if (abs(vr.position(1)) > eval(vr.exper.variables.mazeWidth)/2 && vr.position(2) < eval(vr.exper.variables.MazeLengthAhead))
    vr.itiDur = .5;
    vr.worlds{1}.surface.colors(4,:) = 0;
    vr.worlds{2}.surface.colors(4,:) = 0;
    vr.worlds{3}.surface.colors(4,:) = 0;
    vr.worlds{4}.surface.colors(4,:) = 0;
    vr.itiStartTime = tic;
    vr.inITI = 1; 
end    

if vr.inITI == 1
    vr.itiTime = toc(vr.itiStartTime);
    if vr.itiTime > vr.itiDur
        vr.inITI = 0;
        vr.cuePos = randi(4);
        vr.transTower = vr.transIndRew/vr.numRewTotVis;
        if vr.transTower > 1
            vr.transTower = 1;
        end
        switch vr.cuePos
            case 1
                vr.currentWorld = 1;
                vr.worlds{1}.surface.colors(4,:) = 1;
                vr.worlds{1}.surface.colors(4,vr.distractTower(1,1):vr.distractTower(1,2)) = vr.transTower;
                vr.position = vr.worlds{1}.startLocation;
            case 2
                vr.currentWorld = 2;
                vr.worlds{2}.surface.colors(4,:) = 1;
                vr.worlds{2}.surface.colors(4,vr.distractTower(2,1):vr.distractTower(2,2)) = vr.transTower;
                vr.position = vr.worlds{2}.startLocation;
            case 3
                vr.currentWorld = 3;
                vr.worlds{3}.surface.colors(4,:) = 1;
                vr.worlds{3}.surface.colors(4,vr.distractTower(3,1):vr.distractTower(3,2)) = vr.transTower;
                vr.position = vr.worlds{3}.startLocation;
            case 4
                vr.currentWorld = 4;
                vr.worlds{4}.surface.colors(4,:) = 1;
                vr.worlds{4}.surface.colors(4,vr.distractTower(4,1):vr.distractTower(4,2)) = vr.transTower;
                vr.position = vr.worlds{4}.startLocation;
        end
        vr.outITI = true;
    end
end

fwrite(vr.fid,[rem(now,1) vr.position([1:2,4]) vr.velocity(1:2) vr.cuePos vr.isReward vr.inITI vr.transIndRew],'float');


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
%save aritemp.mat vr;
fclose all;
fid = fopen(vr.pathDat);
data = fread(fid,'float');
data = reshape(data,10,numel(data)/10);
assignin('base','data',data);
save(vr.pathMat,'data','-append');
fclose all; 
