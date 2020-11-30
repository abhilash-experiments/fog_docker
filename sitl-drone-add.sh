#!/bin/bash

device_id="default"
tag='latest'

usage() {
    echo "USAGE: $0 [ -h ] -d <device_id>"
    echo " Parameters:"
    echo "  -h      : Show this help message"
    echo "  -d <id> : Drone device_id in cloud"
    echo "  -t <tag>: Drone docker image version. tag='latest' if not given"
    echo
    exit -1
}

while getopts hd:t: option
do
case "$option"
in
    h) usage && exit -1 ;;
    d) device_id=$OPTARG ;;
    t) tag=$OPTARG ;;
esac
done

image_name=sitl-drone-${device_id}:${tag}

if [[ "$(docker images -q sitl-drone-${device_id} 2> /dev/null)" == "" ]]; then
    image_name=sitl-drone:${tag}
fi

docker run --name drone-${device_id} -dit ${image_name} bash
docker exec drone-${device_id} bash -c "./drone-entrypoint.sh &"
drone_addr=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' drone-${device_id})
echo "drone-${device_id} address: ${drone_addr}"
docker exec simulator bash -c "/simulator/spawn-drone.sh ${drone_addr} ${device_id}"
