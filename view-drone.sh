device_id="default"

if [ "$1" = "-h" ]; then
    echo "USAGE: $0 [your_drone_device_id]"
    echo
    exit -1
fi

if [ "$1" != "" ]; then
    device_id=${1}
fi

docker exec -ti drone-${device_id} bash
