#!/bin/bash
#
# Build and install prerequisites for compiling lmserver dependencies
#
. /opt/rocks/share/devel/src/roll/etc/bootstrap-functions.sh

RV=`rocks report version major=1`

if [ "${RV}" == "7" ]; then
    echo "Rocks version 7"
    yum install screen
else
    echo "Rocks version 6"
    #do this only once for roll distro to keep known RPMS in the roll src
    (cd src/RPMS; yumdownloader --resolve --enablerepo base screen.x86_64; \
    rpm -i screen*rpm;\
    )
fi

