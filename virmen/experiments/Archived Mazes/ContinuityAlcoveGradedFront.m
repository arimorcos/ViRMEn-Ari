function code = ContinuityAlcoveGradedFront
% ContinuityAlcoveGradedFront   Code for the ViRMEn experiment ContinuityAlcoveGradedFront.
%   code = ContinuityAlcoveGradedFront   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT


% --- INITIALIZATION code: executes before the ViRMEN engine starts.

function vr = initializationCodeFun(vr)

vr.debugMode = false;
vr.moveFlag = false;
vr.mulRewards = 2;
vr.lengthFac = 1 + 0/64; % 1 is shortest distance, 2 is max
vr.maxLenFac = 1 + 26/64; %set to less than 2 to change max distance
vr.scaleFac = .96; %0 is full alcove, 1 is continuity
vr.trialThresh = 500;
vr.percThreshAdv = 1.2;

vr.forRateAlc = 0;
vr.revRateAlc = 0;

vr.forRateLen = 1/64; %must be related to number of textures on delay walls so that textures aren't split in half
vr.revRateLen = 1/64; 
vr.numTrialsReg = 1; %num consecutive incorrect trials to regress length
vr.numTrialsLenAdv = 4;
vr.lengthThresh = 0.9; %scale factor threshold for length to move

vr.midOff = -50;
vr.adapSpeed = 20; %speed at which maze adapts (number of trials over which it looks)
vr.positionOffset = 4; %offset for flashing grey segments

path = ['C:\DATA\Ari\Current Mice\AM' vr.exper.variables.mouseNumber];
tempPath = 'C:\DATA\Ari\Temporary';
if ~exist(tempPath,'dir');
    mkdir(tempPath);
end
if ~exist(path,'dir')
    mkdir(path);
end
vr.filenameTempMat = 'tempStorage.mat';
vr.filenameTempDat = 'tempStorage.dat';
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
vr.pathTempMat = [tempPath,'\',vr.filenameTempMat];
vr.pathTempDat = [tempPath,'\',vr.filenameTempDat];
vr.pathMat = [path,'\',vr.filenameMat];
vr.pathDat = [path, '\',vr.filenameDat];
save(vr.pathTempMat,'exper');
vr.fid = fopen(vr.pathTempDat,'w+');

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

%Get initial delay
vr.percGraded = 0;
vr.percEndGraded = (100-vr.percGraded)/100;
vr.trialResults = [];
vr.rewCount = 0;
vr.lengthTrialThresh = vr.numTrialsLenAdv;

%Define indices of walls
vr.LeftWallBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.LeftWallBlack,:);
vr.RightWallBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.RightWallBlack,:);
vr.RightArmWallBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.RightArmWallBlack,:);
vr.LeftArmWallBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.LeftArmWallBlack,:);
vr.LeftEndWallBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.LeftEndWallBlack,:);
vr.RightEndWallBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.RightEndWallBlack,:);
vr.TTopWallLeftBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.TTopWallLeftBlack,:);
vr.TTopWallRightBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.TTopWallRightBlack,:);
vr.LeftWallWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.LeftWallWhite,:);
vr.RightWallWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.RightWallWhite,:);
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
vr.BackWallGrey = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.BackWallGrey,:);
vr.BackWalls = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.BackWalls,:);
vr.alcWallsWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.alcWallsWhite,:);
vr.alcWallsBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.alcWallsBlack,:);
vr.alcBlock = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.alcBlock,:);

%Define groups for mazes 
% beginBlack = [vr.LeftWallBlack(1):vr.LeftWallBlack(2) vr.RightWallBlack(1):vr.RightWallBlack(2)];
% beginWhite = [vr.LeftWallWhite(1):vr.LeftWallWhite(2) vr.RightWallWhite(1):vr.RightWallWhite(2)];
vr.whiteLeft = [vr.RightArmWallBlack(1):vr.RightArmWallBlack(2) vr.RightEndWallBlack(1):vr.RightEndWallBlack(2)...
    vr.TTopWallRightBlack(1):vr.TTopWallRightBlack(2) vr.LeftArmWallWhite(1):vr.LeftArmWallWhite(2)...
    vr.LeftEndWallWhite(1):vr.LeftEndWallWhite(2) vr.TTopWallLeftWhite(1):vr.TTopWallLeftWhite(2)];
vr.whiteRight = [vr.RightArmWallWhite(1):vr.RightArmWallWhite(2) vr.RightEndWallWhite(1):vr.RightEndWallWhite(2)...
    vr.TTopWallRightWhite(1):vr.TTopWallRightWhite(2) vr.LeftArmWallBlack(1):vr.LeftArmWallBlack(2)...
    vr.LeftEndWallBlack(1):vr.LeftEndWallBlack(2) vr.TTopWallLeftBlack(1):vr.TTopWallLeftBlack(2)];
dirTower = vr.directionTowerEnd(1):vr.directionTowerEnd(2);
delayWalls = [vr.LeftWallDelay(1):vr.LeftWallDelay(2) vr.RightWallDelay(1):vr.RightWallDelay(2)];
backGrey = [vr.BackWallGrey(1):vr.BackWallGrey(2) vr.BackWalls(1):vr.BackWalls(2)];
TTopMiddle = vr.TTopMiddle(1):vr.TTopMiddle(2);

