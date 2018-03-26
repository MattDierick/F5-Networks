This is a delegation portal for F5 SSL Orchestrator build with MEAN stack framework (MongoDB, ExpressJS, AngularJS, NodeJs) and Angular Material for UI, providing delegation capacties for some BIGIP features like Datagroup entries.

![alt tag](https://github.com/MattDierick/F5-Networks/blob/master/others/SSLO-PHP-Portal/ScreenShot.png?raw=true)

Portal is providing a delegated interface storing infos in Mongo Database, and pushing modification through BIGIP V12 REST interface.

1) install nodejs tested with 4.4.2 https://nodejs.org/en/download/package-manager/

2) install mongoDB, tested with 3.2.4 https://docs.mongodb.org/manual/tutorial/

optional : install mongo-express globally (https://github.com/mongo-express/mongo-express). Mongo-Express available by GUI at http://fqdn:8081

Modify mongodb express config file (/usr/local/lib/node_modules/mongo-express/config.default.js) :

      mongo = {
      db:       'admin',
      host:     'localhost',
      password: 'YOURPASS',
      port:     27017,
      ssl:      false,
      url:      'mongodb://localhost:27017/admin',
      username: 'admin',
      };


      auth: [
        {
          database: process.env.ME_CONFIG_MONGODB_AUTH_DATABASE || "apmportal",
          username: process.env.ME_CONFIG_MONGODB_AUTH_USERNAME || "admin",
          password: process.env.ME_CONFIG_MONGODB_AUTH_PASSWORD || "YOURPASS",
        },
      ],


      site: {
          // baseUrl: the URL that mongo express will be located at - Remember to add the forward slash at the start and end!
          baseUrl: process.env.ME_CONFIG_SITE_BASEURL || '/',
          cookieKeyName: 'mongo-express',
          cookieSecret:     process.env.ME_CONFIG_SITE_COOKIESECRET   || 'cookiesecret',
          host:             process.env.VCAP_APP_HOST                 || '0.0.0.0',
          port:             process.env.VCAP_APP_PORT                 || 8081,
          requestSizeLimit: process.env.ME_CONFIG_REQUEST_SIZE        || '50mb',
          sessionSecret:    process.env.ME_CONFIG_SITE_SESSIONSECRET  || 'sessionsecret',
          sslCert:          process.env.ME_CONFIG_SITE_SSL_CRT_PATH   || '',
          sslEnabled:       process.env.ME_CONFIG_SITE_SSL_ENABLED    || false,
          sslKey:           process.env.ME_CONFIG_SITE_SSL_KEY_PATH   || '',
        },



3) chmod 755 in node_modules/.bin/ on supervisor files and node-supervisor

3.5 ) Install nodejs-legacy

4) modify apmconfig.json with your apm config infos or you can do it later on throught the portal.

4) start mongodb (sudo service mongod start) and enter mongo shell (type mongo)

  4.1 create apmportal db --> use apmportal

  4.1 create admin user in apmportal db

  db.createUser(
     {
       user: "admin",
       pwd: "pass",
       roles:
         [
           { role: "readWrite", db: "apmportal" }
         ]
     }
  )


5) populate database apmportal :

in mongo deb repository and default mongodb setup directory :

mongoimport --db apmportal --collection users  --drop --file users.json

mongoimport --db apmportal --collection groups  --drop --file groups.json

mongoimport --db apmportal --collection apmconfig  --drop --file apmconfig.json

mongoimport --db apmportal --collection networklocation  --drop --file networklocation.json

6) npm install

7) modify datagroup name in /F5-SSLO-Portal/routes/index.js according your BIGIP configuration. The default is DG_FQDN.

8) npm start in F5-APM-Demo-Portal folder

9) connect to the portal 127.0.0.1:3000

log with admin/admin


To start process in background : nohup mongo-express &
