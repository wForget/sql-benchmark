#!/bin/bash

args=$@

current_dir=`dirname "$0"`

sh $current_dir/run.sh beeline $args
