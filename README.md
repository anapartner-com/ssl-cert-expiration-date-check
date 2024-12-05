# ssl-cert-check
ssl cert check via bash shell script

This script will use an input file of "fqdn_list.txt" of  FQDN/IP and Ports that have a TLS cert associated.

The output file, certs_info.csv, will contain the list of certs (server, intermediate ca, root ca) if they are return by openssl command.
- Most endpoints will ONLY the return server and intermediate ca certs.   Others may return the full chain with the root ca cert.
- We will expect to see at minimum, one row for the server cert.
- If the other certs (intermediate ca & root ca) are returned, we will see this listed as well as individual rows.   
  


****
![image](https://github.com/user-attachments/assets/8497e310-2fc4-41f3-be99-20f8a92d04ab)

  
Example of using openssl and the Authority Information Access (AIA) issuer URL referral to pull the full chain of certs.   
- ./find_issuer_root_ca_cert_from_aia_url.sh niss-ncaiss.dss.mil 443

![image](https://github.com/user-attachments/assets/3d3186d5-e827-4bf0-842d-ace146226b64)
