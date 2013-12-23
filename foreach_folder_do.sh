#!/bin/bash
# Enter each specified folder and run specified script
# Note:
# <file of folder list>: lines begin with # will be consider as comment and ignored
# <script to execute>: the script can use `pwd` to get in which folder it's executed

# show usage
function usage
{
    cat << EOUSAGE
Usage: foreach_folder_do.sh -in <file of folder list> -do <script to execute> [parameters of script to execute]
EOUSAGE
    exit
}

# check if parameter format correct
if [[ "${1}" != "-in" || "${3}" != "-do" ]]; then
    echo "[ ERROR ] invalid parameter !"
    usage
fi

# parse parameter pair
FOLDER_LIST=${2}
SCRIPT_TO_EXE=${4}
shift 4
PARA_OF_SCRIPT=${*}

# check if mandatory parameter missing
if [[ "${FOLDER_LIST}" = "" || "${SCRIPT_TO_EXE}" = "" ]]; then
    echo "[ ERROR ] need parameter !"
    usage
fi

if [[ -r "${FOLDER_LIST}" && -x "${SCRIPT_TO_EXE}" ]]; then
    echo "Total `cat ${FOLDER_LIST} | grep -v '^[ ]*#' | wc -l` folders:"
else
    echo "[ ERROR ] ${FOLDER_LIST} not readable or ${SCRIPT_TO_EXE} not executable !"
    exit
fi

# for each folder in FOLDER_LIST do SCRIPT_TO_EXE
CUR_FOLDER=`pwd`
for folder in `cat ${FOLDER_LIST} | grep -v '^[ ]*#'`; do
    cd ${folder}; ${SCRIPT_TO_EXE} ${PARA_OF_SCRIPT}
done
cd ${CUR_FOLDER}
