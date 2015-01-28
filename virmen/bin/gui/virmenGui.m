function varargout = virmenGui(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @virmenGui_OpeningFcn, ...
                   'gui_OutputFcn',  @virmenGui_OutputFcn, ...
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


% --- Executes just before virmenGui is made visible.
function virmenGui_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>

global virmenButtonHandles

virmenButtonHandles = struct;

% Read shortcuts
fid = fopen('keyboardShortcuts.txt');
txt = textscan(fid,'%s','delimiter','\t');
txt = txt{1};
numCol = 5;
txt = reshape(txt,numCol,length(txt)/numCol)';
fclose(fid);
handles.shortcuts = struct;
for ndx = 2:size(txt,1)
    for j = 1:size(txt,2)
        handles.shortcuts(ndx-1).(txt{1,j}) = txt{ndx,j};
    end
end

% Read event booleans file
fid = fopen('eventBooleans.txt');
txt = textscan(fid,'%s','delimiter','\t');
txt = txt{1};
indx = find(cellfun(@(x)isnan(str2double(x)),txt));
numCol = length(txt)-indx(end)+1;
txt = reshape(txt,numCol,length(txt)/numCol)';
for ndx = 2:size(txt,1)
    handles.evtNames.(txt{ndx,1}) = ndx-1;
    handles.historyBool.(txt{ndx,1}) = str2double(txt{ndx,2});
    handles.highlightFig.(txt{ndx,1}) = txt{ndx,3};
end
for ndx = 4:size(txt,2)
    handles.figNames.(txt{1,ndx}) = ndx-3;
end
handles.bools = cellfun(@str2double,txt(2:end,4:end));
handles.changedFigs = zeros(1,size(handles.bools,2));
fclose(fid);

mfile = mfilename('fullpath');
path = fileparts(mfile);
if ~exist([path filesep '..' filesep '..' filesep 'defaults'],'dir')
    mkdir([path filesep '..' filesep '..' filesep 'defaults']);
end
if ~exist([path filesep '..' filesep '..' filesep 'defaults' filesep 'defaultVirmenCode.m'],'file')
    copyfile([path filesep 'defaultVirmenCode.m'],[path filesep '..' filesep '..' filesep 'defaults' filesep 'defaultVirmenCode.m']);
end
if ~exist([path filesep '..' filesep '..' filesep 'defaults' filesep 'defaultLayout.txt'],'file')
    copyfile([path filesep 'defaultLayout.txt'],[path filesep '..' filesep '..' filesep 'defaults' filesep 'defaultLayout.txt']);
end
if ~exist([path filesep '..' filesep '..' filesep 'defaults' filesep 'defaultFunctions.txt'],'file')
    copyfile([path filesep 'defaultFunctions.txt'],[path filesep '..' filesep '..' filesep 'defaults' filesep 'defaultFunctions.txt']);
end
if ~exist([path filesep '..' filesep '..' filesep 'defaults' filesep 'defaultProperties.txt'],'file')
    copyfile([path filesep 'defaultProperties.txt'],[path filesep '..' filesep '..' filesep 'defaults' filesep 'defaultProperties.txt']);
end

% Transfer built-on objects and shapes
mt = dir([path filesep '..' filesep 'classes' filesep 'builtinShapes' filesep '*.m']);
for ndx = 1:length(mt)
    copyfile([path filesep '..' filesep 'classes' filesep 'builtinShapes' filesep mt(ndx).name], ...
        [path filesep '..' filesep '..' filesep 'shapes' filesep mt(ndx).name(1:end)]);
end
mt = dir([path filesep '..' filesep 'classes' filesep 'builtinObjects' filesep '*.m']);
for ndx = 1:length(mt)
    copyfile([path filesep '..' filesep 'classes' filesep 'builtinObjects' filesep mt(ndx).name], ...
        [path filesep '..' filesep '..' filesep 'objects' filesep mt(ndx).name(1:end)]);
end

% Read default properties
fid = fopen([path filesep 'defaultProperties.txt']);
txt = textscan(fid,'%s','delimiter','\t');
txt = txt{1};
for ndx = 1:2:length(txt)-1
    handles.defaultProperties.(txt{ndx}) = eval(txt{ndx+1});
end
fid = fopen([path filesep '..' filesep '..' filesep 'defaults' filesep 'defaultProperties.txt']);
txt = textscan(fid,'%s','delimiter','\t');
txt = txt{1};
for ndx = 1:2:length(txt)-1
    handles.defaultProperties.(txt{ndx}) = eval(txt{ndx+1});
end
fclose(fid);

handles.layouts = layoutList;

handles.state = virmenGuiState(handles.defaultProperties);
handles.history.states = cell(1,100);
for ndx = 1:length(handles.history.states)
    handles.history.states{ndx}.state = [];
    handles.history.states{ndx}.undo = struct;
    handles.history.states{ndx}.redo = struct;
end
handles.history.position = 0;
handles.exper = virmenExperiment;
handles.exper.antialiasing = handles.defaultProperties.antialiasing;
handles.exper.worlds{1}.backgroundColor = handles.defaultProperties.worldBackgroundColor;
handles.exper.worlds{1}.startLocation = handles.defaultProperties.startLocation;

fid = fopen([path filesep '..' filesep '..' filesep 'defaults' filesep 'defaultFunctions.txt']);
txt = textscan(fid,'%s','delimiter','\t');
txt = txt{1};
for ndx = 1:2:length(txt)-1
    handles.exper.(txt{ndx}) = str2func(txt{ndx+1});
end
fclose(fid);

set(handles.mainFigure,'windowbuttonupfcn',@virmenDropObject,'WindowButtonMotionFcn',@virmenMoveObject);

guidata(hObject,handles);

virmenEventHandler('startProgram',[]);

% --- Outputs from this function are returned to the command line.
function varargout = virmenGui_OutputFcn(hObject, eventdata, handles)  %#ok<*INUSD>

% Get default command line output from handles structure
varargout{1} = [];

function closereq_Callback(hObject, eventdata, handles)

virmenEventHandler('closeProgram',[]);


% --- Executes on button press in push_editCode.
function push_editCode_Callback(hObject, eventdata, handles) %#ok<*DEFNU>

virmenEventHandler('editCode','experimentCode');

% --- Executes on selection change in pop_movements.
function pop_movements_Callback(hObject, eventdata, handles)

str = get(hObject,'string');
val = get(hObject,'value');
hand = str2func(str{val});
virmenEventHandler('changeExperimentProperties',{'movementFunction',hand});


% --- Executes during object creation, after setting all properties.
function pop_movements_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pop_transformations.
function pop_transformations_Callback(hObject, eventdata, handles)

str = get(hObject,'string');
val = get(hObject,'value');
hand = str2func(str{val});
virmenEventHandler('changeExperimentProperties',{'transformationFunction',hand});


% --- Executes during object creation, after setting all properties.
function pop_transformations_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_antialiasing_Callback(hObject, eventdata, handles)

virmenEventHandler('changeExperimentProperties',{'antialiasing',get(hObject,'string')});


% --- Executes during object creation, after setting all properties.
function edit_antialiasing_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pop_object.
function pop_object_Callback(hObject, eventdata, handles)

val = get(hObject,'value');
virmenEventHandler('objectClick',val-1);


% --- Executes during object creation, after setting all properties.
function pop_object_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in push_objectSymbolic.
function push_objectSymbolic_Callback(hObject, eventdata, handles)


virmenEventHandler('changeSymbolicObjectLocations',[]);


function edit_tilingVertical_Callback(hObject, eventdata, handles)

virmenEventHandler('changeTiling',{1,get(hObject,'string')});


% --- Executes during object creation, after setting all properties.
function edit_tilingVertical_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_tilingHorizontal_Callback(hObject, eventdata, handles)

virmenEventHandler('changeTiling',{2,get(hObject,'string')});


% --- Executes during object creation, after setting all properties.
function edit_tilingHorizontal_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_edgeRadius_Callback(hObject, eventdata, handles)

virmenEventHandler('changeObjectProperties',{'edgeRadius',get(hObject,'string')});


% --- Executes during object creation, after setting all properties.
function edit_edgeRadius_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_renameObject.
function push_renameObject_Callback(hObject, eventdata, handles)

virmenEventHandler('renameObject',[]);


function objectPropertiesEdit_Callback(hObject, eventdata, handles)

data = get(handles.table_objectProperties,'data');
rows = data(:,1);
indx = eventdata.Indices(1);
val  = eventdata.NewData;
virmenEventHandler('changeObjectProperties',{rows{indx},val});

function objectPropertiesSelect_Callback(hObject, eventdata, handles)

highlightFigure;


function objectLocationsEdit_Callback(hObject, eventdata, handles)

data = get(handles.table_objectLocations,'data');
virmenEventHandler('changeObjectLocations',data(:,2:end));

function objectLocationsSelect_Callback(hObject, eventdata, handles)

set(hObject,'userdata',eventdata.Indices(:,1));
highlightFigure;


% --- Executes on selection change in pop_shape.
function pop_shape_Callback(hObject, eventdata, handles)

val = get(hObject,'value');
virmenEventHandler('shapeClick',val);


% --- Executes during object creation, after setting all properties.
function pop_shape_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_setShapeColor.
function push_setShapeColor_Callback(hObject, eventdata, handles)

virmenEventHandler('shapeClick',{handles.state.selectedShape,'open'})


% --- Executes on button press in push_shapeSymbolic.
function push_shapeSymbolic_Callback(hObject, eventdata, handles)

virmenEventHandler('changeSymbolicShapeLocations',[]);


% --- Executes on button press in push_renameShape.
function push_renameShape_Callback(hObject, eventdata, handles)

virmenEventHandler('renameShape',[]);


function shapePropertiesEdit_Callback(hObject, eventdata, handles)

data = get(handles.table_shapeProperties,'data');
rows = data(:,1);
indx = eventdata.Indices(1);
val  = eventdata.NewData;
virmenEventHandler('changeShapeProperties',{rows(indx),{val}});


function shapePropertiesSelect_Callback(hObject, eventdata, handles)

highlightFigure;



function shapeLocationsEdit_Callback(hObject, eventdata, handles)

data = get(handles.table_shapeLocations,'data');
virmenEventHandler('changeShapeLocations',data(:,2:end));


function shapeLocationsSelect_Callback(hObject, eventdata, handles)

set(hObject,'userdata',eventdata.Indices(:,1));
highlightFigure;


function variablesEdit_Callback(hObject, eventdata, handles)

data = get(handles.table_variables,'data');
rows = data(:,1);
indx = eventdata.Indices(1);
val  = eventdata.NewData;
virmenEventHandler('changeVariables',{rows{indx},val});

function variablesSelect_Callback(hObject, eventdata, handles)

set(hObject,'userdata',eventdata.Indices(:,1));
highlightFigure;


% --- Executes on selection change in pop_experimentCode.
function pop_experimentCode_Callback(hObject, eventdata, handles)

str = get(hObject,'string');
val = get(hObject,'value');
if strcmp(str{val}(1),'[')
    fn = [];
else
    fn = str2func(str{val});
end
    
virmenEventHandler('changeExperimentProperties',{'experimentCode',fn});


% --- Executes during object creation, after setting all properties.
function pop_experimentCode_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_editTransformation.
function push_editTransformation_Callback(hObject, eventdata, handles)

virmenEventHandler('editCode','transformationFunction');


% --- Executes on button press in push_editMovement.
function push_editMovement_Callback(hObject, eventdata, handles)

virmenEventHandler('editCode','movementFunction');


% --- Executes on button press in push_sortShapes.
function push_sortShapes_Callback(hObject, eventdata, handles)

virmenEventHandler('sortShapes','n/a');

% --- Executes on button press in push_sortObjects.
function push_sortObjects_Callback(hObject, eventdata, handles)

virmenEventHandler('sortObjects','n/a');
