#!/bin/bash

export PX4_SIM_MODEL=iris_rtps
export GAZEBO_MODEL_PATH=px4-firmware/Tools/sitl_gazebo/models/:$GAZEBO_MODEL_PATH
IP_ADDR=$(ifconfig | grep -A1 "docker0" | grep inet | awk '{print $2}')
GAZEBO_MODEL_PATH=px4-firmware/Tools/sitl_gazebo/models/:$GAZEBO_MODEL_PATH GAZEBOIP=${IP_ADDR} GAZEBOMASTER_URI=${IP_ADDR}:11345 gzclient --verbose
