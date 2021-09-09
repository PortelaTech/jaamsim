#!/bin/sh -xv
if [ -d /var/jars ] ; then
    JARSDIR=/var/jars
else
    JARSDIR=./build/jars
fi
JARFILE=JaamSim2021-04.jar # JaamSim2016-13.jar JaamSim2021-04-bare.jar

echo PATH=${PATH}
export IS_HEADLESS=1
java -jar ${JARSDIR}/${JARFILE} $1 -h -m -b
