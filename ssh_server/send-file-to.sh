#!/bin/bash

function usage()
{
    cat << EOUSAGE
Usage: send-file-to.sh [-f <FOLDER_TO_STORE>] [-n] <SERVER_NAME> FILE1 [FILE2 ..]
       -f specify server folder to store files
       -n don't try remove files of same name on server before transfer
EOUSAGE
}

# Name-to-ip mapping file
IP_MAP_FILE="${HOME}/Script/ssh_server/map-name-to-ip.sh"

TARGET_PATH=""
declare -i DELETE_BEFORE_CP=1

while getopts ":f:u:p:n" opt
do
    case ${opt} in
        f ) TARGET_PATH="${OPTARG}"
            ;;
        n ) DELETE_BEFORE_CP=0
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
SERVER_META=`${IP_MAP_FILE} ${SERVER_NAME}`
if [ "${SERVER_META}" = "" ]; then
    echo "Unknown server or wrong parameters."
    usage
    exit 1
fi

# Check parameters
if [ ${#} -eq 0 ]; then
    echo "Please specify file to transfer."
    exit -1
fi

# If TARGET_PATH not specified, set it to user's home folder
if [ "${TARGET_PATH}" == "" ]; then
    SERVER_USER="${SERVER_META#*\ }"
    SERVER_USER="${SERVER_USER%@*}"
    TARGET_PATH="/home/${SERVER_USER}/"
fi

# If TARGET_PATH is not end with a '/', attach one
TARGET_PATH="${TARGET_PATH%/}/"

# Generate file list
FILE_DEL_LIST=""
FILE_SEND_LIST=""
for FILE in $@; do
    FILE_DEL_LIST="${TARGET_PATH}${FILE##*/} ${FILE_DEL_LIST}"
    FILE_SEND_LIST="${FILE} ${FILE_SEND_LIST}"
done

# Delete exist file from server before transfer
if [ ${DELETE_BEFORE_CP} -eq 1 ]; then
    echo ">> Deleting files before send.. ${FILE_DEL_LIST}"
    ssh -p ${SERVER_META} "rm -f ${FILE_DEL_LIST}"
fi

# Send file to server
SERVER_PORT="${SERVER_META%%\ *}"
echo ">> Sending files to server ${SERVER_NAME} .."
scp -P ${SERVER_PORT} ${FILE_SEND_LIST} ${SERVER_META#*\ }:${TARGET_PATH}

