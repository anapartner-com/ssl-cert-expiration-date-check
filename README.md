# ssl-cert-check
ssl cert check via bash shell script

This script will use an input file of "fqdn_list.txt" of  FQDN/IP and Ports that have a TLS cert associated.

The output will contain the list of certs (server, intermediate, root ca cert) if they are return by openssl command.
- Some endpoints will only return server and intermediate certs.   Others may return the full chain.
  


****
![image](https://github.com/user-attachments/assets/589fbc75-8a49-43b5-9ab5-94150b47714e)


