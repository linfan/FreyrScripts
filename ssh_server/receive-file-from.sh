#!/bin/bash

function usage()
{
    cat << EOUSAGE
Usage: receive-file-from.sh [-u <SERVER_USER>] [-f <FOLDER_TO_STORE>] [-p <SERVER_PORT>] [-d] <SERVER_NAME> FILE1 [FILE2 ..]
       -u specify server user
       -p specify server port
       -f specify local folder to receive files
       -d delete files on server after transfer finish
EOUSAGE
}

IP_MAP_FILE="${HOME}/Script/ssh_server/map-name-to-ip.sh" # Name-to-ip mapping file
SERVER_USER=""
SERVER_PORT="22"
TARGET_PATH="./"
declare -i DELETE_AFTER_CP=0

while getopts ":f:u:p:d" opt
do
    case ${opt} in
        f ) TARGET_PATH="${OPTARG}"
            ;;
        u ) SERVER_USER="${OPTARG}"
            ;;
        p ) SERVER_PORT="${OPTARG}"
            ;;
        d ) DELETE_AFTER_CP=1
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

# Check parameters
if [ ${#} -eq 0 ]; then
    echo "Please specify file to transfer."
    exit -1
fi

# Replace the user name
if [ "${SERVER_USER}" != "" ]; then
    SERVER_USER_IP="${SERVER_USER}@${SERVER_USER_IP#*@}"
fi

# Generate file list
FILE_DEL_LIST=""
FILE_LIST=""
for FILE in $@; do
    FILE_DEL_LIST="${FILE} ${FILE_DEL_LIST}"
    FILE_LIST="${SERVER_USER_IP}:${FILE} ${FILE_LIST}"
done

# If TARGET_PATH is not end with a '/', attach one
TARGET_PATH="${TARGET_PATH%/}/"

# Receive file from server
echo ">> Receiving files from server ${SERVER_NAME} .."
scp -P ${SERVER_PORT} ${FILE_LIST} ${TARGET_PATH}

# Delete tranfered files from server
if [ ${DELETE_AFTER_CP} -eq 1 ]; then
    echo ">> Deleting files after received.. ${FILE_DEL_LIST}"
    ssh -p ${SERVER_PORT} ${SERVER_USER_IP} "rm -f ${FILE_DEL_LIST}"
fi

