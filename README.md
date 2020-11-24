# fog_docker
Create docker images of PX4/ROS2 and Gazebo for Drone simulation environment

files:

Create container images:
* create_drone_docker.sh: Script to compile SW, build and save docker images
* Dockerfile.drone : Docker file to build PX4/ROS2 container
* Dockerfile.gaezbo : Docker file to build Gazebo simulation container

Run container images:
* launch-docker-gazebo.sh : Run gazebo container
* launch-docker-px4.sh : Run drone container.
  * Parameter: drone_instance. e.g. launch-docker-px4.sh 0  -> launches container with px4 instance number 0
* launch-gzclient.sh : Run Gazebo client in host
  
Scripts included in container image:
* run-fog-gazebo.sh : Script executed in gazebo container, starts up gazebo server
* run-fog-px4.sh : Script executed in drone container, starts px4 instance and calls script to spawns drone instance in Gazebo
* spawn-drone.sh : Script executed in gazebo container, spawns drone instance in Gazebo

Helper scripts for debugging:
* view-drone.sh : Script to show console in drone container.
  * Parameter: drone_instance. e.g. view-drone.sh 3   -> show console in drone_3 container
* view-gazebo.sh : Script to show console in gazebo container


