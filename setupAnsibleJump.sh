#!/usr/bin/env bash

#Set up ssh key
if [ -z /tmp/id_rsa ]; then
    chmod 400 /tmp/id_rsa
    mv /tmp/id_rsa /home/adminuser/.ssh
fi

#Install Ansible & Dynamic Inventory
iRetry=5 
iCount=0
while true; do
    apt-get update
    iWorks=$(echo $?)
    if [ $iWorks -eq 0 ]; then
        apt-get install -y ansible
        iWorks=$(echo $?)
        if [ $iWorks -eq 0 ]; then
            wget -q "https://raw.githubusercontent.com/Alucardesu/task8_terraform_compose/main/myazure_rm.yml"
            iWorks=$(echo $?)
            if [ $iWorks -eq 0 ]; then
                ansible-inventory -i myazure_rm.yml
                iWorks=$(echo $?)
                if [ $iWorks -eq 0 ]; then
                    break
                fi
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