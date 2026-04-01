DID=$(xxd -l 8 -c 8 -p < /dev/random);
for ((i=1; i<=$2; i++)); do
IP=$(printf "%d.%d.%d.%d\n" "$((RANDOM % 256 ))" "$((RANDOM % 256 ))" "$((RANDOM % 256 ))" "$((RANDOM % 256 ))");
curl -k --silent --output /dev/null --location 'https://'$1'/api/animals' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'' --header 'Content-Type: application/json';
curl -k --silent --output /dev/null --location 'https://'$1'/api/animals' --header 'Authorization: Basic dXNlcjE6aWxvdmVmNQ==' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'' --header 'Content-Type: application/json';

curl -k --silent --output /dev/null --location 'https://'$1'/api/locations/100' --header 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3Mzk4ODIzNTUsImV4cCI6MTc0MzQ4MjM1NSwidXNlcl9pZCI6IlJMMEc2YzZFIiwicm9sZSI6InV.3dtm-57SlVNFi5h61eV0h1ih2fs1Voe9_azn_Fdgd1g' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'';
curl -k --silent --output /dev/null --location 'https://'$1'/api/locations/101' --header 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3Mzk4ODIzNTUsImV4cCI6MTc0MzQ4MjM1NSwidXNlcl9pZCI6IlJMMEc2YzZFIiwicm9sZSI6InV.3dtm-57SlVNFi5h61eV0h1ih2fs1Voe9_azn_Fdgd1g' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'';
curl -k --silent --output /dev/null --location 'https://'$1'/api/locations/1' --header 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImtpZCI6IjAwMDEifQ.eyJpYXQiOjE3Mzk4ODIzNTUsImV4cCI6MjM2MjA2MDgwMCwidXNlcl9pZCI6IkRDSEhDTFlBIiwicm9sZSI6InVzZXIifQ.sBrlMnJgpInkMkQG3rl29IktVCC4Xx2NPC0oKKlK9YQ' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'';
curl -k --silent --output /dev/null --location 'https://'$1'/api/locations/2' --header 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImtpZCI6IjAwMDEifQ.eyJpYXQiOjE3Mzk4ODIzNTUsImV4cCI6MjM2MjA2MDgwMCwidXNlcl9pZCI6IkFaUW83OUlXIiwicm9sZSI6ImFkbWluIn0.snQII46hjaHM8w7ZYAA-IQk_9uQi6O__USSSa4dJ84E' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'';
curl -k --silent --output /dev/null --location 'https://'$1'/api/locations/3' --header 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImtpZCI6IjAwMDEifQ.eyJpYXQiOjE3Mzk4ODIzNTUsImV4cCI6MjM2MjA2MDgwMCwidXNlcl9pZCI6ImZlUjlOS3RVIiwicm9sZSI6ImFkbWluIn0.I8Vup-1EPMlA9Zobt_dQuH4zRQtVbKlQ_4-UwAiQMWs' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'';
curl -k --silent --output /dev/null --location 'https://'$1'/api/locations/4' --header 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImtpZCI6IjAwMDEifQ.eyJpYXQiOjE3Mzk4ODIzNTUsImV4cCI6MjM2MjA2MDgwMCwidXNlcl9pZCI6IkhYSkxMUkVHIiwicm9sZSI6InVzZXIifQ.nNcD8wmMnuNDWGs1ElaOeA78iT2NAK1zTmjhOjT1ZmE' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'';


curl -k --silent --output /dev/null --location 'https://'$1'/api/colors' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'' --header 'Content-Type: application/json';
curl -k --silent --output /dev/null --location 'https://'$1'/api/colors' --header 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImtpZCI6IjAwMDEifQ.eyJhdWQiOiJ3d3cuZXhhbXBsZS5jb20iLCJzdWIiOiJqcm9ja2V0QGV4YW1wbGUuY29tIiwiRmlyc3QgTmFtZSI6IkJvYiIsIkxhc3QgTmFtZSI6IlRoZVNwb25nZSIsIkVtYWlsIjoiYm9iQHNwb25nZS5jb20ifQ.eQUXK369aFJ3FclFgFMdWekGfQlmg2GcXT5FA3FieKw' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'' --header 'Content-Type: application/json';

curl -k --silent --output /dev/null --location 'https://'$1'/api/adjectives' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'' --header 'Content-Type: application/json';
curl -k --silent --output /dev/null --location 'https://'$1'/api/adjectives' --header 'Authorization: apikey My_API_Key' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'' --header 'Content-Type: application/json';
done