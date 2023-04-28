#!/bin/bash

# refer to https://github.com/Intel-bigdata/HiBench/tree/master/bin/functions

# shellcheck disable=SC2006

function checkCMD() {
    local cmd=$1
    which "$cmd" > /dev/null 2>&1
    if [ $? -eq 1 ]; then
        assert 0 "\"$cmd\" utility missing. Please install it to generate proper report."
        return 1
    fi
}

function timestamp() {		# get current timestamp
    sec=`date +%s`
    nanosec=`date +%N`
    re='^[0-9]+$'
    if ! [[ $nanosec =~ $re ]] ; then
        $nanosec=0
    fi
    tmp=`expr $sec \* 1000 `
    msec=`expr $nanosec / 1000000 `
    echo `expr $tmp + $msec`
}

function get_field_name() {	# print report column header
    # shellcheck disable=SC2182
    printf "${REPORT_COLUMN_FORMATS}" File Date Time "Duration(s)"
}

function gen_report() {		# dump the result to report file
    local type=$1
    local start=$2
    local end=$3
    local duration=$(echo "scale=3;($end-$start)/1000"|bc)

    REPORT_TITLE=`get_field_name`
    if [ ! -f ${REPORT_DIR}/${REPORT_NAME} ] ; then
        echo "${REPORT_TITLE}" > ${REPORT_DIR}/${REPORT_NAME}
    fi

    REPORT_LINE=$(printf "${REPORT_COLUMN_FORMATS}" $type $(date +%F) $(date +%T) $duration)
    echo "${REPORT_LINE}" >> ${REPORT_DIR}/${REPORT_NAME}
}
