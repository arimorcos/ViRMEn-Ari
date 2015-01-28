function code = DMS500C300M200D
% DMS500C300M200D   Code for the ViRMEn experiment DMS500C300M200D.
%   code = DMS500C300M200D   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT


% --- INITIALIZATION code: executes before the ViRMEN engine starts.
function vr = initializationCodeFun(vr)

vr.debugMode = true;
vr.midOff = 0.8;
vr.mulRewards = 2;
vr.adapSpeed = 20;

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

%Get initial delay
vr.percGraded = 50;
vr.percEndGraded = (100-vr.percGraded)/100;
vr.trialResults = [];
vr.rewCount = 0;

%Define indices of walls
vr.LeftWallBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.LeftWallBlack,:);
vr.RightWallBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.RightWallBlack,:);
vr.BackWallBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.BackWallBlack,:);
vr.RightArmWallBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.RightArmWallBlack,:);
vr.LeftArmWallBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.LeftArmWallBlack,:);
vr.LeftEndWallBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.LeftEndWallBlack,:);
vr.RightEndWallBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.RightEndWallBlack,:);
vr.TTopWallLeftBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.TTopWallLeftBlack,:);
vr.TTopWallRightBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.TTopWallRightBlack,:);
vr.LeftWallWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.LeftWallWhite,:);
vr.RightWallWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.RightWallWhite,:);
vr.BackWallWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.BackWallWhite,:);
vr.RightArmWallWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.RightArmWallWhite,:);
vr.LeftArmWallWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.LeftArmWallWhite,:);
vr.LeftEndWallWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.LeftEndWallWhite,:);
vr.RightEndWallWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.RightEndWallWhite,:);
vr.TTopWallLeftWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.TTopWallLeftWhite,:);
vr.TTopWallRightWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.TTopWallRightWhite,:);
vr.LeftWallDelay = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.LeftWallDelay,:);
vr.RightWallDelay = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.RightWallDelay,:);
vr.directionTowerEnd = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.directionTowerEnd,:);
vr.TTopMiddle = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.TTopMiddle,:);


%Define groups for mazes 
beginBlack = [vr.LeftWallBlack(1):vr.LeftWallBlack(2) vr.RightWallBlack(1):vr.RightWallBlack(2)];
beginWhite = [vr.LeftWallWhite(1):vr.LeftWallWhite(2) vr.RightWallWhite(1):vr.RightWallWhite(2)];
vr.whiteLeft = [vr.RightArmWallBlack(1):vr.RightArmWallBlack(2) vr.RightEndWallBlack(1):vr.RightEndWallBlack(2)...
    vr.TTopWallRightBlack(1):vr.TTopWallRightBlack(2) vr.LeftArmWallWhite(1):vr.LeftArmWallWhite(2)...
    vr.LeftEndWallWhite(1):vr.LeftEndWallWhite(2) vr.TTopWallLeftWhite(1):vr.TTopWallLeftWhite(2)];
vr.whiteRight = [vr.RightArmWallWhite(1):vr.RightArmWallWhite(2) vr.RightEndWallWhite(1):vr.RightEndWallWhite(2)...
    vr.TTopWallRightWhite(1):vr.TTopWallRightWhite(2) vr.LeftArmWallBlack(1):vr.LeftArmWallBlack(2)...
    vr.LeftEndWallBlack(1):vr.LeftEndWallBlack(2) vr.TTopWallLeftBlack(1):vr.TTopWallLeftBlack(2)];
dirTower = vr.directionTowerEnd(1):vr.directionTowerEnd(2);
delayWalls = [vr.LeftWallDelay(1):vr.LeftWallDelay(2) vr.RightWallDelay(1):vr.RightWallDelay(2)];
backBlack = vr.BackWallBlack(1):vr.BackWallBlack(2);
backWhite = vr.BackWallWhite(1):vr.BackWallWhite(2);
TTopMiddle = vr.TTopMiddle(1):vr.TTopMiddle(2);

vr.blackLeftOn = [beginBlack vr.whiteRight dirTower backBlack TTopMiddle];
vr.blackLeftOff = [beginWhite vr.whiteLeft delayWalls];

vr.blackRightOn = [beginBlack vr.whiteLeft dirTower backBlack TTopMiddle];
vr.blackRightOff = [beginWhite vr.whiteRight delayWalls];

vr.whiteLeftOn = [beginWhite vr.whiteLeft dirTower backWhite TTopMiddle];  
vr.whiteLeftOff = [beginBlack vr.whiteRight delayWalls];

vr.whiteRightOn = [beginWhite vr.whiteRight dirTower backWhite TTopMiddle];
vr.whiteRightOff = [beginBlack vr.whiteLeft delayWalls];

vr.inITI = 0;
vr.isReward = 0;
% vr.cuePos = randi(4);
vr.cuePos = 1;
vr.worlds{1}.surface.visible(:) = 0;
switch vr.cuePos
    case 1
        vr.worlds{1}.surface.visible(vr.blackLeftOn) = 1;
        vr.worlds{1}.surface.visible(vr.LeftWallBlack(1) + ceil(vr.percEndGraded*(vr.LeftWallBlack(2)-vr.LeftWallBlack(1))):vr.LeftWallBlack(2)) = 0;
        vr.worlds{1}.surface.visible(vr.RightWallBlack(1) + ceil(vr.percEndGraded*(vr.RightWallBlack(2)-vr.RightWallBlack(1))):vr.RightWallBlack(2)) = 0;
        vr.worlds{1}.surface.visible(vr.LeftWallDelay(1) + ceil(vr.percEndGraded*(vr.LeftWallDelay(2)-vr.LeftWallDelay(1))):vr.LeftWallDelay(end)) = 1;
        vr.worlds{1}.surface.visible(vr.RightWallDelay(1) + ceil(vr.percEndGraded*(vr.RightWallDelay(2)-vr.RightWallDelay(1))):vr.RightWallDelay(end)) = 1;
    case 2
        vr.worlds{1}.surface.visible(vr.blackRightOn) = 1;
        vr.worlds{1}.surface.visible(vr.LeftWallBlack(1) + ceil(vr.percEndGraded*(vr.LeftWallBlack(2)-vr.LeftWallBlack(1))):vr.LeftWallBlack(2)) = 0;
        vr.worlds{1}.surface.visible(vr.RightWallBlack(1) + ceil(vr.percEndGraded*(vr.RightWallBlack(2)-vr.RightWallBlack(1))):vr.RightWallBlack(2)) = 0;
        vr.worlds{1}.surface.visible(vr.LeftWallDelay(1) + ceil(vr.percEndGraded*(vr.LeftWallDelay(2)-vr.LeftWallDelay(1))):vr.LeftWallDelay(end)) = 1;
        vr.worlds{1}.surface.visible(vr.RightWallDelay(1) + ceil(vr.percEndGraded*(vr.RightWallDelay(2)-vr.RightWallDelay(1))):vr.RightWallDelay(end)) = 1;
    case 3
        vr.worlds{1}.surface.visible(vr.whiteLeftOn) = 1;
        vr.worlds{1}.surface.visible(vr.LeftWallWhite(1) + ceil(vr.percEndGraded*(vr.LeftWallWhite(2)-vr.LeftWallWhite(1))):vr.LeftWallWhite(2)) = 0;
        vr.worlds{1}.surface.visible(vr.RightWallWhite(1) + ceil(vr.percEndGraded*(vr.RightWallWhite(2)-vr.RightWallWhite(1))):vr.RightWallWhite(2)) = 0;
        vr.worlds{1}.surface.visible(vr.LeftWallDelay(1) + ceil(vr.percEndGraded*(vr.LeftWallDelay(2)-vr.LeftWallDelay(1))):vr.LeftWallDelay(end)) = 1;
        vr.worlds{1}.surface.visible(vr.RightWallDelay(1) + ceil(vr.percEndGraded*(vr.RightWallDelay(2)-vr.RightWallDelay(1))):vr.RightWallDelay(end)) = 1;
    case 4
        vr.worlds{1}.surface.visible(vr.whiteRightOn) = 1;
        vr.worlds{1}.surface.visible(vr.LeftWallWhite(1) + ceil(vr.percEndGraded*(vr.LeftWallWhite(2)-vr.LeftWallWhite(1))):vr.LeftWallWhite(2)) = 0;
        vr.worlds{1}.surface.visible(vr.RightWallWhite(1) + ceil(vr.percEndGraded*(vr.RightWallWhite(2)-vr.RightWallWhite(1))):vr.RightWallWhite(2)) = 0;
        vr.worlds{1}.surface.visible(vr.LeftWallDelay(1) + ceil(vr.percEndGraded*(vr.LeftWallDelay(2)-vr.LeftWallDelay(1))):vr.LeftWallDelay(end)) = 1;
        vr.worlds{1}.surface.visible(vr.RightWallDelay(1) + ceil(vr.percEndGraded*(vr.RightWallDelay(2)-vr.RightWallDelay(1))):vr.RightWallDelay(end)) = 1;
    otherwise
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

