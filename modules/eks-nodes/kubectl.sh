#!/bin/bash

COUNT=$1
DUPLO_TENANT=$2
TIMEOUT=$3
REGION=$(duploctl tenant region $DUPLO_TENANT | sed -E 's/.*"region": "([^"]+)".*/\1/')

if [ "$REGION" = "us-east-1" ]; then
    node_dns="ec2.internal"
else
   node_dns="$REGION.compute.internal"
fi

FILE_PATH="./.terraform"
ID="$(cat $FILE_PATH/$COUNT-ID)"
FILE="temp-$COUNT-$ID"
FULL_PATH="$FILE_PATH/$FILE"

if [ -e "$FULL_PATH" ]; then
    NODE_LIST="$(cat $FULL_PATH)"
    SANITY_LIST=$(duploctl hosts list --tenant $DUPLO_TENANT -q [].PrivateIpAddress)
    NODE_ARRAY=($(echo $NODE_LIST | tr -d '[],"'))
    SANITY_ARRAY=($(echo $SANITY_LIST | tr -d '[],"'))
    if [[ -z $NODE_ARRAY ]]; then
        echo "File is empty"
    else
        echo "Sleeping 60 seconds, waiting for nodes to come up."
        sleep 60
        for node_ip in "${NODE_ARRAY[@]}"; do
            for sanity_ip in "${SANITY_ARRAY[@]}"; do
                if [[ "$node_ip" == "$sanity_ip" ]]; then
                    NODE_FMT="ip-${node_ip//./-}.$node_dns"
                    echo "kubectl draining node: $NODE_FMT"
                    kubectl drain $NODE_FMT --ignore-daemonsets --delete-emptydir-data --timeout="${TIMEOUT}s"
                fi
            done
        done
    fi
fi

if [ -e "$FULL_PATH" ]; then
    rm "$FULL_PATH"
    echo "File '$FULL_PATH' deleted."
fi

if [ -e "$FILE_PATH/$COUNT-ID" ]; then
    rm "$FILE_PATH/$COUNT-ID"
    echo "File '$FILE_PATH/$COUNT-ID' deleted."
fi