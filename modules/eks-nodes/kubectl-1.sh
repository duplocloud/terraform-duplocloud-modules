#!/bin/bash

NODENAME=$1
DUPLO_TENANT=$2
COUNT=$3
ID=$4

FILE="temp-$COUNT-$ID"
FILE_PATH="./.terraform"
FULL_PATH="$FILE_PATH/$FILE"
# Check if the file exists
if [ -e "$FULL_PATH" ]; then
    # Delete the file
    rm "$FULL_PATH"
    echo "File '$FILE' deleted."
else
    echo "File '$FILE' does not exist."
fi

NODE_LIST=$(duploctl hosts list -q "[?FriendlyName=='$NODENAME'].PrivateIpAddress" --tenant $DUPLO_TENANT)
NODE_LIST=$(echo $NODE_LIST | tr -d '[]",' | tr ' ' '\n')
echo $NODE_LIST > $FULL_PATH
echo $NODE_LIST
echo $ID > "$FILE_PATH/$COUNT-ID"
echo "Echoed to $FULL_PATH"
