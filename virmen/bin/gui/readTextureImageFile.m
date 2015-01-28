function [img, colorMap, errorString] = readTextureImageFile(filename)

info = imfinfo(filename);
errorString = '';

switch info.ColorType
    case 'grayscale'
        img = imread(filename);
        img = double(img)+1;
        colorMap = gray(256);
    case 'truecolor'
        img = imread(filename);
        answer = inputdlg({'Number of colors'},'Colormap',1,{'5'});
        if isempty(answer)
            img = [];
            colorMap = [];
            errorString = '';
            return
        end
        try
            numColors = eval(answer{1});
        catch %#ok<CTCH>
            img = [];
            colorMap = [];
            errorString = 'Invalid Matlab expression.';
            return
        end    
        try
            [img,colorMap] = rgb2ind(img,numColors);
            img = double(img)+1;
        catch %#ok<CTCH>
            img = [];
            colorMap = [];
            errorString = 'Could not process image. This may require the Image Processing Toolbox.';
        end
    case 'indexed'
        [img colorMap] = imread(filename);
        img = double(img)+1;
    otherwise
        img = [];
        colorMap = [];
        errorString = 'Could not identify file format.';
end