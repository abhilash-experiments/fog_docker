source /opt/ros/foxy/setup.bash
echo "Start Mavlink Router"
mavlink-routerd &
echo "Start Mavlink control"
ros2 launch px4_mavlink_ctrl mavlink_ctrl.launch &
#ros2 run px4_mavlink_ctrl mavlink_ctrl --ros-args -p udp_remote_port:=14580 -p udp_local_port:=14540 >/px4_sitl/mav_ctrl_out.log 2>/px4_sitl/mav_ctrl_err.log &
echo "Start Communication link"
cd /enclave && source /opt/ros/foxy/setup.bash && communication_link -device_id "${1}" >/px4_sitl/commlink_out.log 2>/px4_sitl/commlink_err.log &
echo "Start Micrortps_agent"
micrortps_agent -t UDP >/px4_sitl/urtps_out.log 2>/px4_sitl/urtps_err.log &
echo "done."
