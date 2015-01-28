function code = PairedInstantaneousDelay
% PairedInstantaneousDelay   Code for the ViRMEn experiment PairedInstantaneousDelay.
%   code = PairedInstantaneousDelay   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT

% --- INITIALIZATION code: executes before the ViRMEN engine starts.
function vr = initializationCodeFun(vr)

vr.debugMode = true;
vr.mouseNum = 999;

vr.greyFac = 1/6; %goes from 0 to 1 to signify the amount of maze which is grey
vr.midOff = 5/6;
vr.numRewPer = 1;

vr.mulRewards = 1;
vr.adapSpeed = 20;

%initialize important cell information
vr.conds = {'Black Left','Black Left Delay','Black Right','Black Right Delay',...
    'White Left','White Left Delay','White Right','White Right Delay'};

vr = initializePathVIRMEN(vr);

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
vr.blackLeftTower = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.blackLeftTower,:);
vr.blackRightTower = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.blackRightTower,:);
vr.whiteLeftTower = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.whiteLeftTower,:);
vr.whiteRightTower = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.whiteRightTower,:);
vr.LeftWallDelay = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.LeftWallDelay,:);
vr.RightWallDelay = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.RightWallDelay,:);
vr.TTopMiddle = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.TTopMiddle,:);
vr.greyLeftTower = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.greyLeftTower,:);
vr.greyRightTower = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.greyRightTower,:);

%Define groups for mazes
beginBlack = [vr.LeftWallBlack(1):vr.LeftWallBlack(2) vr.RightWallBlack(1):vr.RightWallBlack(2)];
beginWhite = [vr.LeftWallWhite(1):vr.LeftWallWhite(2) vr.RightWallWhite(1):vr.RightWallWhite(2)];
vr.whiteLeftArms = [vr.RightArmWallBlack(1):vr.RightArmWallBlack(2) vr.RightEndWallBlack(1):vr.RightEndWallBlack(2)...
    vr.TTopWallRightBlack(1):vr.TTopWallRightBlack(2) vr.LeftArmWallWhite(1):vr.LeftArmWallWhite(2)...
    vr.LeftEndWallWhite(1):vr.LeftEndWallWhite(2) vr.TTopWallLeftWhite(1):vr.TTopWallLeftWhite(2)];
vr.whiteRightArms = [vr.RightArmWallWhite(1):vr.RightArmWallWhite(2) vr.RightEndWallWhite(1):vr.RightEndWallWhite(2)...
    vr.TTopWallRightWhite(1):vr.TTopWallRightWhite(2) vr.LeftArmWallBlack(1):vr.LeftArmWallBlack(2)...
    vr.LeftEndWallBlack(1):vr.LeftEndWallBlack(2) vr.TTopWallLeftBlack(1):vr.TTopWallLeftBlack(2)];
backBlack = vr.BackWallBlack(1):vr.BackWallBlack(2);
backWhite = vr.BackWallWhite(1):vr.BackWallWhite(2);
vr.whiteRightTowers = [vr.whiteRightTower(1):vr.whiteRightTower(2) vr.blackLeftTower(1):vr.blackLeftTower(2)];
vr.whiteLeftTowers = [vr.whiteLeftTower(1):vr.whiteLeftTower(2) vr.blackRightTower(1):vr.blackRightTower(2)];
vr.greyTowers = [vr.greyLeftTower(1):vr.greyLeftTower(2) vr.greyRightTower(1):vr.greyRightTower(2)...
    vr.TTopMiddle(1):vr.TTopMiddle(2)];

vr.blackLeft = [beginBlack vr.whiteRightArms backBlack];
vr.blackRight = [beginBlack vr.whiteLeftArms backBlack];
vr.whiteLeft = [beginWhite vr.whiteLeftArms backWhite];
vr.whiteRight = [beginWhite vr.whiteRightArms backWhite];

vr.worlds{1}.surface.visible(:) = 0;
vr.currentCueWorld = 1+2*randi([0 3]);
switch vr.currentCueWorld
    case 1
        vr.worlds{1}.surface.visible(vr.blackLeft) = 1;
        vr.worlds{1}.surface.visible(vr.whiteRightTowers) = 1;
    case 3
        vr.worlds{1}.surface.visible(vr.blackRight) = 1;
        vr.worlds{1}.surface.visible(vr.whiteLeftTowers) = 1;
    case 5
        vr.worlds{1}.surface.visible(vr.whiteLeft) = 1;
        vr.worlds{1}.surface.visible(vr.whiteLeftTowers) = 1;
    case 7
        vr.worlds{1}.surface.visible(vr.whiteRight) = 1;
        vr.worlds{1}.surface.visible(vr.whiteRightTowers) = 1;
    otherwise
        display('No World');
        return;
