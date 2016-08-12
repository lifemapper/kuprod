#!/bin/bash

IP=192.168.202.200
MAC=00:21:9b:b6:5a:1f
INT=em2
RACK=0
RANK=0
SWITCH=network-$RACK-$RANK

/opt/rocks/bin/rocks add host $SWITCH cpus=1 rack=0 rank=0 membership="Ethernet Switch" os=linux
/opt/rocks/bin/rocks set host runaction $SWITCH action=os
/opt/rocks/bin/rocks set host installaction $SWITCH action=install
/opt/rocks/bin/rocks add host interface $SWITCH $INT
/opt/rocks/bin/rocks set host interface ip $SWITCH $INT $IP
/opt/rocks/bin/rocks set host interface name $SWITCH $INT $SWITCH
/opt/rocks/bin/rocks set host interface subnet $SWITCH $INT private
/opt/rocks/bin/rocks set host boot $SWITCH action=install
/opt/rocks/bin/rocks set host interface mac $SWITCH $INT $MAC

/opt/rocks/bin/rocks sync config
