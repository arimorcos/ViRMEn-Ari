function velocity = moveWithTwoMice(vr)

velocity = [0 0 0 0];

% Read data from NIDAQ
data = peekdata(vr.ai,50);

% Remove NaN's from the data (these occur after NIDAQ has stopped)
f = isnan(mean(data,2));
data(f,:) = [];
data = mean(data,1)';
data(isnan(data)) = 0;

% Update velocity
% vr.scale = -30;
data = [cosd(-45) -sind(-45); sind(-45) cosd(-45)]*data;
if ~isfield(vr,'scaling')
    vr.scaling = [30 30];
end
velocity(1) = -vr.scaling(1)*data(1);
velocity(2) = -vr.scaling(2)*data(2);