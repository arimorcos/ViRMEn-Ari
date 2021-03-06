function newObj = copyVirmenObject(obj)

newObj = eval(class(obj));
props = properties(newObj);
areThereVars = 0;
for ndx = 1:length(props)
    if strcmp(props{ndx},'variables')
        props = props([ndx 1:ndx-1 ndx+1:end]);
        areThereVars = 1;
    end
end

if areThereVars == 1
    fld = fieldnames(obj.variables);
    for ndx = 1:length(fld)
        newObj.variables.(fld{ndx}) = obj.variables.(fld{ndx});
    end
end

for ndx = (1+areThereVars):length(props)
    if strcmp(props{ndx},'parent') || strcmp(props{ndx},'items')
        newObj.(props{ndx}) = {};
    elseif iscell(obj.(props{ndx}))
        newObj.(props{ndx}) = cell(size(obj.(props{ndx})));
        for c = 1:numel(obj.(props{ndx}))
            newObj.(props{ndx}){c} = copyVirmenObject(obj.(props{ndx}){c});
        end
    else
        supr = superclasses(class(obj.(props{ndx})));
        if length(setdiff(supr,'virmenClass')) < length(supr)
            newObj.(props{ndx}) = copyVirmenObject(obj.(props{ndx}));
        else
            newObj.(props{ndx}) = obj.(props{ndx});
        end
    end
end

if areThereVars == 1
    fld = fieldnames(newObj.variables);
    for ndx = length(fld):-1:1
        if ~isfield(obj.variables,fld{ndx})
            newObj.variables = rmfield(newObj.variables,fld{ndx});
        end
    end
end

if strcmp(class(newObj),'virmenExperiment')
    newObj = updateCode(newObj);
end