function code = DMSDiscreetIntGraded2TowersSingleTowerCrutch
% DMSDiscreetIntGraded2TowersSingleTowerCrutch   Code for the ViRMEn experiment DMSDiscreetIntGraded2TowersSingleTowerCrutch.
%   code = DMSDiscreetIntGraded2TowersSingleTowerCrutch   Returns handles to the functions that ViRMEn
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

%single tower crutch
vr.probCrutch = 0.25; %probability of a single tower crutch trial
vr.crutchAdaptive = true; %boolean of whether crutches should be adaptive

vr.midOff = 5/6;
vr.trialThresh = 300;
vr.advThresh = [0.8 0.7 0.6];
vr.condProbs(1,:) = [1 0 0];
vr.condProbs(2,:) = [0.7 0.3 0]; %condition probabilities for the up to 1-3 condition. Must add up to 1
vr.condProbs(3,:) = [1 0 0]; %condition probabilities for the all condition. Must add up to 1
vr.intGraded = 0; %0 - only 0-4, 1 - up to 1-3, 2- all

vr.greyFac = 1/2; %goes from 0 to 1 to signify the amount of maze which is grey
vr.numRewPer = 1;
vr.numSeg = 4;
vr.greyRat = 0.3; %goes from 0 to 1 to signify percentage of each segment which is gray. Must be related to number of textures greyRat*((intLength/mazeLength)*numText)/numSeg must be an integer
vr.flashOffset = 0;

%breaks
vr.breaks = false; %flag of whether or not breaks should occur
vr.breakDur = 20; %break duration in seconds
vr.breakThreshTime = 30; %time threshold for breaks in seconds
vr.trialTicFlag = true;
vr.breakFlag = true;
vr.inBreak = false;

%increase ITI
vr.increaseITI = true; %flag of whether or not ITIs should increase 
vr.missITIVec = [4 10 15]; %vector of increase in ITIs in response to consecutive missed trials

vr.adaptive = true;
vr.adapSpeed = 20; %number of trials over which to perform adaptive
vr.adapSpeedConds = 30;

vr.condThresh = 0.75;
vr.deltaProb = 0.03;
vr.maxProbs = [1 0.35 0.15];

%initialize important cell information
vr.conds = {'Black Left','Black Right','White Left','White Right'};

vr = initializePathVIRMEN(vr);

%Get initial delay
vr.easyFac = 1;
vr.numLeftTurns = 0;
vr.numBlackTurns = 0;
vr.crutchTrial = false;
vr.numTrialsLevel = 0;
vr.mazeLength = eval(vr.exper.variables.MazeLengthAhead);
vr.totIntLength = vr.mazeLength*(1-vr.greyFac);
vr.ranges = linspace(0,vr.totIntLength,vr.numSeg+1);

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
vr.TTopMiddle = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.TTopMiddle,:);
vr.blackLeftTower = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.blackLeftTower,:);
vr.blackRightTower = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.blackRightTower,:);
vr.whiteLeftTower = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.whiteLeftTower,:);
vr.whiteRightTower = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.whiteRightTower,:);
vr.greyLeftTower = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.greyLeftTower,:);
vr.greyRightTower = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.greyRightTower,:);
vr.behindDelay = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.behindDelay,:);
vr.backWallBlackSingleTower = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.backWallBlackSingleTower,:);
vr.backWallWhiteSingleTower = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.backWallWhiteSingleTower,:);
vr.behindBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.behindBlack,:);
vr.behindWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.behindWhite,:);

%Define groups for mazes
beginBlack = [vr.LeftWallBlack(1):vr.LeftWallBlack(2) vr.RightWallBlack(1):vr.RightWallBlack(2)];
beginWhite = [vr.LeftWallWhite(1):vr.LeftWallWhite(2) vr.RightWallWhite(1):vr.RightWallWhite(2)];
beginDelay = [vr.LeftWallDelay(1):vr.LeftWallDelay(2) vr.RightWallDelay(1):vr.RightWallDelay(2)];
vr.whiteLeft = [vr.RightArmWallBlack(1):vr.RightArmWallBlack(2) vr.RightEndWallBlack(1):vr.RightEndWallBlack(2)...
    vr.TTopWallRightBlack(1):vr.TTopWallRightBlack(2) vr.LeftArmWallWhite(1):vr.LeftArmWallWhite(2)...
    vr.LeftEndWallWhite(1):vr.LeftEndWallWhite(2) vr.TTopWallLeftWhite(1):vr.TTopWallLeftWhite(2)];
