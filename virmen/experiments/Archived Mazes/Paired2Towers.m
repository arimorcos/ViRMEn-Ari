function code = Paired2Towers
% Paired2Towers   Code for the ViRMEn experiment Paired2Towers.
%   code = Paired2Towers   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT

% --- INITIALIZATION code: executes before the ViRMEN engine starts.
function vr = initializationCodeFun(vr)

vr.debugMode = false;
vr.mouseNum = 28;

vr.mulRewards = 1;
vr.adapSpeed = 20;

%initialize important cell information
vr.conds = {'Black Left Single Tower','Black Left Two Towers','Black Right Single Tower',...
    'Black Right Two Towers','White Left Single Tower','White Left Two Towers',...
    'White Right Single Tower','White Right Two Towers'};

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
vr.whiteRightTowers = [vr.whiteRightTower(1):vr.whiteRightTower(2) vr.blackLeftTower(1):vr.blackLeftTower(2)];
vr.whiteLeftTowers = [vr.whiteLeftTower(1):vr.whiteLeftTower(2) vr.blackRightTower(1):vr.blackRightTower(2)];

vr.blackLeftTower = [beginBlack whiteRight backBlack vr.blackLeftTower(1):vr.blackLeftTower(2)];
vr.blackRightTower = [beginBlack whiteLeft backBlack vr.blackRightTower(1):vr.blackRightTower(2)];
vr.whiteLeftTower = [beginWhite whiteLeft backWhite vr.whiteLeftTower(1):vr.whiteLeftTower(2)];
vr.whiteRightTower = [beginWhite whiteRight backWhite vr.whiteRightTower(1):vr.whiteRightTower(2)];

vr.blackLeftTowers = [beginBlack whiteRight backBlack vr.whiteRightTowers];
vr.blackRightTowers = [beginBlack whiteLeft backBlack vr.whiteLeftTowers];
vr.whiteLeftTowers = [beginWhite whiteLeft backWhite vr.whiteLeftTowers];
vr.whiteRightTowers = [beginWhite whiteRight backWhite vr.whiteRightTowers];

vr.worlds{1}.surface.visible(:) = 0;
vr.currentCueWorld = 1+2*randi([0 3]);
switch vr.currentCueWorld
    case 1
        vr.worlds{1}.surface.visible(vr.blackLeftTower) = 1;
    case 3
        vr.worlds{1}.surface.visible(vr.blackRightTower) = 1;
    case 5
        vr.worlds{1}.surface.visible(vr.whiteLeftTower) = 1;
    case 7
        vr.worlds{1}.surface.visible(vr.whiteRightTower) = 1;
    otherwise
        display('No World');
        return;
end
vr.whichWorldFlag = 0;

vr.numTrialsSingleTower = 0;
vr.numTrialsTwoTowers = 0;
vr.numRewardsTwoTowers = 0;
vr.numRewardsSingleTower = 0;

%initalize pClampWrite
vr = writeToPClamp(vr,true);

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

%write to pclamp
vr = writeToPClamp(vr,false);

if vr.inITI == 0 && abs(vr.position(1)) > eval(vr.exper.variables.armLength)/vr.armFac &&...
        vr.position(2) > eval(vr.exper.variables.MazeLengthAhead)
    if vr.position(1) < 0 && ismember(vr.currentCueWorld,[1 2 5 6])
        if vr.currentCueWorld == 1 || vr.currentCueWorld == 5
            vr = giveReward(vr,1);
            vr.whichWorldFlag = vr.currentCueWorld + 1;
            vr.numRewardsSingleTower = vr.numRewardsSingleTower + 1;
        elseif vr.currentCueWorld == 2 || vr.currentCueWorld == 6
            if vr.mulRewards == 0
                vr = giveReward(vr,1);
            elseif vr.mulRewards == 1
                vr = giveReward(vr,2);
            elseif vr.mulRewards >= 2
                vr = giveReward(vr,3);
            end
            vr.whichWorldFlag = 0;
            vr.numRewardsTwoTowers = vr.numRewardsTwoTowers + 1;
        end
        vr.itiDur = vr.itiCorrect;
        vr.trialResults(1,size(vr.trialResults,2)+1) = 1;
        vr.streak = vr.streak + 1;
    elseif  vr.position(1) > 0 && ismember(vr.currentCueWorld,[3 4 7 8])
       if vr.currentCueWorld == 3 || vr.currentCueWorld == 7
            vr = giveReward(vr,1);
            vr.whichWorldFlag = vr.currentCueWorld + 1;
            vr.numRewardsSingleTower = vr.numRewardsSingleTower + 1;
        elseif vr.currentCueWorld == 4 || vr.currentCueWorld == 8
            if vr.mulRewards == 0
                vr = giveReward(vr,1);
            elseif vr.mulRewards == 1
                vr = giveReward(vr,2);
            elseif vr.mulRewards >= 2
                vr = giveReward(vr,3);
            end
            vr.whichWorldFlag = 0;
            vr.numRewardsTwoTowers = vr.numRewardsTwoTowers + 1;
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
        vr.numTrialsSingleTower = vr.numTrialsSingleTower + 1;
    elseif ismember(vr.currentCueWorld,[2 4 6 8])
        vr.numTrialsTwoTowers = vr.numTrialsTwoTowers + 1;
    end
else
    vr.isReward = 0;
end

if vr.inITI == 1
    vr.itiTime = toc(vr.itiStartTime);
    
    if vr.cellWrite
        [dataStruct] = createSaveStruct(vr.mouseNum,vr.experimenter,...
            vr.conds,vr.whiteMazes,vr.leftMazes,vr.mazeName,vr.currentCueWorld,...
            vr.leftMazes(vr.currentCueWorld),vr.whiteMazes(vr.currentCueWorld),...
            vr.isReward,vr.itiCorrect,vr.itiMiss,vr.isReward~=0,vr.leftMazes(vr.currentCueWorld)==(vr.isReward~=0),...
            vr.whiteMazes(vr.currentCueWorld)==(vr.isReward~=0),vr.streak,vr.trialStartTime,...
            rem(now,1),vr.startTime,'twoTowers',ismember(vr.currentCueWorld,[2 4 6 8])); %#ok<NASGU>
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
                vr.worlds{1}.surface.visible(vr.blackLeftTower) = 1;
            case 2
                vr.worlds{1}.surface.visible(vr.blackLeftTowers) = 1;
            case 3
                vr.worlds{1}.surface.visible(vr.blackRightTower) = 1;
            case 4
                vr.worlds{1}.surface.visible(vr.blackRightTowers) = 1;
            case 5
                vr.worlds{1}.surface.visible(vr.whiteLeftTower) = 1;
            case 6
                vr.worlds{1}.surface.visible(vr.whiteLeftTowers) = 1;
            case 7 
                vr.worlds{1}.surface.visible(vr.whiteRightTower) = 1;
            case 8
                vr.worlds{1}.surface.visible(vr.whiteRightTowers) = 1;
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
vr.text(2).string = ['TRIALSTOWER ', num2str(vr.numTrialsSingleTower)];
vr.text(3).string = ['TRIALS2TOWERS ', num2str(vr.numTrialsTwoTowers)];
vr.text(4).string = ['REWARDSTOWER ',num2str(vr.numRewardsSingleTower)];
vr.text(5).string = ['REWARDS2TOWERS ',num2str(vr.numRewardsTwoTowers)];

fwrite(vr.fid,[rem(now,1) vr.position([1:2,4]) vr.velocity(1:2) vr.currentCueWorld vr.isReward vr.inITI],'float');


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
commonTerminationVIRMEN(vr);