vr.alcWallsWhiteT = vr.alcWallsWhite(1):vr.alcWallsWhite(2);
vr.alcWallsBlackT = vr.alcWallsBlack(1):vr.alcWallsBlack(2);
vr.alcBlockLeft = [vr.alcBlock(1) vr.alcBlock(1)+floor(0.5*(vr.alcBlock(2)-vr.alcBlock(1)))];
vr.alcBlockRight = [vr.alcBlock(1)+ceil(0.5*(vr.alcBlock(2)-vr.alcBlock(1))) vr.alcBlock(2)];
% vr.alcBlockLeft = vr.alcBlock(1):vr.alcBlock(2);

vr.blackLeftOn = [vr.whiteRight dirTower backGrey TTopMiddle];
vr.blackLeftOff = [vr.whiteLeft delayWalls];

vr.blackRightOn = [vr.whiteLeft dirTower backGrey TTopMiddle];
vr.blackRightOff = [vr.whiteRight delayWalls];

vr.whiteLeftOn = [vr.whiteLeft dirTower backGrey TTopMiddle];  
vr.whiteLeftOff = [vr.whiteRight delayWalls];

vr.whiteRightOn = [vr.whiteRight dirTower backGrey TTopMiddle];
vr.whiteRightOff = [vr.whiteLeft delayWalls];

vr.inITI = 0;
vr.isReward = 0;
vr.cuePos = randi(4);
vr.worlds{1}.surface.visible(:) = 0;
switch vr.cuePos
    case 1
        vr.worlds{1}.surface.visible(vr.blackLeftOn) = 1;
        vr.worlds{1}.surface.visible(vr.alcWallsBlackT) = 1;
    case 2
        vr.worlds{1}.surface.visible(vr.blackRightOn) = 1;
        vr.worlds{1}.surface.visible(vr.alcWallsBlackT) = 1;
    case 3
        vr.worlds{1}.surface.visible(vr.whiteLeftOn) = 1;
        vr.worlds{1}.surface.visible(vr.alcWallsWhiteT) = 1;
    case 4
        vr.worlds{1}.surface.visible(vr.whiteRightOn) = 1;
        vr.worlds{1}.surface.visible(vr.alcWallsWhiteT) = 1;
    otherwise
        error('No World');
end

%designate integration condition
if vr.cuePos <= 2
    numWhite = randi([0 0],1);
else
    numWhite = randi([8 8],1);
end
vr.whiteDots = sort(randsample(8,numWhite)); %generate which segments will be white

vr.segLength = eval(vr.exper.variables.segLength);
vr.alcLength = eval(vr.exper.variables.alcLength);
vr.MazeLengthAhead = eval(vr.exper.variables.MazeLengthAhead);

lastLeftWhite = vr.LeftWallWhite(1);
lastLeftBlack = vr.LeftWallBlack(1);
lastRightWhite = vr.RightWallWhite(1);
lastRightBlack = vr.RightWallBlack(1);

for i = 1:8 
   if sum(vr.whiteDots == i) ~= 0
       vr.worlds{1}.surface.visible(lastLeftWhite:lastLeftWhite + floor((vr.LeftWallWhite(2)-vr.LeftWallWhite(1))*(vr.alcLength/(vr.MazeLengthAhead)))) = 1;
       vr.worlds{1}.surface.visible(lastRightWhite:lastRightWhite + floor((vr.RightWallWhite(2)-vr.RightWallWhite(1))*(vr.alcLength/(vr.MazeLengthAhead)))) = 1;
       vr.worlds{1}.surface.visible(lastLeftBlack:lastLeftBlack + floor((vr.LeftWallBlack(2)-vr.LeftWallBlack(1))*(vr.alcLength/(vr.MazeLengthAhead)))) = 0;
       vr.worlds{1}.surface.visible(lastRightBlack:lastRightBlack + floor((vr.RightWallBlack(2)-vr.RightWallBlack(1))*(vr.alcLength/(vr.MazeLengthAhead)))) = 0;
   else
       vr.worlds{1}.surface.visible(lastLeftWhite:lastLeftWhite + floor((vr.LeftWallWhite(2)-vr.LeftWallWhite(1))*(vr.alcLength/(vr.MazeLengthAhead)))) = 0;
       vr.worlds{1}.surface.visible(lastRightWhite:lastRightWhite + floor((vr.RightWallWhite(2)-vr.RightWallWhite(1))*(vr.alcLength/(vr.MazeLengthAhead)))) = 0;
       vr.worlds{1}.surface.visible(lastLeftBlack:lastLeftBlack + floor((vr.LeftWallBlack(2)-vr.LeftWallBlack(1))*(vr.alcLength/(vr.MazeLengthAhead)))) = 1;
       vr.worlds{1}.surface.visible(lastRightBlack:lastRightBlack + floor((vr.RightWallBlack(2)-vr.RightWallBlack(1))*(vr.alcLength/(vr.MazeLengthAhead)))) = 1;
   end
   lastLeftWhite = lastLeftWhite + 1 + floor((vr.LeftWallWhite(2)-vr.LeftWallWhite(1))*(vr.segLength + vr.alcLength)/(vr.MazeLengthAhead));
   lastRightWhite = lastRightWhite + 1 + floor((vr.RightWallWhite(2)-vr.RightWallWhite(1))*(vr.segLength + vr.alcLength)/(vr.MazeLengthAhead));
   lastLeftBlack = lastLeftBlack + 1 + floor((vr.LeftWallBlack(2)-vr.LeftWallBlack(1))*(vr.segLength + vr.alcLength)/(vr.MazeLengthAhead));
   lastRightBlack = lastRightBlack + 1 + floor((vr.RightWallBlack(2)-vr.RightWallBlack(1))*(vr.segLength + vr.alcLength)/(vr.MazeLengthAhead));
