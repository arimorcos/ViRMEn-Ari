function [vr] = initializePathVIRMEN(vr)
%INITIALIZEPATHVIRMEN This is a function to initialize virmen path
%information run during the initialization block of all mazes

%are we on imaging rig? 
vr.imaging = true;

%initialize jackpot prob
vr.jackpotProb = 0.05;

%initialize reward arm depth
vr.armFac = 3; %armLength/armFac is where reward is given

%initialize vertex offset
vr.vertexOffset = 0;

%initialize cell info
vr.experimenter = 'ASM';
vr.whiteMazes = getWhiteMazes(vr.exper);
vr.leftMazes = getLeftMazes(vr.exper);
vr.mazeName = func2str(vr.exper.experimentCode);
vr.exper.variables.mouseNumber = sprintf('%03d',vr.mouseNum); %save mouse num in exper 

%set up path information
path = ['C:\DATA\Ari\Current Mice\AM' sprintf('%03d',vr.mouseNum)];
tempPath = 'C:\DATA\Ari\Temporary';
if ~exist(tempPath,'dir');
    mkdir(tempPath);
end
if ~exist(path,'dir')
    mkdir(path);
end
vr.filenameTempMat = 'tempStorage.mat';
vr.filenameTempMatCell = 'tempStorageCell.mat';
vr.filenameTempDat = 'tempStorage.dat';
vr.filenameMat = ['AM',vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'.mat'];
vr.filenameMatCell = ['AM',vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'_Cell.mat'];
vr.filenameDat = ['AM',vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'.dat'];
fileIndex = 0;
fileList = what(path);
while sum(strcmp(fileList.mat,vr.filenameMat)) > 0
    fileIndex = fileIndex + 1;
    vr.filenameMat = ['AM',vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'_',num2str(fileIndex),'.mat'];
    vr.filenameMatCell = ['AM',vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'_Cell_',num2str(fileIndex),'.mat'];
    vr.filenameDat = ['AM',vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'_',num2str(fileIndex),'.dat'];
    fileList = what(path);
end
exper = copyVirmenObject(vr.exper); %#ok<NASGU>
vr.pathTempMat = [tempPath,'\',vr.filenameTempMat];
vr.pathTempMatCell = [tempPath,'\',vr.filenameTempMatCell];
vr.pathTempDat = [tempPath,'\',vr.filenameTempDat];
vr.pathMat = [path,'\',vr.filenameMat];
vr.pathMatCell = [path,'\',vr.filenameMatCell];
vr.pathDat = [path, '\',vr.filenameDat];
save(vr.pathTempMat,'exper');
vr.fid = fopen(vr.pathTempDat,'w');

%save tempFile
save(vr.pathTempMatCell,'-struct','vr','conds');

% Start the DAQ acquisition
if ~vr.debugMode
    daqreset; %reset DAQ in case it's still in use by a previous Matlab program
    vr.ai = analoginput('nidaq','dev1'); % connect to the DAQ card
    addchannel(vr.ai,0:1); % start channels 0 and 1
    set(vr.ai,'samplerate',1000,'samplespertrigger',1e7); % define buffer
    start(vr.ai); % start acquisition

    vr.ao = analogoutput('nidaq','dev1');
    addchannel(vr.ao,0);
    set(vr.ao,'samplerate',10000);
end

%Set up alternate analog out object for outputting iteration number
if ~vr.debugMode && vr.imaging
    vr.aoCOUNT = analogoutput('nidaq','dev1');
    addchannel(vr.aoCOUNT,1);
    set(vr.aoCOUNT,'samplerate',1000);
end

%initialize counters
vr.streak = 0;
vr.inITI = 0;
vr.isReward = 0;
vr.startTime = now;
vr.trialStartTime = rem(now,1);
vr.numTrials = 0;
vr.numRewards = 0;
vr.trialResults = [];
vr.itiCorrect = 2;
vr.itiMiss = 4;

%initialize text boxes
vr.text(1).string = '';
vr.text(1).position = [1 .8];
vr.text(1).size = .03;
vr.text(1).color = [1 0 1];

vr.text(2).string = '';
vr.text(2).position = [1 .7];
vr.text(2).size = .03;
vr.text(2).color = [1 1 0];

vr.text(3).string = '';
vr.text(3).position = [1 .6];
vr.text(3).size = .03;
vr.text(3).color = [0 1 1];

vr.text(4).string = '';
vr.text(4).position = [1 .5];
vr.text(4).size = .03;
vr.text(4).color = [.5 .5 1];

vr.text(5).string = '';
vr.text(5).position = [1 .4];
vr.text(5).size = .03;
vr.text(5).color = [1 .5 .5];

%move pointer
set(0,'pointerlocation',[0 0]);

end

