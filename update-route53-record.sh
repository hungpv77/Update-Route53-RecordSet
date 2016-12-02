#!/bin/bash
DOMAIN_NAME="route53.fffdev.com"
HOSTED_ZONE_ID="Z1986QIYBBYSUJ"

main(){
    IP_LIST_UPDATE=$(updated_ip_list)    
    update_route53_record ${IP_LIST_UPDATE}
}

# Get IP List of $DOMAIN_NAME from route53
get_ip_list(){    
    RECORD_SET_JSON=$( aws route53 list-resource-record-sets --hosted-zone-id Z1986QIYBBYSUJ --query "ResourceRecordSets[?Name == '$DOMAIN_NAME.']")

    #Remove the first and last character in string  to convert json array to json object  
    RECORD_SET_JSON=${RECORD_SET_JSON:1:-1}

    # Need to install jq to parse json http://xmodulo.com/how-to-parse-json-string-via-command-line-on-linux.html
    # Get value of ResourceRecords
    RECORD_SET_JSON=$( echo $RECORD_SET_JSON | jq -r '.ResourceRecords' )

    echo $RECORD_SET_JSON    
}

updated_ip_list(){
    # Get public IP of running instance
    # IP=$( curl http://169.254.169.254/latest/meta-data/public-ipv4 )
    IP="192.168.10.1"

    # Get IP list from Route53 by invoking get_ip_list
    IP_LIST=$(get_ip_list)

    echo "DEBUG: IP_LIST: $IP_LIST"

    # Get length of json array
    LENGTH=$(echo $IP_LIST | jq '. | length')

    # Add one element to last array
    IP_LIST=$(echo $IP_LIST | jq '.['$LENGTH'].Value |= .+ '\"$IP\"'')
        
    echo $IP_LIST
}

update_route53_record(){   
    echo "IP_LIST_UPDATE: $1"
    JSON_REQUEST='{
              "Comment": "Delete the A record set",
              "Changes": [
                {
                  "Action": "UPSERT",
                  "ResourceRecordSet": {
                    "Name": '\"$DOMAIN_NAME\"',
                    "Type": "A",
                    "TTL": 300,
                    "ResourceRecords": '.$1.'
                  }
                }
              ]
            }'
    echo $JSON_REQUEST
    echo "Calling API..."
    aws route53 change-resource-record-sets  --hosted-zone-id "$HOSTED_ZONE_ID" --change-batch "$JSON_REQUEST"
}
main
exit 0