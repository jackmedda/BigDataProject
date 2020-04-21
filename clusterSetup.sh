#!/bin/bash

cat /etc/hosts > /home/ubuntu/.tmpHosts
cat /home/ubuntu/.ssh/config > /home/ubuntu/.tmpSSHConfig

index=$2
IFS='_' read -ra IPs <<<$3
for i in ${IPs[@]}; do
    awk -v ip="$i" -v idx="$index" '!x{x=sub(/^$/,ip" datanode"idx"\n")}1' /etc/hosts > _tmp && sudo mv _tmp /etc/hosts
    echo -e "Host datanode${index}\nHostName datanode${index}\nUser ubuntu\nIdentityFile /home/ubuntu/.ssh/${1}.pem" >> /home/ubuntu/.ssh/config
    echo "datanode${index}" | sudo tee -a /home/ubuntu/hadoop/etc/hadoop/workers
    echo "datanode${index}" | sudo tee -a /home/ubuntu/spark/conf/slaves
    index=$((index + 1))
done