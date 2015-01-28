function velocity = moveKeyboardMouseAM(vr) 


velocity = [0 0 0 0];
if ~isfield(vr,'scaling')
    vr.scaling = [30 30];
end

[~,~,keyPresses] = KbCheck;
if keyPresses(87) %w
    velocity(1) = 300*(vr.scaling(2)/50)/(cos(vr.position(4)));
    velocity(2) = 300*(vr.scaling(1)/50)/(cos((pi/2)-vr.position(4)));
elseif keyPresses(83) %s
    velocity(1) = -300*(vr.scaling(2)/50)/(cos(vr.position(4)));
    velocity(2) = -300*(vr.scaling(1)/50)/(cos((pi/2)-vr.position(4)));
elseif keyPresses(68) %d
    velocity(1) = 100*(vr.scaling(1)/50)*sin(vr.position(4));
    velocity(2) = 100*(vr.scaling(2)/50)*cos(vr.position(4));
elseif keyPresses(65) %a
    velocity(1) = -100*(vr.scaling(1)/50)*sin(vr.position(4));
    velocity(2) = -100*(vr.scaling(2)/50)*cos(vr.position(4));
end
    
beta = -0.005;
scr = get(0,'screensize');
ptr = get(0,'pointerlocation')-scr(3:4)/2;
velocity(4) = ptr(1)*beta;
end

