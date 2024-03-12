%% Run samples of the ServiceQueue simulation
% 
% Collect statistics and plot histograms along the way.

% MATLAB-ism: Comment lines that start with %% and a space are treated as
% section headings.  If you click the "Run Section" button, MATLAB will
% evaluate just the commands between the section headings just before and
% just after the text cursor.  This can be really useful when you have some
% very long calculations, such as simulation runs, and some short follow-up
% commands, such as plots.

%% Set up

% Arrival rate
lambda = 1/2;

% Departure (service) rate
mu = 1/1.5;

% Number of serving stations
s = 1;

% Set up to run 100 samples of the queue.
NumSamples = 100;

% Each sample is run up to a maximum time of 1000.
MaxTime = 1000;

% Record how many customers are in the system at the end of each sample.
NumInSystemSamples = cell([NumSamples, 1]);

%% Numbers from theory for M/M/1 queue

% Compute |(1+n) = $P_n$ = probability of finding the system in state $n$
% in the long term.
% Note that this calculation assumes s=1.
rho = lambda / mu;
P0 = 1 - rho;
nMax = 10;
P = zeros([1, nMax+1]);
P(1) = P0;
for n = 1:nMax
    P(1+n) = P0 * rho^n / d;
end

%% Run simulation samples

% The statistics seem to come out a little weird if the log interval is too
% short, because the log entries are not independent enough.  So the log
% interval should be long enough for several arrival and departure events
% happen.
for sample_num = 1:NumSamples
    q = ServiceQueue( ...
        ArrivalRate=lambda, ...
        DepartureRate=mu, ...
        NumServers=s, ...
        LogInterval=10);
    q.schedule_event(Arrival(1, Customer(1)));
    run_until(q, MaxTime);
    % Pull out samples of the number of customers in the queue system. Each
    % sample run of the queue results in a column of samples of customer
    % counts, because tables like q.Log allow easy extraction of whole
    % columns like this.
    NumInSystemSamples{sample_num} = q.Log.NumWaiting + q.Log.NumInService;
end

% Join all the samples. "vertcat" is short for "vertical concatenate",
% meaning it joins a bunch of arrays vertically, which in this case results
% in one tall column.
NumInSystem = vertcat(NumInSystemSamples{:});

% MATLAB-ism: When you pull multiple items from a cell array, the result is
% a "comma-separated list" rather than some kind of array.  Thus, the above
% means
%
%    NumInSystem = vertcat(NumInSystemSamples{1}, NumInSystemSamples{2}, ...)
%
% which concatenates all the columns of numbers in NumInSystemSamples into
% one long column.
%
% This is roughly equivalent to "splatting" in Python, which looks like
% f(*args).

%% Pictures and stats for number of customers in system

% Print out mean number of customers in the system.
meanNumInSystem = mean(NumInSystem);
fprintf("Mean number in system: %f", meanNumInSystem);

% Make a figure with one set of axes.
fig = figure();
t = tiledlayout(fig,1,1);
ax = nexttile(t);

% MATLAB-ism: Once you've created a picture, you can use hold to cause
% further plotting function to work with the same picture rather than
% create a new one.
hold(ax, "on");

% Start with a histogram.  The result is an empirical PDF, that is, the
% area of the bar at horizontal index n is proportional to the fraction of
% samples for which there were n customers in the system.
h = histogram(ax, NumInSystem, Normalization="probability", BinMethod="integers");

% Plot $(0, P_0), (1, P_1), \dots$.
% If all goes well, these dots should land close to the tops of the bars of
% the histogram.
plot(ax, 0:nMax, P, 'o', MarkerEdgeColor='k', MarkerFaceColor='r');

% Add titles and labels and such.
title(ax, "Number of customers in the system");
xlabel(ax, "Count");
ylabel(ax, "Probability");
legend(ax, "simulation", "theory");

% Save the picture as a PDF file.
exportgraphics(fig, "Number in system histogram.pdf");
