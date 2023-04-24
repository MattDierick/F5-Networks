for ((i=1; i<=$1; i++)); do
sh tc.sh arcadia-re.emea-ent.f5demos.com 50;
sh tc.sh arcadia-re-ce.emea-ent.f5demos.com 50;
sh tc.sh sentence.emea-ent.f5demos.com 50;
sh tc.sh api-sentence.emea-ent.f5demos.com 50;
sh tc-http.sh azure-f5xc-ce.westeurope.cloudapp.azure.com 50;
done