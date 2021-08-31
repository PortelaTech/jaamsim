#!/bin/sh -xv
#-b or -batch Starts the simulation immediately after the input file has been read, and exits when the run has completed.
# -m or -minimize Minimizes the graphical user interface, allowing the simulation to run slightly faster when visualizations are not required (for instance, in overnight simulation runs).
# -s or -script Directs JaamSim to accept configuration file inputs piped to JaamSim through standard-in and to direct its outputs specified by the RunOutputList keyword to standard-out. The .jar file (jaamsim.jar) must be used with this feature, not the executable (jaamsim.exe).
# -h or -headless Runs JaamSim without the graphical user interface so that it can be executed on a server that has no graphics capability. Batch mode (-b) is set automatically with this option.
# -sg or -safe_graphics Instructs JaamSim to use only the simplest OpenGL commands for compatibility with older graphics processors.
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
java -jar ${JARSDIR}/JaamSim2021-04.jar $* -h



