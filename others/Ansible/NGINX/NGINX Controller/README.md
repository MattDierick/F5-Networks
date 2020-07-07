NGINX Controller Install Ansible Role for demo and test
=======================================================

This playbook

* Install Docker CE
* Run a Docker PostGres server
* Run a Docker SMTP server
* Install [NGINX Controller](https://www.nginx.com/products/nginx-controller/).

This playbook can be used in order to install and run NGINX Controller on Ubuntu withjust one **Ansible playbook**

Prerequisites:
--------------

* sudo apt update && sudo apt upgrade && sudo apt install ansible
* ansible-galaxy install nginxinc.nginx_controller_install

Run the playbook:
-----------------

* copy the controller TAR.GZF package into /home/ubuntu
* copy the playbook.yaml in /home/ubuntu
* ansible-playbook playbook.yaml


Et voilà :)