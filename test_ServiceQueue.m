function q = test_ServiceQueue(MaxTime)
    % test_ServiceQueue Basic test of the ServiceQueue class.
    %
    % q = test_ServiceQueue(MaxTime) - Schedule one customer to arrive at
    % time 1, then run the queue until its internal clock passes MaxTime.
    arguments
        MaxTime = 100.0;
    end
    q = ServiceQueue(LogInterval=1, NumServers=2);
    q.schedule_event(Arrival(1, Customer(1)));
    run_until(q, MaxTime);
end