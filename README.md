# sched-benchmarking

The purpose of this repository is to find a baseline performance for a scheduler, then compare that scheduler's performance with another scheduler.

There are a number of variables that can get in the way of comparing schedulers' performance:
- CPU frequency variability
- Machine background load
- Target load variability

This is handled with the following tools/strategies:
- **CPU freq**
Because the benchmark processes are given a time limit, they should have the same runtime no matter what the CPU frequency is. Therefore, governing the CPU frequency is not needed. However, for workloads where there is a fixed amount of work rather than a fixed amount of time, governing the CPU frequency will be necessary. In that case, read below.
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

**TODO:**
- 15 minutes Answer the question: What exactly happens when a CPU argument is passed on stress-ng? Does it pin it to one core, or simple make the process a single thread, meaning it can only use one core at a time?

- 8 hours Implement SJF in a sched-ext scheduler running everything on the same CPU core.
- 30 minutes and compare this scheduler's performance with EEVDF and other example sched-ext schedulers.

- 4 hours Does sched-ext pre-empt?
Simple check to find this out:
- Restrict everything to one CPU core:
- Make sure scx_dispatch doesn't take any new tasks
- Check if scx_stopping gets called
- Restrict tasks that get migrated to sched-ext
- Create 2 tasks that are switched to sched-ext, and these are the only ones.