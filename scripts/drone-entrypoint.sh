#!/bin/bash
dev_id_file="/enclave/drone_device_id"

if [ ! -e ${dev_id_file} ]; then
    echo "No ${dev_id_file} file found!!"
    exit -1
fi

logs_dir=/fog-drone/logs
source ${dev_id_file}
drone_device_id=${DRONE_DEVICE_ID}
/fog-drone/run-fog-px4.sh  "${drone_device_id}" ${logs_dir}
/fog-drone/run-fog-ros2.sh "${drone_device_id}" ${logs_dir}
