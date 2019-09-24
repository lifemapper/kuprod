#!/bin/bash

set_defaults() {
    TEST=1
    size=50
    mem=4096
    
    if [ $TEST -eq 0 ]; then
        COM=
    else
        COM=echo
    fi
    
    fqdn=`/bin/hostname`
    pos=`expr index $fqdn '.'`
    hostname=${fqdn:0:pos-1}
    echo "Hostname is $hostname"
}

create_devapp () {
    name=$1
    echo "Name is $name"
    # exists=`zfs list | grep tank/vms/$name | wc -l`
    exists=1
    if [ "$exists" == 0 ] ; then
       cmd="zfs create -V ${size}G tank/vms/${name}"
       $COM $cmd
       echo "Creating ZFS volume"
    else
       echo "ZFS tank/vms/$name exists"
    fi

    cmd="rocks add host vm ${hostname} name=${name} mem=${mem} cpus=2 membership='Development Appliance'"
    $COM $cmd
    # cmd="rocks set host vm ${name} disk='phy:/dev/tank/vms/${name},vda,virtio'"
    cmd="rocks set host vm ${name} disk=file:/state/partition1/kvm/$name.vda,vda,virtio"
    $COM $cmd
    cmd="rocks set host vm ${name} disksize=${size}"
    $COM $cmd
}

### Main ###
if [ $# -gt 1 ]; then
    usage
    exit 0
fi

set_defaults
create_devapp dev-0
create_devapp dev-1


# rocks add host vm notyeti name=vmdevel-0-0 cpus=2 membership="Hosted VM"
# rocks set host vm vmdevel-0-0 mem=4096
# rocks set host interface subnet vmdevel-0-0 eth0 private
# rocks set host interface ip vmdevel-0-0 eth0 192.168.202.244
# rocks set host vm vmdevel-0-0 disksize=75
# 

name=rollme
zfs create -V 50G tank/vms/${name}
rocks add host vm notyeti name=${name} cpus=2 membership="Development Appliance"
rocks set host vm ${name} disk='phy:/dev/tank/vms/${name},vda,virtio'
rocks set host vm ${name} disksize=50
rocks set host vm ${name} mem=4096
