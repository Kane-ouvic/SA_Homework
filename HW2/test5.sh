#!/bin/sh

username_table=()
password_table=()
shell_table=()
groups_table=()

# JSON
OIFS="$IFS"
IFS=' '

## parse username
str=`cat file1 | jq -r ".[] | .username" | xargs echo`
read -a new_string <<< "${str}"
IFS="$OIFS"
for i in "${new_string[@]}"
do     
   username_table+=("$i")
done
for ((i=0; i < ${#username_table[@]}; i++))
do
    ### 印出 array 的 key 及 value
    echo $i ${username_table[i]}
done

## parse password
str=`cat file1 | jq -r ".[] | .password" | xargs echo`
read -a new_string <<< "${str}"
IFS="$OIFS"
for i in "${new_string[@]}"
do     
   password_table+=("$i")
done
for ((i=0; i < ${#password_table[@]}; i++))
do
    ### 印出 array 的 key 及 value
    echo $i ${password_table[i]}
done

## parse shell
str=`cat file1 | jq -r ".[] | .shell" | xargs echo`
read -a new_string <<< "${str}"
IFS="$OIFS"
for i in "${new_string[@]}"
do     
   shell_table+=("$i")
done
for ((i=0; i < ${#shell_table[@]}; i++))
do
    ### 印出 array 的 key 及 value
    echo $i ${shell_table[i]}
done


# OIFS="$IFS"
# IFS=']'
# ## parse groups
# str=`cat file1 | jq -r ".[] | .groups" | xargs echo`
# read -a new_string <<< "${str}"
# IFS="$OIFS"
# for i in "${new_string[@]}"
# do 
#    temp_str=`echo $i | sed 's/\\[//g' | sed 's/\,//g' `
#    groups_table+=("$temp_str")
# done


total_nums=`awk 'END { print NR }' file2`
for ((i=2; i <= ${total_nums}; i++))
do
    ### 印出 array 的 key 及 value
    temp_str=`cat file2 | head -$i | tail +$i |awk -F, '{print $4}' | sed 's/\\r//g' `
    groups_table+=("$temp_str")
done

echo -n -e "=====================================\n"

# for ((i=0; i < ${#groups_table[@]}; i++))
# do
#     ### 印出 array 的 key 及 value
#     echo $i ${groups_table[i]}

#     OIFS="$IFS"
#     IFS=' '
#     group_str="${groups_table[i]}"
#     read -a new_string <<< "${group_str}"
#     IFS="$OIFS"
#     for i in "${new_string[@]}"
#     do 
#         # echo $i
#         if [ $(getent group $i) ]; then
#             echo "group exists."
#         else
#             echo "group does not exist."
#             pw groupadd $i
#         fi
#         # echo $i
#     done

# done

# echo -n -e "=====================================\n"

# adduser



for ((i=0; i < ${#username_table[@]}; i++))
do
    ### 印出 array 的 key 及 value
    # check_id=`id ${username_table[i]} | xargs echo`
    if id -u "${username_table[i]}" >/dev/null 2>&1; then
        echo "user exists"
        # echo $i ${username_table[i]} ${password_table[i]} ${shell_table[i]}
        # pw useradd ${username_table[i]} -s ${shell_table[i]} # create user
        # echo ${password_table[i]} | pw usermod -n ${username_table[i]} -h 0 # change password
        # if [ "${groups_table[i]}" = "" ]
        # then
        #     echo -n -e "dont need to create user\n"
        # else
        #     echo ${groups_table[i]}
        # fi
    else
        echo $i ${username_table[i]} ${password_table[i]} ${shell_table[i]}
        pw useradd ${username_table[i]} -s ${shell_table[i]} # create user
        echo ${password_table[i]} | pw usermod -n ${username_table[i]} -h 0 # change password
        if [ "${groups_table[i]}" = "" ]
        then
            echo -n -e "dont need to create user\n"
        else
            OIFS="$IFS"
            IFS=' '
            group_str="${groups_table[i]}"
            read -a new_string <<< "${group_str}"
            IFS="$OIFS"
            for i in "${new_string[@]}"
            do 
                # echo $i
                if [ $(getent group $i) ]; then
                    echo "group exists."
                    # pw usermod ${username_table[i]} -G $i
                    pw group mod $i -m ${username_table[i]}
                else
                    echo "group does not exist."
                    pw groupadd $i
                    # pw usermod ${username_table[i]} -G $i
                    pw group mod $i -m ${username_table[i]}
                fi
                # echo $i
            done
        fi
    fi

done
    # echo $i ${username_table[i]} ${password_table[i]} ${shell_table[i]}
    # pw useradd ${username_table[i]} -s ${shell_table[i]} # create user
    # echo ${password_table[i]} | pw usermod -n ${username_table[i]} -h 0 # change password



# done

# CSV
echo -n -e "=====================================\n"
## parse groups

# total_nums=`awk 'END { print NR }' file2`
# for ((i=2; i <= ${total_nums}; i++))
# do
#     ### 印出 array 的 key 及 value
#     temp_str=`cat file2 | head -$i | tail +$i|  awk -F, '{print $4}'`
#     groups_table+=("$temp_str")
# done
# for ((i=0; i < ${#groups_table[@]}; i++))
# do
#     ### 印出 array 的 key 及 value
#     echo $i ${groups_table[i]}
# done

# echo $username_table[*]
