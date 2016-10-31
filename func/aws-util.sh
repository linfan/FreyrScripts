#!/bin/bash
# This script need 'aws' cli
# Install and configure it via:
# - pip install aws
# - aws configure

## Global Paremeters ##

IMG_ID=ami-0fcccf61
INS_TYPE=t2.micro
SEC_GRP_ID=<your-security-group-id>
SSH_KEY_NAME=<your-ssh-key-name>
SSH_KEY_PATH=/path/to/your/ssh_key.pem
SSH_USER=ubuntu
DISK_SIZE_IN_GB=8
PROXY_LOCAL_PORT=22001

## Global Constant ##

FAILED=-1
SUCCEED=0
BLOCK_DEVICE_MAPPINGS="[{\"DeviceName\":\"/dev/sda1\",\"Ebs\":{\"VolumeSize\":${DISK_SIZE_IN_GB},\"DeleteOnTermination\":true}}]"
SSH_PARAMETERS=("-o" "UserKnownHostsFile /dev/null" "-o" "StrictHostKeyChecking no" "-i" "${SSH_KEY_PATH}")

## Public Functions ##

# Get IP address of managed instances
# [Parameters]
# $1 - instance name/id (optional)
# [Return]
# List of instance IPs
function aws-get-ins-ip
{
    _aws_ins_desc_wrap 'PublicIpAddress' ${1}
}

# Get ID of managed instances
# [Parameters]
# $1 - instance name/id (optional)
# [Return]
# List of instance IDs
function aws-get-ins-id
{
    _aws_ins_desc_wrap 'InstanceId' ${1}
}

# Get status of managed instances
# [Parameters]
# $1 - instance name/id (optional)
# [Return]
# List of instance status
function aws-get-ins-status
{
    _aws_ins_desc_wrap 'State.Name' ${1}
}

# Get name of managed instances
# [Parameters]
# $1 - instance name/id (optional)
# [Return]
# List of instance names
function aws-get-ins-name
{
    _aws_ins_desc_wrap 'Tags[*].Value' ${1}
}

# Rename specified instance
# [Parameters]
# $1 - name/id of an instance
# $2 - new name of the instance
# [Return]
# ID and new name of instance
function aws-rename-ins
{
    if [ "${2}" = "" ]; then echo "Need specify [instance id] and [instance new name] ..."; return; fi
    insId=$(_aws_get_ins_id ${1})
    insNewName=${2}
    aws ec2 create-tags --resources ${insId} --tags "Key=Name,Value=${insNewName}"
    echo "${insId} -> ${insNewName}"
}

# Create new instance with default configure
# [Parameters]
# $1 - name of instance
# [Return]
# ID of the new instance
function aws-create-ins
{
    if [ "${1}" = "" ]; then echo "Need specify an instance name ..."; return; fi
    insName=${1}
    insId=$(aws ec2 run-instances --image-id ${IMG_ID} --security-group-ids ${SEC_GRP_ID} --count 1 \
        --instance-type ${INS_TYPE} --key-name ${SSH_KEY_NAME} --block-device-mappings ${BLOCK_DEVICE_MAPPINGS} \
        --query 'Instances[0].InstanceId');
    insId=$(_extract_info ${insId})
    aws-rename-ins ${insId} ${insName}
}

# Create many new instances with default configure at once
# [Parameters]
# $1 - number of instance
# $2 - name prefix of instance
# [Return]
# IDs of the new instances
function aws-bulk-create-ins
{
    if [ "${2}" = "" ]; then echo "Need specify [instance count] and [instance name prefix] ..."; return; fi
    insCount=${1}
    insNamePrefix=${2}
    insIds=$(aws ec2 run-instances --image-id ${IMG_ID} --security-group-ids ${SEC_GRP_ID} --count ${insCount} \
        --instance-type ${INS_TYPE} --key-name ${SSH_KEY_NAME} --block-device-mappings ${BLOCK_DEVICE_MAPPINGS} \
        --query 'Instances[].InstanceId');
    insIds=$(_extract_info ${insIds})
    insIds=(`echo $insIds`)
    index=0
    for id in ${insIds}; do
        index=$(_plus_one ${index})
        insName="${insNamePrefix}_${index}"
        aws-rename-ins ${id} ${insName}
    done
}

# Start specified instance
# [Parameters]
# ${1}...${n} - name/id list of instances
# [Return]
# Current status of specified instance
function aws-start-ins
{
    if [ "${1}" = "" ]; then echo "Need specify an instance name/id ..."; return; fi
    for ins in ${@}; do
        _aws_ec2_action ${ins} "start-instances" "StartingInstances"
    done
}

# Stop specified instance
# [Parameters]
# ${1}...${n} - name/id list of instances
# [Return]
# Current status of specified instance
function aws-stop-ins
{
    if [ "${1}" = "" ]; then echo "Need specify an instance name/id ..."; return; fi
    for ins in ${@}; do
        _aws_ec2_action ${ins} "stop-instances" "StoppingInstances"
    done
}

