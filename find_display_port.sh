#!/bin/bash
# Find the correct value of DISPLAY that can be used
# Usage: ./find_display_port.sh

declare -i port=0
while [ ${port} -lt 40 ]; do
    export DISPLAY="localhost:${port}.0"
    xclock > /dev/null 2>&1
    if [ ${?} -eq 0 ]; then
        echo "Please use: export DISPLAY=localhost:${port}.0"
        break
    else
        port=port+1
    fi
done
