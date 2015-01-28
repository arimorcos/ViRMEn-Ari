function code = Maze7_Spatial_Discrete_Crutch
% Maze7_Spatial_Discrete_Crutch   Code for the ViRMEn experiment Maze7_Spatial_Discrete_Crutch.
%   code = Maze7_Spatial_Discrete_Crutch   Returns handles to the functions that ViRMEn
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
vr.rewSize = 1; %num pulses per reward
vr.adaptive = true;
vr.adapSpeed = 20; %number of trials over which to perform adaptive

%single tower crutch
vr.alternateCrutch = false; %should crutch trials alternate w/ non-crutch? If false, use probCrutch to determine
vr.probCrutch = 0; %probability of a single tower crutch trial
vr.crutchIdentity = 'NonDiscreteWallsWhiteEndGrey'; %identity of crutch trial

%discrete control
vr.condProbs(1,:) = [1 0 0 0];
vr.condProbs(2,:) = [0.7 0.3 0 0];
vr.condProbs(3,:) = [0.7 0.3 0 0]; %condition probabilities for the up to 1-3 condition. Must add up to 1
vr.condProbs(4,:) = [1/4 1/4 1/4 1/4]; %condition probabilities for the all condition. Must add up to 1
vr.intGraded = 3; %0 - only 0-6, 1 - up to 1-5, 2- up to 2-4 3 - all
vr.numSeg = 6;
vr.greyRat = 3/8; %goes from 0 to 1 to signify percentage of each segment which is gray. Must be related to number of textures greyRat*((intLength/mazeLength)*numText)/numSeg must be an integer
vr.flashOffset = 0;

%Delay control
vr.greyFac = 5/53; %goes from 0 to 1 to signify the amount of maze which is grey
vr.numRewPer = 1;

%initialize important cell information
vr.conds = {'Dots Left', 'Dots Right'};

vr = initializePathVIRMEN(vr);

%initialize parameters
vr.crutchTrial = false;
vr.mazeLength = eval(vr.exper.variables.mazeLengthAhead);
vr.totIntLength = vr.mazeLength*(1-vr.greyFac);
vr.ranges = linspace(0,vr.totIntLength,vr.numSeg+1);

%Define indices of walls
vr.leftDots = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.leftDots,:);
vr.rightDots = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.rightDots,:);
vr.leftGrey = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.leftGrey,:);
vr.rightGrey = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.rightGrey,:);
vr.backWall = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.backWall,:);
vr.endLeftGrey = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.endLeftGrey,:);
vr.endRightGrey = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.endRightGrey,:);
vr.endLeftDots = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.endLeftDots,:);
vr.endRightDots = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.endRightDots,:);
vr.endTowerLeft = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.endTowerLeft,:);
vr.endTowerRight = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.endTowerRight,:);
vr.behindWalls = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.behindWalls,:);

vr.allGrey = [vr.leftGrey(1):vr.leftGrey(2) vr.rightGrey(1):vr.rightGrey(2) ...
    vr.backWall(1):vr.backWall(2) vr.endLeftGrey(1):vr.endLeftGrey(2) ...
    vr.endRightGrey(1):vr.endRightGrey(2) vr.endTowerLeft(1):vr.endTowerLeft(2),...
    vr.endTowerRight(1):vr.endTowerRight(2) vr.behindWalls(1):vr.behindWalls(2)];

vr.dotsLeftCrutch = [vr.leftDots(1):vr.leftDots(2) vr.rightGrey(1):vr.rightGrey(2) ...
    vr.backWall(1):vr.backWall(2) vr.endLeftGrey(1):vr.endLeftGrey(2) ...
    vr.endRightGrey(1):vr.endRightGrey(2) vr.endTowerLeft(1):vr.endTowerLeft(2),...
    vr.endTowerRight(1):vr.endTowerRight(2) vr.behindWalls(1):vr.behindWalls(2)];
vr.dotsRightCrutch = [vr.rightDots(1):vr.rightDots(2) vr.leftGrey(1):vr.leftGrey(2) ...
    vr.backWall(1):vr.backWall(2) vr.endRightGrey(1):vr.endRightGrey(2) ...
    vr.endLeftGrey(1):vr.endLeftGrey(2) vr.endTowerRight(1):vr.endTowerRight(2),...
    vr.endTowerLeft(1):vr.endTowerLeft(2) vr.behindWalls(1):vr.behindWalls(2)];

vr.worlds{1}.surface.visible(:) = 0;
vr.cuePos = randi(2);
if vr.cuePos == 1
    vr.currentCueWorld = 1;
    vr.worlds{1}.surface.visible(vr.allGrey) = 1;
elseif vr.cuePos == 2
    vr.currentCueWorld = 2;
    vr.worlds{1}.surface.visible(vr.allGrey) = 1;
