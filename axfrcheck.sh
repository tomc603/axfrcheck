#!/usr/bin/env bash

# Default options
VERBOSE=0
INTERVAL=1
SERVER=""
TIMEOUT=1
TRIES=1
ZONE=""

#
# Print CLI usage information
#
usage() {
    echo "$(basename ${0}) - Perform a periodic AXFR query"
    echo ""
    echo "Usage: $(basename ${0}) [-i INTERVAL] [-r RETRIES] -s SERVER [-t TIMEOUT] [-v] -z ZONE"
    echo "  -i INTERVAL  Seconds between AXFR queries."
    echo "               Default: 1"
    echo "  -r RETRIES   Number of times to attempt AXFR query."
    echo "               Default: 1"
    echo "  -s SERVER    DNS server to send AXFR query to."
    echo "  -t TIMEOUT   AXFR query timeout in seconds."
    echo "               Default: 1"
    echo "  -v           Output verbose runtime information."
    echo "  -z ZONE      DNS zone to perform AXFR query against."
}

#
# Parse CLI options and arguments
#
while getopts ":r:s:t:vi:z:" opt; do
    case $opt in
        i)
            INTERVAL=$OPTARG
            ;;
        r)
            TRIES=$OPTARG
            ;;
        s)
            SERVER=$OPTARG
            ;;
        t)
            TIMEOUT=$OPTARG
            ;;
        v)
            VERBOSE=1
            ;;
        z)
            ZONE=$OPTARG
            ;;
        \?)
            echo "WARNING: Invalid option: -$OPTARG" >&2
            ;;
        :)
            echo "ERROR: Option -$OPTARG requires an argument." >&2
            usage
            exit 1
            ;;
    esac
done

#
# Sanity check our parameters
#
if [ "$SERVER" == "" ]; then
    echo "ERROR: You must specify a server" >&2
    usage
    exit 1
fi
if [ "$ZONE" == "" ]; then
    echo "ERROR: You must specify a zone" >&2
    usage
    exit 1
fi

#
# Loop forever performing a TCP AXFR with a timeout of $TIMEOUT. If the AXFR fails, alert the user via STDOUT
# Wait $INTERVAL seconds between AXFR attempts, and attempt AXFR $TRIES times.
#
while true; do
    stamp=$(date +%s)
    output=$(dig @${SERVER} ${ZONE} AXFR +noall +short +tcp +time=${TIMEOUT} +tries=${TRIES})
    if [ $? -ne 0 ] || [[ "$output" =~ "failed" ]]; then
        echo "AXFR Failed:  ${stamp}"
        if [ $VERBOSE -ne 0 ]; then
            echo "$output" >&2
        fi
    elif [ $VERBOSE -ne 0 ]; then
        echo "AXFR Success: ${stamp}"
    fi
    sleep $INTERVAL
done
