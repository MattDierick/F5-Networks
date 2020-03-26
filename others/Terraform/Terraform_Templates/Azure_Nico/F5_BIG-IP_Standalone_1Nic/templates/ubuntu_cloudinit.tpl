#cloud-config
package_upgrade: true
packages:
  - nginx
  - python-pip

runcmd:
  - pip install requests
  - pip install simplejson
  - sed -i '/sites-enabled/aserver { \n listen 127.0.0.1:80;\nserver_name 127.0.0.1;\n\n location /nginx_status {\nstub_status;\n}\n}\n' /etc/nginx/nginx.conf
  - systemctl restart nginx
      