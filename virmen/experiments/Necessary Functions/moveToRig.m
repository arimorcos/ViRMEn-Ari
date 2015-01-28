function moveToRig(toRig)
%moveToRig.m Function to change transformation/movement functions on all
%mazes
%
%To move to rig, set toRig to 1.
%To move to computer, set toRig to 0.

RIGMOVEMENT = 'moveWithMouseBottom';
RIGTRANSFORM = 'fliptransformCylMex';

COMPMOVEMENT = 'movePointer2DFast';
COMPTRANSFORM = 'transformCylMex';

if nargin < 1 %if no input
    toRig = 1;
end

%get parent directory
parDir = mfilename('fullpath');
parDir = parDir(1:regexp(parDir,'Necessary Functions')-1); %remove cellGUI from path

%move to parent directory
origDir = cd(parDir);

%get list of matfiles in directory
folderContents = what;
matFiles = folderContents.mat;
numFiles = length(matFiles);

%create waitbar
progBar = waitbar(0,['Progress: 0/',num2str(numFiles),' Completed']);

%cycle through each matfile
for i=1:numFiles
    
    saveFlag = false;
    
    %load exper from matfile
    load(matFiles{i},'exper');
    
    if toRig
        %determine if movement needs to be changed
        if ~strcmp(RIGMOVEMENT,func2str(exper.movementFunction))
            exper.movementFunction = str2func(RIGMOVEMENT);
            saveFlag = true;
        end

        %determine if transform function needs to be changed
        if ~strcmp(RIGTRANSFORM,func2str(exper.transformationFunction))
            exper.transformationFunction = str2func(RIGTRANSFORM);
            saveFlag = true;
        end
    else
        %determine if movement needs to be changed
        if ~strcmp(COMPMOVEMENT,func2str(exper.movementFunction))
            exper.movementFunction = str2func(COMPMOVEMENT);
            saveFlag = true;
        end

        %determine if transform function needs to be changed
        if ~strcmp(COMPTRANSFORM,func2str(exper.transformationFunction))
            exper.transformationFunction = str2func(COMPTRANSFORM);
            saveFlag = true;
        end
    end    
    
    if saveFlag %if we should save it
        save(matFiles{i},'exper');
    end
    
    %update progBar
    waitbar(i/numFiles,progBar,['Progress: ',num2str(i),'/',num2str(numFiles),' Completed']);
    
end

%close progBar
close(progBar);

%change back to origDir
cd(origDir);

end