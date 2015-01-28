function code = Linear_Track_2Cond
% Linear_Track_2Cond   Code for the ViRMEn experiment Linear_Track_2Cond.
%   code = Linear_Track_2Cond   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT

% --- INITIALIZATION code: executes before the ViRMEN engine starts.
function vr = initializationCodeFun(vr)

vr.debugMode = false;
vr.mouseNum = 93;
vr.rewSize = 1; %num pulses per reward

%control lengthening
vr.extend = true;
vr.mazeLength = 50;
vr.dUnits = 10;
vr.regTimeThresh = 30; %number of seconds trial must take for length to regress
vr.advTimeThresh = 30; %number of seconds trial must be completed in for length to advance
vr.minLength = 40; %minimum maze length
vr.maxLength = eval(vr.exper.variables.mazeLengthAhead); %maximum maze length (determined by maze)

%initialize important cell information
vr.conds = {'Black','White'};

vr = initializePathVIRMEN(vr);

%Define indices of walls
vr.blackWalls = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.blackWalls,:);
vr.whiteWalls = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.whiteWalls,:);
vr.backWallsBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.backWallsBlack,:);
vr.backWallsWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.backWallsWhite,:);
vr.behindWallsBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.behindWallsBlack,:);
vr.behindWallsWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.behindWallsWhite,:);
vr.xTower = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.xTower,:);
vr.endWallX = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.endWallX,:);

%Define groups for mazes
vr.blackTrial = [vr.endWallX(1):vr.endWallX(2) vr.blackWalls(1):vr.blackWalls(2) ...
    vr.backWallsBlack(1):vr.backWallsBlack(2) vr.xTower(1):vr.xTower(2) ...
    vr.behindWallsBlack(1):vr.behindWallsBlack(2)];
vr.whiteTrial = [vr.endWallX(1):vr.endWallX(2) vr.whiteWalls(1):vr.whiteWalls(2) ...
    vr.backWallsWhite(1):vr.backWallsWhite(2) vr.xTower(1):vr.xTower(2) ...
    vr.behindWallsWhite(1):vr.behindWallsWhite(2)];

%get edge indices
vr.backWallInd = [vr.worlds{1}.objects.indices.backWallsBlack ...
    vr.worlds{1}.objects.indices.backWallsWhite];
vertStartStop = vr.worlds{1}.objects.vertices(vr.backWallInd,:);
edgeIndStartStop = vr.worlds{1}.objects.edges(vr.backWallInd,:);
vr.backWallsVert = [];
vr.backWallsEdgeInd = [];
for i=1:size(vertStartStop,1)
    vr.backWallsVert = [vr.backWallsVert vertStartStop(i,1):vertStartStop(i,2)];
    vr.backWallsEdgeInd = [vr.backWallsEdgeInd edgeIndStartStop(i,1):edgeIndStartStop(i,2)];
end
vr.backWallsEdgeInd(vr.backWallsEdgeInd==0) = []; %remove zeros
vr.backWallsOriginalYPos = vr.worlds{1}.surface.vertices(2,vr.backWallsVert);
vr.backWallsOriginalEndpoints = vr.worlds{1}.edges.endpoints(vr.backWallsEdgeInd,[2 4]);

%get original start location
vr.originalStart = vr.worlds{1}.startLocation;

%move walls and start location
vr.worlds{1}.surface.vertices(2,vr.backWallsVert) =...
    vr.backWallsOriginalYPos + (vr.maxLength - vr.mazeLength); %move walls
vr.worlds{1}.edges.endpoints(vr.backWallsEdgeInd,[2 4]) = ...
    vr.backWallsOriginalEndpoints + (vr.maxLength - vr.mazeLength); %move edges

tempStart = vr.originalStart;
tempStart(2) = tempStart(2) + (vr.maxLength - vr.mazeLength);
vr.position = tempStart;


vr.worlds{1}.surface.visible(:) = 0;
vr.cuePos = randi(2);
if vr.cuePos == 1
    vr.currentCueWorld = 1;
    vr.worlds{1}.surface.visible(vr.blackTrial) = 1;
elseif vr.cuePos == 2
    vr.currentCueWorld = 2;
    vr.worlds{1}.surface.visible(vr.whiteTrial) = 1;
else
    error('No World');
end
vr.trialStart = tic;

%initalize pClampWrite
vr = writeToPClamp(vr,true);

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

%write to pclamp
vr = writeToPClamp(vr,false);

if vr.inITI == 0 && vr.position(2) > 0.9*eval(vr.exper.variables.mazeLengthAhead)
    %give reward and mark as correct trial
    vr = giveReward(vr,vr.rewSize);
    vr.itiDur = vr.itiCorrect;
    vr.numRewards = vr.numRewards + 1;
    vr.streak = vr.streak + 1;
    
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
            vr.whiteMazes(vr.cuePos),vr.isReward,vr.itiCorrect,vr.itiMiss,vr.isReward ~= 0,vr.leftMazes(vr.cuePos)==(vr.isReward~=0),...
            vr.whiteMazes(vr.cuePos)==(vr.isReward~=0),vr.streak,vr.trialStartTime,rem(now,1),vr.startTime,...
            'mazeLength',vr.mazeLength); %#ok<NASGU>
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
        
        %update length
        if vr.extend
            trialTime = toc(vr.trialStart);
            if trialTime >= vr.regTimeThresh %if trial took too long
                vr.mazeLength = vr.mazeLength - vr.dUnits;
            elseif trialTime <= vr.advTimeThresh
                vr.mazeLength = vr.mazeLength + vr.dUnits;
            end
            
            vr.mazeLength = max(vr.mazeLength,vr.minLength); %make sure maze length doesn't go below min
            vr.mazeLength = min(vr.mazeLength,vr.maxLength); %make sure maze length doesn't go above max
                
        end
        
        %generate new trial
        vr.cuePos = randi(2);
        if vr.cuePos == 1
            vr.currentCueWorld = 1;
            vr.worlds{1}.surface.visible(vr.blackTrial) = 1;
        elseif vr.cuePos == 2
            vr.currentCueWorld = 2;
            vr.worlds{1}.surface.visible(vr.whiteTrial) = 1;
        else
            error('No World');
        end
        
        %move walls and start location
        vr.worlds{1}.surface.vertices(2,vr.backWallsVert) =...
            vr.backWallsOriginalYPos + (vr.maxLength - vr.mazeLength); %move walls
        vr.worlds{1}.edges.endpoints(vr.backWallsEdgeInd,[2 4]) = ...
            vr.backWallsOriginalEndpoints + (vr.maxLength - vr.mazeLength); %move edges
        
        tempStart = vr.originalStart;
        tempStart(2) = tempStart(2) + (vr.maxLength - vr.mazeLength);
        vr.position = tempStart;
        
        vr.dp = 0; %prevents movement
        vr.trialStartTime = rem(now,1);
        vr.trialStart = tic;
    end
end

vr.text(1).string = ['TIME ' datestr(now-vr.startTime,'HH.MM.SS')];
vr.text(2).string = ['TRIALS ', num2str(vr.numTrials)];
vr.text(3).string = ['LENGTH ',num2str(vr.mazeLength)];

fwrite(vr.fid,[rem(now,1) vr.position([1:2,4]) vr.velocity(1:2) vr.cuePos vr.isReward vr.inITI vr.mazeLength],'float');


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
commonTerminationVIRMEN(vr);