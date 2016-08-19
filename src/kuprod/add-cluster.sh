#!/bin/bash

IP=
VLAN=
NODE_CONTAINER=

# Defaults
TEST=1
NUM_NODES=2
NUM_NODE_CPUS=1
FE_MEM_MB=16384
FE_DISK_GB=1000
NODE_MEM_MB=8192
NODE_DISK_GB=50

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
        FE_MEM_B="${i#*=}"
        shift
        ;;
    -fc=*|--fe_mac=*)
        FE_MAC="${i#*=}"
        shift
        ;;
    -nc=*|--node_count=*)
        NUM_NODES="${i#*=}"
        shift
        ;;
    -ncc=*|--node_cpu_count=*)
        NUM_NODE_CPUS="${i#*=}"
        shift
        ;;
    -ns=*|--node_size_gb=*)
        NODE_DISK_GB="${i#*=}"
        shift
        ;;
    -nm=*|--node_mem_mb=*)
        NODE_MEM_B="${i#*=}"
        shift
        ;;
    -c=*|--container_hosts=*)
        NODE_CONTAINER="${i#*=}"
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

        if [ ${#NODE_CONTAINER} -eq 0 ]; then
            NODE_CONTAINER="$FE_CONTAINER"
        fi

        if [ $TEST -eq 0 ]; then
            COM=
        else
            COM=echo
        fi

        TimeStamp "# Start"
        echo "  Script called with: bash add-cluster.sh \ " >> LOG 
        echo "                           --ip=$IP \ " >> $LOG
        echo "                           --vlan=$VLAN \ " >> $LOG
        echo "                           --container_hosts=$NODE_CONTAINER \ " >> $LOG
        echo "                           --fe_size_gb=$FE_DISK_GB --fe_mem_mb=$FE_MEM_MB \ " >> $LOG
        echo "                           --node_count=$NUM_NODES --node_cpu_count=$NUM_NODE_CPUS \ " >> $LOG
        echo "                           --node_size_gb=$NODE_DISK_GB --node_mem_mb=$NODE_MEM_MB " >> $LOG
    else
        echo "Usage:  bash add-cluster.sh --ip=<ip address> \ "
        echo "                            --vlan=<vlan #> \ "
        echo "                            --container_hosts=<compute nodes host> \ "
        echo "                            --fe_size_gb=<frontend size in gb> \ "
        echo "                            --fe_mem_mb=<frontend RAM in mb> \ "
        echo "                            --node_count=<number of compute nodes> \ " 
        echo "                            --node_cpu_count=<cores per node> \ "
        echo "                            --node_size_gb=<node size in gb> \ "
        echo "                            --node_mem_mb=<node RAM in mb> "
        echo "        Possible node container hosts are: $vchosts"
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
             container-hosts="$NODE_CONTAINER" \
             cpus-per-compute=$NUM_NODE_CPUS \
             disk-per-compute=$NODE_DISK_GB \
             mem-per-compute=$NODE_MEM_MB \
             vlan=$VLAN"
        TimeStamp "Creating cluster with command: $cmd"
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
        cmd="rocks set host vm $h disk="file:/state/partition1/kvm/disks/$h.vda,vda,virtio""
        TimeStamp "Setting node disk with command: $cmd"
        $COM $cmd
    done

    exists=`zfs list | grep tank/vms/$FE_NAME | wc -l`
    if [ "$exists" == 0 ] ; then
       cmd="zfs create -V ${FE_DISK_GB}G tank/vms/${FE_NAME}"
       TimeStamp "Creating ZFS volume with command: $cmd"
       $COM $cmd
    else
       TimeStamp "ZFS tank/vms/$FE_NAME exists"
    fi

    cmd="rocks set host vm $FE_NAME disk="file:/tank/vms/kvm/disks/$FE_NAME.vda,vda,virtio" disksize=$FE_DISK_GB"
    TimeStamp "Setting FE disk with command $cmd"
    $COM $cmd

    cmd="rocks set host vm $FE_NAME mem=$FE_MEM_MB"
    TimeStamp "Setting FE disk with command $cmd"
    $COM $cmd

}

setParams
addCluster
setDisksMem


##  bash add-cluster.sh --ip=129.237.201.194 --container_hosts=badenov --fe_size_gb=1000 --fe_mem_mb=16384 --node_count=2 --node-cpu=4 --node_size_gb=100 --node_mem_mb=8194 --test=1
## 