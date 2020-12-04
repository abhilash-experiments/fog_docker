#!/bin/bash

tag_value="latest"
build_opt=""
device_id=""
clean_build=0
dont_update=0

build_fogsw=0
build_px4=0
build_gzpkgs=0
build_sim=0
build_drone=0

usage() {
    echo "USAGE: $0 [ -t <tag_value> | -b <build_option> | -p <device_id> | -h ]"
    echo " Parameters:"
    echo "  -h : Show this help message"
    echo "  -t : Tag value for docker images. Defalut: 'latest'"
    echo "  -c : Clean build. Delete and clone SW repo before build"
    echo "  -n : Don't update repository before build. This can be used when"
    echo "        repository contains own local changes/development that are"
    echo "        not pushed into remote branch"
    echo "  -b : Build options:"
    echo "        all    : Build everything and generate all containers"
    echo "        fogsw  : Build fog_sw and generate necessary containers"
    echo "        px4    : Build px4 and generate necessary containers"
    echo "        gzpkgs : Build gazebo ROS2 pkgs"
    echo "        sim    : Generate simulator container"
    echo "        drone  : Generate drone container"
    echo "        none   : Don't build anything. Can be used with -p flag"
    echo "  -p : Provision the drone image with private key and device_id"
    echo "        device_id is given as parameter"
    echo "        private key is searched from ./enclave/rsa_private.pem file from current dir"
    echo
    exit -1
}

while getopts hnct:ab:p: option
do
case "$option"
in
    h) usage ;;
    n) dont_update=1 ;;
    t) tag_value=$OPTARG ;;
    c) clean_build=1 ;;
    b) build_opt=$OPTARG
        if [ "${build_opt}" = "all" ]; then
            # Set Build all
            build_fogsw=1
            build_px4=1
            build_gzpkgs=1
            build_sim=1
            build_drone=1
        elif [ "${build_opt}" = "fogsw" ]; then
            build_fogsw=1
            build_drone=1
        elif [ "${build_opt}" = "px4" ]; then
            build_px4=1
            build_sim=1
            build_drone=1
        elif [ "${build_opt}" = "gzpkgs" ]; then
            build_gzpkgs=1
            build_sim=1
        elif [ "${build_opt}" = "sim" ]; then
            build_sim=1
        elif [ "${build_opt}" = "drone" ]; then
            build_drone=1
        fi
        ;;
    t) tag_value=$OPTARG ;;
    p) device_id=$OPTARG ;;
esac
done

if [ "${build_opt}" = "" ]; then
    # If build option not set then build all
    build_fogsw=1
    build_px4=1
    build_gzpkgs=1
    build_sim=1
    build_drone=1
fi



if [ ${build_fogsw} = 1 ]; then
    echo "===== FOG SW Base docker image ====="
    echo
    pushd .
    if [ ${clean_build} = 1 ]; then
        echo "Clean build, delete fog_sw directory"
        rm -Rf fog_sw
    fi
    if [ ! -d fog_sw ]; then
        echo "Clone fog_sw git reporsitory"
        git clone https://github.com/tiiuae/fog_sw.git fog_sw
        sleep 1
        cd fog_sw
    else
        cd fog_sw
        if [ ${dont_update} = 0 ]; then
            git pull
        fi
    fi
    if [ ${dont_update} = 0 ] && [ ${clean_build} = 0 ]; then
        echo "Update fog_sw submodules"
        git submodule update --init --recursive
        sleep 1
        git reset --hard
        git submodule foreach --recursive git reset --hard
        sleep 1
    fi
    popd
    echo "Create sitl-fogsw-base:${tag_value} image"
    cp DockerFiles/Dockerfile.sitl-fogsw-base ./Dockerfile
    docker build -t sitl-fogsw-base:${tag_value} --build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_ed25519)" .
fi

if [ ${build_px4} = 1 ]; then
    echo "===== PX4 Base docker image ====="
    echo
    pushd .
    if [ ${clean_build} = 1 ]; then
        echo "Clean build, delete px4-firmware directory"
        rm -Rf px4-firmware
    fi
    if [ ! -d px4-firmware ]; then
        echo "Clone px4-firmware git reporsitory"
        git clone https://github.com/tiiuae/px4-firmware.git px4-firmware
        sleep 1
        cd px4-firmware
    else
        cd px4-firmware
        if [ ${dont_update} = 0 ]; then
            git pull
        fi
    fi
    if [ ${dont_update} = 0 ] && [ ${clean_build} = 0 ]; then
        echo "Update px4-firmware submodules"
        git submodule update --init --recursive
        sleep 1
        git reset --hard
        git submodule foreach --recursive git reset --hard
        sleep 1
    fi
    popd
    echo "Create sitl-px4-base:${tag_value} image"
    cp DockerFiles/Dockerfile.sitl-px4-base ./Dockerfile
    docker build -t sitl-px4-base:${tag_value} .
fi

if [ ${build_gzpkgs} = 1 ]; then
    echo "===== Gazebo ROS2 pkgs base docker image ====="
    echo
    pushd .
    if [ ${clean_build} = 1 ]; then
        echo "Clean build, delete gazebo_ros_pkgs directory"
        rm -Rf gazebo_ros_pkgs
    fi
    if [ ! -d gazebo_ros_pkgs ]; then
        echo "Clone gazebo_ros_pkgs git reporsitory"
        git clone  --single-branch --branch foxy https://github.com/ros-simulation/gazebo_ros_pkgs.git gazebo_ros_pkgs
        sleep 1
        cd gazebo_ros_pkgs
    else
        cd gazebo_ros_pkgs
        if [ ${dont_update} = 0 ]; then
            git pull
        fi
    fi
    if [ ${dont_update} = 0 ] && [ ${clean_build} = 0 ]; then
        echo "Update gazebo_ros_pkgs submodules"
        git submodule update --init --recursive
        sleep 1
        git reset --hard
        git submodule foreach --recursive git reset --hard
        sleep 1
    fi
    popd
    echo "Create sitl-gzpkgs-base:${tag_value} image"
    cp DockerFiles/Dockerfile.sitl-gzpkgs-base ./Dockerfile
    docker build -t sitl-gzpkgs-base:${tag_value} .
fi

if [ ${build_sim} = 1 ]; then
    echo
    echo "======= Simulator docker image ========"
    echo
    echo "Create sitl-simulator:${tag_value} image"
    cp DockerFiles/Dockerfile.sitl-simulator ./Dockerfile
    docker build -t sitl-simulator:${tag_value} --build-arg tag=${tag_value} .
fi

if [ ${build_drone} = 1 ]; then
    echo
    echo "====== Drone docker image ======"
    echo
    echo "Create sitl-drone:${tag_value} image"
    cp DockerFiles/Dockerfile.sitl-drone ./Dockerfile
    docker build -t sitl-drone:${tag_value} --build-arg tag=${tag_value} .
fi

if [ "${device_id}" != "" ]; then
    echo "Provision drone image with name '${device_id}'"
    private_key="./enclave/rsa_private.pem"
    if [ ! -e ${private_key} ]; then
        echo "ERROR: No ${private_key} file found!!"
        exit -1
    fi

    dev_id_file="./enclave/drone_device_id"
    echo "DRONE_DEVICE_ID=${device_id}" > ${dev_id_file}

    cp DockerFiles/Dockerfile.sitl-drone-provision Dockerfile
    docker build -t sitl-drone-${device_id} --build-arg tag=${tag_value} .
fi

if [ -e Dockerfile ]; then
    rm Dockerfile
fi
