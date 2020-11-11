#!/bin/bash

INTERACTIVE=0
INSTANCE=-1
DEVICE_ID=""

usage() {
	echo "USAGE: $0 [ -h | -i | -n ]"
	echo " Parameters:"
    echo "  -h : Show this help message"
	echo "  -i : Interactive PX4 console"
    echo "  -n : Drone instance number"
    echo "  -d : Device id for communication link"
	echo
	exit -1
}

while getopts hin:d: option
do
case "$option"
in
    h) usage ;;
	i) INTERACTIVE=1;;
    n) INSTANCE=$OPTARG;;
    d) DEVICE_ID=$OPTARG;;
esac
done

if [[ "$INSTANCE" == "-1" ]]; then
    echo "Drone instance missing!!"
    echo
    usage
fi

if [[ "$DEVICE_ID" == "" ]]; then
    echo "Device id for communication link missing!!"
    echo
    usage
fi

docker run --name drone_${INSTANCE} -dit dronesim_px4ros2:1.0 bash
drone_addr=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' drone_${INSTANCE})
echo "Drone address: ${drone_addr}"
docker exec dronesim_gazebo bash -c "/px4_sitl_gazebo/Tools/spawn-drone.sh ${INSTANCE} ${drone_addr}"
docker exec drone_${INSTANCE} bash -c "/px4_sitl/Tools/run-fog-ros2.sh '${DEVICE_ID}'"
if [[ "$INTERACTIVE" == "1" ]]; then
    docker exec -it drone_${INSTANCE} bash -c "Tools/run-fog-px4.sh ${INSTANCE} 1"
else
    docker exec drone_${INSTANCE} bash -c "Tools/run-fog-px4.sh ${INSTANCE}"
fi
