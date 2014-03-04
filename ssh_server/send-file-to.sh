#!/bin/bash

function usage()
{
    cat << EOUSAGE
Usage: send-file-to.sh [-u <SERVER_USER>] [-f <FOLDER_TO_STORE>] [-p <SERVER_PORT>] [-n] <SERVER_NAME> FILE1 [FILE2 ..]
       -u specify server user
       -p specify server port
       -f specify server folder to store files
       -d delete files of same name on server before transfer
EOUSAGE
}

IP_MAP_FILE="${HOME}/Script/ssh_server/map-name-to-ip.sh" # Name-to-ip mapping file
SERVER_USER=`whoami`
SERVER_PORT="22"
TARGET_PATH=""
declare -i TARGET_PATH_SET=0
declare -i DELETE_BEFORE_CP=1

while getopts ":f:u:p:n" opt
do
    case ${opt} in
        f ) TARGET_PATH="${OPTARG}"
            TARGET_PATH_SET=1
            ;;
        u ) SERVER_USER="${OPTARG}"
            ;;
        p ) SERVER_PORT="${OPTARG}"
            ;;
        n ) DELETE_BEFORE_CP=0
            ;;
        ? ) usage
            exit 1
            ;;
    esac
done
shift $((${OPTIND} - 1))
if [ ${TARGET_PATH_SET} -eq 0 ]; then
    TARGET_PATH="/home/${SERVER_USER}/"
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
FILE_SEND_LIST=""
for FILE in $@; do
    FILE_DEL_LIST="${TARGET_PATH}${FILE##*/} ${FILE_DEL_LIST}"
    FILE_SEND_LIST="${FILE} ${FILE_SEND_LIST}"
done

if [ ${DELETE_BEFORE_CP} -eq 1 ]; then
    echo "Deleting files before send.. ${FILE_DEL_LIST}"
    ssh -p ${SERVER_PORT} ${SERVER_USER}@${SERVER_IP} "rm -f ${FILE_DEL_LIST}"
fi
echo "Sending files to server ${SERVER_NAME} .."
scp -P ${SERVER_PORT} ${FILE_SEND_LIST} ${SERVER_USER}@${SERVER_IP}:${TARGET_PATH}

