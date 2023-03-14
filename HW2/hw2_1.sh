#!/bin/sh


usage() {
echo -n -e "\nUsage: sahw2.sh {--sha256 hashes ... | --md5 hashes ...}
-i files ...\n\n--sha256: SHA256 hashes to validate input files.\n--md5:
MD5 hashes to validate input files.\n-i: Input files.\n"
}

error_msg_1(){
    echo "Error: Invalid arguments."
    usage
    exit 0
}

error_msg_2(){
    echo "Error: Invalid values."
    exit 0
}

error_msg_3(){
    echo "Error: Only one type of hash function is allowed."
    exit 0
}

error_msg_4(){
    echo "Error: Invalid checksum."
    exit 0
}

error_msg_5(){
    echo "Error: Invalid file format."
    exit 0
}

compare_nums(){
    if [ $1 -ne $2 ]; then
        error_msg_2
    fi
}

compare_hash(){
    if [ "$1" != "$2" ]; then
        # echo -n -e "not same \n"
        error_msg_4
        # exit
    fi
}

warning_msg(){
    echo "Warning: user root already exists."
}

ask_msg(){
    echo -n -e "This script will
create the following user(s): ... Do you want to continue? [y/n]:"
}

# compare_file(){
    
# }


sha256_args=()
md5_args=()
hash_args=()
file_args=()
input_args=($0)


# read the input
# echo $0
for i in "$@" ; do
    input_args+=("$i")
done


# check the first args
if [ "$1" = "-h" ]
then
    usage
elif [ "$1" = "--md5" ]
then
    # echo -n -e "-md5\n"

    # check exist sha256
    str=$*
    substr='--sha256'
    target=0
    if [[ "$str" == *"$substr"* ]]; then
        error_msg_3
    fi


elif [ "$1" = "--sha256" ]
then
    # echo -n -e "-sha256\n"

    # check exist md5
    str=$*
    substr='--md5'
    if [[ "$str" == *"$substr"* ]]; then
        error_msg_3
    fi
else
    error_msg_1
    exit 0
fi



# get hash and files
target=0
compare_string=""
for ((i=1;; i++))
do
    if [ "${input_args[i+1]}" = "-i" ]
    then
        break
    fi
    # echo "${input_args[i+1]}"
    hash_args+=(${input_args[i+1]})
    target=$(($i+2))
done

