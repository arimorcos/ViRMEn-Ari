function code = Maze10_Spatial_Discrete_100Delay_cutTurn
% Maze10_Spatial_Discrete_100Delay_cutTurn   Code for the ViRMEn experiment Maze10_Spatial_Discrete_100Delay_cutTurn.
%   code = Maze10_Spatial_Discrete_100Delay_cutTurn   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT

% --- INITIALIZATION code: executes before the ViRMEN engine starts.
function vr = initializationCodeFun(vr)

vr.debugMode = false;
vr.mouseNum = 81;
vr.rewSize = 1; %num pulses per reward
vr.adaptive = true;
vr.adapSpeed = 20; %number of trials over which to perform adaptive
vr.intGraded = 0; %0 - only 0-6, 1 - up to 1-5, 2- up to 2-4 3 - all

%discrete control
vr.condProbs(1,:) = [1 0 0 0];
vr.condProbs(2,:) = [1/2 1/2 0 0];
vr.condProbs(3,:) = [1/3 1/3 1/3 0]; %condition probabilities for the up to 1-3 condition. Must add up to 1
vr.condProbs(4,:) = [2/7 2/7 2/7 1/7]; %condition probabilities for the all condition. Must add up to 1
vr.numSeg = 6;
vr.greyRat = 3/8; %goes from 0 to 1 to signify percentage of each segment which is gray. Must be related to number of textures greyRat*((intLength/mazeLength)*numText)/numSeg must be an integer
vr.flashOffset = 0;

%single tower crutch
vr.alternateCrutch = false; %should crutch trials alternate w/ non-crutch? If false, use probCrutch to determine
vr.adaptiveCrutch = true; %should crutch trials be set to %incorrect
vr.probCrutch = 0.3; %probability of a single tower crutch trial
vr.maxCrutch = 0.6;
vr.crutchIdentity = 'NonDiscreteWallsWhiteEndGreyNoDelay'; %identity of crutch trial

%primary delay control
vr.delay = 100; %number of units for delay to start at

%extending delay control
vr.extendDelay = false; %should delay extend?
vr.extThresh = 0.8; %fraction correct (overall) threshold for delay to extend
vr.shrinkThresh = 0.5; %fraction correct (overall) threshold for delay to shrink
vr.extWin = 5; %window over which to calculate fraction correct for extension
vr.extTimeOut = 6; %minimum number of trials between change of delay
vr.dUnits = 10; %number of units for delay to grow/shrink by
vr.maxDelay = 200; %maximum delay (in units);
vr.delayWallMaxLength = 300; %maximum delay wall length
vr.minDelay = 50; %minimum delay (in units);

%Delay control (secondary)
vr.greyFac = 0/48; %goes from 0 to 1 to signify the amount of maze which is grey
vr.numRewPer = 1;

%initialize important cell information
vr.conds = {'Dots Left', 'Dots Right'};

vr = initializePathVIRMEN(vr);

%initialize parameters
vr.crutchTrial = false;
vr.mazeLength = eval(vr.exper.variables.mazeLengthAhead);
vr.totIntLength = vr.mazeLength*(1-vr.greyFac);
vr.ranges = linspace(0,vr.totIntLength,vr.numSeg+1);
vr.extCounter = 1;

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
vr.delayWalls = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.delayWalls,:);
vr.leftCutWall = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.leftCutWall,:);
vr.rightCutWall = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.rightCutWall,:);
vr.leftCutDots = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.leftCutDots,:);
vr.rightCutDots = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.rightCutDots,:);

vr.allGrey = [vr.leftGrey(1):vr.leftGrey(2) vr.rightGrey(1):vr.rightGrey(2) ...
    vr.backWall(1):vr.backWall(2) vr.endLeftGrey(1):vr.endLeftGrey(2) ...
    vr.endRightGrey(1):vr.endRightGrey(2) vr.endTowerLeft(1):vr.endTowerLeft(2)...
    vr.endTowerRight(1):vr.endTowerRight(2) vr.behindWalls(1):vr.behindWalls(2) ...
    vr.leftCutWall(1):vr.leftCutWall(2) vr.rightCutWall(1):vr.rightCutWall(2)];

vr.dotsLeftCrutch = [vr.leftDots(1):vr.leftDots(2) vr.rightGrey(1):vr.rightGrey(2) ...
    vr.backWall(1):vr.backWall(2) vr.endLeftGrey(1):vr.endLeftGrey(2) ...
    vr.endRightGrey(1):vr.endRightGrey(2) vr.endTowerLeft(1):vr.endTowerLeft(2),...
    vr.endTowerRight(1):vr.endTowerRight(2) vr.behindWalls(1):vr.behindWalls(2) ...
    vr.rightCutWall(1):vr.rightCutWall(2) vr.leftCutDots(1):vr.leftCutDots(2)];
