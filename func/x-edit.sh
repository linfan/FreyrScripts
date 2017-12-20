X_FILE="${HOME}/._x"
X_PASS="pass"

function x-read {
    read PASS
    if [ "${PASS}" = "${X_PASS}" ]; then
        cat ${X_FILE} | base64 --decode
    fi
}

function x-edit {
    read PASS
    if [ "${PASS}" = "${X_PASS}" ]; then
        cat ${X_FILE} | base64 --decode > /tmp/.x
        vim /tmp/.x
        sudo bash -c "cat /tmp/.x | base64 > ${X_FILE}"
        rm -f /tmp/.x
    fi
}

function x-add {
    read PASS
    if [ "${PASS}" = "${X_PASS}" ]; then
        vim /tmp/.x
        sudo touch ${X_FILE}
        cat ${X_FILE} | base64 --decode > /tmp/.y
        cat /tmp/.x >> /tmp/.y
        sudo bash -c "cat /tmp/.y | base64 > ${X_FILE}"
        rm -f /tmp/.[xy]
    fi
}
