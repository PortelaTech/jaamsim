jar tvf ./target/jammsim-1.0-SNAPSHOT.jar  | awk '{print $8}' | sort > /tmp/mvn.txt
jar tvf ./build/jars/JaamSim2021-04.jar   | awk '{print $8}' | sort > /tmp/ant.txt
diff /tmp/mvn.txt /tmp/ant.txt

