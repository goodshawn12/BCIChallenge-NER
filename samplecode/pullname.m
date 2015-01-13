function fname = pullname(file) 


if iscell(file)
    if length(file) > 1
        fname = cell(size(file)); 
        for i = 1 : length(file)
            fname{i} = pullname(file{i}); 
        end
    end
else
    ix = find(file=='/'); 
    if ~isempty(ix)
        file = file(ix(end)+1:end); 
    end
    end_pt = find(file=='.'); 
    if ~isempty(end_pt)
        fname = file(1:end_pt-1); 
    else
        fname = file; 
    end
end