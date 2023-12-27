classdef ServiceQueue < handle
    % ServiceQueue Simulation object that keeps track of customer arrivals,
    % departures, and service.

    properties (SetAccess = public)
        
        % ArrivalRate - Customers arrive according to a Poisson process.
        % The inter-arrival time is exponentially distributed with a rate
        % parameter of ArrivalRate.
        ArrivalRate = 0.5;

        % DepartureRate - When a customer arrives, the time it takes for
        % them to be served is exponentially distributed with a rate
        % parameter of DepartureRate.
        DepartureRate = 1/1.5;

        % NumServers - How many identical serving stations are available.
        NumServers = 1;

        % LogInterval - Approximately how many time units between log
        % entries.  Log events are scheduled so that when one log entry is
        % recorded, the next is scheduled for the curren time plus this
        % interval.
        LogInterval = 1;
    
    end

    properties (SetAccess = private)
        % Time - Current time.
        Time = 0;

        % InterArrivalDist - Distribution object that is sampled when one
        % customer arrives to determine the time until the next customer
        % arrives.
        InterArrivalDist;

        % ServiceDist - Distribution object that is sampled when a serving
        % station begins serving a customer.  The resulting random number
        % is the time until service is complete.
        ServiceDist;

        % ServerAvailable - Row vector of boolean values, initial all true.
        % ServerAvailable(j) is set to false when serving station j begins
        % serving a customer, and is set to true when that service is
        % complete.
        ServerAvailable;

        % Servers - Cell array row vector.  Entries are initially empty.
        % When service station j begins serving a Customer, the Customer
        % object is stored in Servers{j}.
        Servers;

        % Events - PriorityQueue object that holds all active Event objects
        % of all types.  All events have a Time property that specifies
        % when they occur. The next event is the one with the least Time,
        % and can be popped from Events.
        Events;

        % Waiting - Cell array row vector of Customer objects. Initially
        % empty.  All arriving Customers are placed at the end of this
        % vector.  When a serving station is available, the first Customer
        % is removed from Waiting and moved to the corresponding slot in
        % Servers.
        Waiting;

        % Served - Cell array row vector of Customer objects. Initially
        % empty.  When a Customer's service is complete, the Customer
        % object is moved from its slot in Servers to the end of Served.
        Served;

        % Log - Table of log entries. Its columns are 'Time', 'NWaiting',
        % 'NInService', 'NServed', meaning: time, how many customers are
        % currently waiting, how many are currently being served, and how
        % many have been served.
        Log;
    
    end

    methods

        function obj = ServiceQueue(KWArgs)
            % ServiceQueue Constructor. Public properties can be specified
            % as named arguments.

            % An arguments block like this is how to specify that named
            % arguments (keyword style) are to be made available as
            % KWArgs.(name).
            arguments
                % Special syntax declaring that the allowed named arguments
                % should match the public properties of class ServiceQueue.
                KWArgs.?ServiceQueue;
            end

            % Since this method is a constructor, the obj output variable
            % is the instance under construction.

            % This matlab-ism stores named arguments passed to this
            % constructor to the corresponding properties in the object
            % being constructed.
            fnames = fieldnames(KWArgs);
            for ifield=1:length(fnames)
                s = fnames{ifield};
                obj.(s) = KWArgs.(s);
            end

            % Initialize the private properties of this instance.
            obj.InterArrivalDist = ...
                makedist("Exponential", mu=1/obj.ArrivalRate);
            obj.ServiceDist = ...
                makedist("Exponential", mu=1/obj.DepartureRate);
            obj.ServerAvailable = repelem(true, obj.NumServers);
            obj.Servers = cell([1, obj.NumServers]);
            obj.Events = PriorityQueue({}, @(x) x.Time);
            obj.Waiting = {};
            obj.Served = {};
            obj.Log = table( ...
                Size=[0, 4], ...
                VariableNames=...
                    {'Time', 'NWaiting', 'NInService', 'NServed'}, ...
                VariableTypes=...
                    {'double', 'int64', 'int64', 'int64'});

            % The first event is to record the state at time 0 to the log.
            schedule_event(obj, RecordToLog(0));
        end

        function obj = run_until(obj, MaxTime)
            % run_until Event loop.
            % 
            % obj = run_until(obj, MaxTime) Repeatedly handle the next
            % event until the current time is at least MaxTime.

            while obj.Time < MaxTime
                handle_next_event(obj)
            end
        end

        function schedule_event(obj, event)
            % schedule_event Add an object to the event queue.

            if event.Time < obj.Time
                error('event happens in the past');
            end
            push(obj.Events, event);
        end

        function handle_next_event(obj)
            % handle_next_event Pop the next event and use the visitor
            % mechanism on it to do something interesting.

            if is_empty(obj.Events)
                error('no unhandled events');
            end
            event = pop_first(obj.Events);
            if obj.Time > event.Time
                error('event happened in the past');
            end

            % Update the current time to match the event that just
            % happened.
            obj.Time = event.Time;

            % This calls the event's visit() method, passing this service
            % queue object as an argument.  The visit method in the event's
            % class is expected to call one of the handle_??? methods on
            % this service queue object.
            visit(event, obj);
        end

        function handle_arrival(obj, arrival)
            % handle_arrival Handle an Arrival event.
            %
            % handle_arrival(obj, arrival) - Handle an Arrival event.  Add
            % the Customer in the arrival object to the queue's internal
            % state.  Create a new Arrival event and add it to the event
            % list.  In general, there should be exactly one Arrival in the
            % event list at a time, representing the arrival of the next
            % customer.

            % Record the current time in the Customer object as its arrival
            % time.
            c = arrival.Customer;
            c.ArrivalTime = obj.Time;

            % The Customer is appended to the list of waiting customers.
            obj.Waiting{end+1} = c;

            % Construct the next Customer that will arrive.
            % Its Id is one higher than the one that just arrived.
            next_customer = Customer(c.Id + 1);
            
            % It will arrive after a random time sampled from
            % obj.InterArrivalDist.
            inter_arrival_time = random(obj.InterArrivalDist);

            % Build an Arrival instance that says that the next customer
            % arrives at the randomly determined time.
            next_arrival = ...
                Arrival(obj.Time + inter_arrival_time, next_customer);
            schedule_event(obj, next_arrival);

            % Check to see if any customers can advance.
            advance(obj);
        end

        function handle_departure(obj, departure)
            % handle_departure Handle a departure event.

            % This is which service station experiences the departure.
            j = departure.ServerIndex;
            customer = obj.Servers{j};

            % Record the event time as the departure time for this
            % customer.
            customer.DepartureTime = departure.Time;

            % Add this Customer object to the end of Served.
            obj.Served{end+1} = customer;

            % Empty this service station and mark that it is available.
            obj.Servers{j} = false;
            obj.ServerAvailable(j) = true;

            % Check to see if any customers can advance.
            advance(obj);
        end

        function begin_serving(obj, j, customer)
            % begin_serving Begin serving the given customer at station j.
            % This is a helper method for advance(). It's a separate method
            % so that the advance() method isn't too complicated.

            % Record the current time as the time that service began for
            % this customer.
            customer.BeginServiceTime = obj.Time;

            % Store the Customer in slot j of Servers and mark that station
            % j is no longer available.
            obj.Servers{j} = customer;
            obj.ServerAvailable(j) = false;

            % Sample ServiceDist to get the time it will take to serve this
            % customer.
            service_time = random(obj.ServiceDist);

            % Schedule a Departure event so that after the service time,
            % the customer at station j departs.
            obj.schedule_event(Departure(obj.Time + service_time, j));
        end

        function advance(obj)
            % advance Check to see if a waiting customer can advance.

            % Check whether someone is waiting.
            while ~isempty(obj.Waiting)
                % Check whether a server is available. (MATLAB-ism: This is
                % why I keep an array of ServerAvailable flags separate
                % from the Server array. It's very easy to pick out the
                % first index j such that ServerAvailable{j} is true (==
                % 1), by calling the max() function like this.)
                [x, j] = max(obj.ServerAvailable);
               
                % If x = the max of ServerAvailable is true, then at least
                % one serving station is available.
                if x
                    % Move the customer from Waiting list
                    customer = obj.Waiting{1};
                    obj.Waiting(1) = [];
                    % and begin serving them at station j.
                    begin_serving(obj, j, customer);
                else
                    % No station is available, so no more customers can
                    % advance.  Break out of the loop.
                    break;
                end
            end
        end

        function handle_record_to_log(obj, ~)
            % handle_record_to_log Handle a RecordToLog event

            % MATLAB-ism: The ~ in the argument list means that this method
            % will be called with the RecordToLog object, but it doesn't
            % actually use the RecordToLog object.  The MATLAB editor
            % complains if you don't use a variable, and this is a way to
            % hush that complaint.

            % Record a log entry.
            record_log(obj);

            % Schedule the next RecordToLog event to happen after
            % LogInterval time.
            schedule_event(obj, RecordToLog(obj.Time + obj.LogInterval));
        end

        function record_log(obj)
            % record_log Record a summary of the service queue state.

            NWaiting = length(obj.Waiting);
            NInService = obj.NumServers - sum(obj.ServerAvailable);
            NServed = length(obj.Served);

            % MATLAB-ism: This is how to add a row to the end of a table.
            obj.Log(end+1, :) = {obj.Time, NWaiting, NInService, NServed};
        end
    end
end
 
% MATLAB-ism: The notation 
% 
%   classdef ServiceQueue < handle
% 
% makes ServiceQueue a subclass of handle, which means that this is a
% "handle" class, so instances have "handle" semantics. When you assign an
% instance to a variable, as in
%
%   q1 = ServiceQueue()
%   q2 = q1
%
% a handle (or reference) to the object is assigned rather than an
% independent copy.  That is, q1 and q2 are handles to the same object.
% Changes made using q1 will affect q2, and vice-versa.
%
% In contrast, classes that aren't derived from handle are "value" classes.
% When you assign an instance to a variable, an independent copy is made.
% This is MATLAB's usual array behavior:
%
%  u = [1,2,3] v = u v(1) = 10
%
% After the above, u is still [1,2,3] and v is [10,2,3] because the
% assignment v = u copies the array.  The change to v(1) doesn't affect the
% copy in u.
%
% Importantly, copies of value objects are made when they are passed to
% functions.
%
% Handle semantics are used for this simulation, so that methods are able
% to change the state of a ServiceQueue object.  That is, something like
%
%  q = ServiceQueue() handle_next_event(q)
%
% creates a ServiceQueue object and calls a method that changes its state.
% If ServiceQueue was a value class, the instance would be copied when
% passed to the handle_next_event method, and no changes could be made to
% the copy stored in the variable q.
