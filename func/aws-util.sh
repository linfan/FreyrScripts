#!/bin/bash
# This script need 'aws' cli
# Install and configure it via:
# - pip install aws
# - aws configure

## Global Paremeters ##

FAILED=-1
SUCCEED=0
IMG_ID=ami-0fcccf61
INS_TYPE=t2.micro
SEC_GRP_ID=your-security-group-id
SSH_KEY_NAME=your-ssh-key-name
SSH_KEY_PATH=/path/to/your/ssh_key.pem
SSH_USER=ubuntu
DISK_SIZE_IN_GB=50
PROXY_LOCAL_PORT=22001

## Public Functions ##

# Get IP address of managed instances
# [Parameters]
# If no paremeters specified, all instances available will returned
# If one paremeter specified, it means only show instance of specified name
# If two paremeter specified, they are reservation-index and instance-index
# [Return]
# List of instance IPs
function aws-get-ins-ip
{
    PublicIp="$(_aws_ins_desc_wrap PublicIpAddress ${1} ${2})"
    echo ${PublicIp} | sed 's/ / | /g'
}

# Get ID of managed instances
# [Parameters]
# If no paremeters specified, all instances available will returned
# If one paremeter specified, it means only show instance of specified name
# If two paremeter specified, they are reservation-index and instance-index
# [Return]
# List of instance IDs
function aws-get-ins-id
{
    InstanceId="$(_aws_ins_desc_wrap InstanceId ${1} ${2})"
    echo ${InstanceId} | sed 's/ / | /g'
}

# Get status of managed instances
# [Parameters]
# If no paremeters specified, all instances available will returned
# If one paremeter specified, it means only show instance of specified name
# If two paremeter specified, they are reservation-index and instance-index
# [Return]
# List of instance status
function aws-get-ins-status
{
    InstanceStatus="$(_aws_ins_desc_wrap State.Name ${1} ${2})"
    echo ${InstanceStatus} | sed 's/ / | /g'
}

# Get name of managed instances
# [Parameters]
# If no paremeters specified, all instances available will returned
# If one paremeter specified, it means only show instance of specified name
# If two paremeter specified, they are reservation-index and instance-index
# [Return]
# List of instance names
function aws-get-ins-name
{
    InstanceStatus="$(_aws_ins_desc_wrap 'Tags[*].Value' ${1} ${2})"
    echo ${InstanceStatus} | sed 's/ / | /g'
}

# Create new instance with default configure
# [Parameters]
# $1 - name of instance
# [Return]
# ID of the new instance
function aws-create-ins
{
    insName=${1}
    BLOCK_DEVICE_MAPPINGS="[{\"DeviceName\":\"/dev/sda1\",\"Ebs\":{\"VolumeSize\":${DISK_SIZE_IN_GB},\"DeleteOnTermination\":true}}]"
    InstanceId=$(aws ec2 run-instances --image-id ${IMG_ID} --security-group-ids ${SEC_GRP_ID} --count 1 \
        --instance-type ${INS_TYPE} --key-name ${SSH_KEY_NAME} --block-device-mappings ${BLOCK_DEVICE_MAPPINGS} \
        --query 'Instances[0].InstanceId');
    InstanceId=$(_extract_info ${InstanceId})
    if [ "${insName}" != "" ]; then
        aws ec2 create-tags --resources ${InstanceId} --tags "Key=Name,Value=${insName}"
    fi
    echo ${InstanceId}
}

# Start specified instance
# [Parameters]
# $1 - name of instance
# [Return]
# Current and previous status of specified instance
function aws-start-ins
{
    if [ "${1}" = "" ]; then echo "Need specify a instance name ..."; return; fi
    InstanceId=$(aws-get-ins-id ${1} 0)
    aws ec2 start-instances --instance-ids ${InstanceId}
}

# Stop specified instance
# [Parameters]
# $1 - name of instance
# [Return]
# Current and previous status of specified instance
function aws-stop-ins
{
    if [ "${1}" = "" ]; then echo "Need specify a instance name ..."; return; fi
    InstanceId=$(aws-get-ins-id ${1} 0)
    aws ec2 stop-instances --instance-ids ${InstanceId}
}

