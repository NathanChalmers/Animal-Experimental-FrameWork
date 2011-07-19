function r = isSubClass(OBJ, class)

if isobject(OBJ) ~= 1
    r = 0;
    return;
end

meta = metaclass(OBJ).SuperClassList;
r = 0;

for i = 1:length(meta)
    if strcmp(class, meta(1).Name) == 1
        r = 1;
        break;
    end
end