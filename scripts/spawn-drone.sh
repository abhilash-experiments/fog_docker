#!/bin/bash

if [[ $# -lt 2 ]]; then
	echo "Too few arguments!"
	echo "$0 <mavlink_addr> <name> <pos_x> <pos_y>"
	exit 1
fi

mav_addr=$1
# Get index from last digit of mavlink_ip.
# Index is used for place drone into the world coordinate if x,y not given
#  drones ip addresses start normally from 172.17.0.3, so substract 3 to start
#  locate drones from y_pos 0
default_Y=$(( 3 * ( $(echo ${mav_addr} | cut -d '.' -f 4) - 3 ) ))

name=$2
pos_x=${3:-0.0}
pos_y=${4:-${default_Y}}

echo "Params: $mav_addr $name $pos_x $pos_y"

export PX4_SIM_MODEL=ssrc_fog_x

src_path="/simulator"

mavlink_udp_port=14560
mavlink_tcp_port=4560

source ${src_path}/Tools/setup_gazebo.bash ${src_path} ${src_path}
export PATH=$PATH:/px4_sitl_gazebo/build_gazebo

working_dir="$src_path/instance-${name}"
[ ! -d "$working_dir" ] && mkdir -p "$working_dir"

pushd "$working_dir" &>/dev/null
echo "starting new drone instance in $(pwd)"

python3 ${src_path}/Tools/sitl_gazebo/scripts/jinja_gen.py ${src_path}/Tools/sitl_gazebo/models/${PX4_SIM_MODEL}/${PX4_SIM_MODEL}.sdf.jinja ${src_path}/Tools/sitl_gazebo \
	--qgc_addr 172.17.0.1 \
	--use_tcp 0 \
	--mavlink_addr ${mav_addr} \
	--mavlink_udp_port ${mavlink_udp_port} \
	--mavlink_tcp_port ${mavlink_tcp_port} \
	--output-file /tmp/${PX4_SIM_MODEL}-${name}.sdf

echo "Spawning ${PX4_SIM_MODEL}-${name} -- addr: ${mav_addr} udp: ${mavlink_udp_port}, tcp: ${mavlink_tcp_port}"

gz model --spawn-file=/tmp/${PX4_SIM_MODEL}-${name}.sdf --model-name=${PX4_SIM_MODEL}-${name} -x ${pos_x} -y ${pos_y} -z 0.0