vr.dotsRightCrutch = [vr.rightDots(1):vr.rightDots(2) vr.leftGrey(1):vr.leftGrey(2) ...
    vr.backWall(1):vr.backWall(2) vr.endRightGrey(1):vr.endRightGrey(2) ...
    vr.endLeftGrey(1):vr.endLeftGrey(2) vr.endTowerRight(1):vr.endTowerRight(2),...
    vr.endTowerLeft(1):vr.endTowerLeft(2) vr.behindWalls(1):vr.behindWalls(2) ...
    vr.leftCutWall(1):vr.leftCutWall(2) vr.rightCutDots(1):vr.rightCutDots(2)];

%define edgeIndices
vr.delayEdgeInd = vr.worlds{1}.objects.edges(vr.worlds{1}.objects.indices.delayWalls,:);
% vr.leftCutEdgeInd = vr.worlds{1}.objects.edges(vr.worlds{1}.objects.indices.leftCutWall,:);
% vr.rightCutEdgeInd = vr.worlds{1}.objects.edges(vr.worlds{1}.objects.indices.rightCutWall,:);

%get original locations for endWalls and towers
vr.endWallsTowersInd = [vr.worlds{1}.objects.indices.endLeftGrey ...
    vr.worlds{1}.objects.indices.endRightGrey vr.worlds{1}.objects.indices.endLeftDots ...
    vr.worlds{1}.objects.indices.endRightDots vr.worlds{1}.objects.indices.endTowerLeft ...
    vr.worlds{1}.objects.indices.endTowerRight vr.worlds{1}.objects.indices.leftCutWall ...
    vr.worlds{1}.objects.indices.rightCutWall];
vertStartStop = vr.worlds{1}.objects.vertices(vr.endWallsTowersInd,:);
edgeIndStartStop = vr.worlds{1}.objects.edges(vr.endWallsTowersInd,:);
vr.endWallsTowersVert = [];
vr.endWallsTowersEdgeInd = [];
for i=1:size(vertStartStop,1)
    vr.endWallsTowersVert = [vr.endWallsTowersVert vertStartStop(i,1):vertStartStop(i,2)];
    vr.endWallsTowersEdgeInd = [vr.endWallsTowersEdgeInd edgeIndStartStop(i,1):edgeIndStartStop(i,2)];
end
vr.endWallsTowersEdgeInd(vr.endWallsTowersEdgeInd==0) = []; %remove zeros
vr.endWallsTowerOriginalYPos = vr.worlds{1}.surface.vertices(2,vr.endWallsTowersVert);
vr.endWallsTowerOriginalEndpoints = vr.worlds{1}.edges.endpoints(vr.endWallsTowersEdgeInd,[2 4]);

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

%update delayWalls
if ~vr.crutchTrial %if not crutch trial
    visDelayTrianglesLeft = vr.delayWalls(1):vr.delayWalls(1) + floor(...
        (vr.delay/vr.delayWallMaxLength)*0.5*(vr.delayWalls(2) - vr.delayWalls(1)));
    visDelayTrianglesRight = vr.delayWalls(1) + ceil(0.5*(vr.delayWalls(2) -...
        vr.delayWalls(1))):vr.delayWalls(1) + ceil(0.5*(vr.delayWalls(2) -...
        vr.delayWalls(1))) + floor((vr.delay/vr.delayWallMaxLength)*0.5*...
        (vr.delayWalls(2) - vr.delayWalls(1)));
    vr.worlds{1}.surface.visible([visDelayTrianglesLeft visDelayTrianglesRight])...
        = 1; %turn on correct proportion of delay walls
    
    %move endWalls and towers
    vr.worlds{1}.surface.vertices(2,vr.endWallsTowersVert) =...
        vr.endWallsTowerOriginalYPos + vr.delay; %move walls
    vr.worlds{1}.edges.endpoints(vr.endWallsTowersEdgeInd,[2 4]) = ...
        vr.endWallsTowerOriginalEndpoints + vr.delay; %move edges
    
    %move delay wall edge endpoints
    vr.worlds{1}.edges.endpoints(vr.delayEdgeInd,4) = ...
        vr.worlds{1}.edges.endpoints(vr.delayEdgeInd,2) + vr.delay;
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
    
    vr.trialResults(3,end) = vr.crutchTrial; %store crutch trial
    vr.trialResults(4,end) = vr.numLeft; %store numLeft    
    
    vr.worlds{1}.surface.visible(:) = 0;
    vr.itiStartTime = tic;
    vr.inITI = 1;
    vr.numTrials = vr.numTrials + 1;
    vr.cellWrite = true;
else
    vr.isReward = 0;
