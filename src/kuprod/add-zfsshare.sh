# 2017-07-27
# Create ZFS pool and slice on NAS 
# adding zfs share from NAS to virtual cluster
# !!! Do this AFTER add-storage on notyeti frontend

# This example is for notyeti cluster containing VM container and NAS Appliance nodes
#     Private network from notyeti to VM Containers and NAS is 192.168.202.x
# VC notyeti-190 with:
#    public IP 129.237.201.190 and 
#    private network 192.168.190.x

# 1. Create zpool, then slices
zpool create -f tank /dev/sdb /dev/sdc
zpool list

# 2. Create parent slice and set sharenfs
zfs create tank/data
zfs set sharenfs="rw=@192.168.202.0/24,no_root_squash,async" tank/data
zfs set sharenfs=on tank/data

# 3. Create slice for VM, limit size, and set sharenfs
zfs create tank/data/data-190
zfs set quota=2T tank/data/data-190
zfs set sharenfs="rw=@192.168.190.0/24,no_root_squash,async,no_all_squash,rw=@192.168.202.0/24,no_root_squash,async,no_all_squash" tank/data/data-190

########## on notyeti-190, add entry in /etc/auto.share
# 192.168.190.2 is the subnet for NAS to vlan2
# data -fstype=nfs4,tcp,noacl,nodev,nosuid 192.168.190.2:/tank/data/data-190
