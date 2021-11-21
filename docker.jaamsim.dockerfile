FROM openjdk:11 as dev
ARG IMAGE_TYPE
ENV IMAGE_TYPE ${IMAGE_TYPE}
ADD ./releases /var/releases
ADD ./build/jars /var/jars
ADD ./script /var/script
ENV PATH "$PATH:/var/script"
# RUN echo "export PATH=${PATH}" >> /root/.bashrc
ENV TZ Pacific/Auckland
WORKDIR /home
FROM dev as prod
# RUN nohup Xvfb :1 -screen 0 1024x768x16 &> /tmp/xvfb.log  &
ENTRYPOINT ["bash"]
