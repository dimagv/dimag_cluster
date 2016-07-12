#!/usr/bin/env bash

echo $GOPATH
exit 
read -r JSON
echo "Consul watch store-deploy:"
echo "$JSON"
echo "$JSON" | jq -r '.[] | .Payload' | while read payload_raw
do
	PAYLOAD="$(echo $payload_raw | base64 --decode)"
	echo ""
	echo "$PAYLOAD"
	echo ""

	if [[ -z "$PAYLOAD" ]]; then
	    echo "[ERROR] no payload"
	    exit
	fi

	if [[ -z "$STORE_COMPOSE_DIR" ]]; then
	    echo "[ERROR] no store_compose_dir"
	    exit
	fi
	
	if [ "$PAYLOAD" == "latest"]; then
	    cd $STORE_COMPOSE_DIR
	    sudo docker-compose stop store
	    sudo docker-compose rm -f store
	    sudo docker-compose pull store
	    sudo docker-compose up -d
	elif
		cd $STORE_COMPOSE_DIR
		compose_override_file = "docker-compose.override.yml"
		if [ -f compose_override_file ]; then
	   		sudo rm compose_override_file
		fi
		sudo touch compose_override_file
		sudo printf "store:%s\n  image: dimag/store:$PAYLOAD" > compose_override_file
		sudo docker-compose stop store
	    sudo docker-compose rm -f store
	    sudo docker-compose up -d
	fi
done
