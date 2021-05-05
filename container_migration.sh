#!/bin/bash

function get_links(){
	while read link
	do
		linked_container=$(echo $link | cut -d ':' -f 1)
		container_alias=$(echo $link | cut -d ':' -f 2 | cut -d '/' -f 3)
		echo "$linked_container/$container_alias"
	done < <(docker ps -a --format {{.ID}} | xargs -i docker inspect {} --format "{{json .HostConfig}}" | jq '.Links' | jq -r '.[]' 2> echo)
}

function get_linking_containers(){
        while read link
        do
                linking_container=$(echo $link | cut -d ':' -f 2 | cut -d '/' -f 2)
                echo "$linking_container"
        done < <(docker ps -a --format {{.ID}} | xargs -i docker inspect {} --format "{{json .HostConfig}}" | jq '.Links' | jq -r '.[]' 2> echo)
}

function get_link_for_container(){
	mycontainer=$1
        while read link
        do
                linked_container=$(echo $link | cut -d ':' -f 1)
                container_alias=$(echo $link | cut -d ':' -f 2 | cut -d '/' -f 3)
		if [ "/$mycontainer" = "$linked_container" ]; then
			echo "$container_alias"
			exit 0
		fi
        done < <(docker ps -a --format {{.ID}} | xargs -i docker inspect {} --format "{{json .HostConfig}}" | jq '.Links' | jq -r '.[]' 2> echo)
}

function exists_network(){
	network_name=$1
	while read nw
	do
		if [ "$nw" = "$1" ]; then
			echo 1
			exit
		fi
	done < <(docker network ls --format {{.Name}})
	echo 0
}

function create_bridge_network(){
	network_name=$1
	if [ $(exists_network $network_name) -eq 0 ]; then
		docker network create $network_name
	fi
}

function connect_container_to_network(){
	container_name="$1"
	network_name="$2"
	create_bridge_network $network_name
	alias=$(get_link_for_container $container_name)
	if [ -n "$alias" ]; then
		docker network connect --alias $alias $network_name $container_name
	else
		docker network connect $network_name $container_name
	fi
}

function help(){
	echo "list-linked	listed verlinkte Container auf"
	echo "get-link [CONTAINER]	gibt Link-Bezeichnung für Container aus"
	echo "list-linking		listet verlinkende Container auf"
	echo "exists-network [NETWORK]	existiert ein Netzwerk, 0/1"
	echo "create-network [NETWORK]	erstellt ein bridge Netzwerk"
	echo "connect-to-network [CONTAINER] [NETWORK] verbindet den [CONTAINER] mit [NETZWERK], wenn ein Link vorhanden ist, wird dieser in --alias verwendet"
}

case $1 in
	list-linked)
		get_links
		;;
	get-link)
		get_link_for_container $2
		;;
	list-linking)
		get_linking_containers
		;;
	exists-network)
		exists_network $2
		;;
	create-network)
		create_bridge_network $2
		;;
	connect-to-network)
		connect_container_to_network "$2" "$3"
		;;
	*)
		help
		;;
esac
