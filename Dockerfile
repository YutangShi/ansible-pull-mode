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

# 啟動 sshd
CMD ["/usr/sbin/sshd", "-D"]
