

%% The Following code is for MCPA struct testing

% Declare basic information provided by users.

% To use the scripts, please declare following variables in this script:
%
% data_file_name_cell: The file name of nirs data. It should be an cell
% array. The samples are below. 
%
% time_window: time_window: defined in number of measures. For data measured at 10 Hz,
% the time_window will be in 1/10 s units (e.g., 0:100 is 0-10 s). For data
% measured at 2 Hz, time will be in 1/2 s units (e.g., 0:20 is 0-10 s).
%
% condition1 and condition2: simply enter 1 and 2 for two-condition case.
% 
% incl_channels: a vector of indices for channels to include in the
% analysis. Again, only the channel's position in the HomER struct matters,
% not any other channel number assignment.
%
% incl_subjects: a vector of indices for subjects to include in the
% analysis. Importantly the subject numbers correspond to the index in the
% struct array (e.g., MyData([1 3 5]) not any other subject number
% assignment.
%

%Hardcoding parameters:

% For testing, please un-comment the data_file_name_cell variable and enter
% data file name in the cell array
% 
% data_file_name_cell = {'alldata_WDIT_control2'};
% 
%  data_file_name_cell = data_file_name_cell';
%  time_window = 0:100;
%  condition1 = 1;
%  condition2 = 2;
%  incl_channels = [3:5,13:19];
%  incl_subjects = [1 3:6 8:14 17:18 20:21, 23:25];
%  %incl_subjects = [1 2 3];
% 
%  MCPA_output = output_MCPA_struct(data_file_name_cell, incl_subjects, incl_channels, time_window);
%  
%  window_averages_struct = summarize_MCPA_Struct(@nanmean, MCPA_output);

% infant-level decoding
% WDIT_infantleveldecoding = leave_one_Ss_out_classifyAverages(window_averages_struct,condition1,condition2);
% trial-level coding
% WDIT_trialleveldecoding = leave_one_Ss_out_classifyIndividualEvents(window_averages_struct,condition1,condition2);


% examining infant-level decoding across different subset sizes for
% channels
% setsize = 5;  
% WDIT_infantleveldecoding_setsize5 = leave_one_Ss_out_classifyAverages(window_averages_struct,condition1,condition2,setsize);
% WDIT_trialleveldecoding_setsize5 = leave_one_Ss_out_classifyIndividualEvents(window_averages_struct,condition1,condition2,setsize);


% now restrict the analyses to just the top 3 channels that were most
% informative and we have almost perfect performance for the 
% incl_channels = [3:5,13:19];
% incl_channels = incl_channels([1,3,8]);


% MCPA_output = output_MCPA_struct(data_file_name_cell, incl_subjects, incl_channels, time_window);
% window_averages_struct = summarize_MCPA_Struct(@nanmean, MCPA_output);
% 
% WDIT_infantleveldecoding_top2 = leave_one_Ss_out_classifyAverages(window_averages_struct,condition1,condition2);
% WDIT_trialleveldecoding_top3 =
% leave_one_Ss_out_classifyIndividualEvents(window_averages_struct,condition1,condition2);?






%% The following code is the test for MCP struct contruction

% For single subject, single prob, and single run
%  raw_nirs_file_name1 = 'Test_for_Joszef_001-RNAv3_MES_Probe1.nirs';
%  MCP_struct = create_MCP_struct(raw_nirs_file_name1);

% For single subjectm single prob, and multiple run
   data_file_array = {'Test_for_Joszef_001-RNAv3_MES_Probe1.nirs' 'Test_for_Joszef_001-RNAv3_MES_Probe1.nirs'};
   MCP_struct_M = create_MCP(data_file_array);














