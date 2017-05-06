function MCP_for_probs = MCP_for_multiple_probs(data_file_array, subject_id)

%% The function combines single subject's mcp struct from differnet probs. 
%
% data_file_array:
% This argument contains all data files for a single subject. Each element
% of this array is also an array for runs in different probs. 
% The format is:
%     prob1                           prob2
%   [[run1, run2, run3, run4, run5], [run1, run2, run3, run4, run5]]
%

%% Getting each prob's mcp first
marks_matrix_name_input = input('\nPlease indicate the name of matrix you store the marks data(eg. aux): ', 's');
sampling_frequency = input('\nPlease enter the sampling frequency: ');
fprintf('Begin to build up MCP struct...\n');

number_of_probs = size(data_file_array, 2);

%% Build up the empty struct for stacked up MCP. 
stackup_mcp = struct;
stackup_mcp(number_of_probs).About_subject = [];
stackup_mcp(number_of_probs).Experiment_data = [];
stackup_mcp(number_of_probs).fNIRs_time_series = [];

%% For loop to execute the mcp creation and the stack up process.
for i = 1:number_of_probs
    mcp = create_MCP(data_file_array{i}, subject_id, i, marks_matrix_name_input, sampling_frequency);
    stackup_mcp(i) = mcp; 
end

fprintf('Stack-up MCP finished...\n');
fprintf('Begin to combine probs...\n');

MCP_for_probs = struct;

%% About_subject
MCP_for_probs.About_subject = stackup_mcp(1).About_subject;
MCP_for_probs.Experiment_data = [];
MCP_for_probs.fNIRs_time_series = [];

%% Experiment_data

% Prob_arrays
prob_arrays(number_of_probs).Array_ID = [];
prob_arrays(number_of_probs).Channels_in_Array = [];
prob_arrays(number_of_probs).Geometry = [];

channel_counter = 0;

for i = 1 : number_of_probs  
    single_prob_array.Array_ID = i;
    single_prob_array.Channels_in_Array = (channel_counter + 1) : (channel_counter + length(stackup_mcp(i).Experiment_data.Prob_arrays.Channels_in_Array));
    channel_counter = channel_counter + length(stackup_mcp(i).Experiment_data.Prob_arrays.Channels_in_Array);
    single_prob_array.Geometry = [];
    prob_arrays(i) = single_prob_array;
end

MCP_for_probs.Experiment_data.Prob_arrays = prob_arrays;

% Conditions
MCP_for_probs.Experiment_data.Conditions = stackup_mcp(1).Experiment_data.Conditions;

% Runs
MCP_for_probs.Experiment_data.Runs = stackup_mcp(1).Experiment_data.Runs;

for j = 2 : number_of_probs
    for k = 1 : size(stackup_mcp(1).Experiment_data.Runs, 2)
        MCP_for_probs.Experiment_data.Runs(k).Source_files = [MCP_for_probs.Experiment_data.Runs(k).Source_files stackup_mcp(j).Experiment_data.Runs(k).Source_files];
    end

end

%% fNIRs_time_series
MCP_for_probs.fNIRs_time_series.Sampling_frequency = stackup_mcp(1).fNIRs_time_series.Sampling_frequency;
MCP_for_probs.fNIRs_time_series.On_Sets_Marks_Matrix =  stackup_mcp(1).fNIRs_time_series.On_Sets_Marks_Matrix;

oxygenated = [];
deoxygenated = [];
total = [];

for l = 1 : number_of_probs
    oxygenated = horzcat(oxygenated, stackup_mcp(l).fNIRs_time_series.Hb_data.Oxygenated);
    deoxygenated = horzcat(deoxygenated, stackup_mcp(l).fNIRs_time_series.Hb_data.Deoxygenated);
    total = horzcat(total, stackup_mcp(l).fNIRs_time_series.Hb_data.Total);
end

MCP_for_probs.fNIRs_time_series.Hb_data.Oxygenated = oxygenated;
MCP_for_probs.fNIRs_time_series.Hb_data.Deoxygenated = deoxygenated;
MCP_for_probs.fNIRs_time_series.Hb_data.Total = total;

name = ['subject' num2str(subject_id) '_mcp'];
fprintf(['MCP construction done! Save the file... name: ' name '.mat\n']);
% save the mcp in to a mat file
save(strcat(name, '.mat'),'MCP_for_probs');

end








