#!/bin/bash

NODENAME=$1
DUPLO_TENANT=$2
COUNT=$3

FILE="temp-$COUNT"
# Check if the file exists
if [ -e "$FILE" ]; then
    # Delete the file
    rm "$FILE"
    echo "File '$FILE' deleted."
else
    echo "File '$FILE' does not exist."
fi

NODE_LIST=$(duploctl hosts list -q "[?FriendlyName=='$NODENAME'].PrivateIpAddress" --tenant $DUPLO_TENANT)
NODE_LIST=$(echo $NODE_LIST | tr -d '[]",' | tr ' ' '\n')
echo $NODE_LIST >> $FILE
echo $NODE_LIST
echo "Echoed to $FILE"
