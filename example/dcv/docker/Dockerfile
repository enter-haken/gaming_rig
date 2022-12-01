FROM ubuntu:22.04

ARG user
ARG uid
ARG gid

WORKDIR /tmp

RUN apt-get update \
  && apt-get install -y wget desktop-file-utils libglib2.0-bin libgtk2.0-bin \ 
    libbrotli1 libcairo-gobject2 libcairo-gobject2 libcairo2 libcups2 libegl1 \
    libgstreamer-plugins-base1.0-0 libgstreamer1.0-0 libgtk-3-0 libpango-1.0-0 \ 
    libpangocairo-1.0-0 libpcsclite1 libsqlite3-0 libva-drm2 libva-x11-2 libva2 \
    libvdpau1 libx11-6 gsettings-backend libgl1 \
  && wget https://d1uj6qtbmh3dt5.cloudfront.net/2022.2/Clients/nice-dcv-viewer_2022.2.4653-1_amd64.ubuntu2204.deb 

RUN dpkg -i nice-dcv-viewer_2022.2.4653-1_amd64.ubuntu2204.deb

ENV USERNAME ${user}

RUN useradd -m $USERNAME 

RUN echo "$USERNAME:$USERNAME" | chpasswd && \
    usermod --shell /bin/bash $USERNAME && \
    usermod  --uid ${uid} $USERNAME && \
    groupmod --gid ${gid} $USERNAME || true


USER ${user}

WORKDIR /home/${user}

CMD [ "dcvviewer", "config.dcv" ]
