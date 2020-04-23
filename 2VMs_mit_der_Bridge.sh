#!/bin/bash

VM1_MAC=08:00:00:00:00:01
VM2_MAC=08:00:00:00:00:02
VM1_IP=10.10.80.11
VM2_IP=10.10.80.12

#create 1. VM and interface
bash basis-script.sh 1 VM1
sleep 30
bash basis-script.sh 4 VM1 ${VM1_MAC}

#create 2. VM and interface

bash basis-script.sh 1 VM2
sleep 30
bash basis-script.sh 4 VM2 ${VM2_MAC}

#create bridge
bash basis-script.sh 3 br00-8 10.10.80.1 255.255.255.0 10.10.80.10 10.10.80.80 ${VM1_MAC} ${VM1_IP} ${VM2_MAC} ${VM2_IP}

#add interfaces to the bridge

bash basis-script.sh 5 VM1 br00-8
bash basis-script.sh 5 VM2 br00-8
