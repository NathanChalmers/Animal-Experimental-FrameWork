function record(DS, step)

for i = 1:length(DS.recordList)
    
    if isfield(DS.storeDim, DS.recordList{i}) ~= 1 || isfield(DS.storeWrite, DS.recordList{i}) ~= 1
        error('FrameSession:Record', 'Error: the record list element is not found in the data store');
    end
    
    %Safety check should happen to insure element exists, would incur
    %linear search
    try
        value = subsref(DS.OBJ, struct('type', '.', 'subs', DS.recordList{i}));
    catch err
        error('FrameSession:Record', 'Error: The property %s does not exist or is not publically accessible', DS.recordList{i});
    end
    
    valueDimensions = size(value);
    
    try
        storeDimensions = subsref(DS, struct('type', {'.', '.'}, 'subs', {'storeDim', DS.recordList{i}}));
    catch err
        error('FrameSession:Record', 'Error: The propety %s dimensions were never recorded while initializing the data store', DS.recordList{i});
    end
    
    if isequal(storeDimensions,-1)
        try
            subsasgn(DS,struct('type', {'.','{}'}, 'subs', {DS.recordList{i}, {step + 1}}),value);
            continue;
        catch err
            error('FrameSession:Record', 'Error: %s is not a valid property in the data store', DS.recordList{i});
        end
    end
    
    try
        asgnStatement = subsref(DS, struct('type', {'.','.'}, 'subs', {'storeWrite', DS.recordList{i}}));
        asgnStatement{1} = step + 1;
    catch err
        error('FrameSession:Record', 'Error: Write Commands for %s were not generated when initializing the data store', DS.recordList{i});
    end
    
    if isequal(valueDimensions, storeDimensions) ~= 1 && length(valueDimensions) == 2 && valueDimensions(1) == storeDimensions(2) && valueDimensions(2) == storeDimensions(1)
        value = value';
    end
    
    if isequal(valueDimensions, storeDimensions)
        try
            subsasgn(DS, struct('type',{'.','()'},'subs', {DS.recordList{i}, asgnStatement}),value);
            continue;
        catch err
            error('FrameSession:Record', 'Error: %s is not a valid property in the data store', DS.recordList{i});
        end
    end
    
    error('FrameSession:record', 'Error: The dimensions of the data store do not match those of the object trying to be recorded');
end

DS.step(1,step + 1) = step;