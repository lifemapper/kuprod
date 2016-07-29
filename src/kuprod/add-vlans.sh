#!/bin/bash

### time
time_stamp () {
    echo $1 `/bin/date` >> $LOG
}

### create logfile
set_log() {
    LOG=/tmp/`/bin/basename $0`.log
    rm $LOG
    touch $LOG
}

### Test whether array contains a value
### args: container vlan# existingVlanNumbersArray
element_in () {
    local e
    for e in "${@:2}"; do
        if [ "$e" == $1 ]; then
            return 0
        fi
    done
    return 1
}

### Add missing vlans to vm-container
### args: container vlan#
add_vlans () {
    echo "rocks add host interface" $1 "vlan"$2 >> $LOG
    echo "rocks set host interface name" $1 "vlan"$2 $1 >> $LOG
    echo "rocks set host interface subnet" $1 "vlan"$2 "private" >> $LOG
    echo "rocks set host interface vlan" $1 "vlan"$2 $2 >> $LOG
    echo >> $LOG
}

### Add missing vlans to vm-container ($1)
### args: container
test_vlans () {
    VLANS=(1 2 3 4 5 6 7)
    EXISTING=(`rocks list host interface $NAME | awk '{print $8}' | grep -E "^[0-9]"`)
    echo >> $LOG
    echo "# Container" $1 "has vlans" ${EXISTING[@]} >> $LOG
    for vlan in ${VLANS[@]}; do
        if element_in $vlan "${EXISTING[@]}"; then 
            echo 'Skipping existing vlan ' $vlan ' for container ' $1
        else
            echo 'Adding vlan ' $vlan ' to container ' $1
            add_vlan $1 $vlan
        fi
    done 
}

### MAIN
set_log
time_stamp "# Start"

VMCONTAINERS=`rocks list host membership vm-container | grep -v HOST | awk '{print $1}'`
for vmc in $VMCONTAINERS; do
    # get the part before the colon 
    NAME=${vmc%:*}
    test_vlans $NAME
done
rocks sync config

time_stamp "# End"
