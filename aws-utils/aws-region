## Public Functions ##

# List all available regions
function aws-region-list
{
    cat <<EOF
----------------------------------------------
| AWS Region Name          | Region Code     |
----------------------------------------------
| US East (N. Virginia)    | us-east-1       |
| US East (Ohio)           | us-east-2       |
| US West (N. California)  | us-west-1       |
| US West (Oregon)         | us-west-2       |
| EU (Ireland)             | eu-west-1       |
| EU (Frankfurt)           | eu-central-1    |
| Asia Pacific (Tokyo)     | ap-northeast-1  |
| Asia Pacific (Seoul)     | ap-northeast-2  |
| Asia Pacific (Singapore) | ap-southeast-1  |
| Asia Pacific (Sydney)    | ap-southeast-2  |
| Asia Pacific (Mumbai)    | ap-south-1      |
| South America (São Paulo)| sa-east-1       |
----------------------------------------------
EOF
}

# Switch between regions
# [Parameters]
# $1 - target region code
# [Return]
# None
function aws-region-switch
{
    if [ "${1}" = "" ]; then echo "Need specify target region ..."; return; fi
    _sed_i "s/^region =.*$/region = ${1}/" ${HOME}/.aws/config
}
