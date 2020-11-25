#!/bin/bash

tag_value="latest"
build_opt=""
device_id=""

build_fogsw=0
build_px4=0
build_sim=0
build_drone=0

usage() {
    echo "USAGE: $0 [ -t <tag_value> | -b <build_option> | -p <device_id> | -h ]"
    echo " Parameters:"
    echo "  -h : Show this help message"
    echo "  -t : Tag value for docker images. Defalut: 'latest'"
    echo "  -b : Build options:"
    echo "        all   : Build everything and generate all containers"
    echo "        fogsw : Build fog_sw and generate necessary containers"
    echo "        px4   : Build px4 and generate necessary containers"
    echo "        sim   : Generate simulator container"
    echo "        drone : Generate drone container"
    echo "        none  : Don't build anything. Can be used with -p flag"
    echo "  -p : Provision the drone image with private key and device_id"
    echo "        device_id is given as parameter"
    echo "        private key is searched from ./enclave/rsa_private.pem file from current dir"
    echo
    exit -1
}

while getopts ht:ab:p: option
do
case "$option"
in
    h) usage ;;
    t) tag_value=$OPTARG ;;
    b) build_opt=$OPTARG
        if [ "${build_opt}" = "all" ]; then
            # Set Build all
            build_fogsw=1
            build_px4=1
            build_sim=1
            build_drone=1
        elif [ "${build_opt}" = "fogsw" ]; then
            build_fogsw=1
            build_drone=1
        elif [ "${build_opt}" = "px4" ]; then
            build_px4=1
            build_sim=1
            build_drone=1
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
    build_sim=1
    build_drone=1
fi



if [ ${build_fogsw} = 1 ]; then
    echo "===== FOG SW Base docker image ====="
    echo
    pushd .
    if [ ! -d fog_sw ]; then
        echo "Clone fog_sw git reporsitory"
        git clone git@github.com:tiiuae/fog_sw.git fog_sw
        cd fog_sw
    else
        cd fog_sw
        git pull
    fi
    echo "Update fog_sw submodules"
    git submodule update --init --recursive
    popd
    echo "Create sitl-fogsw-base:${tag_value} image"
    cp DockerFiles/Dockerfile.sitl-fogsw-base ./Dockerfile
    docker build -t sitl-fogsw-base:${tag_value} --build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_ed25519)" .
fi

if [ ${build_px4} = 1 ]; then
    echo "===== PX4 Base docker image ====="
    echo
    pushd .
    if [ ! -d px4-firmware ]; then
        echo "Clone px4-firmware git reporsitory"
        git clone git@github.com:tiiuae/px4-firmware.git px4-firmware
        cd px4-firmware
    else
        cd px4-firmware
        git pull
    fi
    echo "Update px4-firmware submodules"
    git submodule update --init --recursive
    popd
    echo "Create sitl-px4-base:${tag_value} image"
    cp DockerFiles/Dockerfile.sitl-px4-base ./Dockerfile
    docker build -t sitl-px4-base:${tag_value} .
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
