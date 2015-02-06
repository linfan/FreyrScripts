#!/bin/bash
# Substitution of "docker run", try to fire up a exist same-name container if it exist,
# otherwise it create a new container as common "docker run"
# Known bug: if the command include quotation mark, the script will works weirdly.

PARA="${*}"
NAME=$(echo "${PARA}" | grep '\-\-name' | sed 's/.*--name \([^ ]*\).*/\1/g')
if [ "${NAME}" == "" ]; then
    echo "[ERROR] Must specify a name to the container!";
    exit -1;
fi
EXIST=$(sudo docker ps -a | grep "${NAME}[ ]*$")
if [ "${EXIST}" == "" ]; then
    sudo docker run ${PARA}
else
    sudo docker start ${NAME}
fi
