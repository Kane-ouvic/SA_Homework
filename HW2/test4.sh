#!/bin/sh
  
str=`cat sample_file2.json | jq -r ".[] | .groups" | xargs echo`
 
echo ${str}
OIFS="$IFS"
IFS=' '
read -a new_string <<< "${str}"
IFS="$OIFS"
 
for i in "${new_string[@]}"
do     
   echo "$i"
done


echo -n -e "====================================\n"

addrs=`cat file2 | head -1 | xargs echo`

IFS=',' read -r -a ip_array <<< "$addrs"

for ip in "${ip_array[@]}"
do
    echo "$ip"
done