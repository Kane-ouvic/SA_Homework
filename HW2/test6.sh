#!/bin/sh

check_state=2

if [ $check_state -eq 1 ]
then
    echo true
else
    echo false
fi

str1=`id sdsasadas | xargs echo`
str2=`id ouvic | xargs echo`

# echo $str1
# echo $str1
echo $str2
echo $str2

    substr='no'
    if [[ "$str1" = "" ]]; then
        echo yes
    fi

pw groupadd testgroup1
pw groupadd testgroup2
pw groupadd testgroup3
pw usermod admin_cat -G testgroup1