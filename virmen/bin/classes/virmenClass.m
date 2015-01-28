classdef virmenClass < handle
    properties (SetObservable)
        name = '';
        parent;
        symbolic = struct;
        variables = struct;
    end
    properties (SetObservable, Hidden = true)
        items = struct;
    end
    properties (Hidden)
        backedUpVariables = struct;
        indexedName;
    end
    methods (Hidden = true)
        function enableCallbacks(par)
            desc = par.descendants;
            for obj = 1:length(desc)
                props = properties(desc{obj});
                for ndx = 1:length(props)
                    if strcmp(class(desc{obj}.(props{ndx})),'double')
                        if ~isfield(desc{obj}.symbolic,props{ndx})
                            val = desc{obj}.(props{ndx});
                            str = num2cell(val);
                            str = cellfun(@num2str,str,'uniformoutput',false);
                            desc{obj}.symbolic.(props{ndx}) = str;
                        end
                        if ~strcmp(props{ndx},'iconLocations')
                            addlistener(desc{obj},props{ndx},'PostSet',@setNumericProperty);
                        end
                    end
                end
                
                addlistener(desc{obj},'variables','PreSet',@backupVariableValues);
                addlistener(desc{obj},'variables','PostSet',@changeExperimentVariables);
                addlistener(desc{obj},'parent','PostSet',@fillAncestry);
            end
        end
        function updateNames(obj)
            allObj = descendants(ancestor(obj));
            names = cellfun(@(x)x.name,allObj,'UniformOutput',false);
            [names i j] = unique(names); %#ok<ASGLU>
            for ndx = 1:length(j)
                f = find(j==j(ndx));
                if length(f) == 1
                    allObj{ndx}.indexedName = allObj{ndx}.name;
                else
                    allObj{ndx}.indexedName = [allObj{ndx}.name '(' num2str(length(f(f<=ndx))) ')'];
                end
            end
        end
        function str = getValue(obj)
            str = struct;
            props = fieldnames(obj.symbolic);
            for ndx = 1:length(props)
                if iscell(obj.symbolic.(props{ndx}))
                    str.(props{ndx}) = obj.symbolic.(props{ndx});
                else
                    val = obj.(props{ndx});
                    str.(props{ndx}) = cell(size(val));
                    if numel(val)==1
                        str.(props{ndx}) = {obj.symbolic.(props{ndx})};
                    else
                        for v = 1:numel(val)
                            str.(props{ndx}){v} = num2str(val(v));
                        end
                    end
                end
            end
        end
    end
    methods
        function obj = virmenClass
            obj.name = class(obj);
            obj.parent = {};
            props = properties(obj);
            for ndx = 1:length(props)
                if strcmp(class(obj.(props{ndx})),'double')
                    val = obj.(props{ndx});
                    str = num2cell(val);
                    str = cellfun(@num2str,str,'uniformoutput',false);
                    obj.symbolic.(props{ndx}) = str;
                    if ~strcmp(props{ndx},'iconLocations')
                        addlistener(obj,props{ndx},'PostSet',@setNumericProperty);
                    end
                end
            end
            addlistener(obj,'variables','PreSet',@backupVariableValues);
            addlistener(obj,'variables','PostSet',@changeExperimentVariables);
            addlistener(obj,'parent','PostSet',@fillAncestry);
        end
        function val = get.items(obj)
            dsc = obj.descendants;
            val = struct;
            for ndx = 1:length(dsc)
                if ~isfield(val,dsc{ndx}.name)
                    val.(dsc{ndx}.name) = dsc{ndx};
                else
                    val.(dsc{ndx}.name) = [val.(dsc{ndx}.name) dsc{ndx}];
                end
            end
        end
        function gp = ancestor(obj)
            if isempty(obj.parent)
                gp = obj;
            else
                gp = obj.parent.ancestor;
            end
        end
        function dsc = descendants(obj)
            dsc = {obj};
            ch = obj.children;
            for ndx = 1:length(ch)
                dsc = [dsc ch{ndx}.descendants]; %#ok<AGROW>
            end
        end
        function str = fullName(obj)
            allObj = descendants(ancestor(obj));
            names = cellfun(@(x)x.name,allObj,'UniformOutput',false);
            objNdx = find(cellfun(@(x)x==obj,allObj),1);
            [names i j] = unique(names); %#ok<ASGLU>
            if length(find(j==j(objNdx)))==1
                str = obj.name;
            else
                f = find(j(1:objNdx)==j(objNdx));
                str = [obj.name '(' num2str(length(f)) ')'];
            end
        end
        function ch = children(obj) %#ok<MANU>
            ch = {};
        end
        function obj2 = copyVariable(obj1)
            obj2 = copyVirmenObject(obj1);
        end
    end
end