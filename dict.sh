#!/bin/bash
#File - dict.sh
#Author - Freyr Lin
#Email - linfan.china@gmail.com
#Version - v1.0
#Last modified - 2013/03/01
# Look up a word (either English or Chinese) at dict.cn

USAGE='USAGE: dict.sh "word-to-look-up"'
DEBUG_MODE='Y' # 'Y'
LAZY_DOWNLOAD='N' # 'Y'
PLAY_VOICE='N'
TIMEOUT=3
RETRY_TIMES=3
WEB_FILE='/tmp/dict_lookup.html'
RESOLVED_FILE='/tmp/dict_resolved.txt'
MP3_FILE='/tmp/dict_audio.mp3'
MP3_PLAYER='mpg321'
if [ `uname` == "Darwin" ]; then
    SED='gsed'
else
    SED='sed'
fi

function debug_log()
{
    if [ "${DEBUG_MODE}" == "Y" ]; then
        echo "[DEBUG] ${*}"
    fi
}

function cleanUp()
{
    if [ "${LAZY_DOWNLOAD}" != "Y" ]; then
        rm -f ${WEB_FILE} ${RESOLVED_FILE} ${MP3_FILE}
    fi
}

function playMp3()
{
    debug_log "Play mp3 for ${1} .."
    url="http://audio.dict.cn/${1}"
    download ${url} ${MP3_FILE}
    ${MP3_PLAYER} ${MP3_FILE} > /dev/null 2>&1 &
}

function download()
{
    url=${1}
    file=${2}
    declare -i retyrTimes=0

    if [[ "${LAZY_DOWNLOAD}" == "Y" && -r "${file}" ]]; then
        return 0
    fi

    debug_log "Begin http .."
    curl --connect-timeout ${TIMEOUT} ${url} 2>/dev/null > ${file}
    while [[ ${?} -ne 0 && ${retyrTimes} -lt 5 ]]; do   # timeout
        debug_log "Retry http, $((${retyrTimes}+1)) time.."
        retyrTimes=$((retyrTimes+1))
        curl --connect-timeout 1 ${url} 2>/dev/null > ${file}
    done
    debug_log "Got it .."
    if [ ${retyrTimes} -ge ${RETRY_TIMES} ]; then
        return -1
    fi
    return 0
}

if [ "${1}" == "-v" ]; then
    PLAY_VOICE='Y'
    shift
fi

if [ ${#} -eq 0 ]; then
    echo "${USAGE}"
    exit 1
fi

# Show this word
figlet ${*} > ${RESOLVED_FILE}

# Fetch dict.cn webpage
word=`echo $* | ${SED} 's/ /%20/g'`
download "http://dict.cn/${word}" "${WEB_FILE}"
if [ ${?} -ne 0 ]; then
    echo "[ERROR] Connect to dict.cn failed."
    cleanUp
    exit 1
fi

# Parse webpage content
grep '英 <bdo lang="EN-US">\[[^]]*\]</bdo>' ${WEB_FILE} | ${SED} -e 's#<[^>]*>##g' | grep -o '..\[[^]]*\]' >> ${RESOLVED_FILE}
grep '美 <bdo lang="EN-US">\[[^]]*\]</bdo>' ${WEB_FILE} | ${SED} -e 's#<[^>]*>##g' | grep -o '..\[[^]]*\]' >> ${RESOLVED_FILE}
grep '\(基本释义\|您要查找的是不是\)' -A1000 ${WEB_FILE} | grep '<div class="section ask">' -B1000 | ${SED} 's#<div class="ifufind">\(.*\)</div>#<h3>\1</h3>#g' | grep -v '<div class=' | ${SED} -e 's/<h3>/ ========[ /g' -e 's/<\/h3>/ ]========/g' -e 's/<[^>]*>//g' -e 's/^[ \t]*//' | grep -v 'googletag.cmd.push' | dos2unix | grep -v '^[ \t]*$' >> ${RESOLVED_FILE}
less ${RESOLVED_FILE}

# Play audio
if [ "${PLAY_VOICE}" == "Y" ]; then
    mp3_url=`grep -o 'naudio="[^"]*' ${WEB_FILE} | ${SED} 's#naudio="##g' | head -1`
    if [ "${mp3_url}" != "" ]; then
        playMp3 ${mp3_url}
    fi
fi

cleanUp