vr.whiteRight = [vr.RightArmWallWhite(1):vr.RightArmWallWhite(2) vr.RightEndWallWhite(1):vr.RightEndWallWhite(2)...
    vr.TTopWallRightWhite(1):vr.TTopWallRightWhite(2) vr.LeftArmWallBlack(1):vr.LeftArmWallBlack(2)...
    vr.LeftEndWallBlack(1):vr.LeftEndWallBlack(2) vr.TTopWallLeftBlack(1):vr.TTopWallLeftBlack(2)];
vr.greyTowers = [vr.greyLeftTower(1):vr.greyLeftTower(2) vr.greyRightTower(1):vr.greyRightTower(2)];
vr.whiteRightTowers = [vr.whiteRightTower(1):vr.whiteRightTower(2) vr.blackLeftTower(1):vr.blackLeftTower(2)];
vr.whiteLeftTowers = [vr.whiteLeftTower(1):vr.whiteLeftTower(2) vr.blackRightTower(1):vr.blackRightTower(2)];
backBlack = vr.BackWallBlack(1):vr.BackWallBlack(2);
behindDelay = vr.behindDelay(1):vr.behindDelay(2); %actually grey
behindWhite = vr.behindWhite(1):vr.behindWhite(2);
behindBlack = vr.behindBlack(1):vr.behindBlack(2);
backWhite = vr.BackWallWhite(1):vr.BackWallWhite(2); %actually grey
TTopMiddle = vr.TTopMiddle(1):vr.TTopMiddle(2);
backWallBlackSingleTower = vr.backWallBlackSingleTower(1):vr.backWallBlackSingleTower(2);
backWallWhiteSingleTower = vr.backWallWhiteSingleTower(1):vr.backWallWhiteSingleTower(2);

vr.blackLeftOn = [behindDelay beginDelay vr.whiteRight vr.greyTowers backBlack TTopMiddle];
vr.blackRightOn = [behindDelay beginDelay vr.whiteLeft vr.greyTowers backBlack TTopMiddle];
vr.whiteLeftOn = [behindDelay beginDelay vr.whiteLeft vr.greyTowers backWhite TTopMiddle];
vr.whiteRightOn = [behindDelay beginDelay vr.whiteRight vr.greyTowers backWhite TTopMiddle];

vr.blackLeftCrutch = [behindBlack beginBlack vr.whiteRight backWallBlackSingleTower vr.blackLeftTower(1):vr.blackLeftTower(2)];
vr.blackRightCrutch = [behindBlack beginBlack vr.whiteLeft backWallBlackSingleTower vr.blackRightTower(1):vr.blackRightTower(2)];
vr.whiteLeftCrutch = [behindWhite beginWhite vr.whiteLeft backWallWhiteSingleTower vr.whiteLeftTower(1):vr.whiteLeftTower(2)];
vr.whiteRightCrutch = [behindWhite beginWhite vr.whiteRight backWallWhiteSingleTower vr.whiteRightTower(1):vr.whiteRightTower(2)];

vr.cuePos = randi(4);
vr.worlds{1}.surface.visible(:) = 0;
switch vr.cuePos
    case 1
        vr.worlds{1}.surface.visible(vr.blackLeftOn) = 1;
    case 2
        vr.worlds{1}.surface.visible(vr.blackRightOn) = 1;
    case 3
        vr.worlds{1}.surface.visible(vr.whiteLeftOn) = 1;
    case 4
        vr.worlds{1}.surface.visible(vr.whiteRightOn) = 1;
    otherwise
        error('No World');
end

if vr.cuePos <= 2
    vr.numWhite = randsample(0:(vr.numSeg/2),1,true,vr.condProbs(vr.intGraded+1,:));
else
    vr.numWhite = randsample((vr.numSeg/2):vr.numSeg,1,true,fliplr(vr.condProbs(vr.intGraded+1,:)));
end
vr.whiteDots = sort(randsample(vr.numSeg,vr.numWhite)); %generate which segments will be white

% mazeReg = find(vr.position(2) >= vr.ranges,1,'last');
vr.worlds{1}.surface.visible(vr.LeftWallDelay(1):vr.LeftWallDelay(2)) = 1;
vr.worlds{1}.surface.visible(vr.RightWallDelay(1):vr.RightWallDelay(2)) = 1;

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

if vr.inITI == 0 && abs(vr.position(1)) > eval(vr.exper.variables.armLength)/vr.armFac &&...
        vr.position(2) > eval(vr.exper.variables.MazeLengthAhead)
    if vr.position(1) < 0 && ismember(vr.cuePos,[1 3])
        vr = giveReward(vr,vr.numRewPer);
        
        vr.itiDur = vr.itiCorrect;
        vr.numRewards = vr.numRewards + 1;
        vr.trialResults(1,size(vr.trialResults,2)+1) = 1;
        vr.streak = vr.streak + 1;
    elseif  vr.position(1) > 0 && ismember(vr.cuePos,[2 4])
        vr = giveReward(vr,vr.numRewPer);
        
        vr.itiDur = vr.itiCorrect;
        vr.numRewards = vr.numRewards + 1;
        vr.trialResults(1,size(vr.trialResults,2)+1) = 1;
        vr.streak = vr.streak + 1;
    else
        vr.isReward = 0;
        vr.trialResults(1,size(vr.trialResults,2)+1) = 0;
        if vr.increaseITI
            numConsecMiss = size(vr.trialResults,2) -...
                find(diff(vr.trialResults(1,:))==-1,1,'last'); %find number of consecutive missed trials
            if numConsecMiss > length(vr.missITIVec)
                numConsecMiss = length(vr.missITIVec);
            elseif ~any(vr.trialResults(1,:)==1)
                numConsecMiss = size(vr.trialResults,2);
                if numConsecMiss > length(vr.missITIVec)
                    numConsecMiss = length(vr.missITIVec);
                end
            end
            vr.itiDur = vr.missITIVec(numConsecMiss);
        else
            vr.itiDur = vr.itiMiss;
        end
        vr.streak = 0;
    end
    
    vr.worlds{1}.surface.visible(:) = 0;
    vr.itiStartTime = tic;
    vr.inITI = 1;
    vr.numTrials = vr.numTrials + 1;
    vr.numTrialsLevel = vr.numTrialsLevel + 1;
    vr.cellWrite = true;
    
    if (ismember(vr.cuePos,[1 3]) && vr.isReward ~= 0) || (ismember(vr.cuePos,[2 4]) && vr.isReward == 0)
        vr.numLeftTurns = vr.numLeftTurns + 1;
        vr.trialResults(2,end) = 1;
    else
        vr.trialResults(2,end) = 0;
    end
    if (ismember(vr.cuePos,[1 2]) && vr.isReward ~= 0) || (ismember(vr.cuePos,[3 4]) && vr.isReward == 0)
        vr.numBlackTurns = vr.numBlackTurns + 1;
        vr.trialResults(3,end) = 1;
    else
        vr.trialResults(3,end) = 0;
    end
    vr.trialResults(4,end) = vr.numWhite;
    vr.trialResults(5,end) = vr.crutchTrial; %fifth row is whether or not a crutch trial is present
else
    vr.isReward = 0;
end

%Set trialsStart tic (must be in runtime so that tic doesn't start long
%before session actually starts
if vr.trialTicFlag
    vr.trialsStart = tic;
    vr.trialTicFlag = false;
end

%update flashing visibility
if ~vr.crutchTrial
    mazeReg = find((vr.position(2)+vr.flashOffset) >= vr.ranges,1,'last');
    if isempty(mazeReg) || mazeReg == length(vr.ranges)
        vr.worlds{1}.surface.visible(vr.LeftWallDelay(1):vr.LeftWallDelay(2)) = 1;
        vr.worlds{1}.surface.visible(vr.RightWallDelay(1):vr.RightWallDelay(2)) = 1;
        vr.worlds{1}.surface.visible(vr.RightWallWhite(1):vr.RightWallWhite(2)) = 0;
        vr.worlds{1}.surface.visible(vr.RightWallBlack(1):vr.RightWallBlack(2)) = 0;
        vr.worlds{1}.surface.visible(vr.LeftWallWhite(1):vr.LeftWallWhite(2)) = 0;
        vr.worlds{1}.surface.visible(vr.LeftWallBlack(1):vr.LeftWallBlack(2)) = 0;
    else
        greyCutoff(1) = (vr.ranges(mazeReg)+vr.greyRat*(vr.totIntLength/vr.numSeg))/vr.mazeLength;    greyCutoff(2) = vr.ranges(mazeReg+1)/vr.mazeLength;
        vr.worlds{1}.surface.visible(vr.LeftWallDelay(1):vr.LeftWallDelay(2)) = 0;
        vr.worlds{1}.surface.visible(vr.RightWallDelay(1):vr.RightWallDelay(2)) = 0;
        vr.worlds{1}.surface.visible(vr.RightWallWhite(1):vr.RightWallWhite(2)) = 0;
        vr.worlds{1}.surface.visible(vr.RightWallBlack(1):vr.RightWallBlack(2)) = 0;
        vr.worlds{1}.surface.visible(vr.LeftWallWhite(1):vr.LeftWallWhite(2)) = 0;
        vr.worlds{1}.surface.visible(vr.LeftWallBlack(1):vr.LeftWallBlack(2)) = 0;
        vr.worlds{1}.surface.visible([vr.LeftWallDelay(1):vr.LeftWallDelay(1) + ceil(...
            greyCutoff(1)*(vr.LeftWallDelay(2)-vr.LeftWallDelay(1))),...
            vr.LeftWallDelay(1) + ceil(...
            greyCutoff(2)*(vr.LeftWallDelay(2)-vr.LeftWallDelay(1))):vr.LeftWallDelay(2)]) = 1;
        vr.worlds{1}.surface.visible([vr.RightWallDelay(1):vr.RightWallDelay(1) + ceil(...
            greyCutoff(1)*(vr.RightWallDelay(2)-vr.RightWallDelay(1))),...
            vr.RightWallDelay(1) + ceil(...
            greyCutoff(2)*(vr.RightWallDelay(2)-vr.RightWallDelay(1))):vr.RightWallDelay(2)]) = 1;
        if ~ismember(mazeReg,vr.whiteDots)
            vr.worlds{1}.surface.visible(vr.LeftWallBlack(1) + ceil(...
                greyCutoff(1)*(vr.LeftWallBlack(2)-vr.LeftWallBlack(1))):...
                vr.LeftWallBlack(1) + ceil(...
                greyCutoff(2)*(vr.LeftWallBlack(2)-vr.LeftWallBlack(1)))) = 1;
            vr.worlds{1}.surface.visible(vr.RightWallBlack(1) + ceil(...
                greyCutoff(1)*(vr.RightWallBlack(2)-vr.RightWallBlack(1))):...
                vr.RightWallBlack(1) + ceil(...
                greyCutoff(2)*(vr.RightWallBlack(2)-vr.RightWallBlack(1)))) = 1;
        else
            vr.worlds{1}.surface.visible(vr.LeftWallWhite(1) + ceil(...
                greyCutoff(1)*(vr.LeftWallWhite(2)-vr.LeftWallWhite(1))):...
                vr.LeftWallWhite(1) + ceil(...
                greyCutoff(2)*(vr.LeftWallWhite(2)-vr.LeftWallWhite(1)))) = 1;
            vr.worlds{1}.surface.visible(vr.RightWallWhite(1) + ceil(...
                greyCutoff(1)*(vr.RightWallWhite(2)-vr.RightWallWhite(1))):...
                vr.RightWallWhite(1) + ceil(...
                greyCutoff(2)*(vr.RightWallWhite(2)-vr.RightWallWhite(1)))) = 1;
        end
    end
    
    %Turn on/off gray block
    if (vr.position(2) < vr.midOff*str2double(vr.exper.variables.MazeLengthAhead)) && ~vr.inITI
        vr.worlds{1}.surface.visible([vr.whiteLeft vr.whiteRight...
            vr.whiteLeftTowers vr.whiteRightTowers]) = 0;
        vr.worlds{1}.surface.visible(vr.TTopMiddle(1):vr.TTopMiddle(2)) = 1;
        vr.worlds{1}.surface.visible(vr.greyTowers) = 1;
    elseif (vr.position(2) >= vr.midOff*str2double(vr.exper.variables.MazeLengthAhead)) && ~vr.inITI
        if vr.cuePos == 1 || vr.cuePos == 4
            vr.worlds{1}.surface.visible(vr.whiteRight) = 1;
            vr.worlds{1}.surface.visible(vr.whiteRightTowers) = 1;
        elseif vr.cuePos == 2 || vr.cuePos == 3
            vr.worlds{1}.surface.visible(vr.whiteLeft) = 1;
            vr.worlds{1}.surface.visible(vr.whiteLeftTowers) = 1;
        end
        vr.worlds{1}.surface.visible(vr.TTopMiddle(1):vr.TTopMiddle(2)) = 0;
        vr.worlds{1}.surface.visible(vr.greyTowers) = 1;
    end
end

if vr.inITI == 1
    vr.itiTime = toc(vr.itiStartTime);
    vr.worlds{1}.surface.visible(:) = 0;
    
    if vr.cellWrite
        [dataStruct] = createSaveStruct(vr.mouseNum,vr.experimenter,...
            vr.conds,vr.whiteMazes,vr.leftMazes,vr.mazeName,vr.cuePos,vr.leftMazes(vr.cuePos),...
            vr.whiteMazes(vr.cuePos),vr.isReward,vr.itiCorrect,vr.itiMiss,vr.isReward ~= 0,vr.leftMazes(vr.cuePos)==(vr.isReward~=0),...
            vr.whiteMazes(vr.cuePos)==(vr.isReward~=0),vr.streak,vr.trialStartTime,rem(now,1),...
            vr.startTime,'greyFac',vr.greyFac,'numRewPer',vr.numRewPer,'whiteDots',vr.whiteDots,...
            'numWhite',vr.numWhite,'intGraded',vr.intGraded,'crutchTrial',vr.crutchTrial); %#ok<NASGU>
        eval(['data',num2str(vr.numTrials),'=dataStruct;']);
        %save datastruct
        if exist(vr.pathTempMatCell,'file')
            save(vr.pathTempMatCell,['data',num2str(vr.numTrials)],'-append');
        else
            save(vr.pathTempMatCell,['data',num2str(vr.numTrials)]);
        end
        vr.cellWrite = false;
    end
    
    %check for break
    if toc(vr.trialsStart) < vr.breakThreshTime || ~vr.breaks
        
        if vr.itiTime > vr.itiDur
            vr.inITI = 0;
            
            %perform adaptation
            if vr.adaptive
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
            else
                vr.cuePos = randi(4);
            end                
            
            
            
            randCrutch = rand;
            if randCrutch > vr.probCrutch %if random number between 0 and 1 greater than crutch probability
                vr.crutchTrial = false;
                switch vr.cuePos
                    case 1
                        vr.worlds{1}.surface.visible(vr.blackLeftOn) = 1;
                    case 2
                        vr.worlds{1}.surface.visible(vr.blackRightOn) = 1;
                    case 3
                        vr.worlds{1}.surface.visible(vr.whiteLeftOn) = 1;
                    case 4
                        vr.worlds{1}.surface.visible(vr.whiteRightOn) = 1;
                    otherwise
                        error('No World');
                end
            else
                vr.crutchTrial = true;
                nonCrutchTrials = vr.trialResults(:,vr.trialResults(5,:)==0);
                if size(nonCrutchTrials,2) >= vr.adapSpeed
                    vr.percBlack = sum(nonCrutchTrials(3,(end-vr.adapSpeed+1):end))/vr.adapSpeed;
                    vr.percLeft = sum(nonCrutchTrials(2,(end-vr.adapSpeed+1):end))/vr.adapSpeed;
                else
                    vr.percBlack = sum(nonCrutchTrials(3,1:end))/size(nonCrutchTrials,2);
                    vr.percLeft = sum(nonCrutchTrials(2,1:end))/size(nonCrutchTrials,2);
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
                        vr.worlds{1}.surface.visible(vr.blackLeftCrutch) = 1;
                    case 2
                        vr.worlds{1}.surface.visible(vr.blackRightCrutch) = 1;
                    case 3
                        vr.worlds{1}.surface.visible(vr.whiteLeftCrutch) = 1;
                    case 4
                        vr.worlds{1}.surface.visible(vr.whiteRightCrutch) = 1;
                    otherwise
                        error('No World');
                end
            end
            
            %update intGraded
            if size(vr.trialResults,2) >= vr.trialThresh
                vr.percCorrLevel = sum(vr.trialResults(1,end-vr.trialThresh+1:end))/vr.trialThresh;
            else
                vr.percCorrLevel = 0;
            end
            if vr.intGraded < 3 && vr.numTrialsLevel >= vr.trialThresh &&...
                    vr.percCorrLevel >= vr.advThresh(vr.intGraded+1) %if enough trials and percCorr high enough
                vr.numTrialsLevel = 0;
                vr.intGraded = vr.intGraded + 1;
            end
            
            %calculate performance in each condition
            perf = zeros(1,(vr.numSeg/2)+1);
            if size(vr.trialResults,2) >= vr.adapSpeedConds
                for i=1:(vr.numSeg/2)+1
                    trialSub{i} = vr.trialResults(:,vr.trialResults(4,(end-vr.adapSpeedConds+1):end)== i-1 |...
                        vr.trialResults(4,(end-vr.adapSpeedConds+1):end)== vr.numSeg+1-i);
                    if ~isempty(trialSub{i})
                        perf(i) = sum(trialSub{i}(1,:))/size(trialSub{i},2);
                    else
                        perf(i) = NaN;
                    end
                end
            else
                perf(:) = NaN;
            end
            
            %update condProbs
            if ~isnan(perf(1)) && vr.intGraded == 2 %if there has been a 4-0 trial and past adapThresh
                if perf(1) < vr.condThresh %if performance on 4-0 trials less than condThresh
                    if vr.condProbs(3,3) >= vr.deltaProb %if 2-2 prob greater than change
                        vr.condProbs(3,1) = vr.condProbs(3,1) + vr.deltaProb;
                        vr.condProbs(3,3) = vr.condProbs(3,3) - vr.deltaProb;
                    elseif vr.condProbs(3,3) > 0 && vr.condProbs(3,3) < vr.deltaProb...
                            && vr.condProbs(3,2) >= (vr.deltaProb - vr.condProbs(3,3))
                        initVal = vr.condProbs(3,3);
                        vr.condProbs(3,1) = vr.condProbs(3,1) + vr.deltaProb;
                        vr.condProbs(3,3) = 0;
                        vr.condProbs(3,2) = vr.condProbs(3,2) - vr.deltaProb + initVal;
                    elseif vr.condProbs(3,3) == 0 && vr.condProbs(3,2) >= vr.deltaProb
                        vr.condProbs(3,1) = vr.condProbs(3,1) + vr.deltaProb;
                        vr.condProbs(3,2) = vr.condProbs(3,2) - vr.deltaProb;
                    elseif vr.condProbs(3,3) == 0 && vr.condProbs(3,2) > 0 &&...
                            vr.condProbs(3,2) < vr.deltaProb
                        vr.condProbs(3,1) = vr.condProbs(3,1) + vr.condProbs(3,2);
                        vr.condProbs(3,2) = 0;
                    end
                else
                    if vr.condProbs(3,2) < vr.maxProbs(2)
                        diffProb = vr.maxProbs(2) - vr.condProbs(3,2);
                        if diffProb >= vr.deltaProb
                            vr.condProbs(3,2) = vr.condProbs(3,2)+vr.deltaProb;
                            vr.condProbs(3,1) = vr.condProbs(3,1)-vr.deltaProb;
                        else
                            vr.condProbs(3,2) = vr.maxProbs(2);
                            vr.condProbs(3,1) = vr.condProbs(3,1) - diffProb;
                        end
                    elseif vr.condProbs(3,3) < vr.maxProbs(3)
                        diffProb = vr.maxProbs(3) - vr.condProbs(3,3);
                        if diffProb >= vr.deltaProb
                            vr.condProbs(3,3) = vr.condProbs(3,3)+vr.deltaProb;
                            vr.condProbs(3,1) = vr.condProbs(3,1)-vr.deltaProb;
                        else
                            vr.condProbs(3,3) = vr.maxProbs(3);
                            vr.condProbs(3,1) = vr.condProbs(3,1) - diffProb;
                        end
                    end
                end
            end
            
            %update integration
            if vr.cuePos <= 2
                vr.numWhite = randsample(0:(vr.numSeg/2),1,true,vr.condProbs(vr.intGraded+1,:));
            else
                vr.numWhite = randsample((vr.numSeg/2):vr.numSeg,1,true,fliplr(vr.condProbs(vr.intGraded+1,:)));
            end
            vr.whiteDots = sort(randsample(vr.numSeg,vr.numWhite)); %generate which segments will be white
            
            vr.position = vr.worlds{1}.startLocation;
            vr.dp = 0; %prevents movement
            vr.trialStartTime = rem(now,1);
        end
    else %if break should occur
        vr.worlds{1}.surface.visible(:) = 0;
        if vr.breakFlag
            vr.breakStart = tic;
            vr.breakFlag = false;
            vr.inBreak = true;
        end
        if toc(vr.breakStart) > vr.breakDur
            vr.trialsStart = tic;
            vr.breakFlag = true;
            vr.inBreak = false;
        end
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
vr.text(5).string = ['GREYFAC ',num2str(vr.greyFac)];

fwrite(vr.fid,[rem(now,1) vr.position([1:2,4]) vr.velocity(1:2) vr.cuePos vr.isReward vr.inITI vr.greyFac vr.breakFlag],'float');


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
commonTerminationVIRMEN(vr);