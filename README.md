# ssl-cert-check
ssl cert check via bash shell script

This script will use an input file of "fqdn_list.txt" of  FQDN/IP and Ports that have a TLS cert associated.
- Input file may be any protocol protected with a TLS cert, e.g. HTTPS/LDAPS/JDBC(TLS)/etc, over any exposed port.

The output file, certs_info.csv, will contain the list of certs (server, intermediate ca, root ca) if they are return by openssl command.
- Most endpoints will ONLY the return server and intermediate ca certs.   Others may return the full chain with the root ca cert.
- We will expect to see at minimum, one row for the server cert.
- If the other certs (intermediate ca & root ca) are returned, we will see this listed as well as individual rows.

Reminder:   
- Most commercial sites will use an industry root ca cert that is already updated in local workstations cert/key stores or browsers.
- If the site is DOD or an internal commerical site, then the root ca cert is likely not in a local keystore, e.g. java keystore, Operating System (OS) keystore, and will need to be added manually.
- On MS windows: Use  certlm.msc  for  MS Win "Local Machine" keystore
- For Java (Linux/Win):  Use the java keytool binary  (The below example demonstrates adding a custom Active Directory (ADS) root ca cert to the local Java keystore with the default password of "changeit" )  
    keytool -import -alias exchange-lab-public-root-cert -trustcacerts -file exchange-lab-public-root-cert.cer -storetype JKS -keystore /opt/CA/java/jre/lib/security/cacerts -storepass changeit
- Never add the "server.cert" to the keystore, these will/should rotate often as the expiration may be 90 or 365 days.
- You may add the intermediate ca cert(s) to a keystore if the openssl s_client process does not return this cert during the initial query.  Otherwise, avoid adding it, we should only need the final 'root ca' cert.

     
  


****

![image](https://github.com/user-attachments/assets/17406642-e947-4de9-b8c6-f03ad8768ad6)


  
Example of using openssl and the Authority Information Access (AIA) issuer URL referral to pull the full chain of certs.  
- Only works for certs with an AIA entry
- Script updated to avoid data loops where cross-signing may exist between different intermediate ca and root ca certs.
- ./find_issuer_root_ca_cert_from_aia_url.sh niss-ncaiss.dss.mil 443
  
![image](https://github.com/user-attachments/assets/f8d7085d-2264-43a9-acda-c06c747344b5)
