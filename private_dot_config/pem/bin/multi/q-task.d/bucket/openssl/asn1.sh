openssl asn1parse -inform der -in <(echo "$1" | reverse-dump) -i
