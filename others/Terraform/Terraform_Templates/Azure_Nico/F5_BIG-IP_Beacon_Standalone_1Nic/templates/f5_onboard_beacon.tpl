#!/bin/bash

# BIG-IPS ONBOARD SCRIPT

LOG_FILE=${onboard_log}

if [ ! -e $LOG_FILE ]
then
     touch $LOG_FILE
     exec &>>$LOG_FILE
else
    #if file exists, exit as only want to run once
    exit
fi

exec 1>$LOG_FILE 2>&1

# CHECK TO SEE NETWORK IS READY
CNT=0
while true
do
  STATUS=$(curl -s -k -I example.com | grep HTTP)
  if [[ $STATUS == *"200"* ]]; then
    echo "Got 200! VE is Ready!"
    break
  elif [ $CNT -le 6 ]; then
    echo "Status code: $STATUS  Not done yet..."
    CNT=$[$CNT+1]
  else
    echo "GIVE UP..."
    break
  fi
  sleep 10
done

### DOWNLOAD ONBOARDING PKGS
# Could be pre-packaged or hosted internally

#Loading variables from Terraform

DO_URL='${DO_URL}'
DO_FN=$(basename "$DO_URL")
AS3_URL='${AS3_URL}'
AS3_FN=$(basename "$AS3_URL")
TS_URL='${TS_URL}'
TS_FN=$(basename "$TS_URL")
F5_BEACON_TOKEN='${F5_BEACON_TOKEN}'
ADMIN_PWD='${ADMIN_PASSWD}'

mkdir -p ${libs_dir}

echo -e "\n"$(date) "Download Declarative Onboarding Pkg"
curl -L -o ${libs_dir}/$DO_FN $DO_URL

echo -e "\n"$(date) "Download AS3 Pkg"
curl -L -o ${libs_dir}/$AS3_FN $AS3_URL

echo -e "\n"$(date) "Download TS Pkg"
curl -L -o ${libs_dir}/$TS_FN $TS_URL

sleep 5

# Copy the RPM Pkg to the file location
cp ${libs_dir}/*.rpm /var/config/rest/downloads/

# Install Declarative Onboarding Pkg
DATA="{\"operation\":\"INSTALL\",\"packageFilePath\":\"/var/config/rest/downloads/$DO_FN\"}"
echo -e "\n"$(date) "Install DO Pkg"
restcurl -X POST "shared/iapp/package-management-tasks" -d $DATA

sleep 5 

# Install AS3 Pkg
DATA="{\"operation\":\"INSTALL\",\"packageFilePath\":\"/var/config/rest/downloads/$AS3_FN\"}"
echo -e "\n"$(date) "Install AS3 Pkg"
restcurl -X POST "shared/iapp/package-management-tasks" -d $DATA

sleep 5 

# Install TS Pkg
DATA="{\"operation\":\"INSTALL\",\"packageFilePath\":\"/var/config/rest/downloads/$TS_FN\"}"
echo -e "\n"$(date) "Install TS Pkg"
restcurl -X POST "shared/iapp/package-management-tasks" -d $DATA

sleep 5

tmsh modify auth user admin password $ADMIN_PWD

tmsh save sys config

sleep 40

echo -e "registering device with F5 Beacon"

DATA="{ \"class\":\"Telemetry\",\"controls\":{ \"class\":\"Controls\",\"logLevel\":\"debug\"},\"Poller\":{ \"class\":\"Telemetry_System_Poller\",\"interval\":60,\"enable\":true,\"trace\":false,\"allowSelfSignedCert\":false, \"host\":\"localhost\",\"port\":8100,\"protocol\":\"http\"},\"Beacon_Consumer\":{ \"class\":\"Telemetry_Consumer\",\"type\":\"Generic_HTTP\",\"host\":\"ingestion.ovr.prd.f5aas.com\",\"protocol\":\"https\",\"port\":50443,\"path\":\"/beacon/v1/ingest-telemetry-streaming\",\"method\":\"POST\",\"enable\":true,\"trace\":false,\"headers\":[ { \"name\":\"grpc-metadata-x-f5-ingestion-token\",\"value\":\"\`>@/passphrase\`\"}],\"passphrase\":{ \"cipherText\":\"$F5_BEACON_TOKEN\"}},\"schemaVersion\":\"1.0.0\"}"

echo -e $DATA > /var/tmp/TS_Beacon_declaration.json 

#issues with restcurl to process this json payload ... to be investigated
#we use port 8443 since we deployed a 1NIC interface BIG-IP

curl -sk -u admin:$ADMIN_PWD -H "Content-type: Application/json" -X POST "https://127.0.0.1:8443/mgmt/shared/telemetry/declare" -d @/var/tmp/TS_Beacon_declaration.json

rm /var/tmp/TS_Beacon_declaration.json