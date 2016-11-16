## Global Constant ##

SSH_PARAMETERS=("-o" "UserKnownHostsFile /dev/null" "-o" "StrictHostKeyChecking no" "-i" "${SSH_KEY_PATH}")

## Public Functions ##

# SSH into specified instance
# [Parameters]
# $1 - name of instance
# [Return]
# None
function aws-ssh-to
{
    if [ "${1}" = "" ]; then echo "Need specify an instance name ..."; return; fi
    publicIp=$(aws-ins-get-ip ${1})
    ssh ${SSH_PARAMETERS} ${SSH_USER}@${publicIp}
}

# Copy specified file from local to instance
# [Parameters]
# $1 - name of instance
# $2 - local file to be copy
# $3 - remote path
# [Return]
# None
function aws-ssh-copy-to
{
    if [ "${3}" = "" ]; then echo "Need specify [instance name], [local file] and [remote file] ..."; return; fi
    publicIp=$(aws-ins-get-ip ${1})
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
function aws-ssh-copy-from
{
    if [ "${3}" = "" ]; then echo "Need specify [instance name], [remote file] and [local file] ..."; return; fi
    publicIp=$(aws-ins-get-ip ${1})
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
function aws-ssh-proxy
{
    if [ "${1}" = "" ]; then echo "Need specify an instance name ..."; return; fi
    publicIp=$(aws-ins-get-ip ${1})
    ProxyLocalPort=${2:-${PROXY_LOCAL_PORT}}
    ProxyRemotePort=22
    # Kill existing port forwarding process
    for pid in $(ps aux | grep "CfNgD ${ProxyLocalPort}" | grep -v grep | awk "{print \$2}"); do
        kill -9 ${pid}
    done
    ssh ${SSH_PARAMETERS} -CfNgD ${ProxyLocalPort} -p ${ProxyRemotePort} ${SSH_USER}@${publicIp}
}

# Execute a command on all given instances parallelly
# [Parameters]
# ${1}..${n-1} - name/id of instance
# ${n} - command to execute
# [Return]
# Execute outputs
function aws-ssh-bulk-exec
{
    if [ "${2}" = "" ]; then echo "Need at least an instance name/id and a comamnd ..."; return; fi
    cmdToExec=$(echo ${@[-1]})
    insNames=${@[@]:1:${#@[@]}-1}
    insNames=(`echo ${insNames}`)
    for ins in ${insNames}; do
        ip=$(aws-ins-get-ip ${ins})
        ssh ${SSH_PARAMETERS} ${SSH_USER}@${ip} sh -c "\"${cmdToExec}\""
    done
}
