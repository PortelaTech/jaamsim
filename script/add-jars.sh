#!/bin/sh

rm /tmp/pom.deps

for JARFILE in `ls jar`; do
    ARTIFACT_ID=$(basename ${JARFILE} | perl -pe 's/\.[^.]*$//')
    mvn deploy:deploy-file \
    -DgroupId=jaamsim \
    -DartifactId=${ARTIFACT_ID} \
    -Dversion=0.0.1 \
    -Durl=file:./.local-maven-repo/ \
    -DrepositoryId=local-maven-repo \
    -DupdateReleaseInfo=true \
    -Dfile=jar/${JARFILE}
    echo "<dependency><groupId>jaamsim</groupId><artifactId>${ARTIFACT_ID}</artifactId><version>0.0.1</version></dependency>" >> /tmp/pom.deps
done
cat /tmp/pom.deps
                
