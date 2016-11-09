#!/bin/sh
# Reset password quietly
# E.g.
# reset-passwd.sh core newpassword

USER=${1}
PASS=${2}

sudo passwd ${USER} <<EOF
${PASS}
${PASS}
EOF