end

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
            'leftDotLoc',vr.leftDotLoc,'numLeft',vr.numLeft,'intGraded',vr.intGraded,...
            'delayLength',vr.delay); %#ok<NASGU>
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
            %get crutchSubset
            nonCrutchSub = vr.trialResults(:,vr.trialResults(3,:)==0);
            if size(nonCrutchSub,2) >= vr.adapSpeed
                vr.fracLeft = sum(nonCrutchSub(2,(end-vr.adapSpeed+1):end))/vr.adapSpeed;
                vr.fracCorr = sum(nonCrutchSub(1,(end-vr.adapSpeed+1):end))/vr.adapSpeed;
            else
                vr.fracLeft = sum(nonCrutchSub(2,:))/size(nonCrutchSub,2);
                vr.fracCorr = sum(nonCrutchSub(1,:))/size(nonCrutchSub,2);
            end
            if vr.fracLeft < rand
                vr.cuePos = 1;
            else
                vr.cuePos = 2;
            end
        else
            vr.cuePos = randi(2);
            nonCrutchSub = vr.trialResults(:,vr.trialResults(3,:)==0);
            vr.fracCorr = sum(nonCrutchSub(1,:))/size(nonCrutchSub,2);
        end
        
        %determine if crutch trial
        if vr.alternateCrutch
            vr.crutchTrial = ~vr.crutchTrial;
        else
            if vr.adaptiveCrutch
                vr.probCrutch = min(1 - vr.fracCorr,vr.maxCrutch);
            end
            randCrutch = rand;
            if randCrutch > vr.probCrutch %if random number between 0 and 1 greater than crutch probability
                vr.crutchTrial = false;
            else
                vr.crutchTrial = true;
            end
        end
        
        %update vr.delay
        if vr.extendDelay %if delay should extend
            
            disp(vr.delay);
            disp(vr.extCounter);
            
            if vr.extCounter >= vr.extTimeOut    %if minimum number of timeout trials exceeded

                %get subset of trials in which only 5-1 and 6-0 conditions
                %present
                nonCrutchInd = vr.trialResults(3,:) == 0;
                endpointTrialInd = ismember(vr.trialResults(4,:),[0 1 5 6]);
                trialSub = vr.trialResults(:,nonCrutchInd & endpointTrialInd);
                
                %save oldDelay
                oldDelay = vr.delay;
                
                %determine performance over extWin
                if size(trialSub,2) >= vr.extWin %if number of trials exceeds extWin
                    delayPerf = sum(trialSub(1,(end-vr.extWin+1):end))/vr.extWin;
                    if delayPerf >= vr.extThresh %if performance exceeds threshold
                        vr.delay = vr.delay + vr.dUnits; %extend delay;
                    elseif delayPerf <= vr.shrinkThresh %if performance is less than shrink threshold
                        vr.delay = vr.delay - vr.dUnits;
                    end

                    %ensure delay doesn't exceed max or min value
                    vr.delay = max(vr.delay,vr.minDelay);
                    vr.delay = min(vr.delay,vr.maxDelay);
                end
                
                %reset counter if delay changed
                if vr.delay ~= oldDelay
                    vr.extCounter = 1;
                end
                
            else
                vr.extCounter = vr.extCounter + 1;
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
        
        %update delayWalls
        if ~vr.crutchTrial %if not crutch trial
            visDelayTrianglesLeft = vr.delayWalls(1):vr.delayWalls(1) + floor(...
                (vr.delay/vr.delayWallMaxLength)*0.5*(vr.delayWalls(2) - vr.delayWalls(1)));
            visDelayTrianglesRight = vr.delayWalls(1) + ceil(0.5*(vr.delayWalls(2) -...
                vr.delayWalls(1))):vr.delayWalls(1) + ceil(0.5*(vr.delayWalls(2) -...
                vr.delayWalls(1))) + floor((vr.delay/vr.delayWallMaxLength)*0.5*...
                (vr.delayWalls(2) - vr.delayWalls(1)));
            vr.worlds{1}.surface.visible([visDelayTrianglesLeft visDelayTrianglesRight])...
                = 1; %turn on correct proportion of delay walls
            
            %move endWalls and towers
            vr.worlds{1}.surface.vertices(2,vr.endWallsTowersVert) =...
                vr.endWallsTowerOriginalYPos + vr.delay; %move walls
            vr.worlds{1}.edges.endpoints(vr.endWallsTowersEdgeInd,[2 4]) = ...
                vr.endWallsTowerOriginalEndpoints + vr.delay; %move edges
            
            %move delay wall edge endpoints
            vr.worlds{1}.edges.endpoints(vr.delayEdgeInd,4) = ...
                vr.worlds{1}.edges.endpoints(vr.delayEdgeInd,2) + vr.delay;
        else %fix positions for crutch trial
            %move endWalls and towers
            vr.worlds{1}.surface.vertices(2,vr.endWallsTowersVert) =...
                vr.endWallsTowerOriginalYPos; %move walls
            vr.worlds{1}.edges.endpoints(vr.endWallsTowersEdgeInd,[2 4]) = ...
                vr.endWallsTowerOriginalEndpoints; %move edges
            
            %move delay wall edge endpoints
            vr.worlds{1}.edges.endpoints(vr.delayEdgeInd,4) = ...
                vr.worlds{1}.edges.endpoints(vr.delayEdgeInd,2);
        end
        
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

fwrite(vr.fid,[rem(now,1) vr.position([1:2,4]) vr.velocity(1:2) vr.cuePos vr.isReward vr.inITI vr.delay],'float');


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
commonTerminationVIRMEN(vr);