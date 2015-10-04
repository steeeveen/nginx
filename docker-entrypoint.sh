#!/bin/bash
set -x

#UPDATES MY OWN DNS SERVER
#if [ "$IS_DOCKER" ]; then
    #echo "Updating DNS record"        
    #dockerhost=$(netstat -nr | grep '^0\.0\.0\.0' | awk '{print $2}')
    #curl -X PATCH -d '{"DOCKER_INSTANCE_HOST":"'$dockerhost'"}' \
    #      $DNS_ADDR'/dns.json'
#fi


dnsrecords=$(curl $DNS_ADDR'/dns.json')
dnsrecords="${dnsrecords:1:${#dnsrecords}-2}"
echo $dnsrecords

#EXPORTS DNS SERVER ADDRESSES AS IP
IFS=',' read -a array <<< "$dnsrecords"
for element in "${array[@]}"
do
    element=${element/:/=}
    setenv="export $element"
    eval $setenv
done

#CONFIGURES THE NGINX FILE
sed -i "s/<server_placeholder>/${DOCKER_INSTANCE_HOST}/" /etc/nginx/nginx.conf
cat /etc/nginx/nginx.conf

exec "$@"
