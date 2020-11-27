#!/bin/bash

PX4_SIM_MODEL=ssrc_fog_x GAZEBO_MODEL_PATH=${PWD}/gazebo_model_import/sitl_gazebo/models:$GAZEBO_MODEL_PATH gzclient --verbose
