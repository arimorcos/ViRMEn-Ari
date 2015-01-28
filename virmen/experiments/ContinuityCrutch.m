function code = ContinuityCrutch
% ContinuityCrutch   Code for the ViRMEn experiment ContinuityCrutch.
%   code = ContinuityCrutch   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT


% --- INITIALIZATION code: executes before the ViRMEN engine starts.
function vr = initializationCodeFun(vr)

vr.debugMode = false;

vr.mouseNum = 151;
vr.numRewPer = 1;

%crutch
vr.alternateCrutch = true;
vr.probCrutch = 0.2; %probability of a single tower crutch trial

vr.adaptive = true;
vr.adapSpeed = 20; %number of trials over which to perform adaptive

%initialize important cell information
vr.conds = {'Black Left','Black Right','White Left','White Right'};

vr = initializePathVIRMEN(vr);

%Initialize
vr.numLeftTurns = 0;
vr.numBlackTurns = 0;
vr.netCount = 0;
vr.crutchTrial = false;
vr.trialTicFlag = true;

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

%Define groups for mazes
beginBlack = [vr.LeftWallBlack(1):vr.LeftWallBlack(2) vr.RightWallBlack(1):vr.RightWallBlack(2)];
beginWhite = [vr.LeftWallWhite(1):vr.LeftWallWhite(2) vr.RightWallWhite(1):vr.RightWallWhite(2)];
whiteLeft = [vr.RightArmWallBlack(1):vr.RightArmWallBlack(2) vr.RightEndWallBlack(1):vr.RightEndWallBlack(2)...
    vr.TTopWallRightBlack(1):vr.TTopWallRightBlack(2) vr.LeftArmWallWhite(1):vr.LeftArmWallWhite(2)...
    vr.LeftEndWallWhite(1):vr.LeftEndWallWhite(2) vr.TTopWallLeftWhite(1):vr.TTopWallLeftWhite(2)];
whiteRight = [vr.RightArmWallWhite(1):vr.RightArmWallWhite(2) vr.RightEndWallWhite(1):vr.RightEndWallWhite(2)...
    vr.TTopWallRightWhite(1):vr.TTopWallRightWhite(2) vr.LeftArmWallBlack(1):vr.LeftArmWallBlack(2)...
    vr.LeftEndWallBlack(1):vr.LeftEndWallBlack(2) vr.TTopWallLeftBlack(1):vr.TTopWallLeftBlack(2)];
backBlack = vr.BackWallBlack(1):vr.BackWallBlack(2);
backWhite = vr.BackWallWhite(1):vr.BackWallWhite(2);

vr.blackLeft = [beginBlack whiteRight backBlack vr.blackLeftTower(1):vr.blackLeftTower(2) vr.whiteRightTower(1):vr.whiteRightTower(2)];
vr.blackRight = [beginBlack whiteLeft backBlack vr.blackRightTower(1):vr.blackRightTower(2) vr.whiteLeftTower(1):vr.whiteLeftTower(2)];
vr.whiteLeft = [beginWhite whiteLeft backWhite vr.whiteLeftTower(1):vr.whiteLeftTower(2) vr.blackRightTower(1):vr.blackRightTower(2)];
vr.whiteRight = [beginWhite whiteRight backWhite vr.whiteRightTower(1):vr.whiteRightTower(2) vr.blackLeftTower(1):vr.blackLeftTower(2)];

vr.blackLeftCrutch = [beginBlack whiteRight backBlack vr.blackLeftTower(1):vr.blackLeftTower(2)];
vr.blackRightCrutch = [beginBlack whiteLeft backBlack vr.blackRightTower(1):vr.blackRightTower(2)];
vr.whiteLeftCrutch = [beginWhite whiteLeft backWhite vr.whiteLeftTower(1):vr.whiteLeftTower(2)];
vr.whiteRightCrutch = [beginWhite whiteRight backWhite vr.whiteRightTower(1):vr.whiteRightTower(2)];

vr.cuePos = randi(4);
vr.worlds{1}.surface.visible(:) = 0;
switch vr.cuePos
    case 1
        vr.worlds{1}.surface.visible(vr.blackLeft) = 1;
    case 2
        vr.worlds{1}.surface.visible(vr.blackRight) = 1;
    case 3
        vr.worlds{1}.surface.visible(vr.whiteLeft) = 1;
    case 4
        vr.worlds{1}.surface.visible(vr.whiteRight) = 1;
    otherwise
        error('No World');
