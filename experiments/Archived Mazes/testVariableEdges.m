function code = testVariableEdges
% testVariableEdges   Code for the ViRMEn experiment testVariableEdges.
%   code = testVariableEdges   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT



% --- INITIALIZATION code: executes before the ViRMEN engine starts.
function vr = initializationCodeFun(vr)
vr.mazeStart = tic;


% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

mazeDur = toc(vr.mazeStart);
if mazeDur > 10
    edgeInd = vr.worlds{1}.objects.edges(1,:);
    vr.worlds{1}.edges.radius(edgeInd(1):edgeInd(2)) = NaN; 
end



% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
