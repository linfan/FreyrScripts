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
    # no specified port, show all
    # "lsof -i" can provide similar result
    netstat -${NFLAG}pna 2>/dev/null
else
    # use lsof
    lsof -i ${LFLAG}:${1} 
    # use netstat
    netstat -${NFLAG}pna 2>/dev/null | sed -n 2'p'  # header
    netstat -${NFLAG}pna 2>/dev/null | grep :${1}   # record
fi

