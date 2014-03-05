#!/bin/bash

function usage()
{
    echo 'Usage: ssh-target.sh add <SERVER_NAME> <SERVER_USER> <SERVER_IP>'
    echo '       ssh-target.sh del <SERVER_NAME>'
    echo '       ssh-target.sh list'
}

IP_MAP_FILE="${HOME}/Script/ssh_server/map-name-to-ip.sh" # Name-to-ip mapping file

# Add a server into server mapping file
function ssh-target-add
{
    if [ ${#} -lt 3 ]; then
        usage
        exit 1
    fi
    SERVER_NAME=${1}
    SERVER_USER=${2}
    SERVER_IP=${3}
    declare -i EXIST=0

    # check if record aleady exist
    RES=`grep "SERVER_${SERVER_NAME}_IP" "${IP_MAP_FILE}"`
    if [ "${RES}" != "" ]; then
        EXIST=1
        sed -i "/SERVER_${SERVER_NAME}_IP/d" "${IP_MAP_FILE}"
    fi

    # add record
    sed -i '/BEGIN_OF_IP_LIST/a'"SERVER_${SERVER_NAME}_IP=\"${SERVER_USER}@${SERVER_IP}\"" "${IP_MAP_FILE}"

    # check result
    RES=`grep "SERVER_${SERVER_NAME}_IP" "${IP_MAP_FILE}" | grep "${SERVER_IP}"`
    if [ "${RES}" == "" ]; then
        echo "Server add failed!"
    elif [ ${EXIST} -eq 1 ]; then
        echo "Server ${SERVER_NAME} modified => [${SERVER_USER}] ${SERVER_IP} succeeful."
    else
        echo "Server ${SERVER_NAME} => [${SERVER_USER}] ${SERVER_IP} added successful."
    fi
}

# Remove a server from server mapping file
function ssh-target-remove
{
    if [ ${#} -lt 1 ]; then
        usage
        exit 1
    fi
    SERVER_NAME=${1}

    # check if record exist
    RES=`grep "SERVER_${SERVER_NAME}_IP" "${IP_MAP_FILE}"`
    if [ "${RES}" == "" ]; then
        echo "Server ${SERVER_NAME} not exist."
    else
        # remove record
        sed -i "/SERVER_${SERVER_NAME}_IP/d" "${IP_MAP_FILE}"
        # check result
        RES=`grep "SERVER_${SERVER_NAME}_IP" "${IP_MAP_FILE}"`
        if [ "${RES}" == "" ]; then
            echo "Server ${SERVER_NAME} removed successful."
        else
            echo "Server remove failed!"
        fi
    fi
}

# List all server record
function ssh-target-list
{
    grep -P "SERVER_[^_]+_IP=" "${IP_MAP_FILE}" | sed -r -e 's/SERVER_([^_]+)_IP=([^@]+)@(.+)/\1 \t=> [\2] \3/g' -e 's/"//g'
}

if [ ${#} -lt 1 ]; then
    usage
    exit 1
fi
case ${1} in
    add) ssh-target-add ${2} ${3} ${4}
        ;;
    remove|delete|del) ssh-target-remove ${2}
        ;;
    list) ssh-target-list
        ;;
    *) usage
        ;;
esac

