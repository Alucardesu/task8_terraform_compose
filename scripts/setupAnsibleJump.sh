#!/usr/bin/env bash
sUser="adminuser"
sHome="/home/$sUser"
sRole="$sHome/ansible/roles/task9_web"
sGit="https://github.com/Alucardesu/task8_terraform_compose/archive/refs/heads/main.tar.gz"

#Set up ssh key
if [ -e /tmp/id_rsa ]; then
    chmod 400 /tmp/id_rsa
    mv /tmp/id_rsa $sHome/.ssh
fi

iRetry=5 
iCount=0
while true; do

    #Install python
    apt-get update && apt-get upgrade -y && apt install -y python3-pip
    iWorks=$(echo $?)
    if [ $iWorks -eq 0 ]; then

        #Install ansible & ansible[azure]
        su - $sUser -c "pip3 install 'ansible==2.9.17'"  && su - $sUser -c "pip3 install ansible[azure]"
        iWorks=$(echo $?)
        if [ $iWorks -eq 0 ]; then

            #Creating ansible directory & config files
            su - $sUser -c "mkdir -p $sHome/ansible/roles $sHome/.azure" 
            su - $sUser -c "touch $sHome/.ansible.cfg  $sHome/.azure/credentials" 
            cat <<EOF > $sHome/.ansible.cfg 
[defaults] 
inventory = ~/ansible/myazure_rm.yml 
roles_path = ~/ansible/roles 
host_key_checking = False
EOF

            cat <<EOF > $sHome/.azure/credentials 
[default]
subscription_id=$1
client_id=$2
secret=$3
tenant=$4
EOF
            #Downloading Dynamic Inventory Setup
            su - $sUser -c "mkdir -p $sRole"
            su - $sUser -c "cd $sRole; wget -q -O $sRole/main.tar.gz -c $sGit && tar -zxvf $sRole/main.tar.gz task8_terraform_compose-main/ansible/ --strip-components=2 -C $sRole;"
            iWorks=$(echo $?)
            if [ $iWorks -eq 0 ]; then

                su - $sUser -c "rm -f $sRole/main.tar.gz; mv $sRole/myazure_rm.yml $sHome/ansible/"
                break;
            fi
        fi
    fi

    if (( iCount++ == iRetry )); then
        echo 'Installation Failed' 
        return 1
    else
        sleep 30
    fi
done;