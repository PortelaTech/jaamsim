#!/bin/sh -xv

if [ -d /var/jars ] ; then
    JARSDIR=/var/jars
else
    JARSDIR=./build/jars
fi
java -jar ${JARSDIR}/JaamSim2021-04.jar $*

