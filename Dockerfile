FROM ghcr.io/linuxserver/baseimage-alpine:3.17

# set version label
ARG BUILD_DATE
ARG VERSION
ARG OPENSSH_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache --upgrade \
    logrotate \
    nano \
    netcat-openbsd \
    sudo && \
  echo "**** install openssh-server ****" && \
  if [ -z ${OPENSSH_RELEASE+x} ]; then \
    OPENSSH_RELEASE=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/v3.17/main/x86_64/APKINDEX.tar.gz" | tar -xz -C /tmp && \
    awk '/^P:openssh-server-pam$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://'); \
  fi && \
  apk add --no-cache \
    openssh-client==${OPENSSH_RELEASE} \
    openssh-server-pam==${OPENSSH_RELEASE} \
    openssh-sftp-server==${OPENSSH_RELEASE} && \
  echo "**** setup openssh environment ****" && \
  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config && \
  sed -i 's/#AllowAgentForwarding yes/AllowAgentForwarding yes/g' /etc/ssh/sshd_config && \
  sed -i 's/AllowTcpForwarding no/AllowTcpForwarding yes/g' /etc/ssh/sshd_config && \
  sed -i 's/GatewayPorts no/GatewayPorts yes/g' /etc/ssh/sshd_config && \
  sed -i 's/X11Forwarding no/X11Forwarding yes/g' /etc/ssh/sshd_config && \
  usermod --shell /bin/bash abc && \
  rm -rf \
    /tmp/*

# add local files
COPY /root /

EXPOSE 2222

VOLUME /config
