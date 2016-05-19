#!/bin/sh
export SCRIPT=`cat process.js`
jsawk -i templates.json -n "$SCRIPT"
