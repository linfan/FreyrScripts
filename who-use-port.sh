#!/bin/bash
#File - who-use-port.sh
#Author - Freyr Lin
#Email - linfan.china@gmail.com
#Version - v1.0
#Last modified - 2013/12/20
# Show which process using the specified port

function usage()
{
    cat << EOUSAGE
Usage: who-use-port [-t|-u|-a] [port]
EOUSAGE
}
                                                                                                                                                                                              
NFLAG="tu"
LFLAG=""
case ${1} in
    -t )
    NFLAG="t"
    LFLAG="tcp"
    shift
    ;;
    -u )
    NFLAG="u"
    LFLAG="udp"
    shift
    ;;
    -a )
    NFLAG=""
    shift
    ;;
    -h )
    usage
    exit 0
    ;;
esac
if [ "${1}" == "" ]; then
    netstat -${NFLAG}pna 2>/dev/null
else
    netstat -${NFLAG}pna 2>/dev/null | sed -n 2'p'
    netstat -${NFLAG}pna 2>/dev/null | grep :${1}
    lsof -i ${LFLAG}:${1}
fi
