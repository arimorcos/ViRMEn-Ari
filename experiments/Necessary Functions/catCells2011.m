function [data] = catCells2011(path,startString)
%catCells.m This function loads in multiple structures and concatenates
%them in one cell array. It then saves the file and overwrites the old
%structures

%turn off warning for not finding load pattern
warning('off','MATLAB:load:variablePatternNotFound');

%load all variables
load(path,[startString,'*']);

%get number of files
numFiles = length(whos([startString,'*']));

if numFiles == 0
    data = {};
    return;
end

%initialize cell array
data = cell(1,numFiles);

%import data into cell
for i=1:numFiles
    eval(['data{i} = ',startString,num2str(i),';']);
end
end

