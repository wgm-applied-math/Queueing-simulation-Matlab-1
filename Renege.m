classdef Renege
    properties
        Time;
        CustomerId;
    end
    methods
        function obj = Renege(Time, CustomerId)
            arguments
                Time = 0.0;
                CustomerId = 0;
            end
            obj.Time = Time;
            obj.CustomerId = CustomerId;
        end
        function varargout = visit(obj, other)
            [varargout{1:nargout}] = hande_renege(other, obj);
        end
    end
end