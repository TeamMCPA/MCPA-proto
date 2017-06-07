function MCP_Struct = build_MCP(data_file_array, subject_id, probe_array_id, marks_matrix_name)

%% This function grabs data from the struct in Homer2-formatted .nirs files and creates an MCP struct for multivariate pattern analyses
%
% NOTICE: The funtion is a wrapper for combining multiple probes and runs
% within a single subject. See homer2_to_mcp.m for full explanation
%
% data_file_array should be a cell array of r-by-p cells for r runs and p
% probes. Each cell contains the path to a Homer2-formatted .nirs file.


%% build_MCP will run recursively for multiple subjects
% If the contents of the first cell in data_file_array are also a cell
% array, indicating that each cell contains a full subject's worth of data,
% then the function will call itself and re-evaluate on the contents of
% each of those cells. If each subject has only one run and one probe, the
% hierarchical structure must still be used, as follows:
% data_file_array = { {Subj1.nirs}, {Subj2.nirs}, {Subj3.nirs} };
if iscell(data_file_array{1,1}),
    if ischar(subject_id), subject_id = cellstr(subject_id); end
    for subj_num = 1:length(data_file_array),
        MCP_Struct(subj_num) = build_MCP(data_file_array{subj_num},subject_id{subj_num},probe_array_id,marks_matrix_name);
    end
    return
end

%% Convert char arrays to cell arrays, in case somebody tries to input char.
if ischar(data_file_array), data_file_array = cellstr(data_file_array); end
if ischar(probe_array_id), data_file_array = cellstr(probe_array_id); end

number_of_probes = size(data_file_array, 1);
number_of_runs = size(data_file_array, 2);

%% Create a new struct and fill Experiment with information about the probes and runs.

MCP_Struct = struct;

% Collect data for field Subject ID from the commandline
MCP_Struct.Subject.Subject_ID = subject_id;

for current_probe = 1:number_of_probes,
    % Names each probe according to the ID's provided as input
    MCP_Struct.Experiment.Probe_arrays(current_probe).Array_ID = probe_array_id{current_probe};
    % Seeds each probe with an empty channel set (for now)
    MCP_Struct.Experiment.Probe_arrays(current_probe).Channels = [];
    % Create the field for Probe geometry (not currently available)
    MCP_Struct.Experiment.Probe_arrays(current_probe).Geometry = [];
end

for current_run = 1:number_of_runs,
    % Runs are currently identified by sequential integers.
    MCP_Struct.Experiment.Runs(current_run).Run_ID = current_run;
    % Seeds each run with an empty set of index values (for now)
    MCP_Struct.Experiment.Runs(current_run).Index = [];
    % Fill in the row of data_file_array for that run, including all probes
    MCP_Struct.Experiment.Runs(current_run).Source_files = data_file_array(current_run,:);
end

%% Initialize empty fields for MCP struct
MCP_Struct.Subject.Directory = [];
MCP_Struct.Experiment.Conditions = [];

MCP_Struct.fNIRS_Data.Sampling_frequency = [];
MCP_Struct.fNIRS_Data.Onsets_Matrix = [];
MCP_Struct.fNIRS_Data.Hb_data.Oxy = [];
MCP_Struct.fNIRS_Data.Hb_data.Deoxy = [];
MCP_Struct.fNIRS_Data.Hb_data.Total = [];

%% Fill in the data by looping over runs and probes

current_data_index = 0;
current_num_channels = 0;

for current_run = 1:number_of_runs,
    
    for current_probe = 1:number_of_probes,
        % Extract the MCP formatted data for each individual probe file
        mcp_data(current_probe) = homer2_to_mcp(data_file_array{current_run,current_probe},subject_id,probe_array_id{current_probe},marks_matrix_name);
        % Note the directory that this probe's data was found in
        MCP_Struct.Experiment.Runs(current_run).Directory{current_probe} = mcp_data(current_probe).Subject.Directory;
        
        if isempty(MCP_Struct.Experiment.Probe_arrays(current_probe).Channels),
            MCP_Struct.Experiment.Probe_arrays(current_probe).Channels = mcp_data(current_probe).Experiment.Probe_arrays.Channels_in_Array + current_num_channels;
            current_num_channels = max(MCP_Struct.Experiment.Probe_arrays(current_probe).Channels);
        elseif length(MCP_Struct.Experiment.Probe_arrays(max(current_probe-1,1)).Channels) ~= length(MCP_Struct.Experiment.Probe_arrays(current_probe).Channels);
            disp(['Number of channels in ' data_file_array{current_run,current_probe} ' different from previous runs!']);
            disp(['I QUIT!']);
            return
        else
            current_num_channels = max([current_num_channels, MCP_Struct.Experiment.Probe_arrays(current_probe).Channels]);
        end
        
        % Probe geometry is acquired from the first run in which a probe is
        % used. May be later than Run 1 if probe is missing in earlier runs
        if isempty(MCP_Struct.Experiment.Probe_arrays(current_probe).Geometry),
            MCP_Struct.Experiment.Probe_arrays(current_probe).Geometry = mcp_data(current_probe).Experiment.Probe_arrays.Geometry;
        end
        
    end
    
    % For each run, reduce the list of directories to the unique list,
    % since most of the time the probes will be contained in the same
    % directory.
    MCP_Struct.Experiment.Runs(current_run).Directory = unique(MCP_Struct.Experiment.Runs(current_run).Directory);
    
    % Determine the amount of data in each probe for this run and index accordingly
    % If probes differ in the amount of data they contain, always use the
    % probe with more data. The missing data at the end of the other probe
    % can be filled with NaNs
    max_index_each_probe = arrayfun(@(x)(max(x.Experiment.Runs(1).Index)),mcp_data);
    [max_index_this_run, probe_with_most_data] = max(max_index_each_probe);
    MCP_Struct.Experiment.Runs(current_run).Index = [1:max_index_this_run] + current_data_index;
    MCP_Struct.Experiment.Runs(current_run).Time = mcp_data(probe_with_most_data).Experiment.Runs(1).Time;
    current_data_index = MCP_Struct.Experiment.Runs(current_run).Index(end);
    
    % Get the marks data from the probe with the longest timeseries
    new_onsets_matrix = mcp_data(probe_with_most_data).fNIRS_Data.Onsets_Matrix;
    
    % The new working onsets matrix (to be revised and overwrite the old
    % main onsets matrix) will be a vertical concatenation of the old
    % onsets matrix and a zeros matrix with length equal to the new onsets
    % and width equal to the old matrix. In other words, make the old onset
    % matrix longer to accommodate new data, and we'll add new columns
    % later if necessary
    working_onsets_matrix = [ MCP_Struct.fNIRS_Data.Onsets_Matrix;...
        zeros( size(new_onsets_matrix,1) , size(MCP_Struct.fNIRS_Data.Onsets_Matrix,2) )...
        ];
    
    % Copy the conditions data from the probe with the longest timeseries
    this_run_conditions = mcp_data(probe_with_most_data).Experiment.Conditions;
    
    % Cycle through all the conditions and integrate them into the main
    % struct MCP_Struct.Experiment.Conditions by matching names
    for this_cond = 1:length(this_run_conditions),
        this_cond_name = this_run_conditions(this_cond).Name;
        
        % Compare the name of the condition in the new data to the list of
        % existing conditions in the MCP_Struct. Create an index vector to
        % indicate where that condition exists (if it does!).
        index_in_main_struct = arrayfun(@(x)(strcmp(x.Name,this_cond_name)),MCP_Struct.Experiment.Conditions);
        
        % Test whether this condition already exists in the main experiment
        if sum(index_in_main_struct)>0, % The condition already exists
            % Insert the onsets vector for this condition in the
            % appropriate column of onsets matrix
            working_onsets_matrix(MCP_Struct.Experiment.Runs(current_run).Index:end,index_in_main_struct) = new_onsets_matrix(:,this_cond);
        
        else % If a condition by that name does not yet exist
            % Add the condition to the main list of conditions
            MCP_Struct.Experiment.Conditions = [ MCP_Struct.Experiment.Conditions, this_run_conditions(this_cond) ];
            % Add a new column of zeros on the left of the main Onsets matrix
            working_onsets_matrix(:,end+1) = 0;
            % Fill the current run data (to the end) with that condition's
            % onsets data
            working_onsets_matrix(MCP_Struct.Experiment.Runs(current_run).Index,end) = new_onsets_matrix(:,this_cond);
        
        end
        
    end
    
    % Overwrite the main onsets matrix with the working version.
    MCP_Struct.fNIRS_Data.Onsets_Matrix = working_onsets_matrix;
    
    % Build the oxy- deoxy- and total data matrices as nans
    this_run_oxy = nan(max_index_this_run,current_num_channels);
    this_run_deoxy = nan(max_index_this_run,current_num_channels);
    this_run_total = nan(max_index_this_run,current_num_channels);    
    
    for current_probe = 1:number_of_probes,
        this_run_oxy(1:max_index_each_probe(current_probe),MCP_Struct.Experiment.Probe_arrays(current_probe).Channels) = mcp_data(current_probe).fNIRS_Data.Hb_data.Oxy;
        this_run_deoxy(1:max_index_each_probe(current_probe),MCP_Struct.Experiment.Probe_arrays(current_probe).Channels) = mcp_data(current_probe).fNIRS_Data.Hb_data.Deoxy;
        this_run_total(1:max_index_each_probe(current_probe),MCP_Struct.Experiment.Probe_arrays(current_probe).Channels) = mcp_data(current_probe).fNIRS_Data.Hb_data.Total;
    end
    
    MCP_Struct.fNIRS_Data.Hb_data.Oxy(MCP_Struct.Experiment.Runs(current_run).Index,1:current_num_channels) = this_run_oxy;
    MCP_Struct.fNIRS_Data.Hb_data.Deoxy(MCP_Struct.Experiment.Runs(current_run).Index,1:current_num_channels) = this_run_deoxy;
    MCP_Struct.fNIRS_Data.Hb_data.Total(MCP_Struct.Experiment.Runs(current_run).Index,1:current_num_channels) = this_run_total;
    MCP_Struct.Subject.Directory = unique([MCP_Struct.Subject.Directory; MCP_Struct.Experiment.Runs(current_run).Directory]);
    MCP_Struct.fNIRS_Data.Sampling_frequency = [MCP_Struct.fNIRS_Data.Sampling_frequency, mcp_data(probe_with_most_data).fNIRS_Data.Sampling_frequency];
end

MCP_Struct.Subject.Directory = unique(MCP_Struct.Subject.Directory);
MCP_Struct.fNIRS_Data.Sampling_frequency = unique(MCP_Struct.fNIRS_Data.Sampling_frequency);

end

