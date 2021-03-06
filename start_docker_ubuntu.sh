#!/bin/bash

# Originally based on files by Alex Werner for UW Robohub
# Used with verbal permission

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"


# Variables required for logging as a user with the same id as the user running this script
export LOCAL_USER_NAME=$USER
export LOCAL_USER_ID=`id -u $USER`
export LOCAL_GROUP_ID=`id -g $USER`
export LOCAL_GROUP_NAME=`id -gn $USER`
DOCKER_USER_ARGS=""#"--env LOCAL_USER_NAME --env LOCAL_USER_ID --env LOCAL_GROUP_ID --env LOCAL_GROUP_NAME --privileged"


# Settings required for having nvidia GPU acceleration inside the docker
DOCKER_GPU_ARGS="--env DISPLAY=unix${DISPLAY} --env QT_X11_NO_MITSHM=1 --volume=/tmp/.X11-unix:/tmp/.X11-unix:rw"

which nvidia-container-runtime-hook > /dev/null 2> /dev/null
HAS_NVIDIA_DOCKER=$?
if [ $HAS_NVIDIA_DOCKER -eq 0 ]; then
  echo "Detected nvidia-container-runtime. Using gpu."
  DOCKER_GPU_ARGS="$DOCKER_GPU_ARGS --env NVIDIA_VISIBLE_DEVICES=all --env NVIDIA_DRIVER_CAPABILITIES=all --gpus all"
else
  echo "Install docker >=19.03 and nvidia-container-runtime to use gpu"
fi


xhost + 

#ADDITIONAL_FLAGS="--detach"
ADDITIONAL_FLAGS="--rm --interactive --tty"
ADDITIONAL_FLAGS="$ADDITIONAL_FLAGS --device /dev/dri:/dev/dri --volume=/run/udev:/run/udev"


IMAGE_NAME=aquadrone_latest
CONTAINER_NAME=${IMAGE_NAME}_${USER}

echo Using container: $IMAGE_NAME

if ! docker container ps | grep -q ${CONTAINER_NAME}; then
	echo "Starting new container with name: ${CONTAINER_NAME}"
	echo "Removing any remaining container (will say 'error' if none exist)..."
	docker rm ${CONTAINER_NAME}
	echo "GPU ARGS: ${DOCKER_GPU_ARGS}"
	docker run \
	${DOCKER_GPU_ARGS} \
	$DOCKER_SSH_AUTH_ARGS \
	-v "$DIR:/home/aquadrone" \
	$ADDITIONAL_FLAGS --user root \
	--name ${CONTAINER_NAME} --workdir /home/aquadrone \
	--cap-add=SYS_PTRACE \
	--cap-add=SYS_NICE \
	--net=host \
	--device /dev/bus/usb \
	$IMAGE_NAME
else
	echo "Starting shell in running container"
	docker exec -it --workdir /home/aquadrone --env USER=aquadrone --user aquadrone ${CONTAINER_NAME} bash -l -c "stty cols $(tput cols); stty rows $(tput lines); bash"
fi

