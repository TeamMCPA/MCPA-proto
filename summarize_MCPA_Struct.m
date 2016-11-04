function summarized_MCPA_struct = summarize_MCPA_Struct(function_name,MCPA_struct, dimension)
%% This function aims to convert MCPA_struct to other form of matrix that will be used in futher data analysis.
%The function is called with the following arguments:
%
%MCPA_struct: A structure returned by the function output_MCPA_struct. 
%
%The function will return a new struct whose field patterns will be
%summarized by certain method such as get the time_window averages etc.


if ~exist('dimension','var'), dimension = 1; end

%% Get summarized:
if isa(function_name,'function_handle'),
    summarized_MCPA_struct_pattern = squeeze(function_name(MCPA_struct.patterns,dimension));
elseif ischar(function_name),
    summarized_MCPA_struct_pattern = squeeze(feval(function_name, MCPA_struct.patterns));
else
    fprintf('Fail to successfully summarize MCPA_struct to a desired form.\n');
end

%% Return the new struct
try
    summarized_MCPA_struct.data_file = MCPA_struct.data_file;
    summarized_MCPA_struct.created = datestr(now);
    summarized_MCPA_struct.time_window = MCPA_struct.time_window;
    summarized_MCPA_struct.incl_subjects = MCPA_struct.incl_subjects;
    summarized_MCPA_struct.event_types = MCPA_struct.event_types;
    summarized_MCPA_struct.incl_channels = MCPA_struct.incl_channels;
    summarized_MCPA_struct.patterns = summarized_MCPA_struct_pattern;
    fprintf(' Done.\n');
    
catch
    fprintf('Failed to create the new struct...')
end



end