end

%update delay wall segment visibility
lastLeft = vr.LeftWallDelay(1)+ceil((vr.LeftWallDelay(2)-vr.LeftWallDelay(1))*((2-vr.lengthFac)/2))+...
    ceil((vr.LeftWallDelay(2)-vr.LeftWallDelay(1))*(vr.alcLength/(2*vr.MazeLengthAhead)));
lastRight = vr.RightWallDelay(1)+ceil((vr.RightWallDelay(2)-vr.RightWallDelay(1))*((2-vr.lengthFac)/2))+...
    ceil((vr.RightWallDelay(2)-vr.RightWallDelay(1))*(vr.alcLength/(2*vr.MazeLengthAhead)));

for i = 1:8
    if i == 8
        vr.worlds{1}.surface.visible(lastLeft:vr.LeftWallDelay(2)) = 1;
        vr.worlds{1}.surface.visible(lastRight:vr.RightWallDelay(2)) = 1;
    else
        vr.worlds{1}.surface.visible(lastLeft:lastLeft+floor((vr.LeftWallDelay(2)-vr.LeftWallDelay(1))*(vr.segLength/(2*vr.MazeLengthAhead)))) = 1;
        vr.worlds{1}.surface.visible(lastRight:lastRight+floor((vr.RightWallDelay(2)-vr.RightWallDelay(1))*(vr.segLength/(2*vr.MazeLengthAhead)))) = 1;
        lastLeft = lastLeft+ceil((vr.LeftWallDelay(2)-vr.LeftWallDelay(1))*(vr.segLength + vr.alcLength)/(2*vr.MazeLengthAhead));
        lastRight = lastRight+ceil((vr.RightWallDelay(2)-vr.RightWallDelay(1))*(vr.segLength + vr.alcLength)/(2*vr.MazeLengthAhead));
    end
end

%get color wall vertices
vr.LeftWallWhiteVert = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.LeftWallWhite,:);
vr.RightWallWhiteVert = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.RightWallWhite,:);
vr.LeftWallBlackVert = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.LeftWallBlack,:);
vr.RightWallBlackVert = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.RightWallBlack,:);

%store color walls root
vr.leftWhiteRoot = vr.worlds{1}.surface.vertices(1,vr.LeftWallWhiteVert(1):vr.LeftWallWhiteVert(2));
vr.rightWhiteRoot = vr.worlds{1}.surface.vertices(1,vr.RightWallWhiteVert(1):vr.RightWallWhiteVert(2));
vr.leftBlackRoot = vr.worlds{1}.surface.vertices(1,vr.LeftWallBlackVert(1):vr.LeftWallBlackVert(2));
vr.rightBlackRoot = vr.worlds{1}.surface.vertices(1,vr.RightWallBlackVert(1):vr.RightWallBlackVert(2));

vr.alcWallDist = str2double(vr.exper.variables.alcDist);

%move color walls
vr.worlds{1}.surface.vertices(1,vr.LeftWallWhiteVert(1):vr.LeftWallWhiteVert(2)) = vr.leftWhiteRoot + vr.scaleFac*vr.alcWallDist;
vr.worlds{1}.surface.vertices(1,vr.RightWallWhiteVert(1):vr.RightWallWhiteVert(2)) = vr.rightWhiteRoot - vr.scaleFac*vr.alcWallDist;
vr.worlds{1}.surface.vertices(1,vr.LeftWallBlackVert(1):vr.LeftWallBlackVert(2)) = vr.leftBlackRoot + vr.scaleFac*vr.alcWallDist;
vr.worlds{1}.surface.vertices(1,vr.RightWallBlackVert(1):vr.RightWallBlackVert(2)) = vr.rightBlackRoot - vr.scaleFac*vr.alcWallDist;

