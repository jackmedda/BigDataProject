#!/bin/bash

n_datanodes=$2
END=$((n_datanodes+2))
for(( i=$1; i<END; i++ )); do
     ssh-keygen -f "/home/ubuntu/.ssh/known_hosts" -R "datanode"$i
done

sudo rm -r /home/ubuntu/hadoop/data/namenode
sudo rm -r /home/ubuntu/hadoop/data/datanode
sudo echo "datanode1" > /home/ubuntu/hadoop/etc/hadoop/workers
sudo echo "datanode1" > /home/ubuntu/spark/conf/slaves
sudo mv /home/ubuntu/.tmpHosts /etc/hosts
sudo mv /home/ubuntu/.tmpSSHConfig /home/ubuntu/.ssh/config
sudo rm -r /tmp/*