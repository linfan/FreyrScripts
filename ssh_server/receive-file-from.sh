#!/bin/bash

function usage()
{
    cat << EOUSAGE
Usage: receive-file-from.sh [-f <FOLDER_TO_STORE>] [-d] <SERVER_NAME> FILE1 [FILE2 ..]
       -f specify local folder to receive files
       -d delete files on server after transfer finish
EOUSAGE
}

# Name-to-ip mapping file
IP_MAP_FILE="${HOME}/Script/ssh_server/map-name-to-ip.sh"

TARGET_PATH="./"
declare -i DELETE_AFTER_CP=0

while getopts ":f:d" opt
do
    case ${opt} in
        f ) TARGET_PATH="${OPTARG}"
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

# Generate file list
FILE_DEL_LIST=""
FILE_LIST="${SERVER_META%%\ *}" # put server port first
for FILE in $@; do
    FILE_DEL_LIST="${FILE} ${FILE_DEL_LIST}"
    FILE_LIST="${FILE_LIST} ${SERVER_META#*\ }:${FILE}"
done

# If TARGET_PATH is not end with a '/', attach one
TARGET_PATH="${TARGET_PATH%/}/"

# Receive file from server
echo ">> Receiving files from server ${SERVER_NAME} .."
scp -P ${FILE_LIST} ${TARGET_PATH}

# Delete tranfered files from server
if [ ${DELETE_AFTER_CP} -eq 1 ]; then
    echo ">> Deleting files after received.. ${FILE_DEL_LIST}"
    ssh -p ${SERVER_META} "rm -f ${FILE_DEL_LIST}"
fi

