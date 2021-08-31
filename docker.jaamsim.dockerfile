FROM openjdk:11 as dev
ARG IMAGE_TYPE
ENV IMAGE_TYPE ${IMAGE_TYPE}
ADD ./build/jars /var/jars
ADD ./script/run-jaamsim.sh /run-jaamsim.sh
EXPOSE 8080
ENV TZ Pacific/Auckland
WORKDIR /home
FROM dev as prod
CMD ["bash"] 