%get vertices for back objects and delay walls 
vr.RightArmWallBlackV = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.RightArmWallBlack,:);
vr.LeftArmWallBlackV = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.LeftArmWallBlack,:);
vr.LeftEndWallBlackV = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.LeftEndWallBlack,:);
vr.RightEndWallBlackV = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.RightEndWallBlack,:);
vr.TTopWallLeftBlackV = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.TTopWallLeftBlack,:);
vr.TTopWallRightBlackV = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.TTopWallRightBlack,:);
vr.RightArmWallWhiteV = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.RightArmWallWhite,:);
vr.LeftArmWallWhitev = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.LeftArmWallWhite,:);
vr.LeftEndWallWhiteV = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.LeftEndWallWhite,:);
vr.RightEndWallWhiteV = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.RightEndWallWhite,:);
vr.TTopWallLeftWhiteV = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.TTopWallLeftWhite,:);
vr.TTopWallRightWhiteV = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.TTopWallRightWhite,:);
vr.LeftWallDelayV = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.LeftWallDelay,:);
vr.RightWallDelayV = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.RightWallDelay,:);
vr.directionTowerEndV = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.directionTowerEnd,:);
vr.TTopMiddleV = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.TTopMiddle,:);

vr.vertBackVals = [vr.RightArmWallBlackV(1):vr.RightArmWallBlackV(2) vr.LeftArmWallBlackV(1):vr.LeftArmWallBlackV(2)...
    vr.LeftEndWallBlackV(1):vr.LeftEndWallBlackV(2) vr.RightEndWallBlackV(1):vr.RightEndWallBlackV(2)... 
    vr.TTopWallLeftBlackV(1):vr.TTopWallLeftBlackV(2) vr.TTopWallRightBlackV(1):vr.TTopWallRightBlackV(2)...
    vr.RightArmWallWhiteV(1):vr.RightArmWallWhiteV(2) vr.LeftArmWallWhitev(1):vr.LeftArmWallWhitev(2)...
    vr.LeftEndWallWhiteV(1):vr.LeftEndWallWhiteV(2) vr.RightEndWallWhiteV(1):vr.RightEndWallWhiteV(2)...
    vr.TTopWallLeftWhiteV(1):vr.TTopWallLeftWhiteV(2) vr.TTopWallRightWhiteV(1):vr.TTopWallRightWhiteV(2)...
    vr.LeftWallDelayV(1):vr.LeftWallDelayV(2) vr.RightWallDelayV(1):vr.RightWallDelayV(2)...
    vr.directionTowerEndV(1):vr.directionTowerEndV(2) vr.TTopMiddleV(1):vr.TTopMiddleV(2)];

vr.rootBackVals = vr.worlds{1}.surface.vertices(2,vr.vertBackVals);

%get root edges
vr.RightArmWallBlackRootEdges = vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.RightArmWallBlack,:);
vr.LeftArmWallBlackRootEdges = vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.LeftArmWallBlack,:);
vr.LeftEndWallBlackRootEdges = vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.LeftEndWallBlack,:);
vr.RightEndWallBlackRootEdges = vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.RightEndWallBlack,:);
vr.TTopWallLeftBlackRootEdges = vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.TTopWallLeftBlack,:);
vr.TTopWallRightBlackRootEdges = vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.TTopWallRightBlack,:);
vr.RightArmWallWhiteRootEdges = vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.RightArmWallWhite,:);
vr.LeftArmWallWhiteRootEdges = vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.LeftArmWallWhite,:);
vr.LeftEndWallWhiteRootEdges = vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.LeftEndWallWhite,:);
vr.RightEndWallWhiteRootEdges = vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.RightEndWallWhite,:);
vr.TTopWallLeftWhiteRootEdges = vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.TTopWallLeftWhite,:);
vr.TTopWallRightWhiteRootEdges = vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.TTopWallRightWhite,:);
vr.LeftWallDelayRootEdges = vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.LeftWallDelay,:);
vr.RightWallDelayRootEdges = vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.RightWallDelay,:);
vr.directionTowerEndRootEdges = vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.directionTowerEnd,:);
vr.TTopMiddleRootEdges = vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.TTopMiddle,:);

%move all back walls and edges
vr.worlds{1}.surface.vertices(2,vr.vertBackVals) = vr.rootBackVals + ...
    round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));

vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.RightArmWallBlack,[2 4]) = vr.RightArmWallBlackRootEdges([2 4]) + ...
    round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.LeftArmWallBlack,[2 4]) = vr.LeftArmWallBlackRootEdges([2 4]) + ...
    round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.LeftEndWallBlack,[2 4]) = vr.LeftEndWallBlackRootEdges([2 4]) + ...
    round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.RightEndWallBlack,[2 4]) = vr.RightEndWallBlackRootEdges([2 4]) + ...
    round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.TTopWallLeftBlack,[2 4]) = vr.TTopWallLeftBlackRootEdges([2 4]) + ...
    round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.TTopWallRightBlack,[2 4]) = vr.TTopWallRightBlackRootEdges([2 4]) + ...
    round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.RightArmWallWhite,[2 4]) = vr.RightArmWallWhiteRootEdges([2 4]) + ...
    round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.LeftArmWallWhite,[2 4]) = vr.LeftArmWallWhiteRootEdges([2 4]) + ...
    round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.LeftEndWallWhite,[2 4]) = vr.LeftEndWallWhiteRootEdges([2 4]) + ...
    round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.RightEndWallWhite,[2 4]) = vr.RightEndWallWhiteRootEdges([2 4]) + ...
    round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.TTopWallLeftWhite,[2 4]) = vr.TTopWallLeftWhiteRootEdges([2 4]) + ...
    round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.TTopWallRightWhite,[2 4]) = vr.TTopWallRightWhiteRootEdges([2 4]) + ...
    round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.LeftWallDelay,[2 4]) = vr.LeftWallDelayRootEdges([2 4]) + ...
    round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.RightWallDelay,[2 4]) = vr.RightWallDelayRootEdges([2 4]) + ...
    round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.directionTowerEnd,[2 4]) = vr.directionTowerEndRootEdges([2 4]) + ...
    round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.TTopMiddle,[2 4]) = vr.TTopMiddleRootEdges([2 4]) + ...
    round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));

