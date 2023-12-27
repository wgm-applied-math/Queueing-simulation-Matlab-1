function times = served_customer_times(q)
% served_customer_times - List out the duration each customer spent at a
% service station.
%
% times = served_customer_times(q) - Go through a ServiceQueue's list of
% served customers and record the time it spent at a service station in the
% row vector times.

arguments
    q ServiceQueue
end

num_customers_served = size(q.Served, 2);
times = zeros([1, num_customers_served]);

for j = 1:num_customers_served
    customer = q.Served{j};
    times(j) = customer.DepartureTime - customer.ArrivalTime;
end

end