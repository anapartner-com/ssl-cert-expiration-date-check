# ssl-cert-check
ssl cert check via bash shell script

This script will use an input file of "fqdn_list.txt" of  FQDN/IP and Ports that have a TLS cert associated.

The output will contain the list of certs (server, intermediate ca, root ca) if they are return by openssl command.
- Most endpoints will ONLY the return server and intermediate ca certs.   Others may return the full chain with the root ca cert.
- We will expect to see at minimum, one row for the server cert.
- If the other certs (intermediate ca & root ca) are returned, we will see this listed as well as individual rows.   
  


****
![image](https://github.com/user-attachments/assets/59fb2e1f-2e7a-4c45-a0eb-2ea3426dec5b)

Example of using openssl and the issuer referral to pull the root CA cert   
- issuer_root_ca_cert.sh  niss-ncaiss.dss.mil 443   

![image](https://github.com/user-attachments/assets/3d3186d5-e827-4bf0-842d-ace146226b64)
