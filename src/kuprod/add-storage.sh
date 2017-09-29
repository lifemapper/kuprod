# !!! Do this BEFORE add-zfsshare on NAS
# ....................................
### define varibles
# ....................................
SetDefaults () {
   idx=`expr index $HOSTNAME .`
   BASEHOSTNAME=${HOSTNAME:0:idx-1}
   
   VC=$1
   VLAN=$2

   LOG=/tmp/`/bin/basename $0`.log
   rm $LOG
   touch $LOG
   TimeStamp "# Start"
   echo Creating new security update roll for $BASEHOSTNAME
}

# 2017-06-30
# adding interface for the storage network on FE

# This example is for VC notyeti-190 with:
#    public IP 129.237.201.190 and 
#    private network 192.168.190.x

# 1. add a network
/opt/rocks/bin/rocks add network storage-190 subnet=192.168.190.0 netmask=255.255.255.0 mtu=1500

# 2. add nas interface for VLAN=2 used for notyeti-190 clsuter
# the interface em1 is the private interface, and ".2" has to correspond to the VLAN ID.
/opt/rocks/bin/rocks add host interface nas-0-0 em1.2
/opt/rocks/bin/rocks set host interface ip nas-0-0 em1.2 192.168.190.2
/opt/rocks/bin/rocks set host interface name nas-0-0 em1.2 nas-0-0
/opt/rocks/bin/rocks set host interface subnet nas-0-0 em1.2 storage-190
/opt/rocks/bin/rocks set host interface vlan nas-0-0 em1.2 2

#  3. verify , examine resulting file, what will be executed
/opt/rocks/bin/rocks report host interface nas-0-0 | rocks report script > /tmp/junk
# it is executed in 6

#  4. sync, this add new values to the rocks db
/opt/rocks/bin/rocks sync config

#  5. sync network, this starts new network and activates new interface on FE
/opt/rocks/bin/rocks sync host network nas-0-0

# remove interface and redo network to as before interface
#/opt/rocks/bin/rocks remove host interface nas-0-0 em1.2
#/opt/rocks/bin/rocks sync config
#/opt/rocks/bin/rocks sync host network nas-0-0

# 6. add vlan to the public interface of your VM frontend
# NOT NEEDED, rm
#/opt/rocks/bin/rocks set host interface vlan notyeti-190 eth1 7

# verify interface on nas, do the same on respective VFE and VC
ping 192.168.190.2
ping 192.168.190.1    # ping VM frontend
ping 192.168.190.254  # ping VM compute

########## on nas-0-0
# see /root/root-hsit-20170713

########## on notyeti-190
# see /root/root-hsit-20170713
