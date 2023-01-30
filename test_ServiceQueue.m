function q = test_ServiceQueue()
    q = ServiceQueue();
    q.schedule_event(Arrival(1, Customer(1)));
    while q.Time < 10.0
        handle_next_event(q)
    end
end