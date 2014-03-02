#!/bin/bash

function usage()
{
    echo 'Usage: receive-file-from.sh [-u <SERVER_USER>] [-f <FOLDER_TO_STORE>] [-p <PORT_NUM>] <SERVER_NAME> FILE1 [FILE2 ..]'
}

IP_MAP_FILE="${HOME}/Script/ssh_server/map-name-to-ip.sh" # Name-to-ip mapping file
SERVER_USER=`whoami`
PORT_NUM="22"
TARGET_PATH=""
declare -i TARGET_PATH_SET=0

while getopts ":f:u:p:" opt
do
    case ${opt} in
        f ) TARGET_PATH="${OPTARG}"
            TARGET_PATH_SET=1
            ;;
        u ) SERVER_USER="${OPTARG}"
            ;;
        p ) PORT_NUM="${OPTARG}"
            ;;
        ? ) usage
            exit 1
            ;;
    esac
done
shift $((${OPTIND} - 1))
if [ ${TARGET_PATH_SET} -eq 0 ]; then
    TARGET_PATH="./"
fi
TARGET_PATH="${TARGET_PATH%/}/"    # If TARGET_PATH is not end with a '/', attach one

SERVER_NAME=${1}
shift 1

SERVER_IP=`${IP_MAP_FILE} ${SERVER_NAME}`
if [ "${SERVER_IP}" = "" ]; then
    echo "Unknown server or wrong parameters."
    usage
    exit 1
fi

if [ ${#} -eq 0 ]; then
    echo "Please specify file to transfer."
    exit -1
fi

FILE_LIST=""
for FILE in $@; do
    FILE_LIST="${SERVER_USER}@${SERVER_IP}:${FILE} ${FILE_LIST}"
done
echo "Receiving files from server ${SERVER_NAME} .."
scp -P ${PORT_NUM} ${FILE_LIST} ${TARGET_PATH}

