## Public Functions ##

# List all saved accounts
function aws-account-list
{
    ls ${HOME}/.aws/ | grep 'credentials\.' | grep -o '[^\.]*$'
}

# Save current account used specified name
# [Parameters]
# $1 - account name to save as
# [Return]
# Saved result
function aws-account-save
{
    if [ "${1}" = "" ]; then echo "Need specify an account name ..."; return; fi
    target=${HOME}/.aws/credentials.${1}
    if [ -e ${target} ]; then
        echo "Account [${1}] already exist, explicitly delete it before save."
    else
        _cp_f ${HOME}/.aws/credentials ${target}
        echo "Account [${1}] saved (as ${target})."
    fi
}

# Switch to specified account
# [Parameters]
# $1 - target account name
# [Return]
# Switch result
function aws-account-switch
{
    if [ "${1}" = "" ]; then echo "Need specify target account name ..."; return; fi
    target=${HOME}/.aws/credentials.${1}
    if [ -e ${target} ]; then
        _cp_f ${target} ${HOME}/.aws/credentials
    else
        echo "[ERR] Account [${1}] does not exist !"
    fi
}

# Delete specified account
# [Parameters]
# $1 - account name to delete
# [Return]
# Delete result
function aws-account-delete
{
    if [ "${1}" = "" ]; then echo "Need specify an account name ..."; return; fi
    target=${HOME}/.aws/credentials.${1}
    if [ -e ${target} ]; then
        _rm_f ${target}
        echo "Account [${1}] deleted."
    else
        echo "[ERR] Account [${1}] does not exist !"
    fi
}
