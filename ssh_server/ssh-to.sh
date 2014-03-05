#!/bin/bash

function usage()
{
    echo 'Usage: ssh-to.sh [-u <SERVER_USER>] [-p <SERVER_PORT>] <SERVER_NAME>'
}

IP_MAP_FILE="${HOME}/Script/ssh_server/map-name-to-ip.sh" # Name-to-ip mapping file
SERVER_USER=""
SERVER_PORT="22"

while getopts ":u:p:" opt
do
    case ${opt} in
        u ) SERVER_USER="${OPTARG}"
            ;;
        p ) SERVER_PORT="${OPTARG}"
            ;;
        ? ) usage
            exit 1
            ;;
    esac
done
shift $((${OPTIND} - 1))

SERVER_NAME=${1}
shift 1

# Get server user name and IP
SERVER_USER_IP=`${IP_MAP_FILE} ${SERVER_NAME}`
if [ "${SERVER_USER_IP}" = "" ]; then
    echo "Unknown server or wrong parameters."
    usage
    exit 1
fi

# Replace the user name
if [ "${SERVER_USER}" != "" ]; then
    SERVER_USER_IP="${SERVER_USER}@${SERVER_USER_IP#*@}"
fi

# Login to server
ssh -p ${SERVER_PORT} ${SERVER_USER_IP}

