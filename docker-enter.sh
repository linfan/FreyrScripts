#!/bin/bash
# Enter shell of a spcified docker container
# Usage: ./docker-enter <name-of-container>

CONTAINTER_NAME=${1}

if [ "${CONTAINTER_NAME}" != "" ]; then
    PID=$(sudo docker inspect --format {{.State.Pid}} ${CONTAINTER_NAME})
    if [ "${PID}" != "" ]; then
        sudo nsenter --target ${PID} --mount --uts --ipc --net --pid
    fi
fi
