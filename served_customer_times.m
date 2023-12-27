function times = served_customer_times(q)
% served_customer_times - List out the duration each customer spent at a
% service station.
%
% times = served_customer_times(q) - Go through a ServiceQueue's list of
% served customers and record the time it spent at a service station in the
% row vector times.

arguments
    % q - The ServiceQueue to analyze.
    q ServiceQueue;
end

num_customers_served = size(q.Served, 2);
times = zeros([1, num_customers_served]);

for j = 1:num_customers_served
    customer = q.Served{j};
    times(j) = customer.DepartureTime - customer.ArrivalTime;
end

end

% MATLAB-ism: The "arguments" block in the above definition asserts that
% q is supposed to be an instance of ServiceQueue, or some subclass of
% ServiceQueue.  If you try to call this function on some other kind of
% object, you'll get an error message.  MATLAB is dynamically typed, so
% type assertions aren't generally required.  I've included one here to
% demonstrate how it's done.  The main use of them is to assist in tracking
% down bugs, like passing the wrong thing to a function or passing them in
% the wrong order.  Type assertions also assist in documenting what a
% function does.