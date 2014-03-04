#!/bin/bash

function usage()
{
    cat << EOUSAGE
Usage: receive-file-from.sh [-u <SERVER_USER>] [-f <FOLDER_TO_STORE>] [-p <PORT_NUM>] [-d] <SERVER_NAME> FILE1 [FILE2 ..]
       -u specify server user
       -p specify server port
       -f specify local folder to receive files
       -d delete files on server after transfer finish
EOUSAGE
}

IP_MAP_FILE="${HOME}/Script/ssh_server/map-name-to-ip.sh" # Name-to-ip mapping file
SERVER_USER=`whoami`
PORT_NUM="22"
TARGET_PATH=""
declare -i TARGET_PATH_SET=0
declare -i DELETE_AFTER_CP=0

while getopts ":f:u:p:d" opt
do
    case ${opt} in
        f ) TARGET_PATH="${OPTARG}"
            TARGET_PATH_SET=1
            ;;
        u ) SERVER_USER="${OPTARG}"
            ;;
        p ) PORT_NUM="${OPTARG}"
            ;;
        d ) DELETE_AFTER_CP=1
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

FILE_DEL_LIST=""
FILE_LIST=""
for FILE in $@; do
    FILE_DEL_LIST="${FILE} ${FILE_DEL_LIST}"
    FILE_LIST="${SERVER_USER}@${SERVER_IP}:${FILE} ${FILE_LIST}"
done
echo "Receiving files from server ${SERVER_NAME} .."
scp -P ${PORT_NUM} ${FILE_LIST} ${TARGET_PATH}
if [ ${DELETE_AFTER_CP} -eq 1 ]; then
    echo "Deleting files after received.. ${FILE_DEL_LIST}"
    ssh -p ${SERVER_PORT} ${SERVER_USER}@${SERVER_IP} "rm -f ${FILE_DEL_LIST}"
fi

