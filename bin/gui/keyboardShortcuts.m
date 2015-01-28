function keyboardShortcuts(fig,evt) %#ok<INUSL>

guifig = findall(0,'name','ViRMEn');
handles = guidata(guifig);

src = findobj(guifig,'type','uipanel','shadowcolor','r');

if isempty(evt.Modifier)
    evt.Modifier = '';
end

for ndx = 1:length(handles.shortcuts)
    if strcmp(evt.Key,handles.shortcuts(ndx).key) && strcmp(evt.Modifier,handles.shortcuts(ndx).modifier) && ~strcmp(handles.shortcuts(ndx).modifier,'control')
        if isempty(handles.shortcuts(ndx).figure) || src == handles.(handles.shortcuts(ndx).figure)
            f = findall(guifig,'callback',['virmenEventHandler(''' handles.shortcuts(ndx).callback ''',''' handles.shortcuts(ndx).input ''');'], ...
                'enable','on','type','uimenu');
            g = findall(guifig,'callback',['virmenEventHandler(''' handles.shortcuts(ndx).callback ''',{''switch'',''' handles.shortcuts(ndx).input '''});'], ...
                'enable','on','type','uimenu');
            if ~isempty(f) || ~isempty(g)
                virmenEventHandler(handles.shortcuts(ndx).callback,handles.shortcuts(ndx).input);
            end
        end
    end
end