vr.text(4).string = '0';
vr.text(4).position = [1 .5];
vr.text(4).size = .03;
vr.text(4).color = [0 .5 .5];

vr.numLeftTurns = 0;
vr.numBlackTurns = 0;

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

% putsample(vr.ao,[0,vr.position(4),vr.position(1),vr.position(2)/100]);

if vr.inITI == 0 && abs(vr.position(1)) > eval(vr.exper.variables.armLength)/2 && vr.position(2) > eval(vr.exper.variables.MazeLengthAhead)
    if vr.position(1) < 0 && (vr.cuePos == 1 || vr.cuePos == 3)
        if ~vr.debugMode
            putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
            start(vr.ao);
            stop(vr.ao);
        end
        vr.isReward = 1;
        if vr.rewCount == 1 && vr.mulRewards > 0
            if ~vr.debugMode
                pause(.04);
                putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
                start(vr.ao);
                stop(vr.ao);
            end
            vr.isReward = 2;
        end
        if vr.rewCount >= 2 && vr.mulRewards == 2
           if ~vr.debugMode     
                pause(.04);
                putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
                start(vr.ao);
                stop(vr.ao);
           end
            vr.isReward = 3;
        end
        if vr.mulRewards == 1 && vr.rewCount == 1
            vr.rewCount = 1;
        else
            vr.rewCount = vr.rewCount + 1;
        end
        vr.itiDur = 2;
        vr.numRewards = vr.numRewards + 1;
        vr.trialResults(1,size(vr.trialResults)+1) = 1;
    elseif  vr.position(1) > 0 && (vr.cuePos == 2 || vr.cuePos == 4)
        if ~vr.debugMode
            putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
            start(vr.ao);
            stop(vr.ao);
        end
        vr.isReward = 1;
        if vr.rewCount == 1 && vr.mulRewards > 0
            if ~vr.debugMode
                pause(.04);
                putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
                start(vr.ao);
                stop(vr.ao);
            end
            vr.isReward = 2;
        end
        if vr.rewCount >= 2 && vr.mulRewards == 2
           if ~vr.debugMode     
                pause(.04);
                putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
                start(vr.ao);
                stop(vr.ao);
           end
            vr.isReward = 3;
        end
        if vr.mulRewards == 1 && vr.rewCount == 1
            vr.rewCount = 1;
        else
            vr.rewCount = vr.rewCount + 1;
        end
        vr.itiDur = 2;
        vr.numRewards = vr.numRewards + 1;
        vr.trialResults(1,size(vr.trialResults)+1) = 1;
    else
        vr.isReward = 0;
        vr.itiDur = 4;
        vr.rewCount = 0;
        vr.trialResults(1,size(vr.trialResults)+1) = 0;
    end
    
    vr.worlds{1}.surface.visible(:) = 0;
    vr.itiStartTime = tic;
    vr.inITI = 1;
    vr.numTrials = vr.numTrials + 1;
    
    if ((vr.cuePos == 1 || vr.cuePos == 3) && vr.isReward ~= 0) || ((vr.cuePos == 2 || vr.cuePos == 4) && vr.isReward == 0)
        vr.trialResults(2,end) = 1;
    else
        vr.trialResults(2,end) = 0;
    end
    if ((vr.cuePos == 1 || vr.cuePos == 2) && vr.isReward ~= 0) || ((vr.cuePos == 3 || vr.cuePos == 4) && vr.isReward == 0)
        vr.trialResults(3,end) = 1;
    else
        vr.trialResults(3,end) = 0;
    end
else
    vr.isReward = 0;
end

%Turn on/off gray block
if (vr.position(2) < vr.midOff*str2double(vr.exper.variables.MazeLengthAhead)) && ~vr.inITI
    vr.worlds{1}.surface.visible([vr.whiteLeft vr.whiteRight]) = 0;
    vr.worlds{1}.surface.visible(vr.TTopMiddle(1):vr.TTopMiddle(2)) = 1;
elseif (vr.position(2) >= vr.midOff*str2double(vr.exper.variables.MazeLengthAhead)) && ~vr.inITI
    if vr.cuePos == 1 || vr.cuePos == 4
        vr.worlds{1}.surface.visible(vr.whiteRight) = 1;
        vr.worlds{1}.surface.visible(vr.TTopMiddle(1):vr.TTopMiddle(2)) = 0;
    elseif vr.cuePos == 2 || vr.cuePos == 3
        vr.worlds{1}.surface.visible(vr.whiteLeft) = 1;
        vr.worlds{1}.surface.visible(vr.TTopMiddle(1):vr.TTopMiddle(2)) = 0;
    end
end

if vr.inITI == 1
    vr.itiTime = toc(vr.itiStartTime);
    if vr.itiTime > vr.itiDur
        vr.inITI = 0;
        
        if size(vr.trialResults,2) >= vr.adapSpeed
            vr.percBlack = sum(vr.trialResults(3,(end-vr.adapSpeed+1):end))/vr.adapSpeed;
            vr.percLeft = sum(vr.trialResults(2,(end-vr.adapSpeed+1):end))/vr.adapSpeed;
        else
            vr.percBlack = sum(vr.trialResults(3,1:end))/size(vr.trialResults,2);
            vr.percLeft = sum(vr.trialResults(2,1:end))/size(vr.trialResults,2);
        end
        randLeft = rand;
        randColor = rand;
        if randLeft >= vr.percLeft
            if randColor >= vr.percBlack
                vr.cuePos = 1;
            else
                vr.cuePos = 3;
            end
        else
            if randColor >= vr.percBlack
                vr.cuePos = 2;
            else
                vr.cuePos = 4;
            end
        end
        
        switch vr.cuePos
            case 1
                vr.worlds{1}.surface.visible(vr.blackLeftOn) = 1;
                vr.worlds{1}.surface.visible(vr.LeftWallBlack(1) + ceil(vr.percEndGraded*(vr.LeftWallBlack(2)-vr.LeftWallBlack(1))):vr.LeftWallBlack(2)) = 0;
                vr.worlds{1}.surface.visible(vr.RightWallBlack(1) + ceil(vr.percEndGraded*(vr.RightWallBlack(2)-vr.RightWallBlack(1))):vr.RightWallBlack(2)) = 0;
                vr.worlds{1}.surface.visible(vr.LeftWallDelay(1) + ceil(vr.percEndGraded*(vr.LeftWallDelay(2)-vr.LeftWallDelay(1))):vr.LeftWallDelay(2)) = 1;
                vr.worlds{1}.surface.visible(vr.RightWallDelay(1) + ceil(vr.percEndGraded*(vr.RightWallDelay(2)-vr.RightWallDelay(1))):vr.RightWallDelay(2)) = 1;
            case 2
                vr.worlds{1}.surface.visible(vr.blackRightOn) = 1;
                vr.worlds{1}.surface.visible(vr.LeftWallBlack(1) + ceil(vr.percEndGraded*(vr.LeftWallBlack(2)-vr.LeftWallBlack(1))):vr.LeftWallBlack(2)) = 0;
                vr.worlds{1}.surface.visible(vr.RightWallBlack(1) + ceil(vr.percEndGraded*(vr.RightWallBlack(2)-vr.RightWallBlack(1))):vr.RightWallBlack(2)) = 0;
                vr.worlds{1}.surface.visible(vr.LeftWallDelay(1) + ceil(vr.percEndGraded*(vr.LeftWallDelay(2)-vr.LeftWallDelay(1))):vr.LeftWallDelay(2)) = 1;
                vr.worlds{1}.surface.visible(vr.RightWallDelay(1) + ceil(vr.percEndGraded*(vr.RightWallDelay(2)-vr.RightWallDelay(1))):vr.RightWallDelay(2)) = 1;
            case 3
                vr.worlds{1}.surface.visible(vr.whiteLeftOn) = 1;
                vr.worlds{1}.surface.visible(vr.LeftWallWhite(1) + ceil(vr.percEndGraded*(vr.LeftWallWhite(2)-vr.LeftWallWhite(1))):vr.LeftWallWhite(2)) = 0;
                vr.worlds{1}.surface.visible(vr.RightWallWhite(1) + ceil(vr.percEndGraded*(vr.RightWallWhite(2)-vr.RightWallWhite(1))):vr.RightWallWhite(2)) = 0;
                vr.worlds{1}.surface.visible(vr.LeftWallDelay(1) + ceil(vr.percEndGraded*(vr.LeftWallDelay(2)-vr.LeftWallDelay(1))):vr.LeftWallDelay(2)) = 1;
                vr.worlds{1}.surface.visible(vr.RightWallDelay(1) + ceil(vr.percEndGraded*(vr.RightWallDelay(2)-vr.RightWallDelay(1))):vr.RightWallDelay(2)) = 1;
            case 4
                vr.worlds{1}.surface.visible(vr.whiteRightOn) = 1;
                vr.worlds{1}.surface.visible(vr.LeftWallWhite(1) + ceil(vr.percEndGraded*(vr.LeftWallWhite(2)-vr.LeftWallWhite(1))):vr.LeftWallWhite(2)) = 0;
                vr.worlds{1}.surface.visible(vr.RightWallWhite(1) + ceil(vr.percEndGraded*(vr.RightWallWhite(2)-vr.RightWallWhite(1))):vr.RightWallWhite(2)) = 0;
                vr.worlds{1}.surface.visible(vr.LeftWallDelay(1) + ceil(vr.percEndGraded*(vr.LeftWallDelay(2)-vr.LeftWallDelay(1))):vr.LeftWallDelay(2)) = 1;
                vr.worlds{1}.surface.visible(vr.RightWallDelay(1) + ceil(vr.percEndGraded*(vr.RightWallDelay(2)-vr.RightWallDelay(1))):vr.RightWallDelay(2)) = 1;
            otherwise
                error('No World');
        end
        vr.position = vr.worlds{1}.startLocation;
        vr.outITI = true;
    end
end

vr.percCorrect = 100*vr.numRewards/vr.numTrials;
if isnan(vr.percCorrect)
    vr.percCorrect = 0;
end

vr.text(1).string = ['TIME ' datestr(now-vr.startTime,'HH.MM.SS')];
vr.text(2).string = ['TRIALS ', num2str(vr.numTrials)];
vr.text(3).string = ['REWARDS ',num2str(vr.numRewards)];
vr.text(4).string = ['PERCCORR ',num2str(round(vr.percCorrect))];

fwrite(vr.fid,[rem(now,1) vr.position([1:2,4]) vr.velocity(1:2) vr.cuePos vr.isReward vr.inITI vr.percGraded],'float');


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
fclose all;
copyfile(vr.pathTempMat,vr.pathMat);
copyfile(vr.pathTempDat,vr.pathDat);
delete(vr.pathTempMat,vr.pathTempDat);
fid = fopen(vr.pathDat);
data = fread(fid,'float');
data = reshape(data,10,numel(data)/10);
assignin('base','data',data);
save(vr.pathMat,'data','-append');
save(vr.pathMat,'vr','-append');
fclose all; 
