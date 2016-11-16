## Global Constant ##

FAILED=-1
SUCCEED=0

## Private Functions ##

# The 'sed -i' function fit both Linux and MacOS
function _sed_i
{
    if [ "$(uname)" = "Darwin" ]; then
        sed -i '' ${@}
    else
        sed -i ${@}
    fi
}

# Delete file without confirmation
function _rm_f
{
    /bin/rm -f ${@}
}

# Copy file without confirmation
function _cp_f
{
    /bin/cp -f ${@}
}

# Plus input number by one
function _plus_one
{
    declare -i num="${1}+1"
    printf "%02d" ${num}
}

# Remove any special symbol in string
function _extract_info
{
    matchStr="[.a-zA-Z0-9_\-]\+"
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
        echo $(aws-ins-get-id ${1})
    fi
}

# Create ec2 instance
# [Parameters]
# $1 - number of instance to create
function _aws_create_instance
{
    extraParams=""
    if [ "${USER_DATA_FILE}" != "" ]; then
        extraParams="--user-data file://${USER_DATA_FILE} ${extraParams}"
    fi
    insCount=${1}
    aws ec2 run-instances --image-id ${IMG_ID} --security-group-ids ${SEC_GRP_ID} --count ${insCount} \
        --instance-type ${INS_TYPE} --key-name ${SSH_KEY_NAME} --block-device-mappings ${BLOCK_DEVICE_MAPPINGS} \
        --query 'Instances[0].InstanceId' ${extraParams}
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

# Get instances information according to query parameter
# [Parameters]
# $1 - query parameter
# ${2}...${n} - list of instance name or id
# [Return]
# Queried information
function _aws_ins_desc_wrap
{
    queryPara=${1}
    shift
    if [ "${1}" = "" ]; then _aws_ins_desc ${queryPara} "*"; fi
    for i in ${*}; do
        if [ "$(_is_ins_id ${i})" = "${SUCCEED}" ]; then
            extraParams=("--instance-ids" "${i}")
        else
            extraParams=("--filter" "Name=tag:Name,Values=${i}")
        fi
        _aws_ins_desc ${queryPara} "0" ${extraParams}
    done
}

# Get one instance information according to query parameter
# [Parameters]
# $1 - query parameter
# $2 - query item index
# ${3}...${n} - extra query parameter
# [Return]
# Queried information
function _aws_ins_desc
{
    queryPara=${1}
    indexSign=${2}
    shift 2
    queryStr="Reservations[${indexSign}].Instances[${indexSign}].${queryPara}"
    res=$(aws ec2 describe-instances --query "${queryStr}" ${@})
    echo $(_extract_info ${res}) | sed 's/ / | /g'
}