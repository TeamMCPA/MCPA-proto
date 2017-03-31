function MCP_Struct = create_MCP(data_file_array)

%% This function grab data from the Homer struct and create a pre-processing MCP_sturct. 
% NOTICE: The funtion is for single subject and single prob and multiple
% runs. The funciton takes a cell array of file name as input. Each file is
% the data of different runs from a single subject and a single prob. 
%
% The MCP_struct contains the following fields:
%
% 1. About_subject: 
% This field collects some information about the subject, and the
% path of the nirs file. It contains two subfield: 
%   "Subject_ID" (From the commandline)
%
%   "Absolute_path" (From the nirsfile)
%
% 2. Experiment_data: 
% This field collects the data of "Runs", "Prob", and "Conditions".
% Each of the subfield contains fields. 
%
%   "Runs": Run_ID, (From the commandline)
%           Indecies, (From the commandline)
%           Source_files. (From the nirsfile)
%
%   "Prob_arrays": Array_ID, (From the commandline)
%                  Channels_in_Array, (From the nirsfile)
%                  Geometry. (From the nirsfile, not collected right now)
%
%   "Contidions": Name, (From the commandline)
%                 Condition_mark. (From the nirsfile)
% 
% 3. fNIRs_time_series:
% This field collects the data of "Sampling_frequency", "On_Sets_Marks_Matrix", and "Hb_data".
% "Hb_data" contains subfields. 
%
%   "Sampling_frequency" (From the commandline)

%   "On_Sets_Marks_Matrix" (From the nirsfile)

%   "Hb_data": Oxygenated, (From the nirsfile)
%              Deoxygenated, (From the nirsfile)
%              Toal. (From the nirsfile)
%
%The function is the process of how these fields obtain the data.
%

%% Convert char arrays to cell arrays, in case somebody tries to input char.
if ischar(data_file_array), data_file_array = cellstr(data_file_array); end

% number_of_files = size(data_file_array, 2);

%% Create a new struct
MCP_Struct = struct;

% Store the Homer version nirs file and prepare to extract data from it.
raw_nirs_file = extract_Homer_File(load(data_file_array{1}, '-mat'));
% Get the path data to from the first file in the input data file array. 
[nirs_file_path, nirs_file_name, nirs_file_ext] = fileparts(data_file_array{1});

%% Extract data from raw nirs file and add them into the MCP struct

% Collect data for field Subject ID from the commandline
MCP_Struct.About_subject.Subject_ID = input('\nPlease enter subject id: ', 's');  %Subject ID

% Collect data for Absolute_path from previous variable
if nirs_file_path,
   MCP_Struct.About_subject.Absolute_path = nirs_file_path; %Absolute Path
else
   MCP_Struct.About_subject.Absolute_path = pwd;
end

% Collect data for prob array ID from the commandline
MCP_Struct.Experiment_data.Prob_arrays.Array_ID = input('\n Please enter the Prob_array ID: ', 's'); % Prob Array ID

% Collect data for channel array
MCP_Struct.Experiment_data.Prob_arrays.Channels_in_Array = 1 : size(raw_nirs_file.procResult.dc, 3); % channels

% Collect data for geometry
MCP_Struct.Experiment_data.Prob_arrays.Geometry = []; % geometry
    

% Store marks data field from the homer file. 
try 
    marks_matrix_name = input('\nPlease indicate the name of matrix you store the marks data(eg. aux): ', 's');
    
    % Determine the dimension of the marks vector
    marks_number = size(eval(sprintf('raw_nirs_file.%s', marks_matrix_name)), 2);
catch 
    fprintf('\nPlease enter a valid file name: ');
end

% Label the different dimension marks from the marks vector, name them, and
% then add to an array. 
marks_name_array = [];

for i = 1:marks_number
    name = input('\nPlease enter names for marks IN ORDER: ', 's');
    marks_name_array = union(marks_name_array, {name});
end

% Store the array into the name field
MCP_Struct.Experiment_data.Conditions.Name = marks_name_array;

% Store the total number of marks into a field
MCP_Struct.Experiment_data.Conditions.Condition_mark = marks_number;

% Collect sample frequency from the commandline
MCP_Struct.fNIRs_time_series.Sampling_frequency = input('\nPlease enter the sampling frequency: ');

% Handling run's data:

% For the first file, collect runID, run indecies from commandline and
% source files from the previous variable
fprintf('Enter run 1 infomration:\n');
MCP_Struct.Experiment_data.Runs.Run_ID = input('\nPlease enter run ID: ', 's');
MCP_Struct.Experiment_data.Runs.Indecies = input('\nPlease enter run indecies(eg. [1:100]): ');
MCP_Struct.Experiment_data.Runs.Source_files = [nirs_file_name nirs_file_ext];

% Store the marks matrix
MCP_Struct.fNIRs_time_series.On_Sets_Marks_Matrix = eval(sprintf('raw_nirs_file.%s', marks_matrix_name)); 

% Store Hb_data from the input homer file. Notice the format of
% procResult.dc is (Data Length x Hb components(HbO, HBD, HBTotal) x Channels)
MCP_Struct.fNIRs_time_series.Hb_data.Oxygenated = squeeze(raw_nirs_file.procResult.dc(:, 1, :));
MCP_Struct.fNIRs_time_series.Hb_data.Deoxygenated = squeeze(raw_nirs_file.procResult.dc(:, 2, :));
MCP_Struct.fNIRs_time_series.Hb_data.Total = squeeze(raw_nirs_file.procResult.dc(:, 3, :));

%% Collect runs data if there are more homer files input

% The process is the same as the above. 
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


