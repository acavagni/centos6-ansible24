# centos6-ansible24 Dockerfile

This is the Dockerfile for building a custom CentOS-6-x86_64 container image
ready to be deployed as an ansible 2.4 (or newer) TARGET HOST.

The goal is to use Docker to quickly spin up multiple CentOS-6 based
containers and use them as a lab of ansible "ready" target machines.

This container comes equipped with:
  - an sshd server
  - an ansible user (with password 'ansible' and sudo enabled)
  - the python26 intepreter 

New sshd server keys are generated at runtime (on each container run) so, before
proceeding using ansible, you must edit your ansible.cfg configuration file and
add "-o UserKnownHostsFile=/dev/null" to the "ssh_args" parameter and set the
"host_key_checking" parameter to "False" in order to be able to login via ssh.

DO NOT USE IN PRODUCTION - THIS CONTAINER IS INSECURE AND IT IS INTENDED
FOR TESTING PURPOSE ONLY !!!

This image based on the official Centos 6 base image:
  https://hub.docker.com/_/centos/

