function MCP_Struct = homer2_to_mcp(data_file, subject_id, probe_array_id, marks_matrix_name)

%% This function grabs data from the struct in a Homer2-formatted .nirs file and creates an MCP struct for multivariate pattern analyses
%
% NOTICE: The funtion is for a single subject, a single probe, one run.
% There is a superceding function that can call multiple files (for
% multiple probes and/or multiple runs) and stitch them together by looping
% over this function.
%
% The MCP_struct contains the following fields:
%
% 1. Subject:
% This field collects some information about the subject, and the
% path of the nirs file. It contains two subfield:
%   "Subject_ID" (From the commandline)
%
%   "Directory" (From the nirsfile)
%
% 2. Experiment:
% This field collects the data of "Runs", "Probe", and "Conditions".
% Each of the subfield contains fields.
%
%   "Runs": Run_ID, (From the commandline)
%           Index, (From the commandline)
%           Source_files. (From the nirs file)
%
%   "Probe_arrays": Array_ID, (From the commandline)
%                  Channels_in_Array, (From the nirsfile)
%                  Geometry. (From the nirsfile, not collected right now)
%
%   "Conditions": Name, (From the commandline)
%                 Condition_mark. (From the nirsfile)
%
% 3. fNIRS_Data:
% This field collects the data of "Sampling_frequency", "Onsets_Matrix", and "Hb_data".
% "Hb_data" contains subfields.
%
%   "Sampling_frequency" Mean sampling frequency from the t vector

%   "Onsets_Matrix" (From the nirsfile)

%   "Hb_data": Oxygenated, (From the nirsfile)
%              Deoxygenated, (From the nirsfile)
%              Toal. (From the nirsfile)
%
%The function is the process of how these fields obtain the data.
%

%% Convert char arrays to cell arrays, in case somebody tries to input char.
if ischar(data_file), data_file = cellstr(data_file); end

%% Create a new struct
MCP_Struct = struct;

%% Extract data from raw nirs file and add them into the MCP struct

% Store the Homer version nirs file and prepare to extract data from it.
raw_nirs_file = extract_Homer_File(load(data_file{1}, '-mat'));
% Get the path data to from the first file in the input data file array.
[nirs_file_path, nirs_file_name, nirs_file_ext] = fileparts(which(data_file{1}));

% Collect data for field Subject ID from the commandline
MCP_Struct.Subject.Subject_ID = subject_id;

% Collect data for Directory from previous variable
if nirs_file_path,
    MCP_Struct.Subject.Directory = nirs_file_path; %Absolute Path
else
    MCP_Struct.Subject.Directory = pwd;
end

% Collect data for probe array ID from the commandline
MCP_Struct.Experiment.Probe_arrays.Array_ID = probe_array_id; % probeArray ID

% Collect data for channel array
MCP_Struct.Experiment.Probe_arrays.Channels_in_Array = 1 : size(raw_nirs_file.procResult.dc, 3); % channels

% Collect data for geometry
MCP_Struct.Experiment.Probe_arrays.Geometry = raw_nirs_file.SD; % geometry


% Store marks data field from the homer file.
try
    
    % Determine the dimension of the marks vector. (Notice that right now there are two version of marks vector)
    % Ver 1: 's' stores the marks as a t-by-s logical matrix for s 
    % different stimulus types. Here the width is the number of stimuli.
    % Ver 2: 'aux' stores the marks as integer values in a t-by-1 vector.
    % Here the number of unique values (besides zero) is the number of
    % stimuli.
    
    marks_matrix = eval(sprintf('raw_nirs_file.%s', marks_matrix_name));
    
    if size(marks_matrix,2) > 1, % Ver 1, usually 's' field
        marks_numbers = [1:size(marks_matrix,2)];
    elseif size(marks_matrix,2) == 1, % Ver 2, usually 'aux' field
        marks_numbers = unique(eval(sprintf('raw_nirs_file.%s', marks_matrix_name)));
        marks_numbers = marks_numbers(marks_numbers~=0); % remove the zero
    end
    
catch
    fprintf('No marks data found in file.\nPlease enter a valid file name.');
end

% Label the different dimension marks from the marks vector, name them, and
% then add to an array. Copy the onsets into the new Onsets_Matrix.
MCP_Struct.fNIRS_Data.Onsets_Matrix = zeros(size(marks_matrix,1),length(marks_numbers));

for i = 1:length(marks_numbers),
    
    % Default name for each mark is simply "mX" where X is the mark integer
    name = strcat('m', num2str(marks_numbers(i)));
    
    % Store the array into the name field
    MCP_Struct.Experiment.Conditions(i).Name = name;

    % Store the total number of marks into a field
    MCP_Struct.Experiment.Conditions(i).Mark = marks_numbers(i);
    
    % Store the marks matrix
    if size(marks_matrix,2) > 1, % Ver 1, usually 's' field
        MCP_Struct.fNIRS_Data.Onsets_Matrix(:,i) = marks_matrix(:,i);
    elseif size(marks_matrix,2) == 1, % Ver 2, usually 'aux' field
        MCP_Struct.fNIRS_Data.Onsets_Matrix(:,i) = (marks_matrix==marks_numbers(i));
    end
    
    
end


%% Sampling frequency
% Sampling frequency is estimated by taking the inverse of the mean 
% difference between every time stamp in the "t" field of the .nirs file.
MCP_Struct.fNIRS_Data.Sampling_frequency = 1/mean(diff(raw_nirs_file.t));
% In the case that this value is not uniform (some machines have a slight
% drift in their sampling frequency, it might be necessary to resample the
% timeseries to maintain a consistent interval between observations. This
% function is not yet supported.
if 2*std(diff(raw_nirs_file.t)) > 0.05*mean(diff(raw_nirs_file.t)),
    disp('WARNING: Sampling rate variability (2 sd) exceeds 5% of the mean.');
    disp(['Mean sampling period: ' mean(diff(raw_nirs_file.t)) ' sec']);
    disp(['2 standard deviations: ' sd(diff(raw_nirs_file.t)) ' sec']);
end


%% Handling run's data:
% For the first file, collect runID, run Index from commandline and
% source files from the previous variable
fprintf(['Subject ' num2str(subject_id) ' - probe ' num2str(probe_array_id) ' ->\n']);

MCP_Struct.Experiment.Runs.Run_ID = 1;
MCP_Struct.Experiment.Runs.Index = 1:size(raw_nirs_file.procResult.dc, 1);
MCP_Struct.Experiment.Runs.Time = raw_nirs_file.t;
MCP_Struct.Experiment.Runs.Source_files = {[nirs_file_name nirs_file_ext]};

previous_index = size(raw_nirs_file.procResult.dc, 1);

% Store Hb_data from the input homer file. Notice the format of
% procResult.dc is (Data Length x Hb components(HbO, HBD, HBTotal) x Channels)
MCP_Struct.fNIRS_Data.Hb_data.Oxy = squeeze(raw_nirs_file.procResult.dc(:, 1, :));
MCP_Struct.fNIRS_Data.Hb_data.Deoxy = squeeze(raw_nirs_file.procResult.dc(:, 2, :));
MCP_Struct.fNIRS_Data.Hb_data.Total = squeeze(raw_nirs_file.procResult.dc(:, 3, :));

end