end

%initalize pClampWrite
vr = writeToPClamp(vr,true);

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

%write to pclamp
vr = writeToPClamp(vr,false);

if vr.inITI == 0 && abs(vr.position(1)) > eval(vr.exper.variables.armLength)/vr.armFac &&...
        vr.position(2) > eval(vr.exper.variables.MazeLengthAhead)
    if vr.position(1) < 0 && ismember(vr.cuePos,[1 3])
        vr = giveReward(vr,vr.numRewPer);
        
        vr.itiDur = vr.itiCorrect;
        vr.numRewards = vr.numRewards + 1;
        vr.trialResults(1,size(vr.trialResults,2)+1) = 1;
        vr.streak = vr.streak + 1;
        if ~vr.crutchTrial
            vr.netCount = vr.netCount + 1;
        end
        vr.missFlag = false;
    elseif  vr.position(1) > 0 && ismember(vr.cuePos,[2 4])
        vr = giveReward(vr,vr.numRewPer);
        
        vr.itiDur = vr.itiCorrect;
        vr.numRewards = vr.numRewards + 1;
        vr.trialResults(1,size(vr.trialResults,2)+1) = 1;
        vr.streak = vr.streak + 1;
        if ~vr.crutchTrial
            vr.netCount = vr.netCount + 1;
        end
        vr.missFlag = false;
    else
        vr.itiDur = vr.itiMiss;
        vr.isReward = 0;
        vr.trialResults(1,size(vr.trialResults,2)+1) = 0;
        vr.missFlag = true;
        vr.streak = 0;
        if ~vr.crutchTrial
            vr.netCount = vr.netCount - 1;
        end
    end
    
    vr.worlds{1}.surface.visible(:) = 0;
    vr.itiStartTime = tic;
    vr.inITI = 1;
    vr.numTrials = vr.numTrials + 1;
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
    vr.trialResults(4,end) = vr.crutchTrial; %fifth row is whether or not a crutch trial is present
    
else
    vr.isReward = 0;
end

%Set trialsStart tic (must be in runtime so that tic doesn't start long
%before session actually starts
if vr.trialTicFlag
    vr.trialsStart = tic;
    vr.trialTicFlag = false;
end

if vr.inITI == 1
    vr.itiTime = toc(vr.itiStartTime);
    
    if vr.cellWrite
        [dataStruct] = createSaveStruct(vr.mouseNum,vr.experimenter,...
            vr.conds,vr.whiteMazes,vr.leftMazes,vr.mazeName,vr.cuePos,vr.leftMazes(vr.cuePos),...
            vr.whiteMazes(vr.cuePos),vr.isReward,vr.itiCorrect,vr.itiMiss,vr.isReward ~= 0,vr.leftMazes(vr.cuePos)==(vr.isReward~=0),...
            vr.whiteMazes(vr.cuePos)==(vr.isReward~=0),vr.streak,vr.trialStartTime,rem(now,1),...
            vr.startTime,'numRewPer',vr.numRewPer,'crutchTrial',vr.crutchTrial); %#ok<NASGU>
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
        if vr.adaptive
            nonCrutchTrials = vr.trialResults(:,vr.trialResults(4,:)==0);
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
        else
            vr.cuePos = randi(4);
        end
        
        
        if vr.alternateCrutch
            vr.crutchTrial = ~vr.crutchTrial;
        else
            randCrutch = rand;
            if randCrutch > vr.probCrutch
                vr.crutchTrial = false;
            else
                vr.crutchTrial = true;
            end
        end
        
        vr.worlds{1}.surface.visible(:) = 0;
        if ~vr.crutchTrial %if not a crutch trial
            switch vr.cuePos
                case 1
                    vr.worlds{1}.surface.visible(vr.blackLeft) = 1;
                case 2
                    vr.worlds{1}.surface.visible(vr.blackRight) = 1;
                case 3
                    vr.worlds{1}.surface.visible(vr.whiteLeft) = 1;
                case 4
                    vr.worlds{1}.surface.visible(vr.whiteRight) = 1;
                otherwise
                    error('No World');
            end
        else
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

fwrite(vr.fid,[rem(now,1) vr.position([1:2,4]) vr.velocity(1:2) vr.cuePos vr.isReward vr.inITI],'float');


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
commonTerminationVIRMEN(vr);