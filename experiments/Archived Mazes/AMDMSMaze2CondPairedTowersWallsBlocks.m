function code = AMDMSMaze2CondPairedTowersWallsBlocks
% AMDMSMaze2CondPairedTowersWallsBlocks   Code for the ViRMEn experiment AMDMSMaze2CondPairedTowersWallsBlocks.
%   code = AMDMSMaze2CondPairedTowersWallsBlocks   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT

% --- INITIALIZATION code: executes before the ViRMEN engine starts.
function vr = initializationCodeFun(vr)

vr.debugMode = true;
vr.shouldUDP = true;
vr.mulRewards = 1;
vr.blockSize = 5;

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
vr.cuePos = randi(4);
switch vr.cuePos
    case 1
        vr.currentWorld = 1;
    case 2 
        vr.currentWorld = 3;
    case 3
        vr.currentWorld = 5;
    case 4
        vr.currentWorld = 7;
    otherwise
        display('No World');
        return;
end
vr.outITI = false;
vr.numBlackTurn = 0;
vr.numLeftTurn = 0;
vr.whichWorldFlag = 0;
vr.numTrials = 0;
vr.numTrialsBlock = 0;
vr.block = true;

vr.text(1).string = '0';
vr.text(1).position = [1 .8];
vr.text(1).size = .03;
vr.text(1).color = [1 0 1];
vr.startTime = now;

vr.text(2).string = '0';
vr.text(2).position = [1 .7];
vr.text(2).size = .03;
vr.text(2).color = [1 1 0];
vr.numTrialsTower = 0;

vr.text(3).string = '0';
vr.text(3).position = [1 .5];
vr.text(3).size = .03;
vr.text(3).color = [0 1 1];
vr.numTrialsNoTower = 0;

vr.text(4).string = '0';
vr.text(4).position = [1 .6];
vr.text(4).size = .03;
vr.text(4).color = [.5 .5 1];
vr.numRewardsTower = 0;

vr.text(5).string = '0';
vr.text(5).position = [1 .4];
vr.text(5).size = .03;
vr.text(5).color = [1 .5 .5];
vr.numRewardsNoTower = 0;

vr.text(6).string = '0';
vr.text(6).position = [1 .3];
vr.text(6).size = .03;
vr.text(6).color = [1 .5 .5];
vr.numRewardsNoTower = 0;

%initialize udp
if vr.shouldUDP
    vr.udp = udp('10.11.148.178',135,'LocalPort',49152);
    fopen(vr.udp);
end

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

% putsample(vr.ao,[0,vr.position(4),vr.position(1),vr.position(2)/100]);

if vr.inITI == 0 && abs(vr.position(1)) > eval(vr.exper.variables.armLength)/2 && vr.position(2) > eval(vr.exper.variables.MazeLengthAhead)
    if vr.position(1) < 0 && (vr.currentWorld == 1 || vr.currentWorld == 2 || vr.currentWorld == 5 || vr.currentWorld == 6)
        if ~vr.debugMode
            putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
            start(vr.ao);
            stop(vr.ao);
        end
        if vr.currentWorld == 1 || vr.currentWorld == 5
            vr.isReward = 1;
            vr.whichWorldFlag = vr.currentWorld + 1;
            vr.numRewardsTower = vr.numRewardsTower + 1;
        elseif vr.currentWorld == 2 || vr.currentWorld == 6
            if ~vr.debugMode && vr.mulRewards > 0
                pause(.04);
                putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
                start(vr.ao);
                stop(vr.ao);
                if ~vr.debugMode && vr.mulRewards == 2
                    pause(.04);
                    putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
                    start(vr.ao);
                    stop(vr.ao);
                    vr.isReward = 3;
                else
                    vr.isReward = 2;
                end
            end
            vr.whichWorldFlag = 0;
            vr.numRewardsNoTower = vr.numRewardsNoTower + 1;
        end
        vr.itiDur = 2;
    elseif  vr.position(1) > 0 && (vr.currentWorld == 3 || vr.currentWorld == 4 || vr.currentWorld == 7 || vr.currentWorld == 8)
        if ~vr.debugMode    
            putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
            start(vr. ao);
            stop(vr.ao);
        end
        if vr.currentWorld == 3 || vr.currentWorld == 7
            vr.isReward = 1;
            vr.whichWorldFlag = vr.currentWorld + 1;
            vr.numRewardsTower = vr.numRewardsTower + 1;
        elseif vr.currentWorld == 4 || vr.currentWorld == 8
            if ~vr.debugMode
                pause(.04);
                putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
                start(vr.ao);
                stop(vr.ao);
                if ~vr.debugMode && vr.mulRewards == 2
                    pause(.04);
                    putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
                    start(vr.ao);
                    stop(vr.ao);
                    vr.isReward = 3;
                else
                    vr.isReward = 2;
                end
            end
            vr.numRewardsNoTower = vr.numRewardsNoTower + 1;
            vr.whichWorldFlag = 0;
        end
        vr.itiDur = 2;
    else
        vr.isReward = 0;
        vr.itiDur = 4;
        vr.whichWorldFlag = 0;
    end
    
    if vr.isReward ~= 0 && (vr.currentWorld == 1 || vr.currentWorld == 2 || vr.currentWorld == 3 || vr.currentWorld == 4)
        vr.numBlackTurn = vr.numBlackTurn + 1;
    elseif vr.isReward == 0 && (vr.currentWorld == 5 || vr.currentWorld == 6 || vr.currentWorld == 7 || vr.currentWorld == 8)
        vr.numBlackTurn = vr.numBlackTurn + 1;
    end
    
    if vr.isReward ~= 0 && (vr.currentWorld == 1 || vr.currentWorld == 2 || vr.currentWorld == 5 || vr.currentWorld == 6)
        vr.numLeftTurn = vr.numLeftTurn + 1;
    elseif vr.isReward == 0 && (vr.currentWorld == 3 || vr.currentWorld == 4 || vr.currentWorld == 7 || vr.currentWorld == 8)
        vr.numLeftTurn = vr.numLeftTurn + 1;
    end
    
    vr.worlds{1}.surface.colors(4,:) = 0;
    vr.worlds{2}.surface.colors(4,:) = 0;
    vr.worlds{3}.surface.colors(4,:) = 0;
    vr.worlds{4}.surface.colors(4,:) = 0;
    vr.worlds{5}.surface.colors(4,:) = 0;
    vr.worlds{6}.surface.colors(4,:) = 0;
    vr.worlds{7}.surface.colors(4,:) = 0;
    vr.worlds{8}.surface.colors(4,:) = 0;
    vr.itiStartTime = tic;
    vr.inITI = 1;
    vr.numTrials = vr.numTrials + 1;
    if vr.currentWorld == 1 || vr.currentWorld == 3 || vr.currentWorld == 5 || vr.currentWorld == 7
        vr.numTrialsTower = vr.numTrialsTower + 1;
        vr.numTrialsBlock = vr.numTrialsBlock + 1;
    elseif vr.currentWorld == 2 || vr.currentWorld == 4 || vr.currentWorld == 6 || vr.currentWorld == 8
        vr.numTrialsNoTower = vr.numTrialsNoTower + 1;
    end
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
        if vr.numTrialsBlock >= vr.blockSize
            vr.block = ~vr.block;
            vr.numTrialsBlock = 0;
        end
        if vr.block
            if vr.whichWorldFlag == 0
                if abs(.5 - vr.percLeftTurn) >= abs(.5 - vr.percBlackTurn)
                    if vr.randCueLeft >= vr.percLeftTurn
                        vr.cuePos = 1;
                    elseif vr.randCueLeft < vr.percLeftTurn
                        vr.cuePos = 2;
                    end
                elseif abs(.5 - vr.percLeftTurn)< abs(.5 - vr.percBlackTurn)
                    if vr.randCueBlack >= vr.percBlackTurn
                        vr.cuePos = 2;
                    elseif vr.randCueBlack < vr.percBlackTurn
                        vr.cuePos = 1;
                    end
                end
                if vr.cuePos == 1
                    vr.currentWorld = 1;
                    vr.worlds{1}.surface.colors(4,:) = 1;
                    vr.position = vr.worlds{1}.startLocation;
                elseif vr.cuePos == 2
                    vr.currentWorld = 7;
                    vr.worlds{7}.surface.colors(4,:) = 1;
                    vr.position = vr.worlds{7}.startLocation;
                else 
                    error('No World');
                end
            elseif vr.whichWorldFlag ~= 0 
                vr.currentWorld = vr.whichWorldFlag;
                vr.worlds{vr.whichWorldFlag}.surface.colors(4,:) = 1;
                vr.position = vr.worlds{vr.whichWorldFlag}.startLocation;
            end
        elseif ~vr.block
            if vr.whichWorldFlag == 0
                if abs(.5 - vr.percLeftTurn) >= abs(.5 - vr.percBlackTurn)
                    if vr.randCueLeft >= vr.percLeftTurn
                        vr.cuePos = 2;
                    elseif vr.randCueLeft < vr.percLeftTurn
                        vr.cuePos = 1;
                    end
                elseif abs(.5 - vr.percLeftTurn)< abs(.5 - vr.percBlackTurn)
                    if vr.randCueBlack >= vr.percBlackTurn
                        vr.cuePos = 1;
                    elseif vr.randCueBlack < vr.percBlackTurn
                        vr.cuePos = 2;
                    end
                end
                if vr.cuePos == 1
                    vr.currentWorld = 3;
                    vr.worlds{3}.surface.colors(4,:) = 1;
                    vr.position = vr.worlds{3}.startLocation;
                elseif vr.cuePos == 2
                    vr.currentWorld = 5;
                    vr.worlds{5}.surface.colors(4,:) = 1;
                    vr.position = vr.worlds{5}.startLocation;
                else 
                    error('No World');
                end
            elseif vr.whichWorldFlag ~= 0 
                vr.currentWorld = vr.whichWorldFlag;
                vr.worlds{vr.whichWorldFlag}.surface.colors(4,:) = 1;
                vr.position = vr.worlds{vr.whichWorldFlag}.startLocation;
            end
        end
        vr.outITI = true;
    end
          
end

vr.text(1).string = ['TIME ' datestr(now-vr.startTime,'HH.MM.SS')];
vr.text(2).string = ['TRIALSTOWER ', num2str(vr.numTrialsTower)];
vr.text(3).string = ['TRIALSNOTOWER ', num2str(vr.numTrialsNoTower)];
vr.text(4).string = ['REWARDSTOWER ',num2str(vr.numRewardsTower)];
vr.text(5).string = ['REWARDSNOTOWER ',num2str(vr.numRewardsNoTower)];
vr.text(6).string = ['BLOCK ',num2str(vr.block)];
    
%update udp
if vr.shouldUDP
    flushoutput(vr.udp);
    fwrite(vr.udp,[double(datestr(now - vr.startTime,'HH:MM:SS')) vr.numTrialsTower vr.numRewardsTower 100*vr.numRewardsTower/vr.numTrialsTower vr.numTrialsNoTower vr.numRewardsNoTower 100*vr.numRewardsNoTower/vr.numTrialsNoTower]);
end

fwrite(vr.fid,[rem(now,1) vr.position([1:2,4]) vr.velocity(1:2) vr.currentWorld vr.isReward vr.inITI],'float');


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
