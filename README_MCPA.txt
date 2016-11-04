MCPA for Homer1 and Homer2 MATLAB Scripts README

Chengyu Deng(cdeng2@u.rochester.edu)
University of Rochester



There are 10 files in total, which are:

main.m
output_MCPA_struct.m
event_types_handling.m
get_subject_events.m
Homer_version.m
extract_Homer_File.m
connect_subjects_data.m
summarize_MCPA_Struct.m
leave_one_Ss_out_classifyAverages.m
leave_one_Ss_out_classifyIndividualEvents.m

‘main.m’ is the main script that produces the MCPA struct and the results of analysis. It contains crucial variables such as time window, subjects array and channel array. All results are returned in the ‘main.m’ script.

‘output_MCPA_struct.m’ is a function that extracts data from the nirs file and then returns a MCPA struct for analysis. The function calls ‘event_types_handling.m’, ‘get_subject_events.m’, ‘Homer_version.m’, ‘extract_Homer_File.m’, ‘connect_subjects_data.m’ for helping build the MCPA struct. 

‘summarize_MCPA_Struct.m’ is a method that summarizes MCPA struct. Through this function, the MCPA struct can be summarized differently by passing different function parameters. In the script, this function is used for summarizing nanmean of time window in the MCPA struct pattern. 

‘leave_one_Ss_out_classifyAverages.m’ and ’leave_one_Ss_out_classifyIndividualEvents.m’ are two methods for analysis. 

To run those scripts, enter nirs file names into an cell array called data_file_name_cell and then set up remaining parameters such as incl_subjects, incl_channels, time_window, condition1 and condition2 in ’main.m’ and then it will get an MCPA struct through ‘output_MCPA_struct’ function and then get summarized through ‘summarize_MCPA_Struct’ function. (Notice, there is no need to change the parameters of output_MCPA_struct and summarize_MCPA_Struct for testing). 

Then the following code in the main.m are analysis for the input nirs file. 



