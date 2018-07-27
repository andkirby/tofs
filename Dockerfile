FROM ruby:2.5.1
COPY container-files /
RUN curl -Ls bit.ly/bash-init | bash && curl -Ls bit.ly/bash-ps1 | bash \
  && apt install -y openssh-server \
  && mkdir /var/run/sshd -p \
  && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
  && echo 'export VISIBLE=now' >> /etc/profile \
  # prevent notices on SSH login
  && touch /var/log/lastlog \
  && cp /container-files/sshd_config /etc/ssh/sshd_config \
  && cp /container-files/id_rsa.pub /root/ \
  && cat /root/id_rsa.pub >> /root/.ssh/authorized_keys \
  && rm -f /root/id_rsa.pub \
  && chmod og-rwx -R /root/.ssh \
  && true

ENV NOTVISIBLE 'in users profile'
EXPOSE 22

ENTRYPOINT /usr/sbin/sshd -D -e
