function varargout = chooseObjectGui(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @chooseObjectGui_OpeningFcn, ...
                   'gui_OutputFcn',  @chooseObjectGui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before chooseObjectGui is made visible.
function chooseObjectGui_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>

handles.currentExperiment = varargin{1};
handles.type = varargin{2};

scr = get(0,'screensize');
set(handles.mainFigure,'position',[50 100 scr(3)-100 scr(4)-200]);

mfile = mfilename('fullpath');
path = fileparts(mfile);
mt = dir([path filesep '..' filesep '..' filesep 'experiments' filesep '*.mat']);

str = {'[Current experiment]'};
for ndx = 1:length(mt)
    str{ndx+1} = mt(ndx).name(1:end-4);
end
set(handles.list_experiments,'string',str);

handles = loadExperiment(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes chooseObjectGui wait for user response (see UIRESUME)
uiwait(handles.mainFigure);


function handles = loadExperiment(handles)

val = get(handles.list_experiments,'value');
if val == 1
    exper = handles.currentExperiment;
else
    str = get(handles.list_experiments,'string');
    load(str{val});
end

items = exper.descendants;
for ndx = length(items):-1:1
    supr = superclasses(items{ndx});
    if length(setdiff(supr,handles.type))==length(supr) && ~strcmp(class(items{ndx}),handles.type)
        items(ndx) = [];
    end
end
set(handles.mainFigure,'userdata',items);

wd = 1;
hg = 1;
while wd*hg < length(items)
    if wd == 2*(hg+1) || wd == 8
        hg = hg+1;
    else
        wd = wd+1;
    end
end
scale = .95;

listPos = get(handles.list_experiments,'position');
ndx = 1;
delete(findobj(handles.mainFigure,'type','axes'));
xs = [];
ys = [];
zs = [];
axs = [];
for y = hg:-1:1
    for x = 1:wd
        pos = [(x-1)/wd+(1-scale)/(2*wd) (y-1)/hg+(1-scale)/(2*hg) scale/wd scale/hg];
        pos(1) = (listPos(1)+listPos(3))+pos(1)*(1-(listPos(1)+listPos(3)));
        pos(2) = listPos(2)+pos(2)*listPos(4);
        pos(3) = pos(3)*(1-(listPos(1)+listPos(3)));
        pos(4) = pos(4)*listPos(4);
        axes('outerposition',pos);
        if ndx <= length(items)
            switch handles.type
                case 'virmenWorld'
                    [h he hp] = items{ndx}.draw2D;
                    if ~isempty(h)
                        delete([he hp]);
                        he = [];
                    end
                    view(3)
                    axis tight;
                    axis equal;
                    set(gca,'xtick',[],'ytick',[],'ztick',[],'box','off');
                    tt = title(items{ndx}.fullName);
                    hands = [h he tt];
                    
                    xs(end+1) = range(get(gca,'xlim')); %#ok<AGROW>
                    ys(end+1) = range(get(gca,'ylim')); %#ok<AGROW>
                    zs(end+1) = range(get(gca,'zlim')); %#ok<AGROW>
                    axs(end+1) = gca; %#ok<AGROW>
                case 'virmenTexture'
                    h = items{ndx}.draw;
                    set(h,'edgecolor','none');
                    view(2);
                    axis tight;
                    xl = xlim;
                    yl = ylim;
                    mx = max([range(xl) range(yl)])*1.05;
                    axis equal;
                    axis off;
                    xlim([mean(xl)-mx/2 mean(xl)+mx/2]);
                    ylim([mean(yl)-mx/2 mean(yl)+mx/2]);
                    tt = title(items{ndx}.fullName);
                    hands = [h tt];
                case 'virmenObject'
                    h = items{ndx}.draw3D;
                    set(h,'edgecolor','none');
                    axis tight;
                    axis equal;
                    set(gca,'xtick',[],'ytick',[],'ztick',[]);
                    grid off;
                    set(gca,'color','none');
                    tt = title(items{ndx}.fullName);
                    hands = [h tt];
            end
            set(tt,'interpreter','none','units','pixels');
            hands = [hands gca]; %#ok<AGROW>
            set(hands,'userdata',ndx);
            set(hands,'buttondownfcn',@clickObject); %['handles.output = ' num2str(ndx) '; guidata(gcf, handles); uiresume;']);
        else
            axis off
        end
        ndx = ndx+1;
    end
end

switch handles.type
    case 'virmenWorld'
        if ~isempty(xs)
            xs = max(xs)/2*1.05;
            ys = max(ys)/2*1.05;
            zs = max(zs)/2*1.05;
            for ndx = 1:length(axs);
                xl = get(axs(ndx),'xlim');
                yl = get(axs(ndx),'ylim');
                zl = get(axs(ndx),'zlim');
                set(axs(ndx),'xlim',mean(xl)+[-xs xs]);
                set(axs(ndx),'ylim',mean(yl)+[-ys ys]);
                set(axs(ndx),'zlim',mean(zl)+[-zs zs]);
            end
        end
end

function clickObject(src,evt)

handles = guidata(src);
handles.output = get(src,'userdata');
guidata(src, handles);
uiresume;

% --- Outputs from this function are returned to the command line.
function varargout = chooseObjectGui_OutputFcn(hObject, eventdata, handles)  %#ok<*INUSD>

if isempty(handles)
    varargout{1} = [];
    varargout{2} = [];
else
    items = get(gcf,'userdata');
    obj = items{handles.output};
    
    vars = variablesList(obj);   
    
    varargout{1} = obj;
    varargout{2} = vars;
    close(gcf)
end


function virmenVariablesList = variablesList(virmenObj)

virmenVariablesList = struct;
virmenItems = virmenObj.descendants;
for virmenNdx = 1:length(virmenItems)
    virmenProps = fieldnames(virmenItems{virmenNdx}.symbolic);
    for virmenP = 1:length(virmenProps)
        virmenStr = virmenItems{virmenNdx}.symbolic.(virmenProps{virmenP});
        if ~iscell(virmenStr)
            virmenStr = {virmenStr};
        end
        for virmenS = 1:length(virmenStr)
            try
                eval([virmenStr{virmenS} ';']);
            catch virmenME
                virmenF = strfind(virmenME.message,'''');
                virmenVarName = virmenME.message(virmenF(1)+1:virmenF(2)-1);
                virmenVariablesList.(virmenVarName) = virmenItems{virmenNdx}.ancestor.variables.(virmenVarName);
            end
        end
    end
end


% --- Executes on selection change in list_experiments.
function list_experiments_Callback(hObject, eventdata, handles) %#ok<*DEFNU>

handles = loadExperiment(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function list_experiments_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
