classdef RecordToLog
    properties
        Time;
    end
    methods
        function obj = RecordToLog(Time)
            arguments
                Time = 0.0;
            end
            obj.Time = Time;
        end
        function varargout = visit(obj, other)
            [varargout{1:nargout}] = handle_record_to_log(other, obj);
        end
    end
end