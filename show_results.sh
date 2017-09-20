#!/usr/bin/bash

if [ "$1" == "--help" ]; then
	echo usage: show_results.sh SUBJECT MODE WORKLOAD_TYPE
	echo
	echo "SUBJECT       = vanilla | pathman"
	echo "MODE          = inserts | workload"
	echo "WORKLOAD_TYPE = a | b | c | d | e | f"
	echo
	echo i.e. show_results.sh vanilla workload a
	echo
	exit 0
fi

subject=$1
mode=$2
workload_type=$3

if [ -z "$subject" ]; then
	subject=vanilla
	>&2 echo "no subject, defaults to '$subject'"
fi

if [ -z "$mode" ]; then
	mode=inserts
	>&2 echo "no mode, defaults to '$mode'"
fi

if [ -z "$workload_type" ]; then
	workload_type=a
	>&2 echo "no workload_type, defaults to '$workload_type'"
fi


grep Throughput $subject/*$mode-$workload_type*.log | \
sed 's/^.*\(workload\|inserts\)-.-\(.*\).log:/\2\t/g' | \
sed 's/\[OVERALL\].*,.*,//g' | \
sort -k1 -g