# Terminate specified instance
# [Parameters]
# ${1}...${n} - name/id list of instances
# [Return]
# Current status of specified instance
function aws-terminate-ins
{
    if [ "${1}" = "" ]; then echo "Need specify an instance name/id ..."; return; fi
    for ins in ${@}; do
        _aws_ec2_action ${ins} "terminate-instances" "TerminatingInstances"
    done
}

# Execute a command on all given instances parallelly
# [Parameters]
# ${1}..${n-1} - name/id of instance
# ${n} - command to execute
# [Return]
# Execute outputs
function aws-bulk-exec
{
    if [ "${2}" = "" ]; then echo "Need at least an instance name/id and a comamnd ..."; return; fi
    cmdToExec=$(echo ${@[-1]})
    insNames=${@[@]:1:${#@[@]}-1}
    insNames=(`echo ${insNames}`)
    for ins in ${insNames}; do
        ip=$(aws-get-ins-ip ${ins})
        ssh ${SSH_PARAMETERS} ${SSH_USER}@${ip} sh -c "\"${cmdToExec}\""
    done
}

# SSH into specified instance
# [Parameters]
# $1 - name of instance
# [Return]
# None
function aws-ssh-to
{
    if [ "${1}" = "" ]; then echo "Need specify an instance name ..."; return; fi
    publicIp=$(aws-get-ins-ip ${1})
    ssh ${SSH_PARAMETERS} ${SSH_USER}@${publicIp}
}

# Copy specified file from local to instance
# [Parameters]
# $1 - name of instance
# $2 - local file to be copy
# $3 - remote path
# [Return]
# None
function aws-copy-file-to
{
    if [ "${3}" = "" ]; then echo "Need specify [instance name], [local file] and [remote file] ..."; return; fi
    publicIp=$(aws-get-ins-ip ${1})
    LocalFile=${2}
    RemoteFile=${3}
    scp ${SSH_PARAMETERS} ${LocalFile} ${SSH_USER}@${publicIp}:${RemoteFile}
}

# Copy specified file from instance to local
# [Parameters]
# $1 - name of instance
# $2 - remote file to be copy
# $3 - local path
# [Return]
# None
function aws-copy-file-from
{
    if [ "${3}" = "" ]; then echo "Need specify [instance name], [remote file] and [local file] ..."; return; fi
    publicIp=$(aws-get-ins-ip ${1})
    RemoteFile=${2}
    LocalFile=${3}
    scp ${SSH_PARAMETERS} ${SSH_USER}@${publicIp}:${RemoteFile} ${LocalFile}
}

# Setup socks5 proxy
# [Parameters]
# $1 - name of instance
# $2 - proxy local port (optional)
# [Return]
# None
function aws-socks5-proxy
{
    if [ "${1}" = "" ]; then echo "Need specify an instance name ..."; return; fi
    publicIp=$(aws-get-ins-ip ${1})
    ProxyLocalPort=${2:-${PROXY_LOCAL_PORT}}
    ProxyRemotePort=22
    # Kill existing port forwarding process
    for pid in $(ps aux | grep "CfNgD ${ProxyLocalPort}" | grep -v grep | awk "{print \$2}"); do
        kill -9 ${pid}
    done
    ssh ${SSH_PARAMETERS} -CfNgD ${ProxyLocalPort} -p ${ProxyRemotePort} ${SSH_USER}@${publicIp}
}

## Private Functions ##
# Plus input number by one
function _plus_one
{
    declare -i num="${1}+1"
    printf "%02d" ${num}
}
# Remove any special symbol in string
function _extract_info
{
    matchStr="[.a-zA-Z0-9-]\+"
    echo ${1} | grep -o "${matchStr}"
}
# Judge whether input content is an instance id
function _is_ins_id
{
    if [ "$(echo ${1} | grep '^i-[0-9a-z]\{8,\}$')" ]; then echo "${SUCCEED}"; else echo "${FAILED}"; fi
}
# Get instance id by instance name/id
function _aws_get_ins_id
{
    if [ "$(_is_ins_id ${1})" = "${SUCCEED}" ]; then
        echo ${1}
    else
        echo $(aws-get-ins-id ${1})
    fi
}
# Perform an ec2 action
# [Parameters]
# $1 - instance name/id
# $1 - action name
# $2 - query string
function _aws_ec2_action
{
    insId=$(_aws_get_ins_id ${1})
    res=$(aws ec2 ${2} --instance-ids ${insId} --query "${3}[0].CurrentState.Name")
    echo "${insId} -> $(_extract_info ${res})"
}
# Get instance information according to query parameters
# [Parameters]
# $1 - query string
# $2 - instance name or id
# [Return]
# Queried information
function _aws_ins_desc_wrap
{
    if [ "${2}" = "" ]; then
        indexSign="*"
        extraParams=""
    else
        indexSign="0"
        if [ "$(_is_ins_id ${2})" = "${SUCCEED}" ]; then
            extraParams=("--instance-ids" "${2}")
        else
            extraParams=("--filter" "Name=tag:Name,Values=${2}")
        fi
    fi
    queryStr="Reservations[${indexSign}].Instances[${indexSign}].${1}"
    res=$(aws ec2 describe-instances --query "${queryStr}" ${extraParams})
    echo $(_extract_info ${res}) | sed 's/ / | /g'
}
