#!/bin/bash

# shellcheck disable=SC2006

cmd=$1
cmd_args=${@:2}

current_dir=`dirname "$0"`
work_dir=`cd "$current_dir";cd ../; pwd`

SQL_DIR=${SQL_DIR:-${work_dir}/sql/tpcds/kyuubi_tpcds_3_2}

. ${work_dir}/bin/functions/workload_functions.sh

checkCMD bc
checkCMD $cmd

export REPORT_DIR=${REPORT_DIR:-${work_dir}/report}
export REPORT_NAME=${REPORT_NAME:-"sql_benchmark_$(timestamp).report"}
export REPORT_COLUMN_FORMATS="%-12s %-10s %-8s %-20s\n"

if [ ! -e ${REPORT_DIR} ] ; then
    mkdir ${REPORT_DIR}
fi

sql_files=$(ls $SQL_DIR/*.sql)
for file in $sql_files
do
    start=$(timestamp)
    `$cmd -f $file $cmd_args`
    end=$(timestamp)
    filename=${file##*/}
    gen_report $filename $start $end
done
