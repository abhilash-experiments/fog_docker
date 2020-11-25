#!/bin/bash

export PX4_SIM_MODEL=ssrc_fog_x
export PX4_QGC_REMOTE_ADDRESS=172.17.0.1

drone_device_id=${1}
logs_dir=${2}

src_path="/fog-drone"
working_dir="/fog-drone/instance-${drone_device_id}"
[ ! -d "$working_dir" ] && mkdir -p "$working_dir"

cd ${working_dir}
echo "starting PX4 instance in $(pwd)"
#if [ $no_daemon == 1 ]; then
#	../bin/px4 -i $N "$src_path/etc" -w sitl_${PX4_SIM_MODEL}_${N} -s $src_path/etc/init.d-posix/rcS
#else
../bin/px4 -d "$src_path/etc" -w sitl_${PX4_SIM_MODEL}-${drone_device_id} -s $src_path/etc/init.d-posix/rcS >${logs_dir}/px4_out.log 2>${logs_dir}/px4_err.log &
#fi
