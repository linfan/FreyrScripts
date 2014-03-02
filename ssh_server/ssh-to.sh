#!/bin/bash

function usage()
{
    echo 'Usage: ssh-to.sh [-u <SERVER_USER>] [-p <SERVER_PORT>] <SERVER_NAME>'
}

IP_MAP_FILE="${HOME}/Script/ssh_server/map-name-to-ip.sh" # Name-to-ip mapping file
SERVER_USER=`whoami`
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

SERVER_IP=`${IP_MAP_FILE} ${SERVER_NAME}`
if [ "${SERVER_IP}" = "" ]; then
    echo "Unknown server or wrong parameters."
    usage
    exit 1
fi

ssh -p ${SERVER_PORT} ${SERVER_USER}@${SERVER_IP}