end
vr.whichWorldFlag = 0;

vr.numTrialsNoDelay = 0;
vr.numTrialsInstDelay = 0;
vr.numRewardsInstDelay = 0;
vr.numRewardsNoDelay = 0;

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

if vr.inITI == 0 && abs(vr.position(1)) > eval(vr.exper.variables.armLength)/vr.armFac &&...
        vr.position(2) > eval(vr.exper.variables.MazeLengthAhead)
    if vr.position(1) < 0 && ismember(vr.currentCueWorld,[1 2 5 6])
        if vr.currentCueWorld == 1 || vr.currentCueWorld == 5
            vr = giveReward(vr,1);
            vr.whichWorldFlag = vr.currentCueWorld + 1;
            vr.numRewardsNoDelay = vr.numRewardsNoDelay + 1;
        elseif vr.currentCueWorld == 2 || vr.currentCueWorld == 6
            if vr.mulRewards == 0
                vr = giveReward(vr,1);
            elseif vr.mulRewards == 1
                vr = giveReward(vr,2);
            elseif vr.mulRewards >= 2
                vr = giveReward(vr,3);
            end
            vr.whichWorldFlag = 0;
            vr.numRewardsInstDelay = vr.numRewardsInstDelay + 1;
        end
        vr.itiDur = vr.itiCorrect;
        vr.trialResults(1,size(vr.trialResults,2)+1) = 1;
        vr.streak = vr.streak + 1;
    elseif  vr.position(1) > 0 && ismember(vr.currentCueWorld,[3 4 7 8])
        if vr.currentCueWorld == 3 || vr.currentCueWorld == 7
            vr = giveReward(vr,1);
            vr.whichWorldFlag = vr.currentCueWorld + 1;
            vr.numRewardsNoDelay = vr.numRewardsNoDelay + 1;
        elseif vr.currentCueWorld == 4 || vr.currentCueWorld == 8
            if vr.mulRewards == 0
                vr = giveReward(vr,1);
            elseif vr.mulRewards == 1
                vr = giveReward(vr,2);
            elseif vr.mulRewards >= 2
                vr = giveReward(vr,3);
            end
            vr.whichWorldFlag = 0;
            vr.numRewardsInstDelay = vr.numRewardsInstDelay + 1;
        end
        vr.itiDur = vr.itiCorrect;
        vr.trialResults(1,size(vr.trialResults,2)+1) = 1;
        vr.streak = vr.streak + 1;
    else
        vr.isReward = 0;
        vr.itiDur = vr.itiMiss;
        vr.whichWorldFlag = 0;
        vr.trialResults(1,size(vr.trialResults,2)+1) = 0;
        vr.streak = 0;
    end
    
    if vr.isReward ~= 0 && ismember(vr.currentCueWorld,[1 2 3 4]) %is black?
        vr.trialResults(3,end) = 1;
    elseif vr.isReward == 0 && ismember(vr.currentCueWorld,[5 6 7 8])
        vr.trialResults(3,end) = 1;
    else
        vr.trialResults(3,end) = 0;
    end
    
    if vr.isReward ~= 0 && ismember(vr.currentCueWorld,[1 2 5 6]) %is left?
        vr.trialResults(2,end) = 1;
    elseif vr.isReward == 0 && ismember(vr.currentCueWorld,[3 4 7 8])
        vr.trialResults(2,end) = 1;
    else
        vr.trialResults(2,end) = 0;
    end
    
    vr.worlds{1}.surface.visible(:) = 0;
    vr.itiStartTime = tic;
    vr.inITI = 1;
    vr.numTrials = vr.numTrials + 1;
    vr.cellWrite = true;
    if ismember(vr.currentCueWorld,[1 3 5 7])
        vr.numTrialsNoDelay = vr.numTrialsNoDelay + 1;
    elseif ismember(vr.currentCueWorld,[2 4 6 8])
        vr.numTrialsInstDelay = vr.numTrialsInstDelay + 1;
    end
else
    vr.isReward = 0;
end

