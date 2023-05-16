#!/bin/sh


usage() {
echo -n -e "\nUsage: sahw2.sh {--sha256 hashes ... | --md5 hashes ...} -i files ...\n\n--sha256: SHA256 hashes to validate input files.\n--md5: MD5 hashes to validate input files.\n-i: Input files.\n"
}

error_msg_1(){
    echo -n -e "Error: Invalid arguments." 1>&2
    usage
    exit 1
}

error_msg_2(){
    echo -n -e "Error: Invalid values." 1>&2
    exit 1
}

error_msg_3(){
    echo -n -e "Error: Only one type of hash function is allowed." 1>&2
    exit 1
}

error_msg_4(){
    echo -n -e "Error: Invalid checksum." 1>&2
    exit 1
}

error_msg_5(){
    echo -n -e "Error: Invalid file format." 1>&2
    exit 1
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
    echo "Warning: user $1 already exists."
}

ask_msg(){
    echo -n -e "This script will
create the following user(s): ... Do you want to continue? [y/n]:"
}

hash_args=()
file_args=()
input_args=($0)


for i in "$@" ; do
    input_args+=("$i")
done

choice_code=0
hash_code=0



# check the first args
if [ "$1" = "-h" ]
then
    usage
    exit 0
elif [ "$1" = "--md5" ]
then
    choice_code=1

elif [ "$1" = "--sha256" ]
then
    choice_code=1
elif [ "$1" = "-i" ]
then
    choice_code=2
else
    error_msg_1
fi

# echo -n -e "==========================\n"
str=$*
substr1='--md5'
substr2='--sha256'
substr3='-i'
if [[ "$str" == *"$substr1"* ]] && [[ "$str" == *"$substr2"* ]]; then
    error_msg_3
fi


if [[ "$str" == *"$substr1"* ]]; then
    hash_code=1
elif [[ "$str" == *"$substr2"* ]]; then
    hash_code=2
fi

if [ $choice_code -eq 1 ]
then
    target=0
    for ((i=1;; i++))
    do
        if [ "${input_args[i+1]}" = "-i" ]
        then
            break
        fi
        hash_args+=(${input_args[i+1]})
        target=$(($i+2))
    done

    for ((i=1; i+target < ${#input_args[@]}; i++))
    do
        file_args+=(${input_args[i+target]})
    done
else
    target=0
    for ((i=1;; i++))
    do
        if [ "${input_args[i+1]}" = "--md5" ] || [ "${input_args[i+1]}" = "--sha256" ]
        then
            break
        fi
        # echo "${input_args[i+1]}"
        file_args+=(${input_args[i+1]})
        target=$(($i+2))
    done

    for ((i=1; i+target < ${#input_args[@]}; i++))
    do
        hash_args+=(${input_args[i+target]})
    done
fi


# check the code nums and files num  whether equal
compare_nums ${#hash_args[@]} ${#file_args[@]}




if [ $hash_code -eq 1 ]
then

    for ((i=0; i < ${#file_args[@]}; i++))
    do
        md5_str=`md5 ${file_args[i]} | awk '{print $4}'`
        compare_hash ${hash_args[i]} $md5_str
        # echo $md5_str

    done

elif [ $hash_code -eq 2 ]
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
        cat ${file_args[i]}  | grep -Ev '^[[:space:]]*(#|$)' > ${file_args[i]}_temp
        jq --slurp --raw-input --raw-output 'split("\n") | .[1:] | map(split(",")) |map({"username": .[0],"password": .[1], "shell": .[2], "groups": .[3]})' ${file_args[i]}_temp > ${file_args[i]}.json && cat ${file_args[i]}.json | sed 's/\\r//g' > ${file_args[i]}_sample.json && rm ${file_args[i]}.json
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
            temp_str=`cat ${file_args[i]} | head -$j | tail +$j |awk -F, '{print $4}' | sed 's/\\r//g' `
            groups_table+=("$temp_str")
        done
    fi

    # CSV delete the last element
    if [ $check_state -eq 2 ]
    then
        last_index=$((${#username_table[@]}-1))
        # echo $last_index
        unset username_table[$last_index]
        unset password_table[$last_index]
        unset shell_table[$last_index]
        unset groups_table[$last_index]
    fi
done



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
    exit 0
    ;;
esac

for ((i=0; i < ${#groups_table[@]}; i++))
do
            ### 印出 array 的 key 及 value
    echo ${groups_table[i]}
    # file_args+=(${input_args[i+target]})
done


# adduser

for ((i=0; i < ${#username_table[@]}; i++))
do
    if id -u "${username_table[i]}" >/dev/null 2>&1; then
        # echo "user exists"
        warning_msg ${username_table[i]}

    else
        # echo $i ${username_table[i]} ${password_table[i]} ${shell_table[i]}
        pw useradd ${username_table[i]} -s ${shell_table[i]} # create user
        echo ${password_table[i]} | pw usermod -n ${username_table[i]} -h 0 # change password  0 - stdin  1 - stdout 2 - stderr
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

exit 0