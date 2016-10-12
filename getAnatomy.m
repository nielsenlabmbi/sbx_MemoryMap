function anatomy = getAnatomy()
    global pixelTc;
    
    a = cellfun(@(x)mean(x,3),pixelTc,'uniformoutput',false);
    a = cell2mat(reshape(a,[1 1 length(a)]));
    anatomy = std(a,[],3);
end

