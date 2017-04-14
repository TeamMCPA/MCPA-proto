function verHomer = Homer_version(input_data) 

%% This function check the format of input data file.
% If the input file is a valid HomER file, it will return a version number
% of 1 (HomER1) or 2 (HomER2) based on the number of fields in the struct.
% Otherwise, it returns 0 for non-HomER files.

    data_name = fieldnames(input_data);
    
    % Homer1 format data struct contains only 2 fields
    if length(data_name) == 2 && (sum(strcmp(data_name,'hmr')) || sum(strcmp(data_name,'opt')))
        verHomer = 1;
        
    % Homer2 format data struct contains 10 fields
    elseif length(data_name) > 2 && sum(strcmp(data_name,'procResult'))
        verHomer = 2;
        
    % Unidentified data struct format
    else
        verHomer = 0;
    end

end
