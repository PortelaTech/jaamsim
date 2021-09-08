#!/bin/sh -xv
# -m or -minimize Minimizes the graphical user interface, allowing the simulation to run slightly faster when visualizations are not required (for instance, in overnight simulation runs).
# -h or -headless Runs JaamSim without the graphical user interface so that it can be executed on a server that has no graphics capability. Batch mode (-b) is set automatically with this option.
# It is also possible to load two or more configuration files into a single model using the following command:
#     JaamSim.exe config1.cfg config2.cfg -tags
#     JaamSim.exe run1.cfg -b
#     JaamSim.exe run2.cfg -b
#     program1.exe | java -jar JaamSim.jar config.cfg -s -b | program2.exe
# java -jar JaamSim.jar config1.cfg config2.cfg -tags

if [ -d /var/jars ] ; then
    JARSDIR=/var/jars
else
    JARSDIR=./build/jars
fi
JARFILE=JaamSim2021-04.jar # JaamSim2016-13.jar JaamSim2021-04-bare.jar

echo PATH=${PATH}
export IS_HEADLESS=1
java -jar ${JARSDIR}/${JARFILE} $1 -h -m -b
