#!/bin/bash

cd 'html'

pdfjam -o 'Queueing-simulation-printout.pdf' \
       ServiceQueue.pdf \
       Customer.pdf \
       Event.pdf \
       RecordToLog.pdf \
       Arrival.pdf \
       Departure.pdf \
       test_ServiceQueue.pdf \
       run_ServiceQueue.pdf \
       served_customer_times.pdf \
       PriorityQueue.pdf \
       sort_by.pdf
