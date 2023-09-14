DID=$(xxd -l 8 -c 8 -p < /dev/random);
for ((i=1; i<=$2; i++)); do
IP=$(printf "%d.%d.%d.%d\n" "$((RANDOM % 256 ))" "$((RANDOM % 256 ))" "$((RANDOM % 256 ))" "$((RANDOM % 256 ))");
curl -k --silent --output /dev/null --location 'https://'$1'/api/adjectives' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'' --header 'Content-Type: application/json' \
--data-raw '{
  "name": "worried",
  "email": "bobthesponge@f5.com",
  "Card": "4111 1111 1111 1111",
  "SSN": "123-34-4532"
}';
curl -k --silent --output /dev/null --location 'https://'$1'/api/locations' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'' --header 'Content-Type: application/json' \
--data-raw '{
  "name": "forest",
  "SSN": "187089932132111",
  "Phone": "+33 6 01 02 03 04"
}';

curl -k --silent --output /dev/null --location --request DELETE 'https://'$1'/api/adjectives/4' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'';
curl -k --silent --output /dev/null --location --request DELETE 'https://'$1'/api/locations/4' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'';
curl -k --silent --output /dev/null --location 'https://'$1'/api/adjectives' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'';
curl -k --silent --output /dev/null --location 'https://'$1'/api/locations' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'';
curl -k --silent --output /dev/null --location 'https://'$1'/api/animals' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'';
curl -k --silent --output /dev/null --location 'https://'$1'/api/colors' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'';
curl -k --silent --output /dev/null --location 'https://'$1'/api/locations/1' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'';
curl -k --silent --output /dev/null --location 'https://'$1'/api/locations/2' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'';
curl -k --silent --output /dev/null --location 'https://'$1'/api/locations/3' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'';
curl -k --silent --output /dev/null --location 'https://'$1'/api/adjectives' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'' --header 'Authorization: Basic bWF0dDppbG92ZW1hbWE=';
curl -k --silent --output /dev/null --location 'https://'$1'/api/colors' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'' --header 'apikey: totovalue';
done
