#!/bin/bash

sudo docker run --name dronesim_gazebo -p 11345:11345 -dti dronesim_gazebo:1.0
sudo docker exec -d dronesim_gazebo bash -c "Tools/run-fog-gazebo.sh"