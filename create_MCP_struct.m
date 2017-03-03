 function MCP_struct = create_MCP_struct(data_file_array)
%% This function grab data from the nirs file and create a pre-processing MCP_sturct. 
% NOTICE: The funtion is for single subject, single run, and single prob.
% The MCP_struct contains the following fields:
%
% Subject: 
% This field collects some information about the subject, and the
% path of the nirs file. It contains two subfield: Subject_ID and
% Absolute_path
%
% Experiment_data: 
% This field collects the data of "Runs", "Prob", and "Conditions".
% Each of the subfield contains their fields. 
%   "Runs" contains Run_ID, Indecies, and Source_files.
%   "Prob_arrays" contains Array_ID, Channels_in_Array, and Geometry.
%   "Contidions" contains Name and Condition_mark
% 
% fNIRs_time_series:
% This collect the data of "Sampling_frequency", "On_Sets_Marks_Matrix", and "Hb_data".
% "Hb_data" contains the following subfields:
% Oxygenated
% Deoxygenated
% Toal
%
%The function is the process of how these fields obtain the data.
%
%

% Get the path of the file. 
raw_nirs_file = extract_Homer_File(load(data_file_array, '-mat'));
[nirs_file_path, nirs_file_name, nirs_file_ext] = fileparts(data_file_array);
%% Create a new empty struct
MCP_struct = struct;


%% Extract data from raw nirs file and add them into the MCP struct

% Parameters about the subject
MCP_struct.About_subject.Subject_ID = input('\nPlease enter subject id: ', 's');
if nirs_file_path, 
    MCP_struct.About_subject.Absolute_path = nirs_file_path;
else
    MCP_struct.About_subject.Absolute_path = pwd;
end

% Experiment data 
MCP_struct.Experiment_data.Runs.Run_ID = input('\nPlease enter run ID: ', 's');
MCP_struct.Experiment_data.Runs.Indecies = input('\nPlease enter run indecies(eg. [1:100]): ');
MCP_struct.Experiment_data.Runs.Source_files = [nirs_file_name nirs_file_ext];


MCP_struct.Experiment_data.Prob_arrays.Array_ID = input('\n Please enter the Prob_array ID: ', 's');
MCP_struct.Experiment_data.Prob_arrays.Channels_in_Array = 1 : size(raw_nirs_file.procResult.dc, 3);
MCP_struct.Experiment_data.Prob_arrays.Geometry = [];
    
% Get marks matrix conditions
try 
marks_matrix_name = input('\nPlease indicate the name of matrix you store the marks data(eg. aux): ', 's');
marks_number = size(eval(sprintf('raw_nirs_file.%s', marks_matrix_name)), 2);

catch 
    fprintf('\nPlease enter a valid file name: ');
end


marks_name_array = [];

for i = 1:marks_number
    name = input('\nPlease enter names for marks IN ORDER: ', 's');
    marks_name_array = union(marks_name_array, {name});
end
    
MCP_struct.Experiment_data.Conditions.Name = marks_name_array;
MCP_struct.Experiment_data.Conditions.Condition_mark = marks_number;


% fNIRs time series data
MCP_struct.fNIRs_time_series.Sampling_frequency = input('\nPlease enter the sampling frequency: ');
MCP_struct.fNIRs_time_series.On_Sets_Marks_Matrix = eval(sprintf('raw_nirs_file.%s', marks_matrix_name)); 

MCP_struct.fNIRs_time_series.Hb_data.Oxygenated = squeeze(raw_nirs_file.procResult.dc(:, 1, :));
MCP_struct.fNIRs_time_series.Hb_data.Deoxygenated = squeeze(raw_nirs_file.procResult.dc(:, 2, :));
MCP_struct.fNIRs_time_series.Hb_data.Total = squeeze(raw_nirs_file.procResult.dc(:, 3, :));

fprintf('MCP_Struct done!\n');


end









