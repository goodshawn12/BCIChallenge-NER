function [struct_obj,header,fname] = parse_frame(fname,spec)

arg.header=true; arg.spec=spec; arg.skip_lines=0; arg.delimiter=',';

fid = fopen(fname);
if arg.skip_lines > 0
    for i = 1 : arg.skip_lines
        fgetl(fid); 
    end
end
header = textscan(fgetl(fid),'%s','Delimiter',arg.delimiter);
header = header{1};
num_cols = length(header) ; 
if ~arg.header
    header = cell(1,num_cols); 
    for i = 1 : num_cols
        header{i} = ['column_',num2str(i)]; 
    end
    fseek(fid, 0, 'bof');
end
for i = 1 : num_cols
%     header{i} = header{i}; 
    tmp = header{i}; 
    tmp(tmp==' ' | tmp =='-' | tmp=='@' | tmp =='.') = '_';
    tmp(tmp=='#' | tmp=='(' | tmp ==')' | tmp ==',' | tmp==':' ... 
        | tmp =='/' | tmp=='"' ) = [];
    ix = find(tmp=='_'); 
    if any(ix==1) 
        tmp(1) = [];
    end 
    if ~isnan(str2double(tmp(1))) && ~strcmp('i',tmp(1)) && ~strcmp('j',tmp(1))
        % this allows for numeric column header, adds 's' for struct comp.
        header{i} = ['s',tmp]; 
    else
        header{i} = tmp;
    end
     
end

struct_obj = struct(); 

if ~isempty(arg.spec)
    c = textscan(fid,arg.spec,'Delimiter',arg.delimiter,'Headerlines',arg.skip_lines); 
else
    c = textscan(fid,repmat('%s',[1,num_cols]),'Delimiter',arg.delimiter,'Headerlines',arg.skip_lines); 
end
fclose(fid); 

if any(strcmp('',header))
    header(strcmp('',header)) = [];
    num_cols = length(header) ; 
end


for i = 1 : num_cols
    header{i} = pullname(regexprep(header{i},' ','_')); 
    try
        struct_obj.(header{i}) = c{i}; 
    catch em
        disp(em)
        tmp = header{i}; 
        tmp(1)=[];
        header{i} = tmp; 
        try
            struct_obj.(header{i}) = c{i};
        catch em
            disp(em)
            struct_obj.(['column_',num2str(i)]) = c{i}; 
        end
    end
end