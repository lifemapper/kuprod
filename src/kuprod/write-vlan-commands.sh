#!/bin/bash

### time
time_stamp () {
    echo $1 `/bin/date` >> $SCRIPT
}

### create logfile
set_log() {
    SCRIPT=/tmp/`/bin/basename $0`.sh
    rm $SCRIPT
    touch $SCRIPT
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
write_vlan () {
    echo "rocks add host interface" $1 "vlan"$2 >> $SCRIPT
    echo "rocks set host interface name" $1 "vlan"$2 $1 >> $SCRIPT
    echo "rocks set host interface subnet" $1 "vlan"$2 "private" >> $SCRIPT
    echo "rocks set host interface vlan" $1 "vlan"$2 $2 >> $SCRIPT
    echo >> $SCRIPT
}

### Add missing vlans to vm-container ($1)
### args: container
add_vlan_commands () {
    VLANS=(1 2 3 4 5 6 7)
    EXISTING=(`rocks list host interface $NAME | awk '{print $8}' | grep -E "^[0-9]"`)
    echo >> $SCRIPT
    echo "# Container" $1 "has vlans" ${EXISTING[@]} >> $SCRIPT
    for vlan in ${VLANS[@]}; do
        if element_in $vlan "${EXISTING[@]}"; then 
            echo 'Skipping existing vlan ' $vlan ' for container ' $1
        else
            echo 'Adding vlan ' $vlan ' to container ' $1
            write_vlan $1 $vlan
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
    add_vlan_commands $NAME
done
echo "rocks sync config" >> $SCRIPT

time_stamp "# End"
