## Global Constant ##

BLOCK_DEVICE_MAPPINGS="[{\"DeviceName\":\"/dev/${BOOT_DISK}\",\"Ebs\":{\"VolumeSize\":${DISK_SIZE_IN_GB},\"DeleteOnTermination\":true}}]"

## Public Functions ##

# Get IP address of managed instances
# [Parameters]
# ${1}...${n} - list of instance name/id (optional)
# [Return]
# List of instance IPs
function aws-ins-get-ip
{
    _aws_ins_desc_wrap 'PublicIpAddress' ${*}
}

# Get ID of managed instances
# [Parameters]
# ${1}...${n} - list of instance name/id (optional)
# [Return]
# List of instance IDs
function aws-ins-get-id
{
    _aws_ins_desc_wrap 'InstanceId' ${*}
}

# Get status of managed instances
# [Parameters]
# ${1}...${n} - list instance name/id (optional)
# [Return]
# List of instance status
function aws-ins-get-status
{
    _aws_ins_desc_wrap 'State.Name' ${*}
}

# Get name of managed instances
# [Parameters]
# ${1}...${n} - list of instance name/id (optional)
# [Return]
# List of instance names
function aws-ins-get-name
{
    _aws_ins_desc_wrap 'Tags[*].Value' ${*}
}

# Rename specified instance
# [Parameters]
# $1 - name/id of an instance
# $2 - new name of the instance
# [Return]
# ID and new name of instance
function aws-ins-rename
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
function aws-ins-create
{
    if [ "${1}" = "" ]; then echo "Need specify an instance name ..."; return; fi
    for i in ${@}; do
        insName=${i}
        insId=$(_aws_create_instance 1);
        insId=$(_extract_info ${insId})
        aws-ins-rename ${insId} ${insName}
    done
}

# Create many new instances with default configure at once
# [Parameters]
# $1 - number of instance
# $2 - name prefix of instance
# [Return]
# IDs of the new instances
function aws-ins-bulk-create
{
    if [ "${2}" = "" ]; then echo "Need specify [instance count] and [instance name prefix] ..."; return; fi
    insCount=${1}
    insNamePrefix=${2}
    insIds=$(_aws_create_instance ${insCount});
    insIds=$(_extract_info ${insIds})
    insIds=(`echo $insIds`)
    index=0
    for id in ${insIds}; do
        index=$(_plus_one ${index})
        insName="${insNamePrefix}_${index}"
        aws-ins-rename ${id} ${insName}
    done
}

# Start specified instance
# [Parameters]
# ${1}...${n} - name/id list of instances
# [Return]
# Current status of specified instance
function aws-ins-start
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
function aws-ins-stop
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
function aws-ins-terminate
{
    if [ "${1}" = "" ]; then echo "Need specify an instance name/id ..."; return; fi
    for ins in ${@}; do
        _aws_ec2_action ${ins} "terminate-instances" "TerminatingInstances"
    done
}
