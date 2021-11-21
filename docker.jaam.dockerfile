FROM openjdk:11 as dev
WORKDIR /var/tmp
COPY releases/JaamSim2021-05.jar .
COPY cafemodel.cfg .
CMD /bin/sh # echo /usr/local/openjdk-11/bin/java -jar ./JaamSim2021-05.jar -h cafemodel.cfg
FROM dev as prod
