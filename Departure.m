classdef Departure
    properties
        Time;
        ServerIndex;
    end
    methods
        function obj = Departure(Time, ServerIndex)
            arguments
                Time = 0.0;
                ServerIndex = 0;
            end
            obj.Time = Time;
            obj.ServerIndex = ServerIndex;
        end
        function varargout = visit(obj, other)
            [varargout{1:nargout}] = handle_departure(other, obj);
        end
    end
end