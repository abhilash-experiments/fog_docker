if [ "$1" = "" ]; then
    echo "USAGE: $0 <your_drone_device_id>"
    echo
    exit -1
fi
docker exec -ti drone-${1} bash
