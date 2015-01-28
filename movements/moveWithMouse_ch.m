function velocity = moveWithMouse_ch(vr)

velocity = [0 0 0 0];

% Read data from NIDAQ
data = peekdata(vr.ai,50);

% Remove NaN's from the data (these occur after NIDAQ has stopped)
f = isnan(mean(data,2));
data(f,:) = [];
data = mean(data,1);
data(isnan(data)) = 0;

% Update velocity
alpha = 40;
beta = -1.3; %was -1.3
velocity(1) = alpha*data(1)*cos(vr.position(4));
velocity(2) = alpha*data(1)*sin(vr.position(4));
velocity(4) = beta*data(2);