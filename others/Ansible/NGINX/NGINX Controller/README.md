NGINX Controller Install Ansible Role for demo and test
=======================================================

This playbook

* Install Docker CE
* Run a Docker PostGreSQL server
* Run a Docker SMTP server
* Install [NGINX Controller](https://www.nginx.com/products/nginx-controller/).

This **playbook** can be used in order to install and run NGINX Controller on Ubuntu with all mandatory elements (DB, SMTP ...)

Prerequisites:
--------------

* 8GB of memory / 16 vcpu / 130 GBB HDD
* sudo apt update && sudo apt -y upgrade && sudo apt install -y ansible
* ansible-galaxy install nginxinc.nginx_controller_install

Run the playbook:
-----------------

* copy the controller TAR.GZ package in /home/ubuntu
* copy the playbook.yaml in /home/ubuntu
* modify the playbook.yaml with the right controller VM ip address and controller-package-file-name.tar.gz
* ansible-playbook playbook.yaml


Et voilà :)