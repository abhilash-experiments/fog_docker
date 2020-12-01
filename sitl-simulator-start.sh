#!/bin/bash

tag='latest'

usage() {
    echo "USAGE: $0 [ -h | -t <tag> ]"
    echo " Parameters:"
    echo "  -h      : Show this help message"
    echo "  -t <tag>: Simulator docker image version. tag='latest' if not given"
    echo
    exit -1
}

while getopts ht: option
do
case "$option"
in
    h) usage && exit -1 ;;
    t) tag=$OPTARG ;;
esac
done

if [ ! -d ${PWD}/gazebo_model_import ]; then
    mkdir -p ${PWD}/gazebo_model_import
fi

docker run --name simulator -p 11345:11345 \
    --mount type=volume,dst=/export_model,volume-driver=local,volume-opt=type=none,volume-opt=o=bind,volume-opt=device=${PWD}/gazebo_model_import \
    -dti sitl-simulator:${tag}
