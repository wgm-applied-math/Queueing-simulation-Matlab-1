# Queueing-simulation-Matlab-1
A queueing simulation in Matlab.
I'll eventually add a Python version.

This is an M/M/s queue simulation.
The overall architecture is event driven.

The main class is `ServiceQueue`.
It maintains a list of events, ordered by the time that they occur.
There is one `Arrival` scheduled at any time that represents the arrival of the next customer.
There is a `Departure` event for each customer being served.
There is one `RecordToLog` scheduled at any time that represents the next time statistics will be added to the log table.
