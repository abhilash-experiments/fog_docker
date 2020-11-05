# fog_docker
Create docker images of PX4/ROS2 and Gazebo for Drone simulation environment

## Instractions:
1. Clone fog_docker git repo:<br>
`git clone git@github.com:ssrc-tii/fog_docker.git`

2. Copy your drone private key (rsa_private.pem) into enclave/ folder

3. run create_drone_docker.sh to fetch and build sources and create docker images:<br>
`./create_drone_docker.sh -b -s`

4. run system:<br>
`./launch-docker-gazebo.sh`<br>
`./launch-docker-px4.sh -n 0 -d <your_drone_device_id_in_cloud>`<br>
In case you like to see simulation in gazebo client:<br>
`./launch-gzclient.sh`

5. Launch QGroundControl and set connection: Type: UDP, Listening Port: 14550



## Files:

Create container images:
* create_drone_docker.sh: Script to compile SW, build and save docker images
* Dockerfile.drone : Docker file to build PX4/ROS2 container
* Dockerfile.gazebo : Docker file to build Gazebo simulation container

Run container images:
* launch-docker-gazebo.sh : Run gazebo container
* launch-docker-px4.sh : Run drone container. Use -h flag to see parameters
* launch-gzclient.sh : Run Gazebo client in host

Scripts included in container image:
* run-fog-gazebo.sh : Script executed in gazebo container, starts up gazebo server
* run-fog-px4.sh : Script executed in drone container, starts px4 instance and calls script to spawns drone instance in Gazebo
* run-fog-ros2.sh : Script executed in drone container, starts ROS2 nodes
* spawn-drone.sh : Script executed in gazebo container, spawns drone instance in Gazebo

Helper scripts for debugging:
* view-drone.sh : Script to show console in drone container.
  * Parameter: drone_instance. e.g. view-drone.sh 3   -> show console in drone_3 container
* view-gazebo.sh : Script to show console in gazebo container
