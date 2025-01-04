# sched-benchmarking

The purpose of this repository is to find a baseline performance for a scheduler, then compare that scheduler's performance with another scheduler.

There are a number of variables that can get in the way of comparing schedulers' performance:
- CPU frequency variability
- Machine background load
- Target load variability

This is handled with the following tools/strategies:
- **CPU freq**
The following command ensures that the CPU's governance rule makes it maintain a consistent frequency:
```sudo cpupower frequency-set --governor performance```
Therefore, CPU frequency won't vary during testing, and therefore won't be a factor in runtime variances.
Note: To check what the default CPU frequency governor was, run:
```cpupower frequency-info```
And to see all the options for governors, run:
```cpupower frequency-info --governors```
***Remember to change the frequency governor back to the default after testing.***
- **Machine background load**
This is better done manually than systematically. Make sure nothing else besides kernel tasks are running on the system, or just run all the tests with the same processes running. It's more important to have a consistent background load than a low one.
- **Target load**
To ensure the target load (benchmark) is consistent, ```stress-ng``` is used for the benchmark processes with the following parameters:
- the ```--timeout``` parameter to ensure it ends at a consistent runtime.
- the ```--cpu``` parameter to pin a process to a CPU so that migrations do not occur.
Moreover, the ```time``` tool to measure the *individual* runtime of each task.
- the ```benchmark-serial.sh``` bash script runs each benchmark process sequentially, getting a baseline for how long each task takes.
- the ```benchmark-concurrent.sh``` script runs every benchmark process at the same time, finding out how long the entire runtime was. Because it is known how long each task should take individually, we can compare the individual runtime values with the total runtime, using this as the primary measure for comparing a scheduler's performance.
