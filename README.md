# Queueing-simulation-Matlab-1
A queueing simulation in Matlab.
I'll eventually add a Python version.

This is an M/M/s queue simulation.
The overall architecture is event driven.

The main class is `ServiceQueue`.
It maintains a list of events, ordered by the time that they occur.
There is one `Arrival` scheduled at any time that represents the arrival of the next customer.
When a customer reaches the front of the waiting queue, they can be moved to a service slot.
There is one `RecordToLog` scheduled at any time that represents the next time statistics will be added to the log table.
