
#!/bin/bash
users=("123", "1234")
for user in "${users[@]}"
do
    adduser --disabled-password --gecos "" $user
    usermod -a -G sudo $user
    echo "${user}:${user}" | chpasswd
    chage -d 0 $user
done