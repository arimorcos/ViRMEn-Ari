function shapes = image2texture(img,colorMap)

img = double(flipud(img));
[unq, ~, j] = unique(img(:));
colorMap = colorMap(unq,:);
img = reshape(j,size(img,1),size(img,2));

indx = repmat(1:size(img,2),2,1);
indx = indx(:);
a = img(:,indx);
indx = repmat(1:size(a,1),2,1);
indx = indx(:);
a = a(indx,:);

y = round((1:size(a,1))/2-.5);
x = round((1:size(a,2))/2-.5);

c = contourc(x,y,a,min(img(:))+.5:max(img(:))-.5);

curr = 1;
t = virmenTexture;
while curr <= size(c,2)
    s = shapeImageBoundary;
    x = c(1,curr+1:curr+c(2,curr))'/size(a,2)*2;
    y = c(2,curr+1:curr+c(2,curr))'/size(a,1)*2;
    f = find(x(1:end-1)==x(2:end) & y(1:end-1)==y(2:end));
    x(f) = [];
    y(f) = [];
    f = find((x(2:end-1)==x(1:end-2) & x(2:end-1)==x(3:end)) | (y(2:end-1)==y(1:end-2) & y(2:end-1)==y(3:end)))+1;
    x(f) = [];
    y(f) = [];
    s.x = x;
    s.y = y;
    addShape(t,s);
    curr = curr+c(2,curr)+1;
end

r = findImageRegions(a);
unq = unique(r(:));
i = zeros(length(unq),1);
j = zeros(length(unq),1);
c = zeros(length(unq),1);
for ndx = 1:length(unq)
    [i(ndx) j(ndx)] = find(r==unq(ndx),1);
    c(ndx) = a(i(ndx),j(ndx));
end

cols = unique(a(:));
for ndx = 1:length(cols)
    f = find(c==cols(ndx));
    s = shapeColor;
    s.x = (j(f)-1)/size(a,2) + 0.5/size(a,2);
    s.y = (i(f)-1)/size(a,1) + 0.5/size(a,1);
    s.R = colorMap(cols(ndx),1);
    s.G = colorMap(cols(ndx),2);
    s.B = colorMap(cols(ndx),3);
    addShape(t,s);
end

shapes = t.shapes;