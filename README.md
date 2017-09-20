# Partitioning benchmark for PostgreSQL 10

This benchmark is based on [YCSB](https://github.com/brianfrankcooper/YCSB).

## Overview

This benchmark runs all kinds of workloads (a, b, etc) for several minutes. The table is partitioned by range (using pg_pathman or vanilla), partition key is the 1st column of type `varchar(255)`. The amount of partitions is always the same (500), and the number of worker threads (sessions) changes from 1 to 128 with a step size of 16.

## Step-by-step guide

Perform the following steps:

1. Install your favorite Java SDK (e.g. OpenJDK) and Maven.
2. Build YCSB using Maven: `mvn package`.
3. Install or build PostgreSQL 10.
4. Install [pg_pathman](https://github.com/postgrespro/pg_pathman).
5. Change `logs_dir` and `pg_bin_dir` in `run.sh`.
6. (OPTIONAL) Adjust port in `run.sh` and `*.conf` files.
7. Create a cluster using `initdb` and adjust its `postgresql.conf` using `postgresql.add`.
8. Start PostgreSQL cluster.
9. Finally, run the benchmark (e.g. `./run.sh pathman`). Available options: `pathman`, 'vanilla'.

## What should I do next?

Examine the logs in `logs_dir`. There should be "workload-X-T" + "insert-X-T" files, where X is a workload type (a, b, c etc) and T is the number of threads. Note that we always use T=`FILLER_THREADS` for `ycsb load` to finish it as quickly as possible. The most interesting lines contain words "Throughput" and "RunTime", so `grep` is your best friend.
