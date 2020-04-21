#!/bin/bash

n_datanodes=$2
END=$((n_datanodes+2))
for ((i=$1;i<END;i++)); do
    cat /etc/hosts | ssh -oStrictHostKeyChecking=no datanode$i "sudo sh -c 'cat >/etc/hosts'"
    cat /home/ubuntu/hadoop/etc/hadoop/workers | ssh -oStrictHostKeyChecking=no datanode$i "sudo sh -c 'cat >/home/ubuntu/hadoop/etc/hadoop/workers'"
    cat /home/ubuntu/.ssh/config | ssh -oStrictHostKeyChecking=no datanode$i "sudo sh -c 'cat >/home/ubuntu/.ssh/config'"
done