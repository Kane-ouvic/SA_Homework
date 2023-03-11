#!/bin/sh


error_msg_1(){
    echo -n -e "Error: Invalid arguments. \n"
}

error_msg_2(){
    echo -n -e "Error: Invalid values. \n"
}

error_msg_3(){
    echo -n -e "Error: Only one type of hash function is allowed. \n"
}

error_msg_4(){
    echo -n -e "Error: Invalid checksum. \n"
}

usage() {
echo -n -e "\nUsage: sahw2.sh {--sha256 hashes ... | --md5 hashes ...}
-i files ...\n\n--sha256: SHA256 hashes to validate input files.\n--md5:
MD5 hashes to validate input files.\n-i: Input files.\n"
}


error_msg_1
error_msg_2
usage

echo -n -e "=================================\n"

if [ "$1" = "-h" ]
then
    usage
elif [ "$1" = "-md5" ]
then
    echo -n -e "-md5\n"
else
    error_msg_1
fi


echo -n -e "=================================\n"

echo $*

# for i in "$*" ; do
#     echo "In loop: $i"
# done

var=1

arr=()
for i in "$@" ; do
    arr+=("$i")
done


for ((i=0; i < ${#arr[@]}; i++))
do
    ### 印出 array 的 key 及 value
    echo $i ${arr[$i]}
done


# echo -n "Do you want to 'rm -rf /' (yes/no)? "
# read answer # read from stdin and assign to variable
# case $answer in 
#     [Yy][Ee][Ss])
#     echo "Hahaha"
#     ;;
#     [Nn][Oo])
#     echo "No~~~"
#     ;;
#     *)
#     echo "removing..."
#     ;;
# esac




# for i in `seq 1 3` ; do
# echo "Hello world $1" # the body of the script
# done
