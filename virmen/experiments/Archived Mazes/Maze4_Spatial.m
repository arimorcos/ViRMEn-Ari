function code = Maze4_Spatial
% Maze4_Spatial   Code for the ViRMEn experiment Maze4_Spatial.
%   code = Maze4_Spatial   Returns handles to the functions that ViRMEn
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

%initialize important cell information
vr.conds = {'Dots Left', 'Dots Right'};

vr = initializePathVIRMEN(vr);

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

vr.dotsLeft = [vr.leftDots(1):vr.leftDots(2) vr.rightGrey(1):vr.rightGrey(2) ...
    vr.backWall(1):vr.backWall(2) vr.endLeftDots(1):vr.endLeftDots(2) ...
    vr.endRightGrey(1):vr.endRightGrey(2) vr.endTowerLeft(1):vr.endTowerLeft(2)];
vr.dotsRight = [vr.rightDots(1):vr.rightDots(2) vr.leftGrey(1):vr.leftGrey(2) ...
    vr.backWall(1):vr.backWall(2) vr.endRightDots(1):vr.endRightDots(2) ...
    vr.endLeftGrey(1):vr.endLeftGrey(2) vr.endTowerRight(1):vr.endTowerRight(2)];

vr.worlds{1}.surface.visible(:) = 0;
vr.cuePos = randi(2);
if vr.cuePos == 1
    vr.currentCueWorld = 1;
    vr.worlds{1}.surface.visible(vr.dotsLeft) = 1;
elseif vr.cuePos == 2
    vr.currentCueWorld = 2;
    vr.worlds{1}.surface.visible(vr.dotsRight) = 1;
else
    error('No World');
end

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

if vr.inITI == 1
    vr.itiTime = toc(vr.itiStartTime);
    
    if vr.cellWrite
        [dataStruct] = createSaveStruct(vr.mouseNum,vr.experimenter,...
            vr.conds,vr.whiteMazes,vr.leftMazes,vr.mazeName,vr.cuePos,vr.leftMazes(vr.cuePos),...
            1,vr.isReward,vr.itiCorrect,vr.itiMiss,vr.isReward ~= 0,vr.leftMazes(vr.cuePos)==(vr.isReward~=0),...
            1,vr.streak,vr.trialStartTime,rem(now,1),vr.startTime); %#ok<NASGU>
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
        
        vr.worlds{1}.surface.visible(:) = 0;
        if vr.cuePos == 1
            vr.currentCueWorld = 1;
            vr.worlds{1}.surface.visible(vr.dotsLeft) = 1;
        elseif vr.cuePos == 2
            vr.currentCueWorld = 2;
            vr.worlds{1}.surface.visible(vr.dotsRight) = 1;
        else
            error('No World');
        end
        vr.position = vr.worlds{1}.startLocation;
        
        vr.dp = 0; %prevents movement
        vr.trialStartTime = rem(now,1);
    end
end

vr.text(1).string = ['TIME ' datestr(now-vr.startTime,'HH.MM.SS')];
vr.text(2).string = ['TRIALS ', num2str(vr.numTrials)];
vr.text(3).string = ['REWARDS ',num2str(vr.numRewards)];

fwrite(vr.fid,[rem(now,1) vr.position([1:2,4]) vr.velocity(1:2) vr.cuePos vr.isReward vr.inITI],'float');


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
commonTerminationVIRMEN(vr);