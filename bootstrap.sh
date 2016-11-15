#!/bin/bash
#
# Build and install prerequisites for compiling lmserver dependencies
#
. /opt/rocks/share/devel/src/roll/etc/bootstrap-functions.sh

#do this only once for roll distro to keep known RPMS in the roll src
(cd src/RPMS; 
yumdownloader --resolve --enablerepo base screen.x86_64; \
)


