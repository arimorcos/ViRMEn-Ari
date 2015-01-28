function [trials,mazePatterns] = preallocateTrials(mazeProbs,mazePatterns,...
    nTrials)
%preallocateTrials.m Function to preallocate trials 
%
%INPUTS
%mazeProbs - nProbs x 1 array containing probability of each condition
%   (grouped by left and right)
%mazePatterns - nPatterns x nSeg array of segment patterns (only includes
%   one condition)
%nTrials - number of trials to preallocate (1000 by default)
%
%OUTPUTS
%trials - 1 x nTrials array containing id of each trial
%mazePatterns - mazePatterns including both left and right
%
%ASM 11/13

%default nTrials if not given
if nargin < 3 || isempty(nTrials)
    nTrials = 1000;
end

%duplicate mazeProbs and mazePatterns
mazeProbs = 0.5*repmat(mazeProbs,2,1); %divide probabilities by 2 to account for equal prob
mazePatterns = cat(1,mazePatterns,1-mazePatterns);

%eliminate zeroInd
zeroInd = mazeProbs == 0;
mazeProbs(zeroInd) = [];
mazePatterns(zeroInd,:) = [];

%determine block size
blockFound = false;
multFac = 1;
while ~blockFound
    testSize = multFac/min(mazeProbs);
    if isfloatinteger(testSize) %if is integer
        blockFound = true;
        blockSize = testSize;
    else
        multFac = multFac + 1;
    end
end

%determine number of blocks in nTrials
nBlocks = ceil(nTrials/blockSize);
nBlockTrials = nBlocks*blockSize;

%initialize trials
trials = zeros(1,nBlockTrials);

%generate block array 
nMazeTrialsInBlock = round(mazeProbs*blockSize);
blockArray = arrayfun(@(x,ind) ones(1,x)*ind,nMazeTrialsInBlock,...
    (1:length(nMazeTrialsInBlock))','UniformOutput',false);
blockArray = cat(2,blockArray{:});

%cycle through each block and assign
for i = 1:nBlocks
    trials((i-1)*blockSize+1:i*blockSize) = randsample(blockArray,blockSize);
end

%chop off end of last block
trials = trials(1:nTrials);
    
    
    
    