#!/bin/sh

str=$*
substr1='--sha256'
substr2='--md5'
if [[ "$str" == *"$substr1"* ]] && [[ "$str" == *"$substr2"* ]]; then
    echo error
else
    echo test
fi