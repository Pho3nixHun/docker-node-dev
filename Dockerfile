FROM node:alpine

RUN apk update && apk add --no-cache --virtual build-dependenciess build-base gcc make git nano openssh python wget ca-certificates bash libstdc++

# Get and install glibc for alpine
ARG APK_GLIBC_VERSION=2.29-r0
ARG APK_GLIBC_FILE="glibc-${APK_GLIBC_VERSION}.apk"
ARG APK_GLIBC_BIN_FILE="glibc-bin-${APK_GLIBC_VERSION}.apk"
ARG APK_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${APK_GLIBC_VERSION}"
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && wget "${APK_GLIBC_BASE_URL}/${APK_GLIBC_FILE}"       \
    && apk --no-cache add "${APK_GLIBC_FILE}"               \
    && wget "${APK_GLIBC_BASE_URL}/${APK_GLIBC_BIN_FILE}"   \
    && apk --no-cache add "${APK_GLIBC_BIN_FILE}"           \
    && rm glibc-*

RUN python -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip install --upgrade pip setuptools && \
    rm -r /root/.cache

RUN echo 'root:toor' | chpasswd
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
RUN echo "HostKey /etc/ssh/ssh_host_rsa_key" >> /etc/ssh/sshd_config

EXPOSE 22

USER node
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
RUN npm i -g typescript gulp polymer-cli

ENV PATH="/home/node/.npm-global/bin:${PATH}"
WORKDIR /usr/src/app

USER root
CMD ["/usr/sbin/sshd", "-p", "22", "-h", "/etc/ssh/ssh_host_rsa_key", "-D"]
#CMD /bin/bash