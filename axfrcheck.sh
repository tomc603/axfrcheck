#!/usr/local/bin/bash

DEBUG=0

#
# If the user specifies 'debug' on the command line, print successful AXFR as well
#
if [ "$1" == "debug" ]; then
        DEBUG=1
fi

#
# Loop forever performing a TCP AXFR with a 1s timeout. If the AXFR fails, alert the user via STDOUT
# Wait 1s between AXFR attempts, and attempt AXFR only once.
#
while true; do
        stamp=`date +%s`
        dig @208.78.68.247 youredoingwhattomymother.com AXFR +tcp +time=1 +tries=1 > /dev/null
        if [ $? -ne 0 ]; then
                echo "AXFR Failed:  ${stamp}"
        elif [ $DEBUG -eq 1 ]; then
                echo "AXFR Success: ${stamp}"
        fi
        sleep 1
done
