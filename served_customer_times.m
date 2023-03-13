function times = served_customer_times(q)

num_customers_served = size(q.Served, 2);
times = zeros([num_customers_served, 1]);

for j = 1:num_customers_served
    customer = q.Served{j};
    times(j) = customer.DepartureTime - customer.ArrivalTime;
end

end