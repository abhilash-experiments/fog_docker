#!/bin/bash

if [[ $# -lt 2 ]]; then
	echo "Too few arguments!"
	echo "$0 <instance_number> <mavlink_addr>"
	exit 1
fi

N=$1
mav_addr=$2

export PX4_SIM_MODEL=ssrc_fog_x

src_path="/px4_sitl_gazebo"

mavlink_udp_port=14560
mavlink_tcp_port=4560

source ${src_path}/Tools/setup_gazebo.bash ${src_path} ${src_path}
export PATH=$PATH:/px4_sitl_gazebo/build_gazebo

working_dir="$src_path/instance_$N"
[ ! -d "$working_dir" ] && mkdir -p "$working_dir"

pushd "$working_dir" &>/dev/null
echo "starting instance $N in $(pwd)"

python3 ${src_path}/Tools/sitl_gazebo/scripts/jinja_gen.py ${src_path}/Tools/sitl_gazebo/models/${PX4_SIM_MODEL}/${PX4_SIM_MODEL}.sdf.jinja ${src_path}/Tools/sitl_gazebo \
	--qgc_addr 172.17.0.1 \
	--use_tcp 0 \
	--mavlink_addr ${mav_addr} \
	--mavlink_udp_port $((mavlink_udp_port+${N})) \
	--mavlink_tcp_port $((mavlink_tcp_port+${N})) \
	--output-file /tmp/${PX4_SIM_MODEL}_${N}.sdf

echo "Spawning ${PX4_SIM_MODEL}_${N} -- addr: ${mav_addr} udp: $(($mavlink_udp_port+$N)), tcp: $(($mavlink_tcp_port+$N))"

gz model --spawn-file=/tmp/${PX4_SIM_MODEL}_${N}.sdf --model-name=${PX4_SIM_MODEL}_${N} -x 0.0 -y $((3*${N})) -z 0.0
