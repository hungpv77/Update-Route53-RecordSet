#!/bin/bash

DOMAIN_NAME="route53.fffdev.com"
HOSTED_ZONE_ID="Z1986QIYBBYSUJ"
DEBUG_TEXT=""

main(){
    UPDATED_IP_LIST=$(updated_ip_list)    
    update_route53_record "$UPDATED_IP_LIST"    
}

# Get IP List of $DOMAIN_NAME from route53
get_ip_list(){
    RECORD_SET_JSON=$( sudo aws route53 list-resource-record-sets --hosted-zone-id Z1986QIYBBYSUJ --query "ResourceRecordSets[?Name == '$DOMAIN_NAME.']")    

    #Remove the first and last character in string  to convert json array to json object
    RECORD_SET_JSON=${RECORD_SET_JSON:1:-1}

    # Need to install jq to parse json http://xmodulo.com/how-to-parse-json-string-via-command-line-on-linux.html
    # Get value of ResourceRecords
    RECORD_SET_JSON=$( echo $RECORD_SET_JSON | jq -r '.ResourceRecords' )
    #DEBUG_TEXT="$DEBUG_TEXT DEBUGGING: RECORD_SET_JSON = $RECORD_SET_JSON"
    
    echo $RECORD_SET_JSON
}

delete_ip_item(){      
    # Get IP list from Route53 by invoking get_ip_list
    IP_LIST=$(get_ip_list)
    #DEBUG_TEXT="$DEBUG_TEXT DEBUGGING: IP_LIST (return from Route53) = $IP_LIST"    

    # Get public IP of running instance
    IP=$( curl http://169.254.169.254/latest/meta-data/public-ipv4 ) 
    #DEBUG_TEXT="$DEBUG_TEXT DEBUGGING: IP = $IP"
    
    # Convert IP to json array [{"Value": "192.168.10.1"}]
    IP='[{"Value": '\"$IP\"'}]'
    # Remove one element from json array
    IP_LIST=$(echo $IP_LIST | jq ".-  $IP")
    #DEBUG_TEXT="$DEBUG_TEXT DEBUGGING: IP_LIST (after added one element) = $IP_LIST"
    #echo "DEBUGGING IP_LIST after added one element: $IP_LIST" >> /var/log/update-route53.log

    echo $IP_LIST
}

update_route53_record(){   
    JSON_REQUEST='{
              "Comment": "Update the A record set",
              "Changes": [
                {
                  "Action": "UPSERT",
                  "ResourceRecordSet": {
                    "Name": '\"$DOMAIN_NAME\"',
                    "Type": "A",
                    "TTL": 300,
                    "ResourceRecords": '$1'
                  }
                }
              ]
            }'
    #echo $JSON_REQUEST
    #echo "Calling API..."
    sudo aws route53 change-resource-record-sets  --hosted-zone-id "$HOSTED_ZONE_ID" --change-batch "$JSON_REQUEST"

    DEBUG_TEXT="$DEBUG_TEXT DEBUGGING: aws route53 change-resource-record-sets  --hosted-zone-id \"$HOSTED_ZONE_ID\" --change-batch \"$JSON_REQUEST\""

    # write to log file
    echo "$DEBUG_TEXT"  | tee /var/log/update-route53.log
}
main
exit 0