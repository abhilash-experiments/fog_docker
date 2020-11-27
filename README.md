# fog_docker
Create docker images of PX4/ROS2 and Gazebo for local Drone simulation environment.<br>

If you have ROS2 set up in host environment, you can see all the ROS2 nodes and topics of drone simulation container directly in your host machine over docker0 network.

## Pre-requirements:
Ubuntu 20.04 with Docker installed:<br>
https://docs.docker.com/engine/install/ubuntu/

## Instractions:
1. Clone fog_docker git repo<br>
```
git clone git@github.com:tiiuae/fog_docker.git fog_docker
cd fog_docker
```
3. Build your simulation environment. Use -h flag to see optional parameters<br>
```
./build.sh
```
4. run system<br>
```
./sitl-simulator-start.sh
./sitl-drone-add -d <your_drone_device_id>
```

## Simulation viewers
Simulation viewers helps to visualize drone activity in simulation.

#### Gazebo client

Gazebo client comes with gazebo installation. Make sure you install Gazebo 11.3 version to avoid version conflict between client and gzserver running in simulation container.<br>
Instructions to install gazebo11 to Ubuntu:<br>
http://gazebosim.org/tutorials?tut=install_ubuntu

Start Gazebo client viewer:
```
./sitl-gzclient.sh
```


#### QGroundControl

QGroundControl (QGC) tool can be used to visualize drone movement in world map.
http://qgroundcontrol.com/

Easiest way to run QGC is to download Ubuntu App image and just run it from
command line:
https://s3-us-west-2.amazonaws.com/qgroundcontrol/latest/QGroundControl.AppImage

Set QGroundControl connection:
* Type: TCP
* Host Address: *[ your drone container ip ]*
* Listening Port: 5760

Check above *[ your drone container ip ]* address by calling:<br>
`docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' drone-<your_drone_device_id>`



## Files:

Create container images:
* build.sh : Script to compile SW and build docker images. Use -h flag to see parameters
* Dockerfile.sitl-fogsw-base : Docker file to build fog_sw (ROS2) artifacts
* Dockerfile.sitl-px4-base : Docker file to build px4 firmware artifacts
* Dockerfile.sitl-drone : Docker file to build drone container including PX4 and ROS2
* Dockerfile.simulator : Docker file to build Gazebo simulation container
* Dockerfile.drone-provision : Docker file to provision drone container for cloud connection

Run container images:
* sitl-simulator-start.sh : Run gazebo simulator container
* sitl-drone-add.sh : Run drone container. Use -h flag to see parameters

Scripts included in container image:
* run-fog-gazebo.sh : Script executed in gazebo simulator container, starts up gazebo server
* run-fog-px4.sh : Script executed in drone container, starts px4 instance
* run-fog-ros2.sh : Script executed in drone container, starts ROS2 nodes
* spawn-drone.sh : Script executed in gazebo container, spawns drone model instance in Gazebo

Helper scripts for debugging:
* view-drone.sh : Script to show console in drone container. Use -h flag to see parameters
* view-simulator.sh : Script to show console in gazebo simulator container
