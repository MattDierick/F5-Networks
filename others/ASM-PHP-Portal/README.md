1) install nodejs tested with 4.4.2 https://nodejs.org/en/download/package-manager/

2) npm install in F5-ASM-Demo-Portal folder

3) npm start in F5-ASM-Demo-Portal folder

4) connect to portal 127.0.0.1:3000


ASM configuration is not persitant, will fallback to default when node reboot
change in the asm mgt menu asm config, or edit before /routes/index.js
asm.ip="192.168.142.14";
asm.username="admin";
asm.password="admin";
