function [vr] = giveReward(vr,nRew)
%giveReward Function which delivers rewards using the Master-8 system
%(instantaneous pulses)
%   nRew - number of rewards to deliver

sinDur = 0.04;

if rand <= vr.jackpotProb %if jackpot
    nRew = 3;
end

if ~vr.debugMode
    actualRate = get (vr.ao,'SampleRate'); %get sample rate
    pulselength=round(actualRate*sinDur*nRew); %find duration (rate*duration in seconds *numRew)
    pulsedata=5.0*ones(pulselength,1); %5V amplitude
    pulsedata(pulselength)=0; %reset to 0V at last time point
    putdata(vr.ao,pulsedata);
    start(vr.ao);
    wait(vr.ao,5);
end

vr.isReward = nRew;

end

