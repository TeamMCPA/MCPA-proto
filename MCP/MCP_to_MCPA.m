function MCPA_struct = MCP_to_MCPA(mcp, incl_subjects, incl_channels, time_window)

%% The function aims to convert MCP format data to MCPA_struct for analysis
% The function is clled with the following arguments:
% MCP_to_MCPA(mcp, incl_subjects, incl_channels, time_window)
%
% mcp: An customized MCP struct that contains all data for the analysis.
% Using MCP struct to store data can unify the way that data stored in the
% struct. Directly grabbing data from homer file might cause problems such
% as failure to find specific data. 
%
% incl_subjects: a vector of indices for subjects to include in the
% analysis. Importantly the subject numbers correspond to the index in the
% struct array (e.g., MyData([1 3 5]) not any other subject number
% assignment.
%
% incl_channels: a vector of indices for channels to include in the
% analysis. Again, only the channel's position in the HomER struct matters,
% not any other channel number assignment.
%
% time_window: defined in number of measures. For data measured at 10 Hz,
% the time_window will be in 1/10 s units (e.g., 0:100 is 0-10 s). For data
% measured at 2 Hz, time will be in 1/2 s units (e.g., 0:20 is 0-10 s).
%
% The function will return a new struct containing some metadata and the
% multichannel patterns for each participant and condition.


%% Event type Handling

event_types = 1:size(mcp.Experiment_data.Conditions.Condition_mark);


%% Extract data from the data file into the empty output matrix

% Initiate the subj_mat matrix that will be output later(begin with NaN)
subj_mat = nan(length(time_window), length(event_types), length(incl_channels), length(incl_subjects));
fprintf('Output matrix for MCPA_struct is in dimension: time_window x types x channels x subjects\n');

% Extract data from each subject
fprintf('\nExtracting data for subject: \n');

for subject = 1 : length(incl_subjects)
    
    fprintf('subject: %d. \n', incl_subjects(subject));
    % Event_matrix format:
    % (time x channels x repetition x types)
    event_matrix = MCP_get_subject_events(mcp, incl_subjects(subject), incl_channels, time_window, event_types);
    
    % Event_repetition_mean:
    % (time x channels x event_types_types)
    event_repetition_mean = nanmean(event_matrix, 3);
    event_repetition_mean = reshape(event_repetition_mean, length(time_window), length(incl_channels), length(event_types));
    event_repetition_mean = permute(event_repetition_mean, [1 3 2]);
    % Now the dimension of Event_repetition_mean:
    % (time x event_types x channels )
    
    % Output format: subj_mat(time_window x channels x event_types x subjects)
    subj_mat(:, :, :, subject) = event_repetition_mean;
   
end

%% Return the MCPA_struct
fprintf('\nWriting MCPA_struct for this dataset...');
try
    MCPA_struct.data_file = data_file_array;
    MCPA_struct.created = datestr(now);
    MCPA_struct.time_window = time_window;
    MCPA_struct.incl_subjects = incl_subjects;
    MCPA_struct.incl_channels = incl_channels;
    MCPA_struct.event_types = event_types;
    MCPA_struct.patterns = subj_mat;
    
    fprintf('Done.\n');
catch
    fprintf('Failed.\n');
end


end



















