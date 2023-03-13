function q = test_ServiceQueue(max_time)
    arguments
        max_time = 10.0;
    end
    q = ServiceQueue(0, 1, 0.5, 1/1.5);
    q.schedule_event(Arrival(1, Customer(1)));
    while q.Time < max_time
        handle_next_event(q);
    end
end