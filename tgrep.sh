#!/bin/bash
# File : tgrep.sh
# Bug report to : fan.lin.ext@nsn.com
# Last modify : 2013-06-17
# parse tags file and demonstrate the found content with highlighted and formated output
shopt -s expand_aliases

function usage
{
    cat << EOUSAGE
 Usage: tgrep.sh [-p] [-r] [-c] [-x <STRING>] [-s] [-f] [-k <KIND>] -b <BASEPATH> -t <TAGFILE> -l <TREEFILE> <TAG>
 -b Set base folder of tags file and tree file
 -t Set tags file path
 -l Set tree file path
 -p Partly match search
 -r Raw out put
 -c Considering C++ namespace, for class search using formated output only
 -x Exclude items contain the specified string
 -s Use short-name for item kind descriptor
 -f Search for file, equal to "-k file"
 -k Specific search item kind
EOUSAGE

    if [ "${1}" != "more" ]; then
        cat << EOUSAGE
 -h View more help information
EOUSAGE
    else
        cat << EOUSAGE
 Available KIND:
     class, enum, enumerator, file, function, macro, member,
     namespace, prototype, struct, typedef, union, variable
 Short-names of KIND:
     c  class name
     d  macro definitions (from #define XXX)
     e  enumerator (values inside an enumeration)
     f  function or method name
     F  file name
     g  enumeration name
     l  local variables
     m  member (of structure, union or class data)
     n  namespaces
     p  function prototype
     s  structure name
     t  typedef
     u  union name
     v  variable
     x  external variable declarations
EOUSAGE
    fi

    exit 1
}

function skip
{
    sleep 0
}

function d_echo
{
    if [ ${DEBUG_MODE} = 1 ]; then
        echo "[DEBUG] ${*}"
    fi
}

WHOLE_WORD_MATCH=1
RAW_OUTPUT=0
DEBUG_MODE=0
CONSIDER_NAMESPACE=0
USE_SHORT_KIND_NAME=0
KIND_OPT=""
SEARCH_ITEM=""
EXCLUDE_STRING=""
BASE_PATH="${TGREP_BASE_PATH}"  # define outside of tgrep.sh
TAGS_FILE="${TGREP_TAGS_FILE}"  # define outside of tgrep.sh
TREE_FILE="${TGREP_TREE_FILE}"  # define outside of tgrep.sh

while getopts ":hpcdrfsx:k:b:l:t:" opt
do
    case ${opt} in
        b ) BASE_PATH="${OPTARG}"
            ;;
        t ) TAGS_FILE="${OPTARG}"
            ;;
        l ) TREE_FILE="${OPTARG}"
            ;;
        d ) DEBUG_MODE=1
            ;;
        r ) RAW_OUTPUT=1
            ;;
        f ) KIND_OPT="file"
            ;;
        k ) KIND_OPT="${OPTARG}"
            ;;
        x ) EXCLUDE_STRING="${OPTARG}"
            ;;
        c ) CONSIDER_NAMESPACE=1
            ;;
        s ) USE_SHORT_KIND_NAME=1
            ;;
        p ) WHOLE_WORD_MATCH=0
            ;;
        h ) usage "more"
            ;;
        ? ) usage
            ;;
    esac
done
shift $((${OPTIND} - 1))

d_echo "BASE_PATH : ${BASE_PATH}"
d_echo "TAGS_FILE : ${TAGS_FILE}"
d_echo "TREE_FILE : ${TREE_FILE}"

if [ -d "${BASE_PATH}" ]; then
    skip
else
    echo "[ERROR] base path not exist."
    usage
fi 

if [ "$KIND_OPT" == "file" ]; then
    if [ -f "${TREE_FILE}" ]; then
        skip
    else
        echo "[ERROR] tree file not exist."
        usage
    fi 
else
    if [ -f "${TAGS_FILE}" ]; then
        skip
    else
        echo "[ERROR] tags file not exist."
        usage
    fi 
fi

# If BASE_PATH is not end with a '/', attach one
BASE_PATH="${BASE_PATH%/}/"

if [ -n "${1}" ]; then
    if [ "$KIND_OPT" == "file" ]; then
        TARGET_FILE=${TREE_FILE}
        if [ ${WHOLE_WORD_MATCH} -eq 1 ]; then
            if [ ${RAW_OUTPUT} -eq 1 ]; then
                d_echo "SEARCH_ITEM : Search for file, raw output, match whole word only."
                SEARCH_ITEM="[/]\{0,1\}${1}[/]\{0,1\}"
            else
                d_echo "SEARCH_ITEM : Search for file, formated output, match whole word only."
                SEARCH_ITEM="/${1}$"
            fi
        else
            d_echo "SEARCH_ITEM : Search for file, formated output, match any occasion."
            SEARCH_ITEM="${1}"
        fi
    else
        TARGET_FILE=${TAGS_FILE}
        if [ ${WHOLE_WORD_MATCH} -eq 1 ]; then
            if [ ${RAW_OUTPUT} -eq 1 ]; then
                d_echo "SEARCH_ITEM : Search for tag, raw output, match whole word only."
                SEARCH_ITEM="[:]*${1}[:]*"
            else
                if [ ${CONSIDER_NAMESPACE} -eq 1 ]; then
                    d_echo "SEARCH_ITEM : Search for tag, formated output, consider namespace, match whole word only."
                    SEARCH_ITEM="^[a-zA-Z0-9_:]*${1}[^a-zA-Z0-9_:]"
                else
                    d_echo "SEARCH_ITEM : Search for tag, formated output, match whole word only."
                    SEARCH_ITEM="^${1}[^a-zA-Z0-9_:]"
                fi
            fi
        else
            if [ ${RAW_OUTPUT} -eq 1 ]; then
                d_echo "SEARCH_ITEM : Search for tag, raw output, match any occasion."
                SEARCH_ITEM="${1}"
            else
                if [ ${CONSIDER_NAMESPACE} -eq 1 ]; then
                    d_echo "SEARCH_ITEM : Search for tag, formated output, consider namespace, match any occasion."
                    SEARCH_ITEM="^[a-zA-Z0-9_:]*${1}[a-zA-Z0-9_]*"
                else
                    d_echo "SEARCH_ITEM : Search for tag, formated output, match any occasion."
                    SEARCH_ITEM="^[a-zA-Z0-9_]*${1}[a-zA-Z0-9_]*"
                fi
            fi
        fi
    fi
else
    usage
fi

ITEM_RAW="${1}"
ITEM_TEST="-v -i ${EXCLUDE_STRING}"
if [ ${USE_SHORT_KIND_NAME} -eq 0 ]; then
    ITEM_KIND="-e '[^0-9a-zA-Z\._-:/\\&\*\ \(\)]kind:${KIND_OPT}$' \
        -e '[^0-9a-zA-Z\._-:/\\&\*\ \(\)]kind:${KIND_OPT}[^0-9a-zA-Z\._-:/\\&\*\ \(\)]'"
else
    ITEM_KIND="-e '[^0-9a-zA-Z\._-:/\\&\*\ \(\)]${KIND_OPT}[^0-9a-zA-Z\._-:/\\&\*\ \(\)]' \
        -e '[^0-9a-zA-Z\._-:/\\&\*\ \(\)]${KIND_OPT}$'"
fi
CMD_GREP="grep"
CMD_GREP_C="grep --color=always"
CMD_CUT_END="awk -F '[$;]' '{print \$1}'"
CMD_FORMAT="sed -e 's#/\^[\ \t]*##g' -e 's#[\t\ ]\{1,\}# #g' \
    -e 's#\([^\ ]*\)\ \([^\ ]*\)\ \(.*\)#\1\ \ |\ \ ${BASE_PATH}\2\ \ |\ \ \3#g' \
    -e 's#${BASE_PATH}./#${BASE_PATH}#g' \
    -e '/^.*[0-9a-zA-Z_]${ITEM_RAW}\ /d'"
CMD_FORMAT_TREE="sed 's#^[.]\{0,1\}[/]\{0,1\}#${BASE_PATH}#g'"
CMD1="cat"
CMD2="cat"
CMD3="cat"
CMD4="cat"
CMD5="cat"

COMMAND_LEVEL=0
if [ ${RAW_OUTPUT} -eq 0 ]; then
    if [ "${EXCLUDE_STRING}" == "" ]; then
        if [ "${KIND_OPT}" == "" ]; then
            d_echo "COMMAND_LINE : Search for all tag, formated output, with test file."
            COMMAND_LEVEL=4
            CMD1=${CMD_GREP}
            ITEM1=${SEARCH_ITEM}
            CMD2=${CMD_CUT_END}
            CMD3=${CMD_FORMAT}
            CMD4=${CMD_GREP_C}
            ITEM4=${SEARCH_ITEM}
        elif [ "$KIND_OPT" == "file" ]; then
            d_echo "COMMAND_LINE : Search for file, formated output, with test file."
            COMMAND_LEVEL=3
            CMD1=${CMD_GREP}
            ITEM1=${SEARCH_ITEM}
            CMD2=${CMD_FORMAT_TREE}
            CMD3=${CMD_GREP_C}
            ITEM3=${ITEM_RAW}
        else
            d_echo "COMMAND_LINE : Search for specific tag, formated output, with test file."
            COMMAND_LEVEL=5
            CMD1=${CMD_GREP}
            ITEM1=${SEARCH_ITEM}
            CMD2=${CMD_GREP}
            ITEM2=${ITEM_KIND}
            CMD3=${CMD_CUT_END}
            CMD4=${CMD_FORMAT}
            CMD5=${CMD_GREP_C}
            ITEM5=${SEARCH_ITEM}
        fi
    else
        if [ "${KIND_OPT}" == "" ]; then
            d_echo "COMMAND_LINE : Search for all tag, formated output, without test file."
            COMMAND_LEVEL=5
            CMD1=${CMD_GREP}
            ITEM1=${SEARCH_ITEM}
            CMD2=${CMD_GREP}
            ITEM2=${ITEM_TEST}
            CMD3=${CMD_CUT_END}
            CMD4=${CMD_FORMAT}
            CMD5=${CMD_GREP_C}
            ITEM5=${SEARCH_ITEM}
        elif [ "$KIND_OPT" == "file" ]; then
            d_echo "COMMAND_LINE : Search for file, formated output, without testout file."
            COMMAND_LEVEL=4
            CMD1=${CMD_GREP}
            ITEM1=${SEARCH_ITEM}
            CMD2=${CMD_GREP}
            ITEM2=${ITEM_TEST}
            CMD3=${CMD_FORMAT_TREE}
            CMD4=${CMD_GREP_C}
            ITEM4=${ITEM_RAW}
        else
            d_echo "COMMAND_LINE : Search for specific tag, formated output, without test file."
            COMMAND_LEVEL=5
            CMD1=${CMD_GREP}
            ITEM1=${ITEM_KIND}
            CMD2=${CMD_GREP}
            ITEM2=${ITEM_TEST}
            CMD3=${CMD_CUT_END}
            CMD4=${CMD_FORMAT}
            CMD5=${CMD_GREP_C}
            ITEM5=${SEARCH_ITEM}
        fi
    fi
