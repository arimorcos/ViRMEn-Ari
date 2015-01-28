function code = AMDMSMaze4WallsAdaptiveNoTower2Cond
% AMDMSMaze4WallsAdaptiveNoTower2Cond   Code for the ViRMEn experiment AMDMSMaze4WallsAdaptiveNoTower2Cond.
%   code = AMDMSMaze4WallsAdaptiveNoTower2Cond   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT

% --- INITIALIZATION code: executes before the ViRMEN engine starts.
function vr = initializationCodeFun(vr)

vr.debugMode = false;
vr.shouldUDP = true;
vr.mulRewards = 0;

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
vr.numBlackTurn = 0;
vr.numLeftTurn = 0;
vr.rewCount = 0;

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

%initialize udp
if vr.shouldUDP
    vr.udp = udp('10.11.148.178',135,'LocalPort',49152);
    fopen(vr.udp);
end

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

% putsample(vr.ao,[0,vr.position(4),vr.position(1),vr.position(2)/100]);

if vr.inITI == 0 && abs(vr.position(1)) > eval(vr.exper.variables.armLength)/2 && vr.position(2) > eval(vr.exper.variables.MazeLengthAhead)
    if vr.position(1) < 0 && vr.cuePos == 1
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
        vr.numRewards = vr.numRewards + 1;
        vr.itiDur = 2;
    elseif  vr.position(1) > 0 && vr.cuePos == 2
        if ~vr.debugMode
            putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
            start(vr. ao);
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
        vr.numRewards = vr.numRewards + 1;
        vr.itiDur = 2;
    else
        vr.isReward = 0;
        vr.itiDur = 4;
        vr.rewCount = 0;
    end
    
    if vr.isReward ~= 0 && vr.cuePos == 1
        vr.numBlackTurn = vr.numBlackTurn + 1;
    elseif vr.isReward == 0 && vr.cuePos == 2
        vr.numBlackTurn = vr.numBlackTurn + 1;
    end
    
    if vr.isReward ~= 0 && vr.cuePos == 1
        vr.numLeftTurn = vr.numLeftTurn + 1;
    elseif vr.isReward == 0 && vr.cuePos == 2
        vr.numLeftTurn = vr.numLeftTurn + 1;
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
        vr.percBlackTurn = vr.numBlackTurn/vr.numTrials;
        vr.percLeftTurn = vr.numLeftTurn/vr.numTrials;
        vr.randCueBlack = rand;
        vr.randCueLeft = rand;
        if abs(.5 - vr.percLeftTurn) >= abs(.5 - vr.percBlackTurn)
            if vr.randCueLeft >= vr.percLeftTurn
                vr.cuePos = 1;
            elseif vr.randCueLeft < vr.percLeftTurn
                vr.cuePos = 2;
            end
        elseif abs(.5 - vr.percLeftTurn)< abs(.5 - vr.percBlackTurn)
            if vr.randCueBlack >= vr.percBlackTurn
                vr.cuePos = 1;
            elseif vr.randCueBlack < vr.percBlackTurn
                vr.cuePos = 2;
            end
        end
        if vr.cuePos == 1
            vr.currentWorld = 1;
            vr.worlds{1}.surface.colors(4,:) = 1;
            vr.position = vr.worlds{1}.startLocation;
        elseif vr.cuePos == 2
            vr.currentWorld = 2;
            vr.worlds{2}.surface.colors(4,:) = 1;
            vr.position = vr.worlds{2}.startLocation;
        else 
            error('No World');
        end
        vr.outITI = true;
    end
          
end

vr.text(1).string = ['TIME ' datestr(now-vr.startTime,'HH.MM.SS')];
vr.text(2).string = ['TRIALS ', num2str(vr.numTrials)];
vr.text(3).string = ['REWARDS ',num2str(vr.numRewards)];

%update udp
if vr.shouldUDP
    flushoutput(vr.udp);
    fwrite(vr.udp,[double(datestr(now - vr.startTime,'HH:MM:SS')) vr.numTrials vr.numRewards 100*vr.numRewards/vr.numTrials]);
end

fwrite(vr.fid,[rem(now,1) vr.position([1:2,4]) vr.velocity(1:2) vr.cuePos vr.isReward vr.inITI],'float');


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
%save aritemp.mat vr;
fclose all;
fid = fopen(vr.pathDat);
data = fread(fid,'float');
data = reshape(data,9,numel(data)/9);
assignin('base','data',data);
save(vr.pathMat,'data','-append');
fclose all; 
if vr.shouldUDP
    delete(vr.udp);
end