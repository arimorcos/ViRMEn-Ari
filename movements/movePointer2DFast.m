function velocity = movePointer2DFast(vr)

velocity = [0 0 0 0];
if ~isfield(vr,'scaling')
    vr.scaling = [30 30];
end
scr = get(0,'screensize');
ptr = get(0,'pointerlocation')-scr(3:4)/2;
velocity(1) = ptr(1)*vr.scaling(1)/50;
velocity(2) = ptr(2)*vr.scaling(2)/50;