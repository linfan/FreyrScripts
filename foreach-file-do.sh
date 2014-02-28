#!/bin/bash
#File - foreach_file_do.sh 
#Author - Freyr Lin
#Email - linfan.china@gmail.com
#Version - v1.0
#Last modified - 2014/02/05
# Func: Enter each file under specified folder or from a name-list file, 
#       then run a specified command/script for each of them
# Note:
# 1) this script can handle spaces in file name correctly
# 2) in the name-list file specified by -l parameter, lines begin with # will be consider as comment and ignored
# 3) the command parameter can be any linux command or script take the file name as parameter
# 4) the command-script can use `pwd` to get in which folder it's executed

# Constant
MODE_ALL=0
MODE_DIRECTORY_ONLY=1
MODE_COMMON_FILE_ONLY=2
MODE_FILE_LIST=3

# Global variables
TMP_FILE="/tmp/foreach_file_do_list"
MODE=${MODE_ALL}

function usage
{
    echo "Usage: for_each_file_do.sh -l list_file command [parameters of command]"
    echo "       for_each_file_do.sh [-c] [-d] folder command [parameters of command]"
    echo " -c : common file only"
    echo " -d : directory only"
}

while getopts ":cdl" opt
do
    case ${opt} in
        c ) MODE=${MODE_COMMON_FILE_ONLY}
        ;;
        d ) MODE=${MODE_DIRECTORY_ONLY}
        ;;
        l ) MODE=${MODE_FILE_LIST}
        ;;
        ? ) usage
        exit 0
        ;;
    esac
done
shift $(($OPTIND - 1))

if [ ${#} -lt 2 ]; then
    echo "[ERROR] Not enough parameter."
    usage
    exit 1
fi

# create a file name list
if [ ${MODE} == ${MODE_FILE_LIST} ]; then
    LIST_FILE="${1}"
    if [ -f "${LIST_FILE}" ]; then
        cat ${LIST_FILE} | grep -v '^[ ]*#' >  ${TMP_FILE}
    else
        echo "[ERROR] File ${LIST_FILE} is invalid."
        exit 1
    fi
else
    BASE_PATH="${1%/}/"    # If BASE_PATH is not end with a '/', attach one
    if [ -d "${BASE_PATH}" ]; then
        if [ ${MODE} == ${MODE_ALL} ]; then
            ls "${BASE_PATH}" > ${TMP_FILE}
        elif [ ${MODE} == ${MODE_DIRECTORY_ONLY} ]; then
            ls "${BASE_PATH}" -l | grep '^d' | sed 's#^.* \(Jan\|Feb\|Mar\|Apr\|May\|Jun\|Jul\|Aug\|Sep\|Oct\|Nov\|Dec\)[ ]\+[0-9]\+[ ]\+[0-9:]\+ \(.*\)$#\2#g' > ${TMP_FILE}
        elif [ ${MODE} == ${MODE_COMMON_FILE_ONLY} ]; then
            ls "${BASE_PATH}" -l | grep '^-' | sed 's#^.* \(Jan\|Feb\|Mar\|Apr\|May\|Jun\|Jul\|Aug\|Sep\|Oct\|Nov\|Dec\)[ ]\+[0-9]\+[ ]\+[0-9:]\+ \(.*\)$#\2#g' > ${TMP_FILE}
        else
            echo "[ERROR] Invalid parameter."
            usage
            exit 1
        fi
        sed -i "s#^#${BASE_PATH}#g" ${TMP_FILE}
    else
        echo "[ERROR] Folder ${BASE_PATH} not exist."
        exit 1
    fi
fi

shift
COMMAND=${*}

declare -i c=`wc ${TMP_FILE} -l | grep -o "^[0-9]*"` # total file number
for i in `seq 1 $c`; do
    file=`head -${i} ${TMP_FILE} | tail -1`  # get a full file name
    ${COMMAND} "${file}"  # execute the command
done
rm -f ${TMP_FILE}  # remove the temporary list file

