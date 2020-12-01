source /opt/ros/foxy/setup.bash
drone_device_id=${1}
logs_dir=${2}

export DRONE_DEVICE_ID=${drone_device_id}

echo "Start Mavlink Router"
mavlink-routerd >${logs_dir}/mav_routerd_out.log 2>${logs_dir}/mav_routerd_err.log &
echo "Start Mavlink control"
ros2 launch px4_mavlink_ctrl mavlink_ctrl.launch >${logs_dir}/mav_ctrl_out.log 2>${logs_dir}/mav_ctrl_err.log &
echo "Start Micrortps_agent"
micrortps_agent -t UDP -n ${drone_device_id} >${logs_dir}/urtps_out.log 2>${logs_dir}/urtps_err.log
