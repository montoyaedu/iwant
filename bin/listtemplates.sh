#!/bin/sh
. iwant-resolve > /dev/null
export SCRIPT=`cat $IWANT_HOME/listtemplates.js`
jsawk -i $IWANT_HOME/templates.json -n "$SCRIPT"
