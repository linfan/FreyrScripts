# Multipass port forwarding

function multipass-port-forward()
{
    MACHINE_NAME=${1}
    LOCAL_PORT=${2}
    MACHINE_PORT=${3}
    MACHINE_KEY="/var/root/Library/Application Support/multipassd/ssh-keys/id_rsa"
    if [ "${MACHINE_PORT}" = "" ]; then
        echo "Usage: multipass-port-forward <machine-name> <local-port> <machine-port>"
    else
        MACHINE_IP=`multipass list | grep "^${MACHINE_NAME} " | awk '{print $3}'`
        if [ "${MACHINE_IP}" = "" ]; then
            echo "Error: machine \"${MACHINE_NAME}\" not exist."
        else
            nc -zvw1 ${MACHINE_IP} ${MACHINE_PORT} >/dev/null 2>&1
            if [ ${?} -ne 0 ]; then
                echo "Error: port ${MACHINE_PORT} of machine \"${MACHINE_NAME}\" is closed."
            else
                sudo ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -CfNgL ${LOCAL_PORT}:localhost:${MACHINE_PORT} -i "${MACHINE_KEY}" ubuntu@${MACHINE_IP}
                if [ ${?} -eq 0 ]; then
                    echo "Port forward: ${MACHINE_NAME}:${MACHINE_PORT} -> localhost:${LOCAL_PORT} done."
                else
                    echo "Port forward failed."
                fi
            fi
        fi
    fi
}

function multipass-port-close()
{
    MACHINE_NAME=${1}
    LOCAL_PORT=${2}
    if [ "${LOCAL_PORT}" = "" ]; then
        echo "Usage: multipass-port-close <machine-name> <local-port>"
    else
        SSH_PID=`ps aux | grep "ssh -CfNgL ${LOCAL_PORT}:localhost:" | grep -v 'grep' | awk '{print $2}'`
        if [ "${SSH_PID}" = "" ]; then
            echo "Port forward ${MACHINE_NAME} -> localhost:${LOCAL_PORT} not found."
        else
            sudo kill ${SSH_PID}
            echo "Port close: ${MACHINE_NAME} -> localhost:${LOCAL_PORT} done."
        fi
    fi
}

function multipass-port-list()
{
    echo "-- Machine list --"
    multipass list | grep ' Running ' | gsed 's/\([^ ]\+\)[^0-9]\+\([0-9.]\+\).*/\1  \2/g'
    echo "-- Port forward --"
    ps aux | grep "ssh -CfNgL " | grep "multipassd/ssh-keys/id_rsa" | gsed 's/^.* \([0-9]\+\):localhost:\([0-9]\+\) .* ubuntu@\([0-9.]\+\)/\3:\2 -> localhost:\1/g'
}
