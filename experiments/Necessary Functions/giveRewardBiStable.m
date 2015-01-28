function [vr] = giveRewardBiStable(vr,nRew)
%giveReward Function which delivers rewards using the Master-8 system
%(instantaneous pulses)
%   nRew - number of rewards to deliver

sinDur = 0.039;

if ~vr.debugMode
    actualRate = get (vr.ao,'SampleRate'); %get sample rate
    pulselength=round(actualRate*sinDur*nRew); %find duration (rate*duration in seconds *numRew)
    pulsedata=zeros(pulselength,1); %length of segment amplitude
    pulsedata(1:actualRate*(0.01)) = 5;
    pulsedata(end-actualRate*(0.01):end) = 5;
    putdata(vr.ao,pulsedata);
    start(vr.ao);
    wait(vr.ao,5);
end

vr.isReward = nRew;

end

