# ssl-cert-check
ssl cert check via bash shell script

This script will use an input file of "fqdn_list.txt" of  FQDN/IP and Ports that have a TLS cert associated.

The output file, certs_info.csv, will contain the list of certs (server, intermediate ca, root ca) if they are return by openssl command.
- Most endpoints will ONLY the return server and intermediate ca certs.   Others may return the full chain with the root ca cert.
- We will expect to see at minimum, one row for the server cert.
- If the other certs (intermediate ca & root ca) are returned, we will see this listed as well as individual rows.   
  


****

![image](https://github.com/user-attachments/assets/17406642-e947-4de9-b8c6-f03ad8768ad6)


  
Example of using openssl and the Authority Information Access (AIA) issuer URL referral to pull the full chain of certs.  
- Only works for certs with an AIA entry
- ./find_issuer_root_ca_cert_from_aia_url.sh niss-ncaiss.dss.mil 443
  
![image](https://github.com/user-attachments/assets/f8d7085d-2264-43a9-acda-c06c747344b5)
