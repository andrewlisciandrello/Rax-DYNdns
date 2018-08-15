#!/bin/bash


## Instructions
## http://docs.rackspace.com/cdns/api/v1.0/cdns-devguide/content/Modify_Records-d1e5033.html

## TO pull IP from external source:
## http://www.hostgator.com/ip
## lynx --dump http://www.hostgator.com/ip | awk '/IP:/ {print $2}'

## VARIABLES
IP=`ip a | awk '/inet 10/ {print $2}' | sed 's|/24||g'`  ## this is ugly, i should make it just one awk. Awk|sed makes RMS cry
IP_FROM_FILE=`cat ~/.ip_old`  ## This is also stupid, not sure how to make it better
#
DOMAIN_ID=
RECORD_ID=
#
API_USERNAME=
API_KEY=
DDI=
##

## If IP matched the old IP
if [[ "$IP" = "$IP_FROM_FILE" ]]
then
	# update 'log' and Exit cleanly
	date > /tmp/updatedIP
	exit 0
else

	## Replace 'oldIP' with new one
	echo $IP > ~/.ip_old

	## auth and get token
	curl -s https://identity.api.rackspacecloud.com/v2.0/tokens -X 'POST' -d \
		'{"auth":{"RAX-KSKEY:apiKeyCredentials":{"username":"'$API_USERNAME'", "apiKey":"'$API_KEY'"}}}' \
		-H "Content-Type: application/json" | python2 -m json.tool > /tmp/tmpcat
    ## Wow, the above is stupid/insecure/slow all at once. need to read the json into a variable and pull it from that later
    ## I totes do this in ng-login, should be easy peasy

	## Pull token out of all that stuffs
	TOKEN=$(grep '"id": "[0-9a-z]\{32\}' /tmp/tmpcat | cut -d '"' -f 4)

	## put new IP into CloudDNS
	curl -X PUT -s -H "X-Auth-Token: $TOKEN" -H "Content-Type: application/json" \
		https://dns.api.rackspacecloud.com/v1.0/$DDI/domains/$DOMAIN_ID/records/$RECORD_ID -d "{\"data\": \"$IP\"}" > /tmp/updatedIP
	
	# update 'log' and Exit cleanly
	date > /tmp/updatedIP
	exit 0
fi
