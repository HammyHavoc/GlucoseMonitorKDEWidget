#!/bin/bash
NIGHTSCOUT_INSTANCE=$1
ACCESS_TOKEN=$2

curl -s "${NIGHTSCOUT_INSTANCE}/api/v1/entries.json?count=1&token=${ACCESS_TOKEN}"
