#!/bin/bash

#create 1. VM and interface

bash basis-script.sh 1 VM1
sleep 30
bash basis-script.sh 4 VM1 08:00:00:00:00:01

#create 2. VM and interface

bash basis-script.sh 1 VM2
sleep 30
bash basis-script.sh 4 VM2 08:00:00:00:00:02

#create bridge
bash basis-script.sh 3 br00-8 10.10.80.1 255.255.255.0 10.10.80.10 10.10.80.80 08:00:00:00:00:01 10.10.80.11 08:00:00:00:00:02 10.10.80.12

#add interfaces to the bridge

bash basis-script.sh 5 VM1 br00-8
bash basis-script.sh 5 VM2 br00-8
