#!/bin/bash

if [ ! -d ${PWD}/gazebo_model_import ]; then
    mkdir -p ${PWD}/gazebo_model_import
fi

docker run --name simulator -p 11345:11345 \
    --mount type=volume,dst=/export_model,volume-driver=local,volume-opt=type=none,volume-opt=o=bind,volume-opt=device=${PWD}/gazebo_model_import \
    -dti sitl-simulator
