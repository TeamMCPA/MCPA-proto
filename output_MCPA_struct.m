function MCPA_struct = output_MCPA_struct(data_file_array, incl_subjects, incl_channels, time_window)

%% The function aims to convert homer format data to MCPA_struct for analyses
% The function is called with the following arguments:
% ouput_MCPA_struct(data_file_array, incl_subjects, incl_channels, time_window)
%
% data_file_array: an array that contains names of data files. It can be
% single subject data file name array or aggregated subject data file
% name. data_file_array can be either cell array or char array. 
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


%% Load the HomER processed data
% If a single file is provided, the file is loaded directly into a struct.
% If several files are provided, these files are connected into a single
% struct with an element for each file.

% Convert char arrays to cell arrays, in case somebody tries to input char.
if ischar(data_file_array), data_file_array = cellstr(data_file_array); end

if iscell(data_file_array),
    
    % The case that input is a single cell containing either
    % a *.nirs file or a group data file.
    if length(data_file_array) == 1
        nirs_data = extract_Homer_File(load(data_file_array{1}, '-mat'));
        
        
    % The length of data_file_array is greater than 1 if it is a cell array 
    % with multiple files. connect_subjects_data can loop through multiple 
    % files and save them into a single struct
    elseif length(data_file_array) > 1
        nirs_data = connect_subjects_data(data_file_array);
        
    % Cases where length is not >=1 would be empty structs or some
    % unforeseen error. Complain accordingly.
    else
        fprintf('Failed to get data from name of the file. data_file_array length %g.\n',length(data_file_array));
        MCPA_struct = struct;
        return
    end
    
else
    fprintf('\nWARNING: data_file_array argument %s is not class cell or char\n', inputname(1) )
    MCPA_struct = struct;
    return
    
end
    

%% Event type Handling

event_types = event_types_handling(nirs_data, incl_subjects);  


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
    event_matrix = get_subject_events(nirs_data, incl_subjects(subject), incl_channels, time_window, event_types);

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
    
    fprintf(' Done.\n');
catch
    fprintf(' Failed.\n');
end
    
end











