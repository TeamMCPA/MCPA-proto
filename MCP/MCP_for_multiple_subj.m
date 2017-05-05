function MCP_for_subject = MCP_for_multiple_subj(data_file_for_subjects)

%% The function stacks up mcp struct for each subject and return a stacked MCP struct
%
% 1. data_file_for_subject:
% This argument contains is an array that each element is an array for
% single subject. Each subject has multiple files due to different runs. An
% array stores those files' information and each element of
% data_file_for_subject contains the array for each subject. Please notice
% that this argument must be a cell array which as dimention (1 x n) where
% n is the length of array for each subject's data. 
%
% At the beginning we assume each file's format is the same and each
% subject has same number of runs. 
%
%% Ask the user about some important information for processing the data.

prob_array_id = input('\n Please enter the Prob_array ID: ', 's'); % Prob Array ID
marks_matrix_name_input = input('\nPlease indicate the name of matrix you store the marks data(eg. aux): ', 's');
sampling_frequency = input('\nPlease enter the sampling frequency: ');

number_of_subject = length(data_file_for_subjects);

%% Build up the empty struct for stacked up MCP. 
subject_combined_mcp = struct;
subject_combined_mcp(number_of_subject).About_subject = [];
subject_combined_mcp(number_of_subject).Experiment_data = [];
subject_combined_mcp(number_of_subject).fNIRs_time_series = [];

%subject id information is available through the "for" loop.
%% For loop to execute the mcp creation and the stack up process.
for i = 1:number_of_subject
    mcp = create_MCP(data_file_for_subjects{i}, i, prob_array_id, marks_matrix_name_input, sampling_frequency);
    subject_combined_mcp(i) = mcp;
end

MCP_for_subject = subject_combined_mcp;

end

