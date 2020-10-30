#!/bin/bash


N=${1:-0}

no_daemon=${2:-0}

export PX4_SIM_MODEL=iris_rtps
export PX4_QGC_REMOTE_ADDRESS=172.17.0.1

src_path="/px4_sitl"

working_dir="/px4_sitl/instance_$N"
[ ! -d "$working_dir" ] && mkdir -p "$working_dir"

cd $working_dir
echo "starting PX4 instance $N in $(pwd)"
if [ $no_daemon == 1 ]; then
	../bin/px4 -i $N "$src_path/ROMFS/px4fmu_common" -w sitl_${PX4_SIM_MODEL}_${N} -s etc/init.d-posix/rcS
else
	../bin/px4 -i $N -d "$src_path/ROMFS/px4fmu_common" -w sitl_${PX4_SIM_MODEL}_${N} -s etc/init.d-posix/rcS >${working_dir}/out.log 2>${working_dir}/err.log &
fi
