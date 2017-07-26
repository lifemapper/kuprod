#!/bin/bash

# IP=129.237.201.194
# VLAN=6

# Defaults
TEST=0
FE_DISK_GB=200
FE_MEM_MB=16384
NUM_NODES=6
NODE_CPUS=2
NODE_DISK_GB=50

# Change these explicitely at the command prompt if you wantto change
# Command: rocks set host vm <vm-node-name> mem=<mem-in-Mb>
NODE_MEM_MB=8192

# Nodes are assigned round-robin.  If some VM containers do not have enough
# resources, re-assign virtual nodes to other VM containers
# Command: rocks set host vm <vm-node-name> physnode=<vm-container-name>
for i in "$@"
do
case $i in
    -i=*|--ip=*)
        IP="${i#*=}"
        # past argument=value
        shift
        ;;
    -v=*|--vlan=*)
        VLAN="${i#*=}"
        shift
        ;;
    -fs=*|--fe_size_gb=*)
        FE_DISK_GB="${i#*=}"
        shift
        ;;
    -fm=*|--fe_mem_mb=*)
        FE_MEM_MB="${i#*=}"
        shift
        ;;
    -nc=*|--node_count=*)
        NUM_NODES="${i#*=}"
        shift
        ;;
    -ncc=*|--node_cpu_count=*)
        NODE_CPUS="${i#*=}"
        shift
        ;;
    -ns=*|--node_size_gb=*)
        NODE_DISK_GB="${i#*=}"
        shift
        ;;
    -t|--test)
        TEST=1
        shift
        ;;
    *)
        # unknown option
    ;;
esac
done


# ....................................
### time
# ....................................
TimeStamp () {
    if [ $TEST -eq 0 ]; then
        echo `/bin/date` $1 >> $LOG
    else
        echo $1    
    fi
}

# ....................................
### get command line parameters
# ....................................
setParams () {
    vchosts=`rocks list host | grep 'VM Container' | awk -F: '{print $1}'`

    if [ ${#IP} -ge 7 ] || [ ${#VLAN} -ge 1 ]; then
        lastq="${IP##*.}"
        hn=`/bin/hostname`
        idx=`expr index "$hn" .`
        FE_CONTAINER=${hn:0:idx-1}
        FE_NAME="$FE_CONTAINER"-"$lastq"
        dt=$(date +%F | tr - _)

        LOG="$FE_NAME"_"$dt".log
        rm "$FE_NAME"_*.log
        touch $LOG

        if [ $TEST -eq 0 ]; then
            COM=
        else
            COM=echo
        fi

        TimeStamp "# Start"
        echo "  Script called with: bash add-cluster.sh \ " >> $LOG 
        echo "                           --ip=$IP \ " >> $LOG
        echo "                           --vlan=$VLAN \ " >> $LOG
        echo "                           --fe_size_gb=$FE_DISK_GB \ " >> $LOG 
        echo "                           --fe_mem_mb=$FE_MEM_MB \ " >> $LOG
        echo "                           --node_count=$NUM_NODES \ " >> $LOG 
        echo "                           --node_cpu_count=$NODE_CPUS \ " >> $LOG
        echo "                           --node_size_gb=$NODE_DISK_GB \ " >> $LOG 
        echo "                           --node_mem_mb=$NODE_MEM_MB " >> $LOG
    else
        echo "Usage:  bash add-cluster.sh --ip=<ip address> \ "
        echo "                            --vlan=<vlan #> \ "
        echo "                            --fe_size_gb=<frontend size in gb> \ "
        echo "                            --fe_mem_mb=<frontend RAM in mb> \ "
        echo "                            --node_count=<number of compute nodes> \ " 
        echo "                            --node_cpu_count=<cores per node> \ "
        echo "                            --node_size_gb=<node size in gb> \ "
        echo "                            --node_mem_mb=<node RAM in mb> "
        exit 1
    fi
}

# ....................................
### add cluster 
# ....................................
addCluster () {
    # check if cluster already exists
    result=`rocks list cluster | grep $FE_NAME | awk -F: '{print $1}'`
    if [ "$result" == "$FE_NAME" ] ; then
        msg="Virtual cluster $FE_NAME exists, no commands will be executed."
        TimeStamp $msg
    else
        cmd="rocks add cluster \
             $IP $NUM_NODES \
             cluster-naming=1 \
             fe-name=$FE_NAME \
             fe-container=$FE_CONTAINER \
             disk-per-frontend=$FE_DISK_GB \
             cpus-per-compute=$NODE_CPUS \
             disk-per-compute=$NODE_DISK_GB \
             mem-per-compute=$NODE_MEM_MB \
             vlan=$VLAN"
        TimeStamp "Creating cluster"
        $COM $cmd
    fi
}

# ....................................
### set VMs disks and memory
# ....................................
setDisksMem () {
    cnodes=`rocks list cluster $FE_NAME | tail -n +3 |  awk '{print $2}'`
    for h in $cnodes;
    do  
        cmd="rocks set host vm $h disk=file:/state/partition1/kvm/disks/$h.vda,vda,virtio"
        TimeStamp "Setting node disk"
        $COM $cmd
    done

    exists=`zfs list | grep tank/vms/$FE_NAME | wc -l`
    if [ "$exists" == 0 ] ; then
       cmd="zfs create -V ${FE_DISK_GB}G tank/vms/${FE_NAME}"
       TimeStamp "Creating ZFS volume"
       $COM $cmd
    else
       TimeStamp "ZFS tank/vms/$FE_NAME exists"
    fi

    cmd="rocks set host vm $FE_NAME disk=phy:/dev/tank/vms/$FE_NAME,vda,virtio"
    TimeStamp "Setting FE disk"
    $COM $cmd
    
    cmd="rocks set host vm $FE_NAME disksize=$FE_DISK_GB"
    TimeStamp "Setting FE disk size"
    $COM $cmd    

    cmd="rocks set host vm $FE_NAME mem=$FE_MEM_MB"
    TimeStamp "Setting FE disk"
    $COM $cmd

}

setParams
addCluster
setDisksMem


bash add-cluster.sh --ip=129.237.201.192 \
                    --vlan=4 \
                    --fe_size_gb=200 \
                    --fe_mem_mb=16384 \
                    --node_count=6 \
                    --node_cpu_count=2 \
                    --node_size_gb=50 \
                    --node_mem_mb=16384 \
                    --test
# name=notyeti-1

# zfs create -V tank/vms/$name
# rocks add host vm notyeti name=$name cpus=2 membership="Hosted VM"
# rocks set host vm $name mem=16384  
# rocks set host vm $name disk="phy:/dev/tank/vms/$name,vda,virtio"
# rocks set host vm $name  disksize=100
