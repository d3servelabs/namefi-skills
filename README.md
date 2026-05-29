Register a domain

curl https://backend.astra.namefi.io/v-next/orders/register-domain \
  --request POST \
  --header 'Content-Type: application/json' \
  --header 'Accept: application/json' \
  --header 'x-api-key: $NAMEFI_API_KEY'
  ' \
  --data '{
  "normalizedDomainName": "$DOMAIN_NAME",
  "durationInYears": 1
}'

Check order status

curl 'https://backend.astra.namefi.io/v-next/orders/{orderId}' \
  --header 'Accept: application/json' \
  --header 'x-api-key: $NAMEFI_API_KEY'


GET Dns Records
curl 'https://backend.astra.namefi.io/v-next/dns/records?zoneName=merry-christ-imas.0x.city' \
  --header 'Accept: application/json' \
  --header 'x-api-key: $NAMEFI_API_KEY'

Create DNS Records
curl https://backend.astra.namefi.io/v-next/dns/records/batch \
  --request POST \
  --header 'Content-Type: application/json' \
  --header 'Accept: application/json' \
  --header 'x-api-key: $NAMEFI_API_KEY' \
  --data '{
  "records": [
    {
      "type": "TXT",
      "name": "@",
      "ttl": 60,
      "rdata": "Test"
    }
  ],
  "zoneName": "merry-christ-imas.0x.city"
}'

DELETE

curl https://backend.astra.namefi.io/v-next/dns/records/batch \
  --request DELETE \
  --header 'Content-Type: application/json' \
  --header 'Accept: application/json' \
  --header 'x-api-key: $NAMEFI_API_KEY' \
  --data '{
  "recordsIds": [
    "",
  ],
  "zoneName": "merry-christ-imas.0x.city"
}'

Update DNS Record
** fill recordsId

curl 'https://backend.astra.namefi.io/v-next/dns/records/{recordId}' \
  --request PUT \
  --header 'Content-Type: application/json' \
  --header 'Accept: application/json' \
  --header 'x-api-key: $NAMEFI_API_KEY' \
  --data '{
  "zoneName": "merry-christ-imas.0x.city",
  "type": "TXT",
  "name": "@",
  "rdata": "asdfgh",
  "ttl": 60
}'