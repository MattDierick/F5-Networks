#!/bin/bash

# Base URL for the API endpoint
BASE_URL='https://api-sentence.emea-ent.f5demos.com/api/animals/'

# Read JWT tokens into an array using a while loop (portable approach)
JWT_LIST=()
while IFS= read -r line; do
  JWT_LIST+=("$line")
done < jwts.txt

# Check if there are any JWT tokens in the file
if [ ${#JWT_LIST[@]} -eq 0 ]; then
  echo "Error: No JWT tokens found in jwts.txt"
  exit 1
fi

# Total number of requests
TOTAL_REQUESTS=40

# Generate and send traffic
for ((i=0; i<TOTAL_REQUESTS; i++)); do
  # Generate dynamic RESOURCE_ID (1 to 40)
  RESOURCE_ID=$((i + 1))

  # Generate dynamic SRC_IP (121.78.141.1 to 121.78.141.40)
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
