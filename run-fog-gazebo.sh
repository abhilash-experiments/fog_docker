#!/bin/bash

export PX4_SIM_MODEL=iris_rtps
source /usr/share/gazebo/setup.sh
source /px4_sitl_gazebo/Tools/setup_gazebo.bash /px4_sitl_gazebo /px4_sitl_gazebo
echo "Starting gazebo"
IP_ADDR=$(ifconfig | grep "inet 172" | awk '{print $2}')
echo "GAZEBOMASTER_URI=${IP_ADDR}:11345"
GAZEBOIP=${IP_ADDR} GAZEBOMASTER_URI=${IP_ADDR}:11345 gzserver /px4_sitl_gazebo/Tools/sitl_gazebo/worlds/empty.world --verbose &
