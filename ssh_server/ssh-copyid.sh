#!/bin/bash

function usage()
{
    cat << EOUSAGE
Usage: ssh-copy-id-to.sh [-i <IDENTITY_FILE>] <SERVER_NAME>
    -i specify ssh identity file
EOUSAGE
}

# Name-to-ip mapping file
IP_MAP_FILE="${HOME}/Script/ssh_server/map-name-to-ip.sh"

IDENTITY_FILE=`ls ${HOME}/.ssh/id_[rd]sa.pub | head -1`

while getopts ":i:" opt
do
    case ${opt} in
        i ) IDENTITY_FILE=${OPTARG}
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
    echo "[ERROR] Unknown server or wrong parameters."
    usage
    exit 1
fi

if [ "${IDENTITY_FILE}" == "" ]; then
    echo "[ERROR] Cannot find identity file."
    usage
    exit 1
fi
PUB_CREDENCE=`cat ${IDENTITY_FILE}`
if [ "${PUB_CREDENCE}" == "" ]; then
    echo "[ERROR] No identities found in ${IDENTITY_FILE}"
    exit 1
fi

# Copy identity key to server
echo ${PUB_CREDENCE} | ssh -p ${SERVER_META} "umask 077; test -d .ssh || mkdir .ssh ; cat >> .ssh/authorized_keys"


