#
# This is the Dockerfile for building a custom CentOS-6-x86_64 container image
# ready to be deployed as an ansible 2.4 (or newer) TARGET HOST.
#
# The goal is to use Docker to quickly spin up multiple CentOS-6 based
# containers and use them as a lab of ansible "ready" target machines.
#
# This container comes equipped with:
#   - an sshd server
#   - an ansible user (with password 'ansible' and sudo enabled)
#   - the python26 intepreter 
#
# New sshd server keys are generated at runtime (on each container run) so, before
# proceeding using ansible, you must edit your ansible.cfg configuration file and
# add "-o UserKnownHostsFile=/dev/null" to the "ssh_args" parameter and set the
# "host_key_checking" parameter to "False" in order to be able to login via ssh.
#
# DO NOT USE IN PRODUCTION - THIS CONTAINER IS INSECURE AND IT IS INTENDED
# FOR TESTING PURPOSE ONLY !!!
#
# This image based on the official Centos 6 base image:
#   https://hub.docker.com/_/centos/
#

FROM centos:centos6

MAINTAINER Alessandro Cavagni "https://hub.docker.com/r/acavagni/" version 1.0

EXPOSE 22

RUN \
  rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6 && \
  yum -y install openssh-server sudo && \
  yum clean all && \
  useradd -c "User for Testing Ansible >= 2.4" -G wheel -m ansible && \
  echo "ansible:ansible" | chpasswd && \
  sed -i \
    -e '/^#UseDNS yes/a\UseDNS no' /etc/ssh/sshd_config && \
  sed -i -r \
    -e '/^session\s+required\s+pam_loginuid.so$/s//#&/' /etc/pam.d/sshd && \
  sed -i -r \
    -e '0,/^Defaults\s*.*$/s//\0\nDefaults:ansible !requiretty/' \
    -e '/^#\s*%wheel.*NOPASSWD:/s/^#\s*//' /etc/sudoers && \
  { \
    echo '#!/bin/bash' && \
    echo "# Generates sshd server keys" && \
    echo "ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''" && \
    echo "ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N ''" && \
    echo '# Start the sshd server' && \
    echo '/usr/sbin/sshd -D'; \
  } >> /opt/start_sshd_server.sh && \
  chmod +x /opt/start_sshd_server.sh

CMD ["/opt/start_sshd_server.sh"]
