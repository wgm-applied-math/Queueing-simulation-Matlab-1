n_samples = 100;
max_time = 1000;
NInSystem = [];

%% Run the queue simulation
for sample_num = 1:n_samples
    q = ServiceQueue(LogInterval=0.5);
    q.schedule_event(Arrival(1, Customer(1)));
    run_until(q, max_time);
    % Pull out samples of the number of customers in the queue system
    NInSystem = [NInSystem, q.Log.NWaiting + q.Log.NInService];
end

%% Make a picture
hold on;

% Start with a histogram.
h = histogram(NInSystem, Normalization="probability", BinMethod="integers");

% For comparison, plot the theoretical results for a M/M/1 queue.
% The agreement isn't all that good unless you run for a long time, say
% max_time = 10,000 units, and LogInterval is small, say 0.05.
% The simulation will take a couple of minutes to run.
rho = q.ArrivalRate / q.DepartureRate;
P0 = 1 - rho;
nMax = 10;
ns = 0:nMax;
P = [P0];
for n = 1:nMax
    P(1+n) = P0 * rho^n;
end
plot(ns, P, 'o', MarkerEdgeColor='k', MarkerFaceColor='r');

% This sets some paper-related properties of the figure so that you can
% save it as a PDF and it doesn't fill a whole page.
% gcf is "get current figure handle"
% See https://stackoverflow.com/a/18868933/2407278
fig = gcf;
fig.Units = 'inches';
screenposition = fig.Position;
fig.PaperPosition = [0 0 screenposition(3:4)];
fig.PaperSize = [screenposition(3:4)];