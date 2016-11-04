function [event_matrix] = get_subject_events(nirs_data, subject, channels, time_window, event_types)

%% This function returns a matrix that contains Hbo data for target subject in each type, channel, time and type repetition. 
% First we construct the index matrix that contains specific index of Hbo
% data. Then Use the index matrix to find conresponding Hbo data and add
% them into the output matrix. 


%% Index matrix handling for both Homer1 and Homer2

% Homer2 Format:
if Homer_version(nirs_data) == 2
    %Extract oxy data and marks from the Homer2 struct
    oxy_timeser = nirs_data(subject).procResult.dc(:, 1, channels);
    %switch the columns of 2 and 3 and the oxy_timeser's dimension will
    %be (data length x channels x Hbo) just like dConc's dimension in
    %Homer1
    oxy_timeser = permute(oxy_timeser, [1 3 2]);
    marks_vec = nirs_data(subject).aux;

    %Get max conditons type
    max_condition_type = length(find(marks_vec(:, 1) == 1));

    for i = 2:length(event_types)
        if max_condition_type < length(find(marks_vec(:,i) == 1))
           max_condition_type = length(find(marks_vec(:, i) == 1));
        end
    end

    marks_mat = nan(max_condition_type, length(event_types));

    for type_i = 1:length(event_types)
        %Find the array index in the marks_vec
        temp_marks = find(marks_vec(:, type_i) == 1);
    
        %Abandon the offsets
        temp_marks = temp_marks(1:2:end);
    
        marks_mat(1:length(temp_marks), type_i) = temp_marks;
    end
        
        % Remove rows whose entries are all NaN
        marks_mat = marks_mat(sum(isnan(marks_mat),2)<size(marks_mat,2),:);
        
        
%Homer1 Format:
elseif Homer_version(nirs_data) == 1
    
    % dConc format (datalength x channels x HbO)
    oxy_timeser = nirs_data(subject).hmr.data.dConc(:, channels, 1);
    marks_vec = nirs_data(subject).otp.marksvector;
        
    %marks_mat matrix's row is the max number of the condition in whole
    %conditions, and the column is the event types.
    marks_mat = nan(max(hist(marks_vec(marks_vec~=0))),length(event_types)); 

    for type_i = 1 : length(event_types)
        %Find the array index (vector index) in the marks_vec
        temp_marks = find(marks_vec == event_types(type_i));
        %Now abandon the offsets
        temp_marks = temp_marks(1:2:end);
    
        marks_mat(1:length(temp_marks), type_i) = temp_marks;
    end
        
    % Remove rows whose entries are all NaN
    marks_mat = marks_mat(sum(isnan(marks_mat),2)<size(marks_mat,2),:);
        
else
    %We shall never reach this part hopefully.
    fprintf('Unidentified data format. Fail to return right event matrix.');
    event_matrix = [];
    return
        
end
    

%% Extract the individual events for each event type
% The output matrix setup(time x channels x type repetition x types)
event_matrix = nan(length(time_window), length(channels), size(marks_mat, 1), length(event_types));

for type_i = 1 : length(event_types)
    for event_j = 1 : length(marks_mat(:, type_i))
        if marks_mat(event_j,type_i) + time_window(end) <= length(oxy_timeser),
            event_matrix(:,:,event_j,type_i) = oxy_timeser(marks_mat(event_j,type_i)+time_window,:) - ones(length(time_window),1)*oxy_timeser(marks_mat(event_j,type_i)+time_window(1),:);
        else
            event_matrix(:,:,event_j:end,type_i) = NaN;
        end
    end
end


end