#!/bin/bash
#File - dict.sh
#Author - Freyr Lin
#Email - linfan.china@gmail.com
#Version - v1.0
#Last modified - 2013/03/01
# Look up a word (either English or Chinese) at dict.cn

USAGE='USAGE: dict.sh "word-to-look-up"'
TMP_FILE='/tmp/dict_lookup'

if [ ${#} -eq 0 ]; then
    echo "${USAGE}"
    exit 1
fi

# Show this word
figlet ${*}

# Fetch dict.cn webpage
word=`echo $* | sed 's/ /%20/g'`
declare -i retyrTimes=0
curl --connect-timeout 1 http://dict.cn/${word} 2>/dev/null > ${TMP_FILE}
while [[ ${?} -ne 0 && ${retyrTimes} -lt 5 ]]; do   # timeout
    retyrTimes=$((retyrTimes+1))
    curl --connect-timeout 1 http://dict.cn/${word} 2>/dev/null > ${TMP_FILE}
done
if [ ${retyrTimes} -ge 5 ]; then
    echo "[ERROR] Connect to dict.cn failed."
    rm -f ${TMP_FILE}
    exit 1
fi

# Parse webpage content
grep '\(基本释义\|您要查找的是不是\)' -A1000 ${TMP_FILE} | grep '<div class="section ask">' -B1000 | sed 's#<div class="ifufind">\(.*\)</div>#<h3>\1</h3>#g' | grep -v '<div class=' | sed -e 's/<h3>/ ====[ /g' -e 's/<\/h3>/ ]====/g' -e 's/<[^>]*>//g' -e 's/^[ \t]*//' | grep -v 'googletag.cmd.push' | dos2unix | grep -v '^[ \t]*$'
rm -f ${TMP_FILE}

