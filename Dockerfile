FROM ruby:2.5.1
COPY container-files /container-files

RUN apt-get update -y \
  && curl -Ls bit.ly/bash-init | bash && curl -Ls bit.ly/bash-ps1 | bash \
  # openssh-server
  && apt-get install -y openssh-server nano htop less \
  && mkdir /var/run/sshd -p \
  && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
  && echo 'export VISIBLE=now' >> /etc/profile \
  # prevent notices on SSH login
  && touch /var/log/lastlog \
  && mkdir -p /root/.ssh \
  && cp /container-files/sshd_config /etc/ssh/sshd_config \
  && cp /container-files/id_rsa.pub /root/ \
  && cat /root/id_rsa.pub >> /root/.ssh/authorized_keys \
  && rm -f /root/id_rsa.pub \
  && chmod og-rwx -R /root/.ssh
  # EO openssh-server

ENV NOTVISIBLE 'in users profile'
EXPOSE 22

# app install
COPY src /code
WORKDIR /code
VOLUME /usr/local/bundle
RUN bundle install

ENTRYPOINT /usr/sbin/sshd -D -e
