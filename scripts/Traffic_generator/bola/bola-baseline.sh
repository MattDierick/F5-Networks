#!/bin/bash

# Base URL for the API endpoint
BASE_URL='https://api-sentence-auth.emea-ent.f5demos.com/api/locations/'

# Read JWT tokens into an array using a while loop (portable approach)
JWT_LIST=()
while IFS= read -r line; do
  JWT_LIST+=("$line")
done < /home/azureuser/bola/tokens.txt

# Check if there are any JWT tokens in the file
if [ ${#JWT_LIST[@]} -eq 0 ]; then
  echo "Error: No JWT tokens found in tokens.txt"
  exit 1
fi

# Total number of requests
TOTAL_REQUESTS=70

# Generate and send traffic
for ((i=5; i<TOTAL_REQUESTS; i++)); do
  # Generate dynamic RESOURCE_ID (5 to 75)
  RESOURCE_ID=$((i + 1))

  # Generate dynamic SRC_IP (121.78.141.1 to 121.78.141.60)
  SRC_IP="121.78.141.$((i + 1))"

  # Use the corresponding JWT token (loop around if more requests than tokens)
  JWT_INDEX=$((i % ${#JWT_LIST[@]}))
  JWT=${JWT_LIST[$JWT_INDEX]}

  # Construct and execute the curl command
  COMMAND="curl -k -H 'Authorization: Bearer $JWT' -H 'xff: $SRC_IP' '${BASE_URL}${RESOURCE_ID}'"
  echo "---------------------------------------------------------------------------------------------------------"
  echo $COMMAND
  echo "---------------------------------------------------------------------------------------------------------"
  eval $COMMAND
  echo
done