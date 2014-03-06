#!/bin/bash

function usage()
{
    cat << EOUSAGE
Usage: ssh-to.sh <SERVER_NAME>
EOUSAGE
}

# Name-to-ip mapping file
IP_MAP_FILE="${HOME}/Script/ssh_server/map-name-to-ip.sh"

while getopts ":" opt
do
    case ${opt} in
        ? ) usage
            exit 1
            ;;
    esac
done
shift $((${OPTIND} - 1))

SERVER_NAME=${1}
shift 1

# Get server user name and IP
SERVER_META=`${IP_MAP_FILE} ${SERVER_NAME}`
if [ "${SERVER_META}" = "" ]; then
    echo "Unknown server or wrong parameters."
    usage
    exit 1
fi

# Login to server
ssh -p ${SERVER_META}