%update alcBlock
vr.alcSections = linspace(eval(vr.exper.variables.playerStartY),vr.MazeLengthAhead,9); %generate eighths for alcBlock
[~, index] = min(abs(vr.alcSections(1:8)-eval(vr.exper.variables.playerStartY)));
vr.worlds{1}.surface.visible(vr.alcBlockLeft(:)) = 1;
vr.worlds{1}.surface.visible(vr.alcBlockRight(:)) = 1;
vr.worlds{1}.surface.visible(vr.alcBlockLeft(1)+...
    ceil((vr.alcSections(index)/vr.MazeLengthAhead)*(vr.alcBlockLeft(2)-vr.alcBlockLeft(1))):...
    vr.alcBlockLeft(1)+ceil((vr.alcSections(index+1)/vr.MazeLengthAhead)*(vr.alcBlockLeft(2)-vr.alcBlockLeft(1))))=0;
vr.worlds{1}.surface.visible(vr.alcBlockRight(1)+...
    ceil((vr.alcSections(index)/vr.MazeLengthAhead)*(vr.alcBlockRight(2)-vr.alcBlockRight(1))):...
    vr.alcBlockRight(1)+ceil((vr.alcSections(index+1)/vr.MazeLengthAhead)*(vr.alcBlockRight(2)-vr.alcBlockRight(1))))=0;

vr.outITI = false;

vr.text(1).string = '0';
vr.text(1).position = [1 .8];
vr.text(1).size = .03;
vr.text(1).color = [1 0 1];
vr.startTime = now;

vr.text(2).string = '0';
vr.text(2).position = [1 .7];
vr.text(2).size = .03;
vr.text(2).color = [1 1 0];
vr.numTrials = 0;

vr.text(3).string = '0';
vr.text(3).position = [1 .6];
vr.text(3).size = .03;
vr.text(3).color = [0 1 1];
vr.numRewards = 0;

vr.text(4).string = '0';
vr.text(4).position = [1 .5];
vr.text(4).size = .03;
vr.text(4).color = [0 .5 .5];

vr.text(5).string = '0';
vr.text(5).position = [1 .4];
vr.text(5).size = .03;
vr.text(5).color = [1 0 0];

vr.numLeftTurns = 0;
vr.numBlackTurns = 0;
vr.mazeDesign = [];



% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

% putsample(vr.ao,[0,vr.position(4),vr.position(1),vr.position(2)/100]);

if vr.inITI == 0 && abs(vr.position(1)) > eval(vr.exper.variables.armLength)/2 && vr.position(2) > eval(vr.exper.variables.MazeLengthAhead)
    if vr.position(1) < 0 && (vr.cuePos == 1 || vr.cuePos == 3)
        if ~vr.debugMode
            putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
            start(vr.ao);
            stop(vr.ao);
        end
        vr.isReward = 1;
        if vr.rewCount == 1 && vr.mulRewards > 0
            if ~vr.debugMode
                pause(.04);
                putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
                start(vr.ao);
                stop(vr.ao);
            end
            vr.isReward = 2;
        end
        if vr.rewCount >= 2 && vr.mulRewards == 2
           if ~vr.debugMode     
                pause(.04);
                putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
                start(vr.ao);
                stop(vr.ao);
           end
            vr.isReward = 3;
        end
        if vr.mulRewards == 1 && vr.rewCount == 1
            vr.rewCount = 1;
        else
            vr.rewCount = vr.rewCount + 1;
        end
        vr.itiDur = 2;
        vr.numRewards = vr.numRewards + 1;
        vr.trialResults(1,size(vr.trialResults)+1) = 1;
    elseif  vr.position(1) > 0 && (vr.cuePos == 2 || vr.cuePos == 4)
        if ~vr.debugMode
            putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
            start(vr.ao);
            stop(vr.ao);
        end
        vr.isReward = 1;
        if vr.rewCount == 1 && vr.mulRewards > 0
            if ~vr.debugMode
                pause(.04);
                putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
                start(vr.ao);
                stop(vr.ao);
            end
            vr.isReward = 2;
        end
        if vr.rewCount >= 2 && vr.mulRewards == 2
           if ~vr.debugMode     
                pause(.04);
                putdata(vr.ao,[[5;zeros(5,1)],zeros(6,1),zeros(6,1),zeros(6,1)]);
                start(vr.ao);
                stop(vr.ao);
           end
            vr.isReward = 3;
        end
        if vr.mulRewards == 1 && vr.rewCount == 1
            vr.rewCount = 1;
        else
            vr.rewCount = vr.rewCount + 1;
        end
        vr.itiDur = 2;
        vr.numRewards = vr.numRewards + 1;
        vr.trialResults(1,size(vr.trialResults)+1) = 1;
    else
        vr.isReward = 0;
        vr.itiDur = 4;        
        vr.rewCount = 0;
        vr.trialResults(1,size(vr.trialResults)+1) = 0;
    end
    
    vr.worlds{1}.surface.visible(:) = 0;
    vr.itiStartTime = tic;
    vr.inITI = 1;
    vr.numTrials = vr.numTrials + 1;
    
    if ((vr.cuePos == 1 || vr.cuePos == 3) && vr.isReward ~= 0) || ((vr.cuePos == 2 || vr.cuePos == 4) && vr.isReward == 0)
        vr.trialResults(2,end) = 1;
    else
        vr.trialResults(2,end) = 0;
    end
    if ((vr.cuePos == 1 || vr.cuePos == 2) && vr.isReward ~= 0) || ((vr.cuePos == 3 || vr.cuePos == 4) && vr.isReward == 0)
        vr.trialResults(3,end) = 1;
    else
        vr.trialResults(3,end) = 0;
    end
    
    mazeDes = zeros(8,3);
    mazeDes(vr.whiteDots,1) = 1;
    mazeDes(setdiff(1:8,vr.whiteDots),2) = 1;
    mazeDes(1,3) = vr.isReward;
    mazeDes(2,3) = vr.cuePos;
    vr.mazeDesign = cat(3,vr.mazeDesign,mazeDes);
    