# Terminate specified instance
# [Parameters]
# $1 - name of instance
# [Return]
# Current and previous status of specified instance
function aws-terminate-ins
{
    if [ "${1}" = "" ]; then echo "Need specify a instance name ..."; return; fi
    InstanceId=$(aws-get-ins-id ${1} 0)
    aws ec2 terminate-instances --instance-ids ${InstanceId}
}

# SSH into specified instance
# [Parameters]
# $1 - name of instance
# [Return]
# None
function aws-ssh-to
{
    if [ "${1}" = "" ]; then echo "Need specify a instance name ..."; return; fi
    PublicIp=$(aws-get-ins-ip ${1} 0)
    ssh -o 'UserKnownHostsFile /dev/null' -o 'StrictHostKeyChecking no' -i ${SSH_KEY_PATH} ${SSH_USER}@${PublicIp}
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
    PublicIp=$(aws-get-ins-ip ${1} 0)
    LocalFile=${2}
    RemoteFile=${3}
    scp -o 'UserKnownHostsFile /dev/null' -o 'StrictHostKeyChecking no' -i ${SSH_KEY_PATH} \
        ${LocalFile} ${SSH_USER}@${PublicIp}:${RemoteFile}
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
    PublicIp=$(aws-get-ins-ip ${1} 0)
    RemoteFile=${2}
    LocalFile=${3}
    scp -o 'UserKnownHostsFile /dev/null' -o 'StrictHostKeyChecking no' -i ${SSH_KEY_PATH} \
        ${SSH_USER}@${PublicIp}:${RemoteFile} ${LocalFile}
}

# Setup socks5 proxy
# [Parameters]
# $1 - name of instance
# $2 - proxy local port (optional)
# [Return]
# None
function aws-socks5-proxy
{
    if [ "${1}" = "" ]; then echo "Need specify a instance name ..."; return; fi
    PublicIp=$(aws-get-ins-ip ${1} 0)
    ProxyLocalPort=${2:-${PROXY_LOCAL_PORT}}
    ProxyRemotePort=22
    # Kill existing port forwarding process
    for pid in $(ps aux | grep "CfNgD ${ProxyLocalPort}" | grep -v grep | awk "{print \$2}"); do
        kill -9 ${pid}
    done
    ssh -o 'UserKnownHostsFile /dev/null' -o 'StrictHostKeyChecking no' -i ${SSH_KEY_PATH} \
        -CfNgD ${ProxyLocalPort} -p ${ProxyRemotePort} ${SSH_USER}@${PublicIp}
}

## Private Functions ##
function _minus_one
{
    declare -i num=0
    if [ "${1}" != "" ]; then num="${1}-1"; echo ${num}; else echo "*"; fi
}
function _extract_info
{
    matchStr="[.a-zA-Z0-9-]\+"
    echo ${1} | grep -o "${matchStr}"
}
function _is_num
{
    if [ "$(echo ${1} | grep '^[0-9]*$')" ]; then return ${SUCCEED}; else return ${FAILED}; fi
}
function _aws_get_ins_desc_via_index
{
    queryStr="${1}"
    res=$(aws ec2 describe-instances --query "${queryStr}")
    echo $(_extract_info ${res})
}
function _aws_get_ins_desc_via_tag_name
{
    queryStr="${1}"
    insName=${2}
    res=$(aws ec2 describe-instances --query "${queryStr}" --filter Name=tag:Name,Values=${insName})
    echo $(_extract_info ${res})
}
function _aws_ins_desc_wrap
{
    insQuery="${1}"
    _is_num ${2}
    if [ "$?" = "${SUCCEED}" ] || [ "${2}" = "" ]; then
        resNum=$(_minus_one ${2})
        insNum=$(_minus_one ${3})
        queryStr="Reservations[${resNum}].Instances[${insNum}].${insQuery}"
        echo $(_aws_get_ins_desc_via_index ${queryStr})
    else
        insName=${2}
        queryStr="Reservations[0].Instances[0].${insQuery}"
        echo $(_aws_get_ins_desc_via_tag_name ${queryStr} ${insName})
    fi
}
