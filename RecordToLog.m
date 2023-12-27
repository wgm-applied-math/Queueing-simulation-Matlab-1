classdef RecordToLog < Event
    % RecordToLog Subclass of Event that causes the event queue to record a
    % log entry.

    methods
        function varargout = visit(obj, other)
            % visit - Call handle_record_to_log
            % 
            % visit(obj, other) - call handle_record_to_log(other, obj)
            
            % MATLAB-ism: This incantation means whatever is returned by
            % the call to handle_record_to_log is returned by this visit
            % method.
            [varargout{1:nargout}] = handle_record_to_log(other, obj);
        end
    end
end