else
    error('No World');
end

if vr.cuePos == 1
    vr.numLeft = randsample((vr.numSeg/2):vr.numSeg,1,true,fliplr(vr.condProbs(vr.intGraded+1,:)));
else
    vr.numLeft = randsample(0:(vr.numSeg/2),1,true,vr.condProbs(vr.intGraded+1,:));
end
vr.leftDotLoc = sort(randsample(vr.numSeg,vr.numLeft)); %generate which segments will be white

vr.numLeftTurn = 0;

%initalize pClampWrite
vr = writeToPClamp(vr,true);

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

%write to pclamp
vr = writeToPClamp(vr,false);

if vr.inITI == 0 && abs(vr.position(1)) > eval(vr.exper.variables.armLength)/vr.armFac &&...
        vr.position(2) > eval(vr.exper.variables.mazeLengthAhead)
    if vr.position(1) < 0 && vr.cuePos == 1
        vr = giveReward(vr,vr.rewSize);
        vr.numRewards = vr.numRewards + 1;
        vr.itiDur = vr.itiCorrect;
        vr.streak = vr.streak + 1;
        vr.trialResults(1,size(vr.trialResults,2)+1) = 1; %first row is correct or not
    elseif  vr.position(1) > 0 && vr.cuePos == 2
        vr = giveReward(vr,vr.rewSize);
        vr.itiDur = vr.itiCorrect;
        vr.numRewards = vr.numRewards + 1;
        vr.streak = vr.streak + 1;
        vr.trialResults(1,size(vr.trialResults,2)+1) = 1; %first row is correct or not
    else
        vr.isReward = 0;
        vr.itiDur = vr.itiMiss;
        vr.streak = 0;
        vr.trialResults(1,size(vr.trialResults,2)+1) = 0; %first row is correct or not
    end
    
    if (vr.cuePos == 1 && vr.isReward ~= 0) || (vr.cuePos == 2 && vr.isReward == 0)
        vr.numLeftTurn = vr.numLeftTurn + 1;
        vr.trialResults(2,end) = 1; %2nd row is left turn
    else
         vr.trialResults(2,end) = 0;
    end
    
    vr.worlds{1}.surface.visible(:) = 0;
    vr.itiStartTime = tic;
    vr.inITI = 1;
    vr.numTrials = vr.numTrials + 1;
    vr.cellWrite = true;
else
    vr.isReward = 0;
end

disp(vr.velocity(1));
if ~vr.crutchTrial
    %update discrete visibility
    mazeReg = find((vr.position(2)+vr.flashOffset) >= vr.ranges,1,'last');
    if isempty(mazeReg) || mazeReg == length(vr.ranges) %if before a segment
        vr.worlds{1}.surface.visible(vr.leftGrey(1):vr.leftGrey(2)) = 1;
        vr.worlds{1}.surface.visible(vr.rightGrey(1):vr.rightGrey(2)) = 1;
        vr.worlds{1}.surface.visible(vr.rightDots(1):vr.rightDots(2)) = 0;
        vr.worlds{1}.surface.visible(vr.leftDots(1):vr.leftDots(2)) = 0;
    else
        greyCutoff(1) = (vr.ranges(mazeReg)+vr.greyRat*(vr.totIntLength/vr.numSeg))/vr.mazeLength;
        greyCutoff(2) = vr.ranges(mazeReg+1)/vr.mazeLength;
        %turn all early walls off
        vr.worlds{1}.surface.visible(vr.leftGrey(1):vr.leftGrey(2)) = 0;
        vr.worlds{1}.surface.visible(vr.rightGrey(1):vr.rightGrey(2)) = 0;
        vr.worlds{1}.surface.visible(vr.leftDots(1):vr.leftDots(2)) = 0;
        vr.worlds{1}.surface.visible(vr.rightDots(1):vr.rightDots(2)) = 0;
        if ismember(mazeReg,vr.leftDotLoc) %if segment should be left
            %turn left dot segment on
            vr.worlds{1}.surface.visible(vr.leftDots(1) + ceil(...
                greyCutoff(1)*(vr.leftDots(2)-vr.leftDots(1))):...
                vr.leftDots(1) + floor(...
                greyCutoff(2)*(vr.leftDots(2)-vr.leftDots(1)))) = 1;
            %turn remaining left wall on
            vr.worlds{1}.surface.visible([vr.leftGrey(1):vr.leftGrey(1) + ceil(...
                greyCutoff(1)*(vr.leftGrey(2)-vr.leftGrey(1))),...
                vr.leftGrey(1) + floor(...
                greyCutoff(2)*(vr.leftGrey(2)-vr.leftGrey(1))):vr.leftGrey(2)]) = 1;
            %turn right grey on
            vr.worlds{1}.surface.visible(vr.rightGrey(1):vr.rightGrey(2)) = 1;
        else
            %otherwise turn on right dot segment
            vr.worlds{1}.surface.visible(vr.rightDots(1) + ceil(...
                greyCutoff(1)*(vr.rightDots(2)-vr.rightDots(1))):...
                vr.rightDots(1) + floor(...
                greyCutoff(2)*(vr.rightDots(2)-vr.rightDots(1)))) = 1;
            %turn remaining right wall on
            vr.worlds{1}.surface.visible([vr.rightGrey(1):vr.rightGrey(1) + ceil(...
                greyCutoff(1)*(vr.rightGrey(2)-vr.rightGrey(1))),...
                vr.rightGrey(1) + floor(...
                greyCutoff(2)*(vr.rightGrey(2)-vr.rightGrey(1))):vr.rightGrey(2)]) = 1;
            %turn left grey on
            vr.worlds{1}.surface.visible(vr.leftGrey(1):vr.leftGrey(2)) = 1;
        end
    end