%Turn on/off gray block
if ismember(vr.currentCueWorld,[2 4 6 8])
    if (vr.position(2) < vr.midOff*str2double(vr.exper.variables.MazeLengthAhead)) && ~vr.inITI
        vr.worlds{1}.surface.visible([vr.whiteLeftArms vr.whiteRightArms...
            vr.whiteLeftTowers vr.whiteRightTowers]) = 0;
        vr.worlds{1}.surface.visible(vr.greyTowers) = 1;
    elseif (vr.position(2) >= vr.midOff*str2double(vr.exper.variables.MazeLengthAhead)) && ~vr.inITI
        if ismember(vr.currentCueWorld,[1 2 7 8])
            vr.worlds{1}.surface.visible([vr.whiteRightTowers vr.whiteRightArms]) = 1;
        elseif ismember(vr.currentCueWorld,[3 4 5 6])
            vr.worlds{1}.surface.visible([vr.whiteLeftTowers vr.whiteLeftArms]) = 1;
        end
        vr.worlds{1}.surface.visible(vr.greyTowers) = 0;
    end
end

if vr.inITI == 1
    vr.itiTime = toc(vr.itiStartTime);
    
    if vr.cellWrite
        [dataStruct] = createSaveStruct(vr.mouseNum,vr.experimenter,...
            vr.conds,vr.whiteMazes,vr.leftMazes,vr.mazeName,vr.currentCueWorld,...
            vr.leftMazes(vr.currentCueWorld),vr.whiteMazes(vr.currentCueWorld),...
            vr.isReward,vr.itiCorrect,vr.itiMiss,vr.isReward~=0,vr.leftMazes(vr.currentCueWorld)==(vr.isReward~=0),...
            vr.whiteMazes(vr.currentCueWorld)==(vr.isReward~=0),vr.streak,vr.trialStartTime,...
            rem(now,1),vr.startTime,'Delay',ismember(vr.currentCueWorld,[2 4 6 8])); %#ok<NASGU>
        eval(['data',num2str(vr.numTrials),'=dataStruct;']);
        %save datastruct
        if exist(vr.pathTempMatCell,'file')
            save(vr.pathTempMatCell,['data',num2str(vr.numTrials)],'-append');
        else
            save(vr.pathTempMatCell,['data',num2str(vr.numTrials)]);
        end
        vr.cellWrite = false;
    end
    
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
        if vr.whichWorldFlag == 0
            if randLeft >= vr.percLeft
                if randColor >= vr.percBlack
                    vr.currentCueWorld = 1;
                else
                    vr.currentCueWorld = 5;
                end
            else
                if randColor >= vr.percBlack
                    vr.currentCueWorld = 3;
                else
                    vr.currentCueWorld = 7;
                end
            end
        else
            vr.currentCueWorld = vr.whichWorldFlag;
        end
        switch vr.currentCueWorld
            case 1
                vr.worlds{1}.surface.visible(vr.blackLeft) = 1;
                vr.worlds{1}.surface.visible(vr.whiteRightTowers) = 1;
            case 2
                vr.worlds{1}.surface.visible(vr.blackLeft) = 1;
                vr.worlds{1}.surface.visible(vr.greyTowers) = 1;
                vr.worlds{1}.surface.visible(vr.LeftWallBlack(1) + ceil((1-vr.greyFac)*(vr.LeftWallBlack(2)-vr.LeftWallBlack(1))):vr.LeftWallBlack(2)) = 0;
                vr.worlds{1}.surface.visible(vr.RightWallBlack(1) + ceil((1-vr.greyFac)*(vr.RightWallBlack(2)-vr.RightWallBlack(1))):vr.RightWallBlack(2)) = 0;
                vr.worlds{1}.surface.visible(vr.LeftWallDelay(1) + ceil((1-vr.greyFac)*(vr.LeftWallDelay(2)-vr.LeftWallDelay(1))):vr.LeftWallDelay(end)) = 1;
                vr.worlds{1}.surface.visible(vr.RightWallDelay(1) + ceil((1-vr.greyFac)*(vr.RightWallDelay(2)-vr.RightWallDelay(1))):vr.RightWallDelay(end)) = 1;
            case 3
                vr.worlds{1}.surface.visible(vr.blackRight) = 1;
                vr.worlds{1}.surface.visible(vr.whiteLeftTowers) = 1;
            case 4
                vr.worlds{1}.surface.visible(vr.blackRight) = 1;
                vr.worlds{1}.surface.visible(vr.greyTowers) = 1;
                vr.worlds{1}.surface.visible(vr.LeftWallBlack(1) + ceil((1-vr.greyFac)*(vr.LeftWallBlack(2)-vr.LeftWallBlack(1))):vr.LeftWallBlack(2)) = 0;
                vr.worlds{1}.surface.visible(vr.RightWallBlack(1) + ceil((1-vr.greyFac)*(vr.RightWallBlack(2)-vr.RightWallBlack(1))):vr.RightWallBlack(2)) = 0;
                vr.worlds{1}.surface.visible(vr.LeftWallDelay(1) + ceil((1-vr.greyFac)*(vr.LeftWallDelay(2)-vr.LeftWallDelay(1))):vr.LeftWallDelay(end)) = 1;
                vr.worlds{1}.surface.visible(vr.RightWallDelay(1) + ceil((1-vr.greyFac)*(vr.RightWallDelay(2)-vr.RightWallDelay(1))):vr.RightWallDelay(end)) = 1;
            case 5
                vr.worlds{1}.surface.visible(vr.whiteLeft) = 1;
                vr.worlds{1}.surface.visible(vr.whiteLeftTowers) = 1;
            case 6
                vr.worlds{1}.surface.visible(vr.whiteLeft) = 1;
                vr.worlds{1}.surface.visible(vr.greyTowers) = 1;
                vr.worlds{1}.surface.visible(vr.LeftWallWhite(1) + ceil((1-vr.greyFac)*(vr.LeftWallWhite(2)-vr.LeftWallWhite(1))):vr.LeftWallWhite(2)) = 0;
                vr.worlds{1}.surface.visible(vr.RightWallWhite(1) + ceil((1-vr.greyFac)*(vr.RightWallWhite(2)-vr.RightWallWhite(1))):vr.RightWallWhite(2)) = 0;
                vr.worlds{1}.surface.visible(vr.LeftWallDelay(1) + ceil((1-vr.greyFac)*(vr.LeftWallDelay(2)-vr.LeftWallDelay(1))):vr.LeftWallDelay(end)) = 1;
                vr.worlds{1}.surface.visible(vr.RightWallDelay(1) + ceil((1-vr.greyFac)*(vr.RightWallDelay(2)-vr.RightWallDelay(1))):vr.RightWallDelay(end)) = 1;
            case 7
                vr.worlds{1}.surface.visible(vr.whiteRight) = 1;
                vr.worlds{1}.surface.visible(vr.whiteRightTowers) = 1;
            case 8
                vr.worlds{1}.surface.visible(vr.whiteRight) = 1;
                vr.worlds{1}.surface.visible(vr.greyTowers) = 1;
                vr.worlds{1}.surface.visible(vr.LeftWallWhite(1) + ceil((1-vr.greyFac)*(vr.LeftWallWhite(2)-vr.LeftWallWhite(1))):vr.LeftWallWhite(2)) = 0;
                vr.worlds{1}.surface.visible(vr.RightWallWhite(1) + ceil((1-vr.greyFac)*(vr.RightWallWhite(2)-vr.RightWallWhite(1))):vr.RightWallWhite(2)) = 0;
                vr.worlds{1}.surface.visible(vr.LeftWallDelay(1) + ceil((1-vr.greyFac)*(vr.LeftWallDelay(2)-vr.LeftWallDelay(1))):vr.LeftWallDelay(end)) = 1;
                vr.worlds{1}.surface.visible(vr.RightWallDelay(1) + ceil((1-vr.greyFac)*(vr.RightWallDelay(2)-vr.RightWallDelay(1))):vr.RightWallDelay(end)) = 1;
            otherwise
                display('No World');
                return;
        end
        vr.position = vr.worlds{1}.startLocation;
        
        vr.dp = 0; %prevents movement
        vr.trialStartTime = rem(now,1);
    end
end

vr.text(1).string = ['TIME ' datestr(now-vr.startTime,'HH.MM.SS')];
vr.text(2).string = ['TRIALSNODELAY ', num2str(vr.numTrialsNoDelay)];
vr.text(3).string = ['TRIALSINSTDELAY ', num2str(vr.numTrialsInstDelay)];
vr.text(4).string = ['REWARDSNODELAY ',num2str(vr.numRewardsNoDelay)];
vr.text(5).string = ['REWARDSINSTDELAY ',num2str(vr.numRewardsInstDelay)];

fwrite(vr.fid,[rem(now,1) vr.position([1:2,4]) vr.velocity(1:2) vr.currentCueWorld vr.isReward vr.inITI],'float');


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
commonTerminationVIRMEN(vr);