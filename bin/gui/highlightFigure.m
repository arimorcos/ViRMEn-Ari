function highlightFigure

guifig = findall(0,'name','ViRMEn');
handles = guidata(guifig);

scr = get(0,'screensize');
ptr = get(0,'pointerlocation');
figpos = get(guifig,'position').*scr([3 4 3 4]);
ptr = (ptr-figpos(1:2))./figpos(3:4);
isin = structfun(@(x)all(sum(sign(cumsum(reshape(get(x,'position'),2,2),2)-[ptr' ptr']),2)'==0),handles.figs);
isvis = structfun(@(x)strcmp(get(x,'visible'),'on'),handles.figs);
f = find(and(isin,isvis),1);
if isempty(f)
    return
end
fld = fieldnames(handles.figs);
set(findobj(guifig,'type','uipanel'),'shadowcolor',[.5 .5 .5],'highlightcolor','w');
set(handles.figs.(fld{f}),'shadowcolor','r','highlightcolor','r');

buttons = [findall(guifig,'type','uipushtool'); findall(guifig,'type','uisplittool'); findall(guifig,'type','uitoggletool')];
set(handles.separated,'separator','on');
for ndx = 1:length(buttons)
    if ~strcmp(get(buttons(ndx),'userdata'),'n/a')
        ud = get(buttons(ndx),'userdata');
        ud(strfind(ud,'"')) = [];
        st = strfind(ud,',');
        st = [0 st length(ud)+1]; %#ok<AGROW>
        isVisible = false;
        for fg = 1:length(st)-1
            if all(get(handles.figs.(ud(st(fg)+1:st(fg+1)-1)),'highlightcolor')==[1 0 0])
                isVisible = true;
            end
        end
        if isVisible
            set(buttons(ndx),'visible','on');
        else
            set(buttons(ndx),'visible','off','separator','off');
        end
    end
end

m = findall(guifig,'type','uimenu');
for ndx = 1:length(m)
    if ~strcmp(get(m(ndx),'userdata'),'n/a')
        f = findall(guifig,'tooltipstring',get(m(ndx),'userdata'),'visible','on','enable','on');
        if ~isempty(f)
            set(m(ndx),'enable','on');
            if strcmp(get(f(1),'type'),'uitoggletool')
                set(m(ndx),'checked',get(f(1),'state'));
            end
        else
            if ~isempty(findall(guifig,'tooltipstring',get(m(ndx),'userdata')))
                set(m(ndx),'enable','off');
            end
        end
    end
end