for ((i=1; i+target < ${#input_args[@]}; i++))
do
    file_args+=(${input_args[i+target]})
done

# # echo -n -e "nums: ${#hash_args[@]}  ${#file_args[@]}\n"
# for ((i=0; i < ${#hash_args[@]}; i++))
# do
#         ### 印出 array 的 key 及 value
#     echo $i ${hash_args[i]}
# done

# for ((i=0; i < ${#file_args[@]}; i++))
# do
#         ### 印出 array 的 key 及 value
#     echo $i ${file_args[i]}
# done

# check the code nums and files num  whether equal
compare_nums ${#hash_args[@]} ${#file_args[@]}




if [ "$1" = "--md5" ]
then

    for ((i=0; i < ${#file_args[@]}; i++))
    do
        md5_str=`md5 ${file_args[i]} | awk '{print $4}'`
        compare_hash ${hash_args[i]} $md5_str
        # echo $md5_str

    done

elif [ "$1" = "--sha256" ]
then
    for ((i=0; i < ${#file_args[@]}; i++))
    do
        sha256_str=`sha256 ${file_args[i]} | awk '{print $4}'`
        compare_hash ${hash_args[i]} $sha256_str
        # echo $sha256_str

    done
fi

## judge CSV and JSON

username_table=()
password_table=()
shell_table=()
groups_table=()

check_state=2


for ((i=0; i < ${#file_args[@]}; i++))
do

    if cat ${file_args[i]} | jq type > /dev/null 2>&1
    then
        check_state=1
    else
        jq --slurp --raw-input --raw-output 'split("\n") | .[1:] | map(split(",")) |map({"username": .[0],"password": .[1], "shell": .[2], "groups": .[3]})' ${file_args[i]} > ${file_args[i]}.json && cat ${file_args[i]}.json | sed 's/\\r//g' > ${file_args[i]}_sample.json && rm ${file_args[i]}.json
        # judge if it can parse
        judge_file_str=`cat ${file_args[i]}_sample.json  | jq -r ".[] | .groups" | xargs echo | awk '{print $1}'`
        if [ "$judge_file_str" = "null" ] || [ "$judge_file_str" = "" ] 
        then
            # echo -n -e "I cant parse \n"
            # error msg
            error_msg_5
        else
            # echo -n -e "I can parse \n"
            check_state=2
        fi
    fi


    filename_json=""
    if [ $check_state -eq 1 ]
    then
        filename_json="${file_args[i]}"
    else
        filename_json="${file_args[i]}_sample.json"
    fi

    OIFS="$IFS"
    IFS=' '

    ## parse username
    str=`cat $filename_json | jq -r ".[] | .username" | xargs echo`
    read -a new_string <<< "${str}"
    IFS="$OIFS"
    for j in "${new_string[@]}"
    do     
        username_table+=("$j")
    done

    ## parse password
    str=`cat $filename_json | jq -r ".[] | .password" | xargs echo`
    read -a new_string <<< "${str}"
    IFS="$OIFS"
    for j in "${new_string[@]}"
    do     
        password_table+=("$j")
    done


    ## parse shell
    str=`cat $filename_json | jq -r ".[] | .shell" | xargs echo`
    read -a new_string <<< "${str}"
    IFS="$OIFS"
    for j in "${new_string[@]}"
    do     
        shell_table+=("$j")
    done


    # save groups
    if [ $check_state -eq 1 ]
    then
        OIFS="$IFS"
        IFS=']'
        ## parse groups
        str=`cat $filename_json | jq -r ".[] | .groups" | xargs echo`
        read -a new_string <<< "${str}"
        IFS="$OIFS"
        for j in "${new_string[@]}"
        do 
            temp_str=`echo $j | sed 's/\\[//g' | sed 's/\,//g' `
            groups_table+=("$temp_str")
        done
    else
        total_nums=`awk 'END { print NR }' ${file_args[i]}`
        # echo $total_nums
        for ((j=2; j <= ${total_nums}; j++))
        do
            ### 印出 array 的 key 及 value
            temp_str=`cat ${file_args[i]} | head -$j | tail +$j |awk -F, '{print $4}' | sed 's/\\r//g' `
            groups_table+=("$temp_str")
        done
    fi
done

# # debug
#     for ((j=0; j < ${#username_table[@]}; j++))
#     do
#         ### 印出 array 的 key 及 value
#         echo $j ${username_table[j]} ${password_table[j]} ${shell_table[j]} ${groups_table[j]}
#     done


# ask for create user
echo -n -e "This script will create the following user(s): ${username_table[*]} Do you want to continue? [y/n]:"
read answer # read from stdin and assign to variable
case $answer in 
    [Yy])
    ;;
    [Nn])
    exit 0
    ;;
    *)
    echo "removing..."
    ;;
esac


# adduser

for ((i=0; i < ${#username_table[@]}; i++))
do
    if id -u "${username_table[i]}" >/dev/null 2>&1; then
        # echo "user exists"
        warning_msg

    else
        # echo $i ${username_table[i]} ${password_table[i]} ${shell_table[i]}
        pw useradd ${username_table[i]} -s ${shell_table[i]} # create user
        echo ${password_table[i]} | pw usermod -n ${username_table[i]} -h 0 # change password
        if [ "${groups_table[i]}" != "" ]
        then
            OIFS="$IFS"
            IFS=' '
            group_str="${groups_table[i]}"
            read -a new_string <<< "${group_str}"
            IFS="$OIFS"
            for j in "${new_string[@]}"
            do 
                # echo $i
                if [ $(getent group $j) ]; then
                    # echo "group exists."
                    pw group mod $j -m ${username_table[i]}
                else
                    # echo "group does not exist."
                    pw groupadd $j
                    pw group mod $j -m ${username_table[i]}
                fi
                # echo $i
            done
        fi
    fi
done