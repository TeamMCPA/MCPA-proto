function new_mcp_file = mcp_relabel_stimuli(mcp_file_name,old_label_num,new_labels,save_flag)

% convert the new_labels variable into a cell array
if isnumeric(new_labels),
    new_labels = cellstr(num2str(new_labels));
elseif ischar(new_labels),
    new_labels = cellstr(new_labels);
end

% open the old MCP file
[mcpdir mcpfile ext] = fileparts(mcp_file_name);
old_mcp_file = load([mcpdir mcpfile '.mcp'],'-mat');

% Extract the onsets vector for the condition that will be replaced
% This data will not be deleted from the MCP file. The replacement
% conditions are appended as new conditions.
old_cond_onsets = old_mcp_file.fNIRs_time_series.On_Sets_Marks_Matrix(:,old_label_num);

% If the number of new labels is not equal to the number of onsets in the
% condition they are replacing, quit without making changes.
if length(new_labels) ~= sum(old_cond_onsets),
    new_mcp_file = old_mcp_file;
    disp(sprintf('ERROR: %g new labels to replace %g items in existing condition!',length(new_labels),sum(old_cond_onsets)));
    disp('These values must be equal.');
    return
end

% Turn the list of labels into a set of integers which can be acted upon.
num_existing_conds = size(old_mcp_file.fNIRs_time_series.On_Sets_Marks_Matrix,2);
[ unique_new unique_integers new_integer_labels ] = unique(new_labels);
num_new_conds = length(unique_integers);

% Fill out a new set of onsets, first as integers in a single vector.
new_cond_onsets = old_cond_onsets;
new_cond_onsets(new_cond_onsets==1) = new_integer_labels;
% Second, as a matrix with a column for each integer-label and logicals for
% the onsets of that integer-label in the time series
new_cond_onsets = repmat(new_cond_onsets,1,num_new_conds) == repmat(unique_integers',size(new_cond_onsets));

% Copy the old MCP file
new_mcp_file = old_mcp_file;

% Append the new onsets matrix to the right edge of the old onsets matrix
new_mcp_file.fNIRs_time_series.On_Sets_Marks_Matrix = [old_mcp_file.fNIRs_time_series.On_Sets_Marks_Matrix new_cond_onsets];
% Append the new condition names to the list of conditions
new_mcp_file.Experiment_data.Conditions.Name(num_existing_conds+1:num_existing_conds+num_new_conds) = unique_new';

% If the save_flag is true, write the data out.
if save_flag,
    save([mcpdir mcpfile '_r.mcp'],'-struct','new_mcp_file')
end