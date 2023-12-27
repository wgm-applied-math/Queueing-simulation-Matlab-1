classdef Departure < Event
    % Departure Subclass of Event that represents the departure of a
    % Customer.

    properties
        % ServerIndex - Index of the service station from which the
        % departure occurred
        ServerIndex;
    end
    methods
        function obj = Departure(Time, ServerIndex)
            % Departure - Construct a departure event from a time and
            % server index.
            arguments
                Time = 0.0;
                ServerIndex = 0;
            end
            
            % MATLAB-ism: This incantation is how to invoke the superclass
            % constructor.
            obj = obj@Event(Time);

            obj.ServerIndex = ServerIndex;
        end
        function varargout = visit(obj, other)
            % visit - Call handle_departure

            % MATLAB-ism: This incantation means whatever is returned by
            % the call to handle_departure is returned by this visit
            % method.
            [varargout{1:nargout}] = handle_departure(other, obj);
        end
    end
end