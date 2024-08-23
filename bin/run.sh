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

export RESULT_DIR=${RESULT_DIR:-${work_dir}/result}
export RESULT_NAME=${RESULT_NAME:-"${REPORT_NAME}"}

RESULT_DIR_PATH="${RESULT_DIR}/${RESULT_NAME}"
if [ ! -e $RESULT_DIR_PATH ] ; then
    mkdir -p $RESULT_DIR_PATH
fi
rm -f $RESULT_DIR_PATH/*

sql_files=$(ls $SQL_DIR/*.sql)
for file in $sql_files
do
    filename=${file##*/}
    start=$(timestamp)
    result_file="$RESULT_DIR_PATH/${filename}.result"
    # grep -E "^[+|].*" is used to filter query result
    `$cmd -f $file $cmd_args | grep -E "^[+|].*" 1> ${result_file}`
    end=$(timestamp)
    gen_report $filename $start $end
done
