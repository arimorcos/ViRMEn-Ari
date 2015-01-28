function code = DMSDiscreetIntGraded
% DMSDiscreetIntGraded   Code for the ViRMEn experiment DMSDiscreetIntGraded.
%   code = DMSDiscreetIntGraded   Returns handles to the functions that ViRMEn
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

vr.midOff = .9;
vr.trialThresh = 40;
vr.advThresh = [0.8 0.7 0.6];
vr.intGraded = 2; %0 - only 0-8, 1 - up to 1-7, 2- up to 2-6, 3-all

vr.greyFac = 0.4; %goes from 0 to 1 to signify the amount of maze which is grey
vr.numRewPer = 2;
vr.numSeg = 8;

vr.adapSpeed = 20; %number of trials over which to perform adaptive

%initialize important cell information
vr.conds = {'Black Left','Black Right','White Left','White Right'};

vr = initializePathVIRMEN(vr);

%Get initial delay
vr.numLeftTurns = 0;
vr.numBlackTurns = 0;
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
vr.directionTowerEnd = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.directionTowerEnd,:);
vr.TTopMiddle = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.TTopMiddle,:);

%Define groups for mazes
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

vr.blackLeftOn = [vr.whiteRight dirTower backBlack TTopMiddle];
vr.blackLeftOff = [vr.whiteLeft delayWalls];

vr.blackRightOn = [vr.whiteLeft dirTower backBlack TTopMiddle];
vr.blackRightOff = [vr.whiteRight delayWalls];

vr.whiteLeftOn = [vr.whiteLeft dirTower backWhite TTopMiddle];
vr.whiteLeftOff = [vr.whiteRight delayWalls];

vr.whiteRightOn = [vr.whiteRight dirTower backWhite TTopMiddle];
vr.whiteRightOff = [vr.whiteLeft delayWalls];

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

switch vr.intGraded
    case 0
        vr.dotMax = 0;
        vr.dotMin = 8;
    case 1
        vr.dotMax = 1;
        vr.dotMin = 7;
    case 2
        vr.dotMax = 2;
        vr.dotMin = 6;
    case 3
        vr.dotMax = 4;
        vr.dotMin = 4;
    otherwise
        error('Cannot process initIntGraded');
end
if vr.cuePos <= 2
    vr.numWhite = randi([0 vr.dotMax],1);
    if vr.numWhite == 4 && randi([0 1],1)
        vr.numWhite = randi([0 3],1);
    end        
else
    vr.numWhite = randi([vr.dotMin 8],1);
    if vr.numWhite == 4 && randi([0 1],1)
        vr.numWhite = randi([5 8],1);
    end 
end
vr.whiteDots = sort(randsample(8,vr.numWhite)); %generate which segments will be white

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
        vr.itiDur = vr.itiMiss;
        vr.trialResults(1,size(vr.trialResults,2)+1) = 0;
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
    vr.trialResults(4,end) = vr.intGraded;
else
    vr.isReward = 0;
end

%update flashing visibility
mazeReg = find(vr.position(2) >= vr.ranges,1,'last');
if isempty(mazeReg) || mazeReg == length(vr.ranges)
    vr.worlds{1}.surface.visible(vr.LeftWallDelay(1):vr.LeftWallDelay(2)) = 1;
    vr.worlds{1}.surface.visible(vr.RightWallDelay(1):vr.RightWallDelay(2)) = 1;
    vr.worlds{1}.surface.visible(vr.RightWallWhite(1):vr.RightWallWhite(2)) = 0;
    vr.worlds{1}.surface.visible(vr.RightWallBlack(1):vr.RightWallBlack(2)) = 0;
    vr.worlds{1}.surface.visible(vr.LeftWallWhite(1):vr.LeftWallWhite(2)) = 0;
    vr.worlds{1}.surface.visible(vr.LeftWallBlack(1):vr.LeftWallBlack(2)) = 0;
else
    greyCutoff(1) = (vr.ranges(mazeReg)+(vr.totIntLength/(2*vr.numSeg)))/vr.mazeLength;
    greyCutoff(2) = vr.ranges(mazeReg+1)/vr.mazeLength;
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
    vr.worlds{1}.surface.visible(:) = 0;
    
    if vr.cellWrite
        [dataStruct] = createSaveStruct(vr.mouseNum,vr.experimenter,...
            vr.conds,vr.whiteMazes,vr.leftMazes,vr.mazeName,vr.cuePos,vr.leftMazes(vr.cuePos),...
            vr.whiteMazes(vr.cuePos),vr.isReward,vr.itiCorrect,vr.itiMiss,vr.isReward ~= 0,vr.leftMazes(vr.cuePos)==(vr.isReward~=0),...
            vr.whiteMazes(vr.cuePos)==(vr.isReward~=0),vr.streak,vr.trialStartTime,rem(now,1),...
            vr.startTime,'greyFac',vr.greyFac,'numRewPer',vr.numRewPer,'whiteDots',vr.whiteDots,...
            'numWhite',vr.numWhite,'intGraded',vr.intGraded); %#ok<NASGU>
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
        
        %perform adaptation
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
                vr.worlds{1}.surface.visible(vr.LeftWallBlack(1) + ceil((1-vr.greyFac)*(vr.LeftWallBlack(2)-vr.LeftWallBlack(1))):vr.LeftWallBlack(2)) = 0;
                vr.worlds{1}.surface.visible(vr.RightWallBlack(1) + ceil((1-vr.greyFac)*(vr.RightWallBlack(2)-vr.RightWallBlack(1))):vr.RightWallBlack(2)) = 0;
                vr.worlds{1}.surface.visible(vr.LeftWallDelay(1) + ceil((1-vr.greyFac)*(vr.LeftWallDelay(2)-vr.LeftWallDelay(1))):vr.LeftWallDelay(2)) = 1;
                vr.worlds{1}.surface.visible(vr.RightWallDelay(1) + ceil((1-vr.greyFac)*(vr.RightWallDelay(2)-vr.RightWallDelay(1))):vr.RightWallDelay(2)) = 1;
            case 2
                vr.worlds{1}.surface.visible(vr.blackRightOn) = 1;
                vr.worlds{1}.surface.visible(vr.LeftWallBlack(1) + ceil((1-vr.greyFac)*(vr.LeftWallBlack(2)-vr.LeftWallBlack(1))):vr.LeftWallBlack(2)) = 0;
                vr.worlds{1}.surface.visible(vr.RightWallBlack(1) + ceil((1-vr.greyFac)*(vr.RightWallBlack(2)-vr.RightWallBlack(1))):vr.RightWallBlack(2)) = 0;
                vr.worlds{1}.surface.visible(vr.LeftWallDelay(1) + ceil((1-vr.greyFac)*(vr.LeftWallDelay(2)-vr.LeftWallDelay(1))):vr.LeftWallDelay(2)) = 1;
                vr.worlds{1}.surface.visible(vr.RightWallDelay(1) + ceil((1-vr.greyFac)*(vr.RightWallDelay(2)-vr.RightWallDelay(1))):vr.RightWallDelay(2)) = 1;
            case 3
                vr.worlds{1}.surface.visible(vr.whiteLeftOn) = 1;
                vr.worlds{1}.surface.visible(vr.LeftWallWhite(1) + ceil((1-vr.greyFac)*(vr.LeftWallWhite(2)-vr.LeftWallWhite(1))):vr.LeftWallWhite(2)) = 0;
                vr.worlds{1}.surface.visible(vr.RightWallWhite(1) + ceil((1-vr.greyFac)*(vr.RightWallWhite(2)-vr.RightWallWhite(1))):vr.RightWallWhite(2)) = 0;
                vr.worlds{1}.surface.visible(vr.LeftWallDelay(1) + ceil((1-vr.greyFac)*(vr.LeftWallDelay(2)-vr.LeftWallDelay(1))):vr.LeftWallDelay(2)) = 1;
                vr.worlds{1}.surface.visible(vr.RightWallDelay(1) + ceil((1-vr.greyFac)*(vr.RightWallDelay(2)-vr.RightWallDelay(1))):vr.RightWallDelay(2)) = 1;
            case 4
                vr.worlds{1}.surface.visible(vr.whiteRightOn) = 1;
                vr.worlds{1}.surface.visible(vr.LeftWallWhite(1) + ceil((1-vr.greyFac)*(vr.LeftWallWhite(2)-vr.LeftWallWhite(1))):vr.LeftWallWhite(2)) = 0;
                vr.worlds{1}.surface.visible(vr.RightWallWhite(1) + ceil((1-vr.greyFac)*(vr.RightWallWhite(2)-vr.RightWallWhite(1))):vr.RightWallWhite(2)) = 0;
                vr.worlds{1}.surface.visible(vr.LeftWallDelay(1) + ceil((1-vr.greyFac)*(vr.LeftWallDelay(2)-vr.LeftWallDelay(1))):vr.LeftWallDelay(2)) = 1;
                vr.worlds{1}.surface.visible(vr.RightWallDelay(1) + ceil((1-vr.greyFac)*(vr.RightWallDelay(2)-vr.RightWallDelay(1))):vr.RightWallDelay(2)) = 1;
            otherwise
                error('No World');
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
        
        %update integration
        switch vr.intGraded
            case 0
                vr.dotMax = 0;
                vr.dotMin = 8;
            case 1
                vr.dotMax = 1;
                vr.dotMin = 7;
            case 2
                vr.dotMax = 2;
                vr.dotMin = 6;
            case 3
                vr.dotMax = 4;
                vr.dotMin = 4;
            otherwise
                error('Cannot process initIntGraded');
        end
        if vr.cuePos <= 2
            vr.numWhite = randi([0 vr.dotMax],1);
            if vr.numWhite == 4 && randi([0 1],1)
                vr.numWhite = randi([0 3],1);
            end
        else
            vr.numWhite = randi([vr.dotMin 8],1);
            if vr.numWhite == 4 && randi([0 1],1) %normalize overrepresentation of fours
                vr.numWhite = randi([5 8],1);
            end
        end
        vr.whiteDots = sort(randsample(8,vr.numWhite)); %generate which segments will be white
        
        vr.position = vr.worlds{1}.startLocation;
        
        vr.dp = 0; %prevents movement
        vr.trialStartTime = rem(now,1);
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

fwrite(vr.fid,[rem(now,1) vr.position([1:2,4]) vr.velocity(1:2) vr.cuePos vr.isReward vr.inITI vr.greyFac],'float');


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
commonTerminationVIRMEN(vr);