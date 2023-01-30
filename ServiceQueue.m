classdef ServiceQueue < handle
    properties
        Time;
        NumServers;
        InterArrivalDist;
        ServiceDist;
        ServerAvailable;
        Servers;
        Events;
        Waiting;
        Served;
    end
    methods
        function obj = ServiceQueue(Time, NumServers, ArrivalRate, DepartureRate)
            arguments
                Time = 0.0;
                NumServers = 1;
                ArrivalRate = 0.5;
                DepartureRate = 0.6;
            end
            obj.Time = Time;
            obj.NumServers = NumServers;
            obj.InterArrivalDist = makedist("Exponential","mu",1/ArrivalRate);
            obj.ServiceDist = makedist("Exponential","mu",1/DepartureRate);
            obj.ServerAvailable = repelem(true, NumServers);
            obj.Servers = cell([1, NumServers]);
            obj.Events = PriorityQueue({}, @(x) x.Time);
            obj.Waiting = {};
            obj.Served = {};
        end
        function schedule_event(obj, event)
            if event.Time <= obj.Time
                error('event happens in the past');
            end
            push(obj.Events, event);
        end
        function handle_next_event(obj)
            if is_empty(obj.Events)
                error('no unhandled events');
            end
            event = pop_first(obj.Events);
            if obj.Time > event.Time
                error('event happened in the past');
            end
            obj.Time = event.Time;
            visit(event, obj);
        end
        function handle_arrival(obj, arrival)
            c = arrival.Customer;
            c.ArrivalTime = obj.Time;
            obj.Waiting{end+1} = c;
            % Schedule next arrival...
            next_customer = Customer(c.Id + 1);
            inter_arrival_time = random(obj.InterArrivalDist);
            next_arrival = ...
                Arrival(obj.Time + inter_arrival_time, next_customer);
            schedule_event(obj, next_arrival);
            advance(obj);
        end
        function handle_departure(obj, departure)
            j = departure.ServerIndex;
            customer = obj.Servers{j};
            customer.DepartureTime = departure.Time;
            obj.Served{end+1} = customer;
            obj.Servers{j} = false;
            obj.ServerAvailable(j) = true;
            advance(obj);
        end
        function begin_serving(obj, j, customer)
            customer.BeginServiceTime = obj.Time;
            obj.Servers{j} = customer;
            obj.ServerAvailable(j) = false;
            service_time = random(obj.ServiceDist);
            obj.schedule_event(Departure(obj.Time + service_time, j));
        end
        function advance(obj)
            % If someone is waiting
            if size(obj.Waiting, 2) > 0
                % If a server is available
                [x, j] = max(obj.ServerAvailable);
                if x
                    % Move the customer from Waiting list
                    customer = obj.Waiting{1};
                    obj.Waiting(1) = [];
                    % and begin serving
                    begin_serving(obj, j, customer);
                end
            end
        end
    end
end