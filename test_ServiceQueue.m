function q = test_ServiceQueue(max_time)
    % test_ServiceQueue Basic test of the ServiceQueue class.
    %
    % q = test_ServiceQueue(max_time) - Schedule one customer to arrive at
    % time 1, then run the queue until its internal clock passes max_time.
    % The default for max_time is 100.
    arguments
        max_time = 100.0;
    end
    q = ServiceQueue(LogInterval=1, NumServers=2);
    q.schedule_event(Arrival(1, Customer(1)));
    while q.Time < max_time
        handle_next_event(q);
    end
end