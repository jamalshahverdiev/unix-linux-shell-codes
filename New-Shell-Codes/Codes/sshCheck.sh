#!/bin/bash

# returns:
# 0: success
# 1: error(s)

set -x



OUTPUT=`ps -ef | grep -c sshd`
if [ ${OUTPUT} -gt 1 ]
then
	exit 0
else
	exit 1
fi
