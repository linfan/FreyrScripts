## Note ##

# 1) Inside a profile file, variable ${PROFILE_FOLDER} is available.
#    We can use "source ${PROFILE_FOLDER}/<profile-name>.profile" to import another profile.
# 2) Profile name cannot content space( ), dot(.) or slash(/) symbol,
#    please underscore(_) or dash(-) instead.

## Global Constant ##

PROFILE_FOLDER="${HOME}/.aws/profiles"
DEFAULT_PROFILE_FILE="${PROFILE_FOLDER}/default"

## Init Script ##

if [ ! -d ${PROFILE_FOLDER} ]; then mkdir -p ${PROFILE_FOLDER}; fi
if [ ! -e ${DEFAULT_PROFILE_FILE} ]; then cat <<EOF >${DEFAULT_PROFILE_FILE}
AWS_REGION=
AWS_ACCOUNT=
INS_TYPE=t2.micro
DISK_SIZE_IN_GB=8
PROXY_LOCAL_PORT=22000
SSH_USER=ubuntu
USER_DATA_FILE=
BOOT_DISK=sda1
SEC_GRP_ID=default
IMG_ID=ami-12345678
SSH_KEY_NAME=flin
SSH_KEY_PATH=${HOME}/.ssh/flin.pem
EOF
fi
source ${DEFAULT_PROFILE_FILE}

## Public Functions ##

# Show current profile config
# [Parameters]
# None
function aws-profile-view
{
    cat <<EOF
AWS_REGION=${AWS_REGION}
AWS_ACCOUNT=${AWS_ACCOUNT}
INS_TYPE=${INS_TYPE}
DISK_SIZE_IN_GB=${DISK_SIZE_IN_GB}
PROXY_LOCAL_PORT=${PROXY_LOCAL_PORT}
SSH_USER=${SSH_USER}
USER_DATA_FILE=${USER_DATA_FILE}
BOOT_DISK=${BOOT_DISK}
SEC_GRP_ID=${SEC_GRP_ID}
IMG_ID=${IMG_ID}
SSH_KEY_NAME=${SSH_KEY_NAME}
SSH_KEY_PATH=${SSH_KEY_PATH}
EOF
}

# Save current profile as default config
# [Parameters]
# None
function aws-profile-save
{
    printf "Overwrite default profile config ? (N/Y) " 
    read COMFIRM_OVERWRITE
    if [[ "${COMFIRM_OVERWRITE}" = "y" || "${COMFIRM_OVERWRITE}" = "Y" ]]; then
        aws-profile-view > ${DEFAULT_PROFILE_FILE}
        echo "Profile saved as default config."
    fi
}

# List all available profiles
# [Parameters]
# None
function aws-profile-list
{
    ls ${PROFILE_FOLDER} | grep '\.profile$' | grep -o '^[^.]\+'
}

# Apply an user profile
# [Parameters]
# $1 - name of profile
function aws-profile-apply
{
    profileName=${1}
    profileFile="${PROFILE_FOLDER}/${profileName}.profile"
    if [ -e ${profileFile} ]; then
        source ${profileFile}
        if [ "${AWS_ACCOUNT}" != "" ]; then aws-account-switch ${AWS_ACCOUNT}; fi
        if [ "${AWS_REGION}" != "" ]; then aws-region-switch ${AWS_REGION}; fi
        echo "Profile ${profileName} applied."
    else
        echo "[ERR] Profile ${profileName} not exist !"
    fi
}

# Create a new user profile
# [Parameters]
# $1 - name of profile
function aws-profile-create
{
    profileName=${1}
    profileFile="${PROFILE_FOLDER}/${profileName}.profile"
    if [ -e ${profileFile} ]; then
        echo "[ERR] Profile ${profileName} already exist !"
    else
        cp ${DEFAULT_PROFILE_FILE} ${profileFile}
        _sed_i 's/=.*$/=/g' ${profileFile}
        aws-profile-edit ${profileName}
    fi
}

# Edit an user profile
# [Parameters]
# $1 - name of profile
function aws-profile-edit
{
    profileName=${1}
    profileFile="${PROFILE_FOLDER}/${profileName}.profile"
    if [ -e ${profileFile} ]; then
        EDITOR=${EDITOR:-vi}
        ${EDITOR} ${profileFile}
    else
        echo "[ERR] Profile ${profileName} not exist !"
    fi
}

# Delete an user profile
# [Parameters]
# $1 - name of profile
function aws-profile-delete
{
    profileName=${1}
    profileFile="${PROFILE_FOLDER}/${profileName}.profile"
    if [ -e ${profileFile} ]; then
        rm -f ${profileFile}
        echo "Profile ${profileName} deleted."
    else
        echo "[ERR] Profile ${profileName} not exist !"
    fi
}
