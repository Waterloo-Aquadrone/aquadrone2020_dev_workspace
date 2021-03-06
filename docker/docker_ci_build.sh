#!/bin/bash
#set -v

# From UW Robohub

env

set -e
shopt -s nullglob

LOCAL_USER_NAME=aquadrone
LOCAL_USER_ID=1000
LOCAL_GROUP_NAME=aquadrone
LOCAL_GROUP_ID=1000
echo "Using USER and GROUP aquadrone, ID 1000"


# show ip address on stdout
echo "Container IPs: $(hostname --all-ip-addresses)"

source /.bashrc || true

echo "Running CI Build"
mkdir -p /catkin_ws/src
rm -rf /catkin_ws/build || true
rm -rf /catkin_ws/devel || true
cd /catkin_ws

catkin build
