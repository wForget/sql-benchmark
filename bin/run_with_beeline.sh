#!/bin/bash

# shellcheck disable=SC2006

beeline_args=$@

current_dir=`dirname "$0"`
work_dir=`cd "$current_dir";cd ../; pwd`

sql_dir=${SQL_DIR:-${work_dir}/sql/tpcds}

. ${work_dir}/bin/functions/workload_functions.sh

checkCMD bc
checkCMD beeline

export REPORT_DIR=${REPORT_DIR:-${work_dir}/report}
export REPORT_NAME="sql_benchmark_$(timestamp).report"
export REPORT_COLUMN_FORMATS="%-12s %-10s %-8s %-20s\n"

if [ ! -e ${REPORT_DIR} ] ; then
    mkdir ${REPORT_DIR}
fi

sql_files=$(ls $sql_dir/*.sql)
for file in $sql_files
do
    start=$(timestamp)
    `beeline -f $file $beeline_args`
    end=$(timestamp)
    filename=${file##*/}
    gen_report $filename start end
done