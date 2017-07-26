#!/bin/bash
#
# Create a new virtual cluster

# ....................................
### define varibles
# ....................................
SetDefaults () {
   idx=`expr index $HOSTNAME .`
   BASEHOSTNAME=${HOSTNAME:0:idx-1}
   
   VC_IP=$1
   NODE_COUNT=$2
   MEM_GB=$2
   CPUS=$3

   LOG=/tmp/`/bin/basename $0`.log
   rm $LOG
   touch $LOG
   TimeStamp "# Start"
   echo Creating new security update roll for $BASEHOSTNAME
}

# ....................................
### time
# ....................................
TimeStamp () {
   echo $1 `/bin/date` >> $LOG
}


# ....................................
### create zfs volume
# ....................................
CreateVolume () {
   zfs create -V tank/vms/$name
}

# ....................................
### create zfs volume
# ....................................
CreateCluster () {
	rocks add cluster ip="$VC_IP" num-computes=$NODE_COUNT
	
   rocks add host vm notyeti name=$name cpus=2 membership="Hosted VM"
   rocks set host vm $name mem=16384  
   rocks set host vm $name disk="phy:/dev/tank/vms/$name,vda,virtio"
   rocks set host vm $name  disksize=200
}


SetDefaults
CreateCluster
CreateVolume
TimeStamp

# name=notyeti-1

# zfs create -V tank/vms/$name
# rocks add host vm notyeti name=$name cpus=2 membership="Hosted VM"
# rocks set host vm $name mem=16384  
# rocks set host vm $name disk="phy:/dev/tank/vms/$name,vda,virtio"
# rocks set host vm $name  disksize=100
