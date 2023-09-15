DID=$(xxd -l 8 -c 8 -p < /dev/random);
for ((i=1; i<=$2; i++)); do
IP=$(printf "%d.%d.%d.%d\n" "$((RANDOM % 256 ))" "$((RANDOM % 256 ))" "$((RANDOM % 256 ))" "$((RANDOM % 256 ))");
curl  -k --silent --output /dev/null --location 'https://'$1'/api/locations' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'' --header 'Content-Type: application/json';
curl  -k --silent --output /dev/null --location 'https://'$1'/api/locations' --header 'Authorization: Basic dXNlcjE6aWxvdmVmNQ==' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'' --header 'Content-Type: application/json';

curl  -k --silent --output /dev/null --location 'https://'$1'/api/animals' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'' --header 'Content-Type: application/json';
curl  -k --silent --output /dev/null --location 'https://'$1'/api/animals' --header 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImtpZCI6IjAwMDEifQ.eyJhdWQiOiJ3d3cuZXhhbXBsZS5jb20iLCJzdWIiOiJqcm9ja2V0QGV4YW1wbGUuY29tIiwiRmlyc3QgTmFtZSI6IkJvYiIsIkxhc3QgTmFtZSI6IlRoZVNwb25nZSIsIkVtYWlsIjoiYm9iQHNwb25nZS5jb20ifQ.eQUXK369aFJ3FclFgFMdWekGfQlmg2GcXT5FA3FieKw' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'' --header 'Content-Type: application/json';

curl  -k --silent --output /dev/null --location 'https://'$1'/api/colors' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'' --header 'Content-Type: application/json';
curl  -k --silent --output /dev/null --location 'https://'$1'/api/colors' --header 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImtpZCI6IjAwMDEifQ.eyJhdWQiOiJ3d3cuZXhhbXBsZS5jb20iLCJzdWIiOiJqcm9ja2V0QGV4YW1wbGUuY29tIiwiRmlyc3QgTmFtZSI6IkJvYiIsIkxhc3QgTmFtZSI6IlRoZVNwb25nZSIsIkVtYWlsIjoiYm9iQHNwb25nZS5jb20ifQ.eQUXK369aFJ3FclFgFMdWekGfQlmg2GcXT5FA3FieKw' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'' --header 'Content-Type: application/json';

curl  -k --silent --output /dev/null --location 'https://'$1'/api/adjectives' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'' --header 'Content-Type: application/json';
curl -k --silent --output /dev/null --location 'https://'$1'/api/adjectives' --header 'Authorization: apikey My_API_KEY' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'' --header 'Content-Type: application/json';
done
