FROM debian:8
MAINTAINER Jens Erat <email@jenserat.de>

# Unset SUID bits where not needed
RUN for i in `find / -perm +6000 -type f 2>/dev/null`; do chmod a-s $i; done

ENV VERSION=0.6.1 \
    SHA256SUM=ab4d8341d1c14e753914b68b3ec0c9b169c361123dcef541ff34444b1e54812b

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ` # Fetch gogs ` \
      curl ca-certificates unzip \
      openssh-server \
      ` # gogs dependencies as listed in Debian package ` \
      mysql-common libpq5 libsqlite3-0 openssl libxml2 libxslt1.1 libreadline5 libreadline6 libssl1.0.0 libmysqlclient18 libevent-2.0-5 libevent-core-2.0-5 libevent-extra-2.0-5 git \
      supervisor && \
    ` # Fetch gogs ` \
    cd /opt && \
    curl -LO https://github.com/gogits/gogs/releases/download/v${VERSION}/linux_amd64.zip && \
    echo "${SHA256SUM}  linux_amd64.zip" | sha256sum --check && \
    unzip linux_amd64.zip && \
    ` # Prepare sshd ` \
    rm -f /etc/ssh/ssh_host_*_key_* && \
    mkdir /var/run/sshd && \
    ` # add git user ` \
    adduser --system --home /srv --no-create-home --disabled-password --shell /bin/bash --gecos "" --uid 3000 git && \
    ` # Clean up ` \
    apt-get clean && rm -rf \
      /opt/linux_amd64.zip \
      /var/lib/apt/lists/* \
      /tmp/* \
      /var/tmp/*
 
WORKDIR /opt/gogs
 
# 22:               SSH
# 3000:             HTTP
EXPOSE 22 3000

# /opt/gogs/data:   various uploaded files (avaters, attachments, ...)
# /opt/gogs/custom: custom configuration
# /home/git:        repositories, authorized keys
# /etc/ssh:         sshd configuration and host keys
VOLUME /opt/gogs/data /opt/gogs/custom /srv /etc/ssh
 
COPY supervisord.conf /etc/supervisor/
COPY run.sh /opt/

CMD ["/opt/run.sh"]
