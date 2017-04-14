function event_types = event_types_handling(nirs_data, incl_subjects)

%% This function helps determine the event types numbers and return the types in an array.
% Due to different style of storing event type data in Homer1 and Homer2,
% we need to handle Homer1 and Homer2 data differently. 

%% Type detection for both Homer1 and Homer2

% Homer2 Format:
if Homer_version(nirs_data) == 2
    
    % Scan through the auxiliary signal and note all unique event types
    fprintf('\nHomer2 Format. Scanning for event types...\n');
    event_types = 1:size(nirs_data(incl_subjects(1)).aux, 2);
 
    
% We don't need the following code because we are assuming that all subjects has been test in same number of conditions.     
%     try
%         for subject = 2:length(incl_subjects)
%             if length(event_types) < size(nirs_data(incl_subjects(subject)).aux, 2)
%                 event_types = 1:size(nirs_data(incl_subjects(subject)).aux, 2);
%             end
%         end
%     catch
%         fprintf('Error caused..')
%     end
   

    fprintf('%d event types found (number 1 to %d) \n', length(event_types), length(event_types));
    
% Homer1 Format:    
elseif Homer_version(nirs_data) == 1
    
    % Scan through the marksvector and note all unique event types(marks vector)
    fprintf('\nHomer1 Format. Scanning for event types...\n');
    event_types = [];
    for subject = 1 : length(incl_subjects)
        event_types = union(event_types, unique(nirs_data(incl_subjects(subject)).otp.marksvector));
    end
    % now drop the initial 0 types (no stimulus)
    event_types = event_types(2:end);
    fprintf('%d event types found (number 1 to %d) \n', length(event_types), length(event_types));
    
else
    
    %We shall never reach this part hopefully.
    fprintf('Unidentified data format. Fail to return right event types array.');
    event_types = [];

end
