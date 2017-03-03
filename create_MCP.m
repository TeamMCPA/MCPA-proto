function MCP_Struct = create_MCP(data_file_array)

%% This function grab data from the Homer struct and create a pre-processing MCP_sturct. 
% NOTICE: The funtion is for single subject and single prob and multiple
% runs. The funciton takes a cell array of file name as input. Each file is
% the data of different runs from a single subject and a single prob. 
%
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

%% Convert char arrays to cell arrays, in case somebody tries to input char.
if ischar(data_file_array), data_file_array = cellstr(data_file_array); end

number_of_files = size(data_file_array, 2);

%% Create a new struct
MCP_Struct = struct;

raw_nirs_file = extract_Homer_File(load(data_file_array{1}, '-mat'));
[nirs_file_path, nirs_file_name, nirs_file_ext] = fileparts(data_file_array{1});

%% Extract data from raw nirs file and add them into the MCP struct

MCP_Struct.About_subject.Subject_ID = input('\nPlease enter subject id: ', 's');  %Subject ID
if nirs_file_path,
   MCP_Struct.About_subject.Absolute_path = nirs_file_path; %Absolute Path
else
   MCP_Struct.About_subject.Absolute_path = pwd;
end
   
MCP_Struct.Experiment_data.Prob_arrays.Array_ID = input('\n Please enter the Prob_array ID: ', 's'); % Prob Array ID
MCP_Struct.Experiment_data.Prob_arrays.Channels_in_Array = 1 : size(raw_nirs_file.procResult.dc, 3); % channels
MCP_Struct.Experiment_data.Prob_arrays.Geometry = []; % geometry
       
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
    
MCP_Struct.Experiment_data.Conditions.Name = marks_name_array;
MCP_Struct.Experiment_data.Conditions.Condition_mark = marks_number;

MCP_Struct.fNIRs_time_series.Sampling_frequency = input('\nPlease enter the sampling frequency: ');


fprintf('Enter run 1 infomration:\n');
MCP_Struct.Experiment_data.Runs.Run_ID = input('\nPlease enter run ID: ', 's');
MCP_Struct.Experiment_data.Runs.Indecies = input('\nPlease enter run indecies(eg. [1:100]): ');
MCP_Struct.Experiment_data.Runs.Source_files = [nirs_file_name nirs_file_ext];

MCP_Struct.fNIRs_time_series.On_Sets_Marks_Matrix = eval(sprintf('raw_nirs_file.%s', marks_matrix_name)); 

MCP_Struct.fNIRs_time_series.Hb_data.Oxygenated = squeeze(raw_nirs_file.procResult.dc(:, 1, :));
MCP_Struct.fNIRs_time_series.Hb_data.Deoxygenated = squeeze(raw_nirs_file.procResult.dc(:, 2, :));
MCP_Struct.fNIRs_time_series.Hb_data.Total = squeeze(raw_nirs_file.procResult.dc(:, 3, :));

%% The following is for adding up runs by concatenating Run_ID, Idecies, Source_files and 
for i = 2:number_of_files
    fprintf('Enter run %d infomration:\n', i);
    
    raw_nirs_file_For_Loop = extract_Homer_File(load(data_file_array{i}, '-mat'));
    
    [~, nirs_file_name, nirs_file_ext] = fileparts(data_file_array{i});
    
    MCP_Struct.Experiment_data.Runs(i).Run_ID = input('\nPlease enter run ID: ', 's');
    MCP_Struct.Experiment_data.Runs(i).Indecies = input('\nPlease enter run indecies(eg. [1:100]): ');
    MCP_Struct.Experiment_data.Runs(i).Source_files = [nirs_file_name nirs_file_ext];
    
    MCP_Struct.fNIRs_time_series.On_Sets_Marks_Matrix = [MCP_Struct.fNIRs_time_series.On_Sets_Marks_Matrix; eval(sprintf('raw_nirs_file_For_Loop.%s', marks_matrix_name))]; 

    MCP_Struct.fNIRs_time_series.Hb_data.Oxygenated = [MCP_Struct.fNIRs_time_series.Hb_data.Oxygenated; squeeze(raw_nirs_file_For_Loop.procResult.dc(:, 1, :))];
    MCP_Struct.fNIRs_time_series.Hb_data.Deoxygenated = [MCP_Struct.fNIRs_time_series.Hb_data.Deoxygenated; squeeze(raw_nirs_file_For_Loop.procResult.dc(:, 2, :))];
    MCP_Struct.fNIRs_time_series.Hb_data.Total = [MCP_Struct.fNIRs_time_series.Hb_data.Total; squeeze(raw_nirs_file_For_Loop.procResult.dc(:, 3, :))];
    
end


fprintf('MCP_Struct done!\n');
    
end


