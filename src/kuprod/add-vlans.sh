#!/bin/bash

contains() {
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++)) {
        if [ "${!i}" == "${value}" ]; then
            echo "y"
            return 0
        fi
    }
    echo "n"
    return 1
}

### Add missing vlans to vm-container
add_vlans () {
    rocks add host interface $1 vlan$2
    rocks set host interface name $1 vlan$2 vm-container-0-0
    rocks set host interface subnet $1 vlan$2 private
    rocks set host interface vlan $1 vlan$2 $2
}

### Add missing vlans to vm-container ($1)
test_vlans () {
    VLANS=(1 2 3 4 5 6 7)
    echo one: $1
    echo ${VLANS[@]}
    EXISTING=`rocks list host interface $NAME | grep -v VLAN | awk '{print $8}'`
    for vlan in ${VLANS[@]}; do
        DOIT=$(contains "${EXISTING[@]}" $vlan)
        echo vlan: $vlan container: $1 DOIT: $DOIT
        if [ $(contains "${EXISTING[@]}" $vlan) == "n" ]; then
            echo Adding vlan $vlan to $1
        fi
    done
}

### MAIN
VMCS=`rocks list host membership vm-container | grep -v HOST | awk '{print $1}'`
for vmc in $VMCS; do
    # get the part before the colon 
    NAME=${vmc%:*}
    echo name: $NAME
    test_vlans $NAME
done


# /opt/rocks/bin/rocks add host interface vm-container-0-0 vlan2
# /opt/rocks/bin/rocks set host interface name vm-container-0-0 vlan2 vm-container-0-0
# /opt/rocks/bin/rocks set host interface subnet vm-container-0-0 vlan2 private
# /opt/rocks/bin/rocks set host interface vlan vm-container-0-0 vlan2 2:q

# rocks sync config
