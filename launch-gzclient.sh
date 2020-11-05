#!/bin/bash

export PX4_SIM_MODEL=iris_rtps
export GAZEBO_MODEL_PATH=px4-firmware/Tools/sitl_gazebo/models/:$GAZEBO_MODEL_PATH
IP_ADDR=$(ifconfig | grep -A1 "docker0" | grep inet | awk '{print $2}')
echo "Start Gazebo client: IP:${IP_ADDR}"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
GAZEBO_MODEL_PATH=${SCRIPT_DIR}/px4-firmware/Tools/sitl_gazebo/models/:$GAZEBO_MODEL_PATH GAZEBOIP=${IP_ADDR} GAZEBOMASTER_URI=${IP_ADDR}:11345 gzclient --verbose
