function calibrateBiStable(n_pulses, delay, duration)
if nargin < 3
    duration = 0.035;
end
if nargin < 2
    delay = 1;
end
if nargin < 1
    n_pulses = 125;
end

daqreset;
aout=analogoutput('nidaq','Dev1');
d_to_a_solenoid=addchannel(aout,0);

% set up output pulse for solenoid

set (aout,'SampleRate',1000);
ActualRate = get(aout,'SampleRate');
pulselength=ActualRate*duration;
pulsedata=zeros(pulselength,1); %5V amplitude
pulsedata(1:ActualRate*(0.01)) = 5;
pulsedata(end-ActualRate*(0.01):end) = 5;

%set up number of pulses and pause between
for i=1:n_pulses
    disp(['i = ',num2str(i)]);
putdata(aout,pulsedata);
start(aout);
wait(aout,5);
pause(delay);
end

