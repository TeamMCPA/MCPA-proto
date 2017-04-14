function homer_struct = extract_Homer_File(input_struct)
%% This function recursively searches a struct to find and return the HomER-formatted data

if logical(Homer_version(input_struct))
    % When HomER formatted data is found, the parent struct is returned
    homer_struct = input_struct;

else
    % If HomER formatted data are not found, check inside the first field
    % and see if any HomER data reside there. This condition catches
    % group-level data structs that were then saved into a file of their
    % own.
    data_name = fieldnames(input_struct);
    next_input_struct = eval(sprintf('input_struct.%s',data_name{1}));
    homer_struct = extract_Homer_File(next_input_struct);
    
end

end
