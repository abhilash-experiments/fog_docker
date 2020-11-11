#!/bin/bash

DO_BUILD=0
SAVE_CONTINERS=0

usage() {
	echo "USAGE: $0 [ -b | -s | -h ]"
	echo " Parameters:"
	echo "  -b : Build ROS2 and PX4-firmware"
	echo "  -s : Save containers locally into tar file"
	echo "  -h : Show this help message"
	echo
	exit -1
}

while getopts bsh option
do
case "$option"
in
	b) DO_BUILD=1;;
	s) SAVE_CONTINERS=1;;
	h) usage ;;
esac
done

if [[ $DO_BUILD == 1 ]]; then
	echo "===== Building FOG SW and PX4 Firmware ====="
	echo
	pushd .
	if [ ! -d fog_sw ]; then
		echo "Clone fog_sw git reporsitory"
		git clone git@github.com:ssrc-tii/fog_sw.git fog_sw
		cd fog_sw
	else
		cd fog_sw
		git pull
	fi

	echo "Update fog_sw submodules"
	git submodule update --init --recursive
	echo "Build fog_sw"
	cd ros2_ws
	colcon build
	source install/setup.bash
	cd ../packaging
	./package.sh
	popd

	pushd .
	if [ ! -d px4-firmware ]; then
		echo "Clone px4-firmware git reporsitory"
		git clone git@github.com:ssrc-tii/px4-firmware_private.git px4-firmware
		cd px4-firmware
	else
		cd px4-firmware
		git pull
	fi
	echo "Update px4-firmware submodules"
	git submodule update --init --recursive
	echo "Build px4-firmware"
	DONT_RUN=1 make px4_sitl_rtps gazebo_iris_rtps
	popd
fi


echo
echo "======= Create Docker image for PX4 ========"
echo
cp Dockerfile.drone Dockerfile
docker build --tag dronesim_px4ros2:1.0 .
if [[ $SAVE_CONTINERS == 1 ]]; then
	docker save -o dronesim_PX4_ROS2-1.0.tar dronesim_px4ros2:1.0
fi

echo
echo "====== Create Docker image for Gazebo ======"
echo
cp Dockerfile.gazebo Dockerfile
docker build --tag dronesim_gazebo:1.0 .
if [[ $SAVE_CONTINERS == 1 ]]; then
	docker save -o dronesim_Gazebo-1.0.tar dronesim_gazebo:1.0
fi

rm Dockerfile