else
    vr.isReward = 0;
end

%update alcBlock
if ~vr.inITI
    [~, index] = min(abs(vr.alcSections(1:8)-vr.position(2)-vr.positionOffset));
    vr.worlds{1}.surface.visible(vr.alcBlockLeft(1):vr.alcBlockLeft(2)) = 1;
    vr.worlds{1}.surface.visible(vr.alcBlockRight(1):vr.alcBlockRight(2)) = 1;
    vr.worlds{1}.surface.visible(vr.alcBlockLeft(1)+...
        ceil((vr.alcSections(index)/vr.MazeLengthAhead)*(vr.alcBlockLeft(2)-vr.alcBlockLeft(1))):...
        vr.alcBlockLeft(1)+ceil((vr.alcSections(index+1)/vr.MazeLengthAhead)*(vr.alcBlockLeft(2)-vr.alcBlockLeft(1))))=0;
    vr.worlds{1}.surface.visible(vr.alcBlockRight(1)+...
        ceil((vr.alcSections(index)/vr.MazeLengthAhead)*(vr.alcBlockRight(2)-vr.alcBlockRight(1))):...
        vr.alcBlockRight(1)+ceil((vr.alcSections(index+1)/vr.MazeLengthAhead)*(vr.alcBlockRight(2)-vr.alcBlockRight(1))))=0;
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
    if vr.itiTime > vr.itiDur
        vr.inITI = 0;
        vr.worlds{1}.surface.visible(:) = 0;
        
        if ~vr.moveFlag && size(vr.trialResults,2) >= vr.trialThresh && (sum(vr.trialResults(1,(end-vr.trialThresh+1):end))/vr.trialThresh) >= vr.percThreshAdv
            vr.moveFlag = true;
        end
        
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
                vr.worlds{1}.surface.visible(vr.alcWallsBlackT) = 1;
            case 2
                vr.worlds{1}.surface.visible(vr.blackRightOn) = 1;
                vr.worlds{1}.surface.visible(vr.alcWallsBlackT) = 1;
            case 3
                vr.worlds{1}.surface.visible(vr.whiteLeftOn) = 1;
                vr.worlds{1}.surface.visible(vr.alcWallsWhiteT) = 1;
            case 4
                vr.worlds{1}.surface.visible(vr.whiteRightOn) = 1;
                vr.worlds{1}.surface.visible(vr.alcWallsWhiteT) = 1;
            otherwise
                error('No World');
        end
        
        %designate integration condition
        if vr.cuePos <= 2
            numWhite = randi([0 0],1);
        else
            numWhite = randi([8 8],1);
        end
        vr.whiteDots = sort(randsample(8,numWhite)); %generate which segments will be white

        %modify visibility for integration condition
        lastLeftWhite = vr.LeftWallWhite(1);
        lastLeftBlack = vr.LeftWallBlack(1);
        lastRightWhite = vr.RightWallWhite(1);
        lastRightBlack = vr.RightWallBlack(1);

        for i = 1:8 
           if sum(vr.whiteDots == i) ~= 0
               vr.worlds{1}.surface.visible(lastLeftWhite:lastLeftWhite + floor((vr.LeftWallWhite(2)-vr.LeftWallWhite(1))*(vr.alcLength/(vr.MazeLengthAhead)))) = 1;
               vr.worlds{1}.surface.visible(lastRightWhite:lastRightWhite + floor((vr.RightWallWhite(2)-vr.RightWallWhite(1))*(vr.alcLength/(vr.MazeLengthAhead)))) = 1;
               vr.worlds{1}.surface.visible(lastLeftBlack:lastLeftBlack + floor((vr.LeftWallBlack(2)-vr.LeftWallBlack(1))*(vr.alcLength/(vr.MazeLengthAhead)))) = 0;
               vr.worlds{1}.surface.visible(lastRightBlack:lastRightBlack + floor((vr.RightWallBlack(2)-vr.RightWallBlack(1))*(vr.alcLength/(vr.MazeLengthAhead)))) = 0;
           else
               vr.worlds{1}.surface.visible(lastLeftWhite:lastLeftWhite + floor((vr.LeftWallWhite(2)-vr.LeftWallWhite(1))*(vr.alcLength/(vr.MazeLengthAhead)))) = 0;
               vr.worlds{1}.surface.visible(lastRightWhite:lastRightWhite + floor((vr.RightWallWhite(2)-vr.RightWallWhite(1))*(vr.alcLength/(vr.MazeLengthAhead)))) = 0;
               vr.worlds{1}.surface.visible(lastLeftBlack:lastLeftBlack + floor((vr.LeftWallBlack(2)-vr.LeftWallBlack(1))*(vr.alcLength/(vr.MazeLengthAhead)))) = 1;
               vr.worlds{1}.surface.visible(lastRightBlack:lastRightBlack + floor((vr.RightWallBlack(2)-vr.RightWallBlack(1))*(vr.alcLength/(vr.MazeLengthAhead)))) = 1;
           end
           lastLeftWhite = lastLeftWhite + 1 + floor((vr.LeftWallWhite(2)-vr.LeftWallWhite(1))*(vr.segLength + vr.alcLength)/(vr.MazeLengthAhead));
           lastRightWhite = lastRightWhite + 1 + floor((vr.RightWallWhite(2)-vr.RightWallWhite(1))*(vr.segLength + vr.alcLength)/(vr.MazeLengthAhead));
           lastLeftBlack = lastLeftBlack + 1 + floor((vr.LeftWallBlack(2)-vr.LeftWallBlack(1))*(vr.segLength + vr.alcLength)/(vr.MazeLengthAhead));
           lastRightBlack = lastRightBlack + 1 + floor((vr.RightWallBlack(2)-vr.RightWallBlack(1))*(vr.segLength + vr.alcLength)/(vr.MazeLengthAhead));
        end
        
        %update lengthFac
        if size(vr.trialResults,2) > vr.lengthTrialThresh
            if sum(vr.trialResults(1,end-vr.numTrialsLenAdv+1:end)) >= vr.numTrialsLenAdv-1 && vr.scaleFac <= vr.lengthThresh && vr.lengthFac <= (vr.maxLenFac - vr.forRateLen)
                vr.lengthFac = vr.lengthFac + vr.forRateLen;
                vr.lengthTrialThresh = size(vr.trialResults,2) + vr.numTrialsLenAdv;
            elseif sum(vr.trialResults(1,end-vr.numTrialsReg+1:end)) == 0 && vr.lengthFac > 1 + vr.revRateLen
                vr.lengthFac = vr.lengthFac - vr.revRateLen;
            end
        end
        
        %update delay wall segment visibility
        lastLeft = vr.LeftWallDelay(1)+ceil((vr.LeftWallDelay(2)-vr.LeftWallDelay(1))*((2-vr.lengthFac)/2))+...
            ceil((vr.LeftWallDelay(2)-vr.LeftWallDelay(1))*(vr.alcLength/(2*vr.MazeLengthAhead)));
        lastRight = vr.RightWallDelay(1)+ceil((vr.RightWallDelay(2)-vr.RightWallDelay(1))*((2-vr.lengthFac)/2))+...
            ceil((vr.RightWallDelay(2)-vr.RightWallDelay(1))*(vr.alcLength/(2*vr.MazeLengthAhead)));

        for i = 1:8
            if i == 8
                vr.worlds{1}.surface.visible(lastLeft:vr.LeftWallDelay(2)) = 1;
                vr.worlds{1}.surface.visible(lastRight:vr.RightWallDelay(2)) = 1;
            else
                vr.worlds{1}.surface.visible(lastLeft:lastLeft+floor((vr.LeftWallDelay(2)-vr.LeftWallDelay(1))*(vr.segLength/(2*vr.MazeLengthAhead)))) = 1;
                vr.worlds{1}.surface.visible(lastRight:lastRight+floor((vr.RightWallDelay(2)-vr.RightWallDelay(1))*(vr.segLength/(2*vr.MazeLengthAhead)))) = 1;
                lastLeft = lastLeft+ceil((vr.LeftWallDelay(2)-vr.LeftWallDelay(1))*(vr.segLength + vr.alcLength)/(2*vr.MazeLengthAhead));
                lastRight = lastRight+ceil((vr.RightWallDelay(2)-vr.RightWallDelay(1))*(vr.segLength + vr.alcLength)/(2*vr.MazeLengthAhead));
            end
        end
        
        %update scaleFac
        if vr.trialResults(1,end) == 1 && vr.scaleFac >= vr.forRateAlc && vr.moveFlag
            vr.scaleFac = vr.scaleFac - vr.forRateAlc;
        elseif vr.trialResults(1,end) == 0 && vr.scaleFac < (1 - vr.revRateAlc) && vr.moveFlag
            vr.scaleFac = vr.scaleFac + vr.revRateAlc;
        end
        
        %move color walls
        vr.worlds{1}.surface.vertices(1,vr.LeftWallWhiteVert(1):vr.LeftWallWhiteVert(2)) = vr.leftWhiteRoot + vr.scaleFac*vr.alcWallDist;
        vr.worlds{1}.surface.vertices(1,vr.RightWallWhiteVert(1):vr.RightWallWhiteVert(2)) = vr.rightWhiteRoot - vr.scaleFac*vr.alcWallDist;
        vr.worlds{1}.surface.vertices(1,vr.LeftWallBlackVert(1):vr.LeftWallBlackVert(2)) = vr.leftBlackRoot + vr.scaleFac*vr.alcWallDist;
        vr.worlds{1}.surface.vertices(1,vr.RightWallBlackVert(1):vr.RightWallBlackVert(2)) = vr.rightBlackRoot - vr.scaleFac*vr.alcWallDist;
        
        %move all back walls and edges
        vr.worlds{1}.surface.vertices(2,vr.vertBackVals) = vr.rootBackVals + ...
            round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
        
        vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.RightArmWallBlack,[2 4]) = vr.RightArmWallBlackRootEdges([2 4]) + ...
            round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
        vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.LeftArmWallBlack,[2 4]) = vr.LeftArmWallBlackRootEdges([2 4]) + ...
            round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
        vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.LeftEndWallBlack,[2 4]) = vr.LeftEndWallBlackRootEdges([2 4]) + ...
            round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
        vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.RightEndWallBlack,[2 4]) = vr.RightEndWallBlackRootEdges([2 4]) + ...
            round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
        vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.TTopWallLeftBlack,[2 4]) = vr.TTopWallLeftBlackRootEdges([2 4]) + ...
            round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
        vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.TTopWallRightBlack,[2 4]) = vr.TTopWallRightBlackRootEdges([2 4]) + ...
            round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
        vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.RightArmWallWhite,[2 4]) = vr.RightArmWallWhiteRootEdges([2 4]) + ...
            round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
        vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.LeftArmWallWhite,[2 4]) = vr.LeftArmWallWhiteRootEdges([2 4]) + ...
            round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
        vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.LeftEndWallWhite,[2 4]) = vr.LeftEndWallWhiteRootEdges([2 4]) + ...
            round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
        vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.RightEndWallWhite,[2 4]) = vr.RightEndWallWhiteRootEdges([2 4]) + ...
            round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
        vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.TTopWallLeftWhite,[2 4]) = vr.TTopWallLeftWhiteRootEdges([2 4]) + ...
            round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
        vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.TTopWallRightWhite,[2 4]) = vr.TTopWallRightWhiteRootEdges([2 4]) + ...
            round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
        vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.LeftWallDelay,[2 4]) = vr.LeftWallDelayRootEdges([2 4]) + ...
            round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
        vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.RightWallDelay,[2 4]) = vr.RightWallDelayRootEdges([2 4]) + ...
            round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
        vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.directionTowerEnd,[2 4]) = vr.directionTowerEndRootEdges([2 4]) + ...
            round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
        vr.worlds{1}.edges.endpoints(vr.worlds{1}.objects.indices.TTopMiddle,[2 4]) = vr.TTopMiddleRootEdges([2 4]) + ...
            round((vr.lengthFac - 1)*eval(vr.exper.variables.MazeLengthAhead));
        
%         %move alcove walls
%         for i = 1:2:15
%             vr.worlds{1}.surface.vertices(2,vr.alcWalls(i,1):vr.alcWalls(i,2)) = vr.alcWallsRoot(i,:) + vr.scaleFac*vr.segVert;
%         end
        
        vr.position = vr.worlds{1}.startLocation;
        vr.outITI = true;
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
vr.text(5).string = ['SCALEFAC ',num2str(vr.scaleFac)];

fwrite(vr.fid,[rem(now,1) vr.position([1:2,4]) vr.velocity(1:2) vr.cuePos vr.isReward vr.inITI vr.percGraded vr.scaleFac vr.lengthFac],'float');


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
fclose all;
copyfile(vr.pathTempMat,vr.pathMat);
copyfile(vr.pathTempDat,vr.pathDat);
delete(vr.pathTempMat,vr.pathTempDat);
fid = fopen(vr.pathDat);
data = fread(fid,'float');
data = reshape(data,12,numel(data)/12);
assignin('base','data',data);
save(vr.pathMat,'data','-append');
save(vr.pathMat,'-struct','vr','mazeDesign','-append');
% save(vr.pathMat,'vr','-append');
fclose all; 
