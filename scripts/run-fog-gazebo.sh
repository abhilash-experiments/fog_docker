#!/bin/bash

export PX4_SIM_MODEL=ssrc_fog_x
source /usr/share/gazebo/setup.sh
source /simulator/Tools/setup_gazebo.bash /simulator /simulator
echo "Starting gazebo"
IP_ADDR=$(hostname -I)
GAZEBOIP=${IP_ADDR} GAZEBOMASTER_URI=${IP_ADDR}:11345 gzserver /simulator/Tools/sitl_gazebo/worlds/empty.world --verbose
