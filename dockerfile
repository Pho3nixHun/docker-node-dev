FROM node:alpine

RUN apk update && apk add bash
RUN apk update && apk add --virtual build-dependenciess build-base gcc make git

RUN apk add --no-cache python && \
    python -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip install --upgrade pip setuptools && \
    rm -r /root/.cache
RUN apk add nano openssh
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