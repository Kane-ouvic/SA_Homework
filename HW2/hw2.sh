#!/bin/sh


usage() {
echo -n -e "\nUsage: sahw2.sh {--sha256 hashes ... | --md5 hashes ...}
-i files ...\n\n--sha256: SHA256 hashes to validate input files.\n--md5:
MD5 hashes to validate input files.\n-i: Input files.\n"
}

error_msg_1(){
    echo -n -e "Error: Invalid arguments. \n"
    usage
    exit 0
}

error_msg_2(){
    echo -n -e "Error: Invalid values. \n"
    exit 0
}

error_msg_3(){
    echo -n -e "Error: Only one type of hash function is allowed. \n"
    exit 0
}

error_msg_4(){
    echo -n -e "Error: Invalid checksum. \n"
    exit 0
}




# error_msg_1
# error_msg_2
# usage

sha256_args=()
md5_args=()
hash_args=()
file_args=()
input_args=()


for i in "$@" ; do
    input_args+=("$i")
done

for ((i=1; i < ${#input_args[@]}; i++))
do
    ### 印出 array 的 key 及 value
    echo $i ${input_args[1]}
done

echo -n -e "=================================\n"

# check the first args
if [ "$1" = "-h" ]
then
    usage

elif [ "$1" = "--md5" ]
then
    echo -n -e "-md5\n"

    # check exist sha256
    str=$*
    substr='--sha256'
    target=0
    if [[ "$str" == *"$substr"* ]]; then
        error_msg_3
    
    else
        echo "String does'nt contains the substring"

        for ((i=0; ${input_args[i+1]} != "-i"; i++))
        do
            ### 印出 array 的 key 及 value
            echo ${input_args[i+1]}
            hash_args+=(${input_args[i+1]})
            target=$(($i+3))
            echo $target + "*************"
        done

        echo -n -e "debug: /////////////////////////////// \n"
        for ((i=0; i+target < ${#input_args[@]}; i++))
        do
            ### 印出 array 的 key 及 value
            echo ${input_args[i+target]}
            file_args+=(${input_args[i+target]})
        done
    fi

    # debug
    echo -n -e "debug: **********************************\n"
    echo -n -e "nums: ${#hash_args[@]}  ${#file_args[@]}\n"
    for ((i=0; i < ${#hash_args[@]}; i++))
    do
        ### 印出 array 的 key 及 value
        echo $i ${hash_args[i]}
    done
    for ((i=0; i < ${#file_args[@]}; i++))
    do
        ### 印出 array 的 key 及 value
        echo $i ${file_args[i]}
    done

    # ================================================
    # check the code nums and files num  whether equal

elif [ "$1" = "--sha256" ]
then
    echo -n -e "-sha256\n"

    # check exist md5
    str=$*
    substr='--md5'
    if [[ "$str" == *"$substr"* ]]; then
        error_msg_3
    else
        echo "String does'nt contains the substring"
    fi
else
    error_msg_1
    exit 0
fi


echo -n -e "=================================\n"

# echo $*

# for i in "$*" ; do
#     echo "In loop: $i"
# done

# var=1

# arr=()
# for i in "$@" ; do
#     arr+=("$i")
# done


# for ((i=1; i < ${#arr[@]}; i++))
# do
#     ### 印出 array 的 key 及 value
#     echo $i ${arr[$i]}
# done


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
