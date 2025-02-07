#!/bin/sh
for ((j=1; j<=5; j++)); do
bash tc.sh arcadia-re.emea-ent.f5demos.com 50;
bash api.sh api-sentence.emea-ent.f5demos.com 50;
bash tc.sh arcadia-re-ce.emea-ent.f5demos.com 50;
bash tc.sh api-sentence.emea-ent.f5demos.com 50;
bash tc-http.sh azure-f5xc-ce.westeurope.cloudapp.azure.com 50;
bash api-auth.sh api-sentence-auth.emea-ent.f5demos.com 50;
done