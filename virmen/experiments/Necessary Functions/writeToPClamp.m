function vr = writeToPClamp(vr,initialize)
%writeToPClamp.m function to write current virmen iteration to pClamp and
%increase iteration num

if initialize
    if ~vr.debugMode && vr.imaging
        vr.iterationNum = 1;
        putsample(vr.aoCOUNT,-5); %count is -5 inbetween count 'ticks'
    end
else
    if ~vr.debugMode && vr.imaging
        if vr.iterationNum == 1
            putsample(vr.aoCOUNT,10),
        elseif mod(vr.iterationNum,1e4)==0
            putsample(vr.aoCOUNT,vr.iterationNum/1e5),
        else
            putsample(vr.aoCOUNT,-1),
        end
        vr.iterationNum = vr.iterationNum + 1;
        putsample(vr.aoCOUNT,-5);
    end
end