else
    if [ "${EXCLUDE_STRING}" == "" ]; then
        if [[ "${KIND_OPT}" == "" || "$KIND_OPT" == "file" ]]; then
            d_echo "COMMAND_LINE : Search for all tag or file, raw output, with test file."
            COMMAND_LEVEL=2
            CMD1=${CMD_GREP}
            ITEM1=${SEARCH_ITEM}
            CMD2=${CMD_GREP_C}
            ITEM2=${ITEM_RAW}
        else
            d_echo "COMMAND_LINE : Search for specific tag, raw output, with test file."
            COMMAND_LEVEL=3
            CMD1=${CMD_GREP}
            ITEM1=${SEARCH_ITEM}
            CMD2=${CMD_GREP}
            ITEM2=${ITEM_KIND}
            CMD3=${CMD_GREP_C}
            ITEM3=${ITEM_RAW}
        fi
    else
        if [[ "${KIND_OPT}" == "" || "$KIND_OPT" == "file" ]]; then
            d_echo "COMMAND_LINE : Search for all tag or file, raw output, without test file."
            COMMAND_LEVEL=3
            CMD1=${CMD_GREP}
            ITEM1=${SEARCH_ITEM}
            CMD2=${CMD_GREP}
            ITEM2=${ITEM_TEST}
            CMD3=${CMD_GREP_C}
            ITEM3=${ITEM_RAW}
        else
            d_echo "COMMAND_LINE : Search for specific tag, raw output, without test file."
            COMMAND_LEVEL=4
            CMD1=${CMD_GREP}
            ITEM1=${SEARCH_ITEM}
            CMD2=${CMD_GREP}
            ITEM2=${ITEM_KIND}
            CMD3=${CMD_GREP}
            ITEM3=${ITEM_TEST}
            CMD4=${CMD_GREP_C}
            ITEM4=${ITEM_RAW}
        fi
    fi
fi

alias RUN_COMMAND_1="${CMD1} ${ITEM1} ${TARGET_FILE}"
alias RUN_COMMAND_2="${CMD2} ${ITEM2}"
alias RUN_COMMAND_3="${CMD3} ${ITEM3}"
alias RUN_COMMAND_4="${CMD4} ${ITEM4}"
alias RUN_COMMAND_5="${CMD5} ${ITEM5}"

d_echo "COMMANDS : ${COMMAND_LEVEL}"
d_echo "${CMD1} ${ITEM1} ${TARGET_FILE}"
d_echo "${CMD2} ${ITEM2}"
d_echo "${CMD3} ${ITEM3}"
d_echo "${CMD4} ${ITEM4}"
d_echo "${CMD5} ${ITEM5}"

#RUN_COMMAND_1

case ${COMMAND_LEVEL} in
    0 ) echo ">> COMMAND ERROR !"
        ;;
    1 ) RUN_COMMAND_1
        ;;
    2 ) RUN_COMMAND_1 | RUN_COMMAND_2
        ;;
    3 ) RUN_COMMAND_1 | RUN_COMMAND_2 | RUN_COMMAND_3
        ;;
    4 ) RUN_COMMAND_1 | RUN_COMMAND_2 | RUN_COMMAND_3 | RUN_COMMAND_4
        ;;
    5 ) RUN_COMMAND_1 | RUN_COMMAND_2 | RUN_COMMAND_3 | RUN_COMMAND_4 | RUN_COMMAND_5
        ;;
esac
if [ ${RAW_OUTPUT} -eq 1 ]; then
    echo ">> Base path is ${BASE_PATH}"
fi

unalias RUN_COMMAND_1
unalias RUN_COMMAND_2
unalias RUN_COMMAND_3
unalias RUN_COMMAND_4
unalias RUN_COMMAND_5
