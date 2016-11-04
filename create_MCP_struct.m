function MCP_struct = create_MCP_struct(raw_nirs_file_name)
%% This function grab data from the Homer struct and create a pre-processing MCP_sturct. 
% Instructions...

raw_nirs_file = extract_Homer_File(load(raw_nirs_file_name, '-mat'));

[nirs_file_path, nirs_file_name, nirs_file_ext] = fileparts(raw_nirs_file_name);
%% Create a new struct
MCP_struct = struct;


%% Extract data from raw nirs file and add them into the MCP struct

% Experiment data

MCP_struct.Experiment_data.Runs.Run_ID = input('\nPlease enter run ID: ');
MCP_struct.Experiment_data.Runs.Indecies = input('\n Please enter run indecies(eg. [1:100]):');
MCP_struct.Experiment_data.Runs.Source_files = [nirs_file_name nirs_file_ext];



MCP_struct.Experiment_data.Prob_arrays.Array_ID = input('\n Please enter the Prob_array ID', 's');
MCP_struct.Experiment_data.Prob_arrays.Channels_in_Array = 1 : size(raw_nirs_file.procResult.dc, 3);
MCP_struct.Experiment_data.Prob_arrays.Geometry = [];
    



try 
marks_matrix_name = input('\nPlease indicate the name of matrix you store the marks data(eg. aux):', 's');
marks_number = size(eval(sprintf('raw_nirs_file.%s', marks_matrix_name)), 2);

catch 
    fprintf('\nPlease enter a valid file name.');
end


marks_name_array = [];

for i = 1:marks_number
    name = input('\n Please enter names for marks IN ORDER: ', 's');
    marks_name_array = union(marks_name_array, {name});
end
    
MCP_struct.Experiment_data.Conditions.Name = marks_name_array;
MCP_struct.Experiment_data.Conditions.Condition_mark = marks_number;





% Parameters about the subject
MCP_struct.About_subject.Subject_ID = input('\n Please enter subject id: ');
if nirs_file_path, 
    MCP_struct.About_subject.Absolute_path = nirs_file_path;
else
    MCP_struct.About_subject.Absolute_path = pwd;
end





% fNIRs time series data
MCP_struct.fNIRs_time_series.Sampling_frequency = input('\nPlease enter the sampling frequency:');
MCP_struct.fNIRs_time_series.On_Sets_Marks_Matrix = eval(sprintf('raw_nirs_file.%s', marks_matrix_name)); 



% fNIRs time series data
MCP_struct.fNIRs_time_series.Hb_data.Oxygenated = squeeze(raw_nirs_file.procResult.dc(:, 1, :));
MCP_struct.fNIRs_time_series.Hb_data.Deoxygenated = squeeze(raw_nirs_file.procResult.dc(:, 2, :));
MCP_struct.fNIRs_time_series.Hb_data.Total = squeeze(raw_nirs_file.procResult.dc(:, 3, :));

end









