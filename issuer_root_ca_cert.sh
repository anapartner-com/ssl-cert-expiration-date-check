#!/bin/bash

# Input: FQDN and PORT
FQDN=$1
PORT=$2
ROOT_CA_OUTPUT="root_ca_cert.pem"
PROCESSED_CERTS="processed_certs.txt"

if [[ -z "$FQDN" || -z "$PORT" ]]; then
    echo "Usage: $0 <FQDN> <PORT>"
    exit 1
fi

# Clean up any existing tracking file
rm -f "$PROCESSED_CERTS"

# Fetch the server certificate
echo "Fetching server certificate from $FQDN:$PORT..."
echo | openssl s_client -connect "$FQDN:$PORT" -showcerts 2>/dev/null | \
    awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' > server_cert.pem

if [[ ! -s server_cert.pem ]]; then
    echo "Failed to retrieve server certificate from $FQDN:$PORT"
    exit 1
fi
echo "Server certificate saved to server_cert.pem"

# Function to download and handle issuer certificates
download_issuer_cert() {
    local CERT_FILE="$1"
    local AIA_URL=$(openssl x509 -in "$CERT_FILE" -noout -text | grep -A 1 "Authority Information Access" | grep "CA Issuers" | sed -n 's/.*URI://p')

    if [[ -z "$AIA_URL" ]]; then
        echo "No AIA URL found in $CERT_FILE"
        return 1
    fi

    echo "Downloading issuer certificate from: $AIA_URL"
    curl -o issuer_cert_raw "$AIA_URL" 2>/dev/null

    if [[ $? -ne 0 ]]; then
        echo "Failed to download issuer certificate from $AIA_URL"
        return 1
    fi

    # Check if the file is in PKCS#7 format
    if openssl pkcs7 -inform DER -in issuer_cert_raw -print 2>/dev/null | grep -q "PKCS7"; then
        echo "Converting PKCS#7 certificate to PEM format..."
        openssl pkcs7 -inform DER -in issuer_cert_raw -out issuer_cert.pem -print_certs
    else
        mv issuer_cert_raw issuer_cert.pem
    fi

    return 0
}

# Start with the server certificate
CURRENT_CERT="server_cert.pem"

while true; do
    # Extract issuer and subject
    SUBJECT=$(openssl x509 -in "$CURRENT_CERT" -noout -subject | sed 's/subject= //')
    ISSUER=$(openssl x509 -in "$CURRENT_CERT" -noout -issuer | sed 's/issuer= //')

    echo "Current Certificate Subject: $SUBJECT"
    echo "Issuer: $ISSUER"

    # Check for loop by comparing against processed certificates
    if grep -q "$SUBJECT" "$PROCESSED_CERTS"; then
        echo "Detected a loop with certificate subject: $SUBJECT. Stopping."
        break
    fi

    # Record the current certificate subject to prevent loops
    echo "$SUBJECT" >> "$PROCESSED_CERTS"

    # Check if the issuer matches the subject (root CA)
    if [[ "$ISSUER" == "$SUBJECT" ]]; then
        echo "Root CA certificate found: $CURRENT_CERT"
        cp "$CURRENT_CERT" "$ROOT_CA_OUTPUT"
        break
    fi

    # Try to download the next certificate in the chain
    download_issuer_cert "$CURRENT_CERT"

    if [[ $? -ne 0 ]]; then
        echo "Failed to find the root CA certificate."
        break
    fi

    CURRENT_CERT="issuer_cert.pem"
done

# Clean up the tracking file
rm -f "$PROCESSED_CERTS"

echo "Root CA certificate saved to $ROOT_CA_OUTPUT"
