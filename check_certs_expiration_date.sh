#!/bin/bash
######################################################################################
#   Name:  check_certs_exipration_date.sh
#   Goal:  Query via openssl s_client process to sort and find the expiration date of 
#          each remote hosts' TLS servers certs and if possible, intermediate ca & root ca certs.
#          Return subject name and serial number of each cert.
#
#  ANA 12/2024
######################################################################################


# Define input and output files
INPUT_FILE="fqdn_list.txt"  # Input file with fqdn:port format (one per line)
OUTPUT_FILE="certs_info.csv" # Output CSV file

# Check if the input file exists
if [[ ! -f $INPUT_FILE ]]; then
    echo "Input file '$INPUT_FILE' not found."
    exit 1
fi

# Initialize the output CSV file with headers
#echo "FQDN,Port,Expiration Date (YYYYMMDD),Expiration Date,Serial Number,Subject Name" > "$OUTPUT_FILE"
echo "Expiration (YYYYMMDD),FQDN,Port,Expiration Date (Org),Serial Number,Subject Name" > "$OUTPUT_FILE"

# Read the input file line by line
while IFS= read -r line; do
    # Split FQDN and port
    FQDN=$(echo "$line" | cut -d: -f1)
    PORT=$(echo "$line" | cut -d: -f2)

    if [[ -z "$FQDN" || -z "$PORT" ]]; then
        echo "Skipping invalid line: $line"
        continue
    fi

    # Fetch the certificate using openssl
    echo | openssl s_client -connect "$FQDN:$PORT" -showcerts 2>/dev/null > "temp_output.txt"

    if [[ $? -ne 0 ]]; then
        echo "Failed to connect to $FQDN:$PORT"
        rm -f temp_output.txt
        continue
    fi

    # Extract the certificates from the output
    awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' temp_output.txt > "temp_cert.pem"

    # Check if the file has valid certificates
    if [[ ! -s temp_cert.pem ]]; then
        echo "No valid certificates found for $FQDN:$PORT"
        rm -f temp_output.txt temp_cert.pem
        continue
    fi

    # Split certificates into separate files
    csplit -s -z -f cert_part_ temp_cert.pem '/-----BEGIN CERTIFICATE-----/' '{*}'

    for CERT_FILE in cert_part_*; do
        # Extract expiration date, subject name, and serial number
        EXPIRATION_DATE=$(openssl x509 -enddate -noout -in "$CERT_FILE" 2>/dev/null | cut -d= -f2)
        SUBJECT_NAME=$(openssl x509 -subject -noout -in "$CERT_FILE" 2>/dev/null | sed 's/subject= //')
        SERIAL_NUMBER=$(openssl x509 -serial -noout -in "$CERT_FILE" 2>/dev/null | cut -d= -f2)

        if [[ -n "$EXPIRATION_DATE" && -n "$SUBJECT_NAME" && -n "$SERIAL_NUMBER" ]]; then
            # Convert expiration date to YYYYMMDD format
            FORMATTED_DATE=$(date -d "$EXPIRATION_DATE" +"%Y%m%d" 2>/dev/null)

            # Append data to CSV file
            #echo "$FQDN,$PORT,$FORMATTED_DATE,$EXPIRATION_DATE,$SERIAL_NUMBER,\"$SUBJECT_NAME\"" >> "$OUTPUT_FILE"
            echo "$FORMATTED_DATE,$FQDN,$PORT,$EXPIRATION_DATE,$SERIAL_NUMBER,\"$SUBJECT_NAME\"" >> "$OUTPUT_FILE"
        else
            echo "Could not parse certificate details for $FQDN:$PORT"
        fi
    done

    # Clean up temporary files
    rm -f temp_output.txt temp_cert.pem cert_part_*

done < "$INPUT_FILE"

echo "Certificate information saved to $OUTPUT_FILE"
