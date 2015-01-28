function [dp collision] = virmenDetectCollisions(x,dp,xe,r)

xe = xe(~isnan(r),:);
if isempty(xe)
    collision = false;
    return
end
r = r(~isnan(r));

isCollide = true;
collision = false;
while isCollide
    ang = atan((xe(:,4)-xe(:,2))./(xe(:,3)-xe(:,1)));
    ang(isnan(ang)) = 0;
    vect = [r.*cos(ang+pi/2) r.*sin(ang+pi/2)];
    
    crossPt = zeros(0,1);
    slope = zeros(0,1);
    
    % Line-line intersections
    xe = xe+[vect vect];
    x1 = repmat(x,size(xe,1),1);
    x21 = repmat(dp,size(xe,1),1);
    x31 = xe(:,1:2)-x1;
    x34 = xe(:,1:2)-xe(:,3:4);
    detM = (x21(:,1).*x34(:,2)-x21(:,2).*x34(:,1));
    t = (x31(:,1).*x34(:,2)-x31(:,2).*x34(:,1))./detM;
    s = (x31(:,2).*x21(:,1)-x31(:,1).*x21(:,2))./detM;
    f = find(t>=0 & s>=0 & t<=1 & s<=1);
    crossPt = [crossPt; t(f,:)]; %#ok<AGROW>
    slope = [slope; ang(f,:)]; %#ok<AGROW>
    
    xe = xe-2*[vect vect];
    x31 = xe(:,1:2)-x1;
    x34 = xe(:,1:2)-xe(:,3:4);
    detM = (x21(:,1).*x34(:,2)-x21(:,2).*x34(:,1));
    t = (x31(:,1).*x34(:,2)-x31(:,2).*x34(:,1))./detM;
    s = (x31(:,2).*x21(:,1)-x31(:,1).*x21(:,2))./detM;
    f = find(t>=0 & s>=0 & t<=1 & s<=1);
    crossPt = [crossPt; t(f,:)]; %#ok<AGROW>
    slope = [slope; ang(f,:)]; %#ok<AGROW>
    
    xe = xe+[vect vect];
    
    % Line-circle intersections
    x31 = xe(:,1:2)-x1;
    discr = 4*sum(-x31.*x21,2).^2 - 4*sum(x21.*x21,2).*(sum(x31.*x31,2)-r.^2);
    discr(discr<0) = NaN;
    root1 = (2*sum(x31.*x21,2) - sqrt(discr))./(2*sum(x21.*x21,2));
    root2 = (2*sum(x31.*x21,2) + sqrt(discr))./(2*sum(x21.*x21,2));
    g = root1>=0 & root1<=1;
    crossPt = [crossPt; root1(g,:)]; %#ok<AGROW>
    newpt = (x1(g,:)+[root1(g,:) root1(g,:)].*x21(g,:))-xe(g,1:2);
    slope = [slope; atan(newpt(:,2)./newpt(:,1))+pi/2]; %#ok<AGROW>
    g = root2>=0 & root2<=1 & (root1<0 | root1>1);
    crossPt = [crossPt; root2(g,:)]; %#ok<AGROW>
    newpt = (x1(g,:)+[root2(g,:) root2(g,:)].*x21(g,:))-xe(g,1:2);
    slope = [slope; atan(newpt(:,2)./newpt(:,1))+pi/2]; %#ok<AGROW>
    
    x31 = xe(:,3:4)-x1;
    discr = 4*sum(-x31.*x21,2).^2 - 4*sum(x21.*x21,2).*(sum(x31.*x31,2)-r.^2);
    discr(discr<0) = NaN;
    root1 = (2*sum(x31.*x21,2) - sqrt(discr))./(2*sum(x21.*x21,2));
    root2 = (2*sum(x31.*x21,2) + sqrt(discr))./(2*sum(x21.*x21,2));
    g = root1>=0 & root1<=1;
    crossPt = [crossPt; root1(g,:)]; %#ok<AGROW>
    newpt = (x1(g,:)+[root1(g,:) root1(g,:)].*x21(g,:))-xe(g,3:4);
    slope = [slope; atan(newpt(:,2)./newpt(:,1))+pi/2]; %#ok<AGROW>
    g = root2>=0 & root2<=1 & (root1<0 | root1>1);
    crossPt = [crossPt; root2(g,:)]; %#ok<AGROW>
    newpt = (x1(g,:)+[root2(g,:) root2(g,:)].*x21(g,:))-xe(g,3:4);
    slope = [slope; atan(newpt(:,2)./newpt(:,1))+pi/2]; %#ok<AGROW>
    
    [crossPt ndx] = min(crossPt); %#ok<ASGLU>
    slope = slope(ndx);
    
    if ~isempty(slope)
        P = [cos(slope) sin(slope)]'*[cos(slope) sin(slope)];
        dp = (P*dp')';
        isCollide = true;
        collision = true;
    else
        isCollide = false;
    end
end