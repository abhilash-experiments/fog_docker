device_id="default"

usage() {
    echo "USAGE: $0 [ -h | -d <id> ]"
    echo " Parameters:"
    echo "  -h      : Show this help message"
    echo "  -d <id> : Drone device_id in cloud"
    echo
    exit -1
}

while getopts hd: option
do
case "$option"
in
    h) usage && exit -1 ;;
    d) device_id=$OPTARG ;;
esac
done

docker exec -ti drone-${device_id} bash
