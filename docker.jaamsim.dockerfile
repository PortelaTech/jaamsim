FROM openjdk:11 as dev
ARG IMAGE_TYPE
ENV IMAGE_TYPE ${IMAGE_TYPE}

RUN apt-get update && apt-get install -y x11-apps libxrender1 libxtst6 libxi6 libxext6
RUN rm -rf /tmp/* /usr/share/doc/* /usr/share/info/* /var/tmp/*
RUN useradd -ms /bin/bash user
ENV DISPLAY :0

ADD ./build/jars /var/jars
ADD ./script /var/script
ENV PATH "$PATH:/var/script"
# RUN echo "export PATH=${PATH}" >> /root/.bashrc

ENV TZ Pacific/Auckland
WORKDIR /home
FROM dev as prod

RUN nohup Xvfb :1 -screen 0 1024x768x16 &> /tmp/xvfb.log  &

ENTRYPOINT ["bash"]
