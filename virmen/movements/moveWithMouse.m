function velocity = moveWithMouse(vr)

velocity = [0 0 0 0];

% Read data from NIDAQ
data = peekdata(vr.ai,100);

% Remove NaN's from the data (these occur after NIDAQ has stopped)
f = isnan(mean(data,2));
data(f,:) = [];
data = mean(data,1);
data(isnan(data)) = 0;

% Update velocity
scale = 100;
velocity(1) = data(2)*scale*sin(-vr.position(4));
velocity(2) = data(2)*scale*cos(-vr.position(4));
velocity(4) = data(1);