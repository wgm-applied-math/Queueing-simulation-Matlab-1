classdef (Abstract=true) Event
    % Event Abstract base class for all events.

    properties
        % Time - Time at which this event happens
        Time = 0;
    end

    methods
        function obj = Event(Time)
            % Event Construct an Event with a given time.
            arguments
                Time = 0.0;
            end
            obj.Time = Time;
        end
    end
    methods (Abstract=true)
        % visit - Call a handle_??? event on a target object, passing self
        visit(obj, target)
    end
end

% The classes RecordToLog, Arrival, and Departure represent the different
% kinds of events that a ServiceQueue can handle, and are all subclasses of
% Event.
%
% In MATLAB, it isn't absolutely necessary to have this base class because
% MATLAB uses dynamic typing.  In a strictly typed language like Java, a
% base class like this is often necessary, so I've included it here.
%
% Furthermore, the Event class serves as a form of documentation.  This
% base class enforces that all events must have a Time property and a visit
% method, which ServiceQueue expects.

% MATLAB-ism: Generally it should be possible to construct an object with
% no arguments.  The above constructor uses an "arguments" block to give
% default values for its arguments, so it is possible to call Event(), even
% though this simulation doesn't do so.

% The Visitor design pattern is at work here.  The way a ServiceQueue
% handles an event internally works like this:
%
% 1. handle_next_event(q) pops the next event object e from its internal
% list.
%
% 2. It calls visit(e, q), which invokes the visit() method from the class
% of the event e.
%
% 3. The visit(e, q) method invokes a method handle_??? on q, passing
% itself as the second argument.  For example, a RecordToLog event invokes
% handle_record_to_log(q, e).
%
% The point of the visitor pattern is that this back-scratching sequence of
% method invocations allows you to write methods like handle_record_to_log,
% handle_arrival, handle_departure, etc. without knowing all possible types
% of events ahead of time.  The visit method in each subclass of Event
% effectively uses the dispatch mechanism to identify itself.
%
% The alternative is to have code like this:
%
%   if event is an arrival
%       ...
%   else if event is a departure
%       ...
%   else if event is a record-to-log notice
%       ...
%   end
%
% These can become hard to understand and maintain in an imperative
% language like MATLAB.  Object-oriented programming was developed in part
% to avoid this kind of do-this-or-that based on object subtypes.
%
% FYI: Functional languages like ML, Haskell, and F# have the concept of
% algebraic data types, which are designed to handle object subtypes well,
% while avoiding the state changes allowed in imperative languages.