end

if vr.inITI == 1
    vr.itiTime = toc(vr.itiStartTime);
    vr.worlds{1}.surface.visible(:) = 0;
    
    if vr.cellWrite
        [dataStruct] = createSaveStruct(vr.mouseNum,vr.experimenter,...
            vr.conds,vr.whiteMazes,vr.leftMazes,vr.mazeName,vr.cuePos,vr.leftMazes(vr.cuePos),...
            1,vr.isReward,vr.itiCorrect,vr.itiMiss,vr.isReward ~= 0,vr.leftMazes(vr.cuePos)==(vr.isReward~=0),...
            1,vr.streak,vr.trialStartTime,rem(now,1),vr.startTime,'crutchTrial',vr.crutchTrial,...
            'crutchIdentity',vr.crutchIdentity,'greyFac',vr.greyFac,'numRewPer',vr.numRewPer,...
            'leftDotLoc',vr.leftDotLoc,'numLeft',vr.numLeft,'intGraded',vr.intGraded); %#ok<NASGU>
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
        if vr.adaptive
            if size(vr.trialResults,2) >= vr.adapSpeed
                vr.fracLeft = sum(vr.trialResults(2,(end-vr.adapSpeed+1):end))/vr.adapSpeed;
            else
                vr.fracLeft = sum(vr.trialResults(2,:))/size(vr.trialResults,2);
            end
            disp(vr.fracLeft);
            if vr.fracLeft < rand
                vr.cuePos = 1;
            else
                vr.cuePos = 2;
            end
        else
            vr.cuePos = randi(2);
        end
        
        %determine if crutch trial
        if vr.alternateCrutch
            vr.crutchTrial = ~vr.crutchTrial;
        else
            randCrutch = rand;
            if randCrutch > vr.probCrutch %if random number between 0 and 1 greater than crutch probability
                vr.crutchTrial = false;
            else
                vr.crutchTrial = true;
            end
        end
        
        %update cue
        vr.worlds{1}.surface.visible(:) = 0;
        if vr.cuePos == 1
            vr.currentCueWorld = 1;
            if vr.crutchTrial
                vr.worlds{1}.surface.visible(vr.dotsLeftCrutch) = 1;
            else
                vr.worlds{1}.surface.visible(vr.allGrey) = 1;
            end
        elseif vr.cuePos == 2
            vr.currentCueWorld = 2;
            if vr.crutchTrial 
                vr.worlds{1}.surface.visible(vr.dotsRightCrutch) = 1;
            else
                vr.worlds{1}.surface.visible(vr.allGrey) = 1;
            end
        else
            error('No World');
        end
        vr.position = vr.worlds{1}.startLocation;
        
        %update integration
        if vr.cuePos == 1
            vr.numLeft = randsample((vr.numSeg/2):vr.numSeg,1,true,fliplr(vr.condProbs(vr.intGraded+1,:)));
        else
            vr.numLeft = randsample(0:(vr.numSeg/2),1,true,vr.condProbs(vr.intGraded+1,:));
        end
        vr.leftDotLoc = sort(randsample(vr.numSeg,vr.numLeft)); %generate which segments will be white
        
        vr.dp = 0; %prevents movement
        vr.trialStartTime = rem(now,1);
    end
end

vr.text(1).string = ['TIME ' datestr(now-vr.startTime,'HH.MM.SS')];
vr.text(2).string = ['TRIALS ', num2str(vr.numTrials)];
vr.text(3).string = ['REWARDS ',num2str(vr.numRewards)];

fwrite(vr.fid,[rem(now,1) vr.position([1:2,4]) vr.velocity(1:2) vr.cuePos vr.isReward vr.inITI vr.greyFac],'float');


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
commonTerminationVIRMEN(vr);