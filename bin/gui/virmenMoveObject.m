function virmenMoveObject(varargin)

global virmenDragging

guifig = findall(0,'name','ViRMEn');

if isempty(virmenDragging) || ~isstruct(virmenDragging)
    handles = guidata(guifig);
    ax = findobj(handles.figs.worldSketch,'type','axes');
    if ishandle(ax)
        if handles.state.selectedObject == 0
            tt = get(ax,'title');
            set(tt,'string','');
        else
            pt = get(ax,'currentpoint');
            pt = pt(1,1:2);
            xl = get(ax,'xlim');
            yl = get(ax,'ylim');
            mn = inf;
            try
                warning off %#ok<WNOFF>
                loc = handles.exper.worlds{handles.state.selectedWorld}.objects{handles.state.selectedObject}.locations;
                dst = sqrt(sum(bsxfun(@minus,loc,pt).^2,2))/min(range(xl),range(yl));
                [mn indx] = min(dst);
                warning on %#ok<WNON>
            catch %#ok<CTCH>
                % object is in the process of change/deletion
            end
            tt = get(ax,'title');
            if mn > .05
                set(tt,'string','');
            else
                set(tt,'string',['Location #' num2str(indx)]);
            end
        end
    end
    ax = findobj(handles.figs.textureSketch,'type','axes');
    if ishandle(ax)
        pt = get(ax,'currentpoint');
        pt = pt(1,1:2);
        xl = get(ax,'xlim');
        yl = get(ax,'ylim');
        mn = inf;
        try
            warning off %#ok<WNOFF>
            loc = handles.exper.worlds{handles.state.selectedWorld}.objects{handles.state.selectedObject}.texture.shapes{handles.state.selectedShape}.locations;
            dst = sqrt(sum(bsxfun(@minus,loc,pt).^2,2))/min(range(xl),range(yl));
            [mn indx] = min(dst);
            warning off %#ok<WNOFF>
        catch %#ok<CTCH>
            % object in the process of changing/deletion
        end
            tt = get(ax,'title');
            if mn > .05
                set(tt,'string','');
            else
                set(tt,'string',['Location #' num2str(indx)]);
            end
    end
    return
end

set(guifig,'units','pixels');
pos = get(guifig,'currentpoint');
set(guifig,'units',virmenDragging.backupUnitsFigure);

df = pos - virmenDragging.startPt;

if max(abs(df)<2)
    return
end

set(virmenDragging.axes,'units','pixels');
axPos = get(virmenDragging.axes,'position');
set(virmenDragging.axes,'units',virmenDragging.backupUnitsAxes)

perc = df./axPos(3:4);
lm(1) = range(get(virmenDragging.axes,'xlim'));
lm(2) = range(get(virmenDragging.axes,'ylim'));
move = perc.*lm;

switch virmenDragging.type
    case {'shape','object'}
        if isempty(virmenDragging.tempShape)
            ax = get(guifig,'currentaxes');
            set(guifig,'currentaxes',virmenDragging.axes);
            virmenDragging.tempShape = plot(virmenDragging.axes,virmenDragging.x+move(1),virmenDragging.x+move(2),'marker',virmenDragging.marker,'markersize',virmenDragging.markerSize);
            set(guifig,'currentaxes',ax);
        else
            set(virmenDragging.tempShape,'xdata',virmenDragging.x+move(1),'ydata',virmenDragging.y+move(2));
        end
    case {'objectLocation','shapeLocation'}
        if isempty(virmenDragging.tempShape)
            ax = get(guifig,'currentaxes');
            set(guifig,'currentaxes',virmenDragging.axes);
            virmenDragging.x(virmenDragging.indx) = virmenDragging.startX(virmenDragging.indx) + move(1);
            virmenDragging.y(virmenDragging.indx) = virmenDragging.startY(virmenDragging.indx) + move(2);
            virmenDragging.object.x = virmenDragging.x;
            virmenDragging.object.y = virmenDragging.y;
            [x, y] = virmenDragging.object.coords2D;
            virmenDragging.tempShape = plot(virmenDragging.axes,x,y,'marker',virmenDragging.marker,'markersize',virmenDragging.markerSize);
            set(guifig,'currentaxes',ax);
        else
            virmenDragging.x(virmenDragging.indx) = virmenDragging.startX(virmenDragging.indx) + move(1);
            virmenDragging.y(virmenDragging.indx) = virmenDragging.startY(virmenDragging.indx) + move(2);
            virmenDragging.object.x = virmenDragging.x;
            virmenDragging.object.y = virmenDragging.y;
            [x, y] = virmenDragging.object.coords2D;
            set(virmenDragging.tempShape,'xdata',x,'ydata',y);
        end
    case {'shapeCopy','objectCopy'}
        if isempty(virmenDragging.tempShape)
            ax = get(guifig,'currentaxes');
            set(guifig,'currentaxes',virmenDragging.axes);
            xs = virmenDragging.startX;
            ys = virmenDragging.startY;
            xs(end+1,1) = virmenDragging.startX(virmenDragging.indx) + move(1);
            ys(end+1,1) = virmenDragging.startY(virmenDragging.indx) + move(2);
            
            sz = length(xs);
            if virmenDragging.indx == 1
                ord = [sz 1:sz-1];
            elseif virmenDragging.indx == length(virmenDragging.startX)
                ord = 1:sz;
            elseif norm([xs(sz) ys(sz)]-[xs(virmenDragging.indx-1) ys(virmenDragging.indx-1)]) < ...
                    norm([xs(sz) ys(sz)]-[xs(virmenDragging.indx+1) ys(virmenDragging.indx+1)])
                ord = [1:virmenDragging.indx-1 sz virmenDragging.indx:sz-1];
            else
                ord = [1:virmenDragging.indx sz virmenDragging.indx+1:sz-1];
            end
            xs = xs(ord);
            ys = ys(ord);

            virmenDragging.object.x = xs;
            virmenDragging.object.y = ys;
            [x, y] = virmenDragging.object.coords2D;
            virmenDragging.tempShape = plot(virmenDragging.axes,x,y,'marker',virmenDragging.marker,'markersize',virmenDragging.markerSize);
            set(guifig,'currentaxes',ax);
        else
            xs = virmenDragging.startX;
            ys = virmenDragging.startY;
            xs(end+1,1) = virmenDragging.startX(virmenDragging.indx) + move(1);
            ys(end+1,1) = virmenDragging.startY(virmenDragging.indx) + move(2);
            
            sz = length(xs);
            if virmenDragging.indx == 1
                ord = [sz 1:sz-1];
            elseif virmenDragging.indx == length(virmenDragging.startX)
                ord = 1:sz;
            elseif norm([xs(sz) ys(sz)]-[xs(virmenDragging.indx-1) ys(virmenDragging.indx-1)]) < ...
                    norm([xs(sz) ys(sz)]-[xs(virmenDragging.indx+1) ys(virmenDragging.indx+1)])
                ord = [1:virmenDragging.indx-1 sz virmenDragging.indx:sz-1];
            else
                ord = [1:virmenDragging.indx sz virmenDragging.indx+1:sz-1];
            end
            xs = xs(ord);
            ys = ys(ord);
            
            virmenDragging.object.x = xs;
            virmenDragging.object.y = ys;
            [x, y] = virmenDragging.object.coords2D;
            set(virmenDragging.tempShape,'xdata',x,'ydata',y);
        end
end
drawnow