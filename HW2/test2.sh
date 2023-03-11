#!/bin/sh

if [ "$1" = "-h" ]
then
    usage
elif [ "$1" = "-md5" ]
then
    echo -n -e "-md5\n"
fi