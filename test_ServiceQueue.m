function q = test_ServiceQueue(max_time)
    arguments
        max_time = 100.0;
    end
    q = ServiceQueue(LogInterval=1, NumServers=2);
    q.schedule_event(Arrival(1, Customer(1)));
    while q.Time < max_time
        handle_next_event(q);
    end
end