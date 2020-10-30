#!/bin/bash

sudo docker run --name drone_${1} -dit dronesim_px4ros2:1.0 bash
sudo docker exec drone_${1} bash -c "/px4_sitl/Tools/run-fog-px4.sh ${1} "
drone_addr=$(sudo docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' drone_${1})
echo "Drone address: ${drone_addr}"
sudo docker exec dronesim_gazebo bash -c "/px4_sitl_gazebo/Tools/spawn-drone.sh ${1} ${drone_addr}"
