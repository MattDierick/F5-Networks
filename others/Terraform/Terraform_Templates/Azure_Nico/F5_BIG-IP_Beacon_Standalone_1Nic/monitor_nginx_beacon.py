import requests
from requests.exceptions import HTTPError
import socket
import json

F5_BEACON_TOKEN = "##TEST##"

F5_BEACON_URL = 'https://ingestion.ovr.prd.f5aas.com:50443/beacon/v1/ingest'
headers = {'Content-type': 'application/json', 'Accept': 'text/plain'}

for url in ['http://localhost/']:
    try:
        response = requests.get(url)

        # If the response was successful, no Exception will be raised
        response.raise_for_status()
    except HTTPError as http_err:
        print('HTTP error occurred:',http_err)  # Python 3.6
	beacon_payload = {
        	"sourceName": str(socket.gethostname()),
        	"sourceDescription": "NGINX Web Server",
        	"token": str(F5_BEACON_TOKEN),
        	"components": [{
                	"name": "nginx_status",
                	"description": "nginx web server status",
                	"healthStatus": "CRITICAL",
                	"healthStatusReason": str(http_err)[18:60]
        	}]
	}
	print str(beacon_payload)
    	beacon_request = requests.post(F5_BEACON_URL, data = json.dumps(beacon_payload), headers=headers)
    except Exception as err:
        print('Other error occurred:',err) 
    	beacon_payload = {
                "sourceName": str(socket.gethostname()),
                "sourceDescription": "NGINX Web Server",
                "token": str(F5_BEACON_TOKEN),
		"components": [{
                        "name": "nginx_status",
                        "description": "nginx web server status",
                        "healthStatus": "CRITICAL",
                        "healthStatusReason": str(err)[46:80]
                }]
        }
        print str(beacon_payload)
        beacon_request = requests.post(F5_BEACON_URL, data = json.dumps(beacon_payload), headers=headers)
	print (str(beacon_request.json()))
    else:
        print('Success!')
	beacon_payload = {
                "sourceName": str(socket.gethostname()),
                "sourceDescription": "NGINX Web Server",
                "token": str(F5_BEACON_TOKEN),
		"components": [{
                        "name": "nginx_status",
                        "description": "nginx web server status",
                        "healthStatus": "AVAILABLE",
                        "healthStatusReason": "monitor successful"
                }]
        }
        print str(beacon_payload)
        beacon_request = requests.post(F5_BEACON_URL, data = json.dumps(beacon_payload), headers=headers)
