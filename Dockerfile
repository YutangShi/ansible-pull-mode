FROM ubuntu:22.04

ENV TZ=Asia/Taipei
ENV DEBIAN_FRONTEND=noninteractive

# 更新套件索引並安裝必要套件（包含 ansible）
RUN apt-get update && \
    apt-get install -y \
      openssh-server sudo curl wget bash-completion openssl \
      software-properties-common git python3-pip && \
    apt-get clean

# 安裝 ansible（官方 repo）
RUN add-apt-repository --yes --update ppa:ansible/ansible && \
    apt-get install -y ansible

# 設定 sshd
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# 建立 docker 使用者，密碼為 docker
RUN useradd --create-home --shell /bin/bash \
      --password $(openssl passwd -1 docker) docker

# 賦予 sudo 權限
RUN echo 'docker ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# 加入 SSH 公鑰
RUN wget https://raw.githubusercontent.com/chusiang/ansible-jupyter.dockerfile/master/files/ssh/id_rsa.pub \
      -O /tmp/authorized_keys && \
      mkdir /home/docker/.ssh && \
      mv /tmp/authorized_keys /home/docker/.ssh/ && \
      chown -R docker:docker /home/docker/.ssh && \
      chmod 644 /home/docker/.ssh/authorized_keys && \
      chmod 700 /home/docker/.ssh

EXPOSE 22

# 安裝 Supercronic 作為 cron 替代品
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.26/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=7a79496cf8ad899b99a719355d4db27422396735

RUN curl -fsSLO "$SUPERCRONIC_URL" \
    && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
    && chmod +x "$SUPERCRONIC" \
    && mv "$SUPERCRONIC" "/usr/local/bin/supercronic"

# 建立必要的目錄
RUN mkdir -p /log

# 啟動 sshd 和 supercronic
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]
