function _to_utf8 {
    FROM_ENCODE=${1}
    shift
    for f in $@; do
        iconv -f ${FROM_ENCODE} -t UTF-8 $f >/tmp/o && mv -f /tmp/o $f
        if [ $? -ne 0 ]; then
            echo '[Error] Convert encode failed'
            return
        fi
    done
}
function gb2312-to-utf8 {
    _to_utf8 GB2312 $@
}
function gbk-to-utf8 {
    _to_utf8 CP936 $@
}
