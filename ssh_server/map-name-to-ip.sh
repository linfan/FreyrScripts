#!/bin/bash

# BEGIN_OF_IP_LIST
SERVER_lf_IP="${LF_IP}"
SERVER_xxm_IP="${XXM_IP}"
# END_OF_IP_LIST

echo $(eval echo \${SERVER_${1}_IP})
