#!/bin/bash

COUNT=$1
DUPLO_TENANT=$2
REGION=$(duploctl tenant region $DUPLO_TENANT | sed -E 's/.*"region": "([^"]+)".*/\1/')

FILE="temp-$COUNT"
if [ -e "$FILE" ]; then
    NODE_LIST="$(cat $FILE)"
    echo $NODE_LIST
    echo "Sleeping 60 seconds, waiting for nodes to come up."
    sleep 60s
    for NODE in "${NODE_LIST[@]}"; do
        NODE_FMT="ip-${NODE//./-}.$REGION.compute.internal"
        echo "kubectl drain here, Node is $NODE_FMT"
        kubectl drain $NODE_FMT --ignore-daemonsets --delete-emptydir-data --timeout=120s
    done
fi

if [ -e "$FILE" ]; then
    rm "$FILE"
    echo "File '$FILE' deleted."
fi
