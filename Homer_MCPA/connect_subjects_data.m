function subjects_combined_struct = connect_subjects_data(data_file_array)

%% This function returns an array which contains combined data for all subject both in Homer1 and Homer2
% Input data_file_array must be a cell struct, with file names contained in
% each cell.


%% Convert char arrays to cell arrays, in case somebody tries to input char.
if ischar(data_file_array), data_file_array = cellstr(data_file_array); end


%% Preallocate the ideal structure. 
% The number of single structure that need to be connected.

number_of_files = size(data_file_array, 1);

% If somebody only inputs one file for some reason, quietly extract the 
% file and return the struct for them. Otherwise, proceed with the looping.
if number_of_files == 1,
    subjects_combined_struct = extract_Homer_File(load(data_file_array{1}, '-mat'));
    return
    
else
    
    % Declare an empty struct that will be the final output
    subjects_combined_struct = struct;
    test_file = load(data_file_array{1}, '-mat');
    
    if Homer_version(test_file) == 2 %Homer2
        
        subjects_combined_struct(number_of_files).aux = [];
        subjects_combined_struct(number_of_files).d = [];
        subjects_combined_struct(number_of_files).ml = [];
        subjects_combined_struct(number_of_files).procInput = [];
        subjects_combined_struct(number_of_files).procResult = [];
        subjects_combined_struct(number_of_files).s = [];
        subjects_combined_struct(number_of_files).SD = [];
        subjects_combined_struct(number_of_files).t = [];
        subjects_combined_struct(number_of_files).tIncMan = [];
        subjects_combined_struct(number_of_files).userdata = [];
        
    elseif Homer_version(test_file) == 1 %Homer1
        
        subjects_combined_struct(number_of_files).hmr = [];
        subjects_combined_struct(number_of_files).otp = [];
        
    end
    
    
    %% This main for loop add data into preallocated structure.
    for i = 1 : number_of_files
        
        fprintf('The array content is: %s.\n', data_file_array{i});
        try
            single_nirs_data = extract_Homer_File(load(data_file_array{i}, '-mat'));
            if logical(Homer_version(single_nirs_data))
                fprintf('Identified format data\n');
                subjects_combined_struct(i) = single_nirs_data;
            else
                fprintf('Unidentified format data. Data combination for subject %d failed\n', i);
                
            end
            
        catch
            fprintf('Failed to load number %d subject data.\n', i);
        end
        
    end
    
    % end of function
end
