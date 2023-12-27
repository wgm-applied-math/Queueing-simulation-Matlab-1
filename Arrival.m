classdef Arrival < Event
    % Arrival Subclass of Event that represents the arrival of a Customer.

    properties
        % Customer - The Customer that has arrived.
        Customer;
    end
    methods
        function obj = Arrival(Time, Customer)
            % Arrival - Construct an arrival event from a time and a
            % Customer object.
            arguments
                Time = 0.0;
                Customer = [];
            end
            % MATLAB-ism: This incantation is how to invoke the superclass
            % constructor.
            obj = obj@Event(Time);

            obj.Customer = Customer;
        end

        function varargout = visit(obj, other)
            % visit - Call handle_arrival

            % MATLAB-ism: This incantation means whatever is returned by
            % the call to handle_arrival is returned by this visit method.
            [varargout{1:nargout}] = handle_arrival(other, obj);
        end
    end
end