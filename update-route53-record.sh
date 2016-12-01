#!/bin/bash
DOMAIN_NAME="route53.fffdev.com"

main(){
}

# Get IP List and convert json array to bash array



IP=$( curl http://169.254.169.254/latest/meta-data/public-ipv4 )
echo "IP to delete: $IP"
IP2="54.175.56.142"

HOSTED_ZONE_ID="Z1986QIYBBYSUJ"

JSON_REQUEST='{
          "Comment": "Delete the A record set",
          "Changes": [
            {
              "Action": "UPSERT",
              "ResourceRecordSet": {
                "Name": '\"$DOMAIN_NAME\"',
                "Type": "A",
                "TTL": 300,
                "ResourceRecords": [
                  {
                    "Value": '\"$IP\"'
                  },
                  {
                    "Value": '\"$IP2\"'
                  }

                ]
              }
            }
          ]
        }'
echo $JSON_REQUEST
echo "Calling API..."
aws route53 change-resource-record-sets  --hosted-zone-id "$HOSTED_ZONE_ID" --change-batch "$JSON_REQUEST"


main
exit 0
