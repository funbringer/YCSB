#!/usr/bin/bash

trap "exit" INT

# params
config=$1
run_time=$2
port=5432

# various dirs
test_dir=$(dirname $0)
logs_dir=$test_dir/bench_logs
pg_bin_dir=$HOME/pg_10/bin


if [ -z "$config" ]; then
	config=vanilla
fi

if [ -z "$run_time" ]; then
	run_time=450
fi


# remove old logs
echo wiping old logs in $logs_dir
rm -f $logs_dir/$config*

# show config
echo running $config
echo time $run_time
echo port $port

# show dirs
echo test_dir $test_dir
echo logs_dir $logs_dir
echo pg_bin_dir $pg_bin_dir


# create a role for benchmark
echo creating new role for benchmarks
$pg_bin_dir/psql -p$port postgres -c "create role ycsb with login superuser"

# create a database for benchmark
echo creating new database for benchmarks
$pg_bin_dir/psql -p$port postgres -c "drop database ycsb"
$pg_bin_dir/psql -p$port postgres -c "create database ycsb"

# create a partitioned table
echo creating new table $config for benchmarks
$pg_bin_dir/psql -p$port ycsb < $test_dir/$config.sql


# use max threads for "ycsb load"
FILLER_THREADS=144

for th in 1 16 32 64 96 128; do
	for load in a b c d e f; do

		# clear table
		echo truncating table $config
		$pg_bin_dir/psql -p$port ycsb -c "truncate $config"

		# fill table with data
		echo inserting data for this run
		$test_dir/bin/ycsb load jdbc \
			-cp $test_dir/postgresql-42.1.4.jar \
			-P workloads/workload$load \
			-P "$config.conf" \
			-threads $FILLER_THREADS \
			-s 2>&1 | \
		tee $logs_dir/$config-single-inserts-$load-$th.log;

		# vacuum table
		echo vacuuming all tables
		$pg_bin_dir/psql -p$port ycsb -c "vacuum analyze"

		# run bench
		echo "starting benchmark (load=$load, threads=$th)"
		$test_dir/bin/ycsb run jdbc \
			-cp $test_dir/postgresql-42.1.4.jar \
			-P workloads/workload$load \
			-P "$config.conf" \
			-threads $th \
			-s \
			-p operationcount=1000000000 \
			-p maxexecutiontime=$run_time 2>&1 | \
		grep --line-buffered -P '^[[\d]' | \
		tee $logs_dir/$config-single-workload-$load-$th.log;
	done
done

