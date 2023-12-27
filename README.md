# Queueing-simulation-Matlab-1
A queueing simulation in Matlab.
I hope to eventually add a Python version and a Java version.

This is an M/M/s queue simulation.
The overall architecture is event driven.

The main class is `ServiceQueue`.
It maintains a list of events, ordered by the time that they occur.
There is one `Arrival` scheduled at any time that represents the arrival of the next customer.
When a customer reaches the front of the waiting queue, they can be moved to a service station.
Once a customer moves into a service slot, a `Departure` event for that customer is scheduled.
There should be one `Departure` event scheduled for each busy service station.
There is one `RecordToLog` scheduled at any time that represents the next time statistics will be added to the log table.

FYI: The use of "queueing" rather than "queuing" is for consistency with the textbook.
