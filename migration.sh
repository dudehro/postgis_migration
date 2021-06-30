#!/bin/bash

# Parameter für Migration
PGSQL_MAJOR_VERSION=13.1
POSTGIS_VERSION=3.1
PGSQL_IMAGE_VERSION="${PGSQL_MAJOR_VERSION}-${POSTGIS_VERSION}"
KVWMAP_SERVER_CONFIG=/home/gisadmin/kvwmap-server/config/config

#Parameter für Integration

if [[ -z $PGSQL_MAJOR_VERSION ]] || [[ -z $POSTGIS_VERSION ]]; then
	echo "FEHLER: Version nicht angegeben!"
	exit 1
fi

function help(){
cat<<"EOF"
paths
	listet die benoetigten Pfade auf
ls-db
	listet zu dumpende Datenbanken auf
mkdirs
	erstellt alle benoetigten Verzeichnisse
dump
	erstellt Dump im custom-Format
strip-postgis
	optional, entfernt postgis-Objekte aus custom-Text Dump
convert
	Custom-Format Dumps werden zu Plain-Text Dumps
strip-oid
	optional, entfernt SET default_with_oids aus plain-Text Dump
start-new-db
	startet neuen Container
restore
	stellt Plain-Text Dump im neuen Container her
run pgsql [image]
	startet einen Container mit dem angegebenen Image
EOF
}

function init_paths_vars(){

	if [ ! -f $KVWMAP_SERVER_CONFIG ] ; then
		echo "FEHLER: kvwmap-server Config-File $KVWMAP_SERVER_CONFIG nicht vorhanden!"
		exit 1
	else
		source $KVWMAP_SERVER_CONFIG
	fi

	OLD_DIR_WWW=${WWW_ROOT}
	NEW_DIR_WWW=${WWW_ROOT}_${PGSQL_MAJOR_VERSION}
	OLD_DIR_DATA=${DB_ROOT}/postgresql/data
	NEW_DIR_DATA=${DB_ROOT}/postgresql_${PGSQL_MAJOR_VERSION}/data
	DUMP_DIR_HOST_OLD=${OLD_DIR_WWW}/pg_dump
	DUMP_DIR_HOST_NEW=${NEW_DIR_WWW}/pg_dump
	DUMP_DIR_CONTAINER=/var/www/pg_dump

}

function echo_path_vars(){
	echo "=== nutze folgende Pfade ==="
	echo "OLD_DIR_WWW=$OLD_DIR_WWW"
	echo "NEW_DIR_WWW=$NEW_DIR_WWW"
	echo "OLD_DIR_DATA=$OLD_DIR_DATA"
	echo "NEW_DIR_DATA=$NEW_DIR_DATA"
	echo "DUMP_DIR_HOST_OLD=$DUMP_DIR_HOST_OLD"
	echo "DUMP_DIR_HOST_NEW=$DUMP_DIR_HOST_NEW"
	echo "DUMP_DIR_CONTAINER=$DUMP_DIR_CONTAINER"
	echo "=== ==================== ==="
}

function prepare_host(){

	if [ ! -f /home/gisadmin/etc/postgresql/env_and_volumes_${PGSQL_MAJOR_VERSION} ]; then
		echo "FEHLER: Datei /home/gisadmin/etc/postgresql/env_and_volumes_${PGSQL_MAJOR_VERSION} nicht vorhanden. Abbruch."
		exit 1
	fi

	#alte WWW, DATA, DUMP-Verzeichnisse
	if [ ! -d $OLD_DIR_WWW ]; then
		echo "Verzeichnis $OLD_DIR_WWW existiert nicht!"
		exit 1
	fi

	if [ ! -d $OLD_DIR_DATA ]; then
		echo "Verzeichnis $OLD_DIR_DATA existiert nicht!"
		exit 1
	fi

	if [ ! -d $DUMP_DIR_HOST_OLD ]; then
		echo "Verzeichnis anlegen: $DUMP_DIR_HOST_OLD"
		mkdir $DUMP_DIR_HOST_OLD
	fi


	 # neue WWW, DATA, DUMP-Verzeichnisse
	if [ -d $NEW_DIR_WWW ]; then
		echo "HINWEIS: ${NEW_DIR_WWW} existiert bereits"
	else
		mkdir -p ${NEW_DIR_WWW}/logs/pgsql

		echo "Verzeichnis anlegen: $NEW_DIR_WWW"
		echo "Setze Rechte auf $NEW_DIR_WWW"
		chown 999.gisadmin $NEW_DIR_WWW/logs/pgsql
		chmod 774 $NEW_DIR_WWW/logs/pgsql
	fi

	#create new data
	if [ -d ${NEW_DIR_DATA} ]; then
		echo "HINWEIS: ${NEW_DIR_DATA} existiert bereits"
	else
		echo "Verzeichnis anlegen: $NEW_DIR_DATA"
		echo "Verzeichnis anlegen: $DUMP_DIR_HOST_NEW"
		mkdir -p $NEW_DIR_DATA
		chown gisadmin.gisadmin $NEW_DIR_DATA
		mkdir -p $DUMP_DIR_HOST_NEW
		chown gisadmin.gisadmin $DUMP_DIR_HOST_NEW
	fi

	cp env_and_volumes_13.1 /home/gisadmin/etc/postgres/

}

function start_new_container(){
	dcm run pgsql ${PGSQL_MAJOR_VERSION}
}

function list_databases(){
	while read DB
	do
		echo "$DB"
	done < <(docker exec pgsql-server bash -c "psql -U postgres -t -c \"select distinct datname from pg_catalog.pg_database where datname not like 'template%';\"")
}

function dump_old_db_copy_dump(){
	DUMP_DIR=${DUMP_DIR_CONTAINER}

	docker exec pgsql-server bash -c "mkdir -p \"$DUMP_DIR\""

	#Rollen + Tablespace
	echo "Dump Rollen und Tablespace nach ${DUMP_DIR}"
	docker exec pgsql-server bash -c "pg_dumpall -U postgres --globals-only -f ${DUMP_DIR}/roles_tablespaces.dump"

	#alle Datenbanken mit Schemen und Daten
	while read DB
	do
		OPTION_F="${DUMP_DIR}/schema_data.${DB}.dump"
		echo "Dump DB ${DB} nach ${OPTION_F}"
		docker exec pgsql-server bash -c "pg_dump -U postgres --create -Fc --exclude-table='shp_export_*' -f ${OPTION_F} \"${DB}\" "
	done < <(docker exec pgsql-server bash -c "psql -U postgres -t -c \"select distinct datname from pg_catalog.pg_database where datname not like 'template%';\"")

#	cp -r "$DUMP_DIR_HOST_OLD"/* "$DUMP_DIR_HOST_NEW"/
	#docker cp  "$DUMP_DIR_HOST_OLD"/* "$DUMP_DIR_CONTAINER"/

#	echo "Inhalt von $DUMP_DIR_HOST_NEW"
#	ls -alh $DUMP_DIR_HOST_NEW
}

function restore_dump(){
	DUMP_DIR=/var/www/pg_dump

	#1. Rollen + Tablespace einlesen
	docker exec pgsql-server-"$PGSQL_MAJOR_VERSION" bash -c "psql -U postgres -f ${DUMP_DIR}/roles_tablespaces.dump 1>> "$DUMP_DIR"/restore.log  2>> "$DUMP_DIR"/restore_error.log"


	#2. einzelne DB-Dumps einlesen
 	docker exec pgsql-server-"$PGSQL_MAJOR_VERSION" bash -c "find ${DUMP_DIR} -type f -name \"schema_data.*.dump\" | xargs -I {} psql -U postgres -f {} 1>> "$DUMP_DIR"/restore.log  2>> "$DUMP_DIR"/restore_error.log"
#	docker exec pgsql-server-"$PGSQL_MAJOR_VERSION" bash -c "find ${DUMP_DIR} -type f -name \"schema_data.*.dump\" | xargs -i pg_restore -U postgres -d postgres -C -O {} 1>> "$DUMP_DIR"/restore.log  2>> "$DUMP_DIR"/restore_error.log"

}


function convert_dump_format(){
	echo "converting custom-format dumps into plain-text dumps"
        while read DUMP_FILE
        do
                echo $DUMP_FILE
                docker exec pgsql-server bash -c "pg_restore -Cc -f ${DUMP_FILE}_plain  \"$DUMP_FILE\" "
        done < <(docker exec pgsql-server bash -c "find ${DUMP_DIR_CONTAINER} -type f -name \"schema_data.*.dump\" ")
}

function strip_withoid(){
	echo "stripping \"SET default_with_oids\" from plain-text dumps"
	DUMP_DIR=/var/www/pg_dump
	while read DUMP_FILE
	do
		echo $DUMP_FILE
		docker exec pgsql-server bash -c "sed -i -e 's/\(SET default_with_oids = true;\|SET default_with_oids = false;\)//' \"$DUMP_FILE\" "
	done < <(docker exec pgsql-server bash -c "find ${DUMP_DIR} -type f -name \"schema_data.*.dump\" ")
}

function strip_postgis_functions(){
	echo "stripping postgis-objects from custom-format dumps"
	DUMP_DIR=/var/www/pg_dump
	#	/usr/share/postgresql/9.6/contrib/postgis-2.5/postgis_restore.pl
	#	/usr/share/postgresql/9.6/contrib/postgis-2.3/postgis_restore.pl
	docker exec pgsql-server bash -c "find ${DUMP_DIR} -type f -name \"schema_data.*.dump\" | xargs -i perl /usr/share/postgresql/9.6/contrib/postgis-2.5/postgis_restore.pl {} > {}"
}

function run_pgsql_container(){

  DB_ROOT=$(pwd)

  if [ -n "$1" ]; then
    #Image wurde als Parameter übergeben
    IMAGETAG=$1
    IMAGE=$(echo $IMAGETAG | cut -d ':' -f 1)
    TAG=$(echo $IMAGETAG | cut -d ':' -f 2)
    PG_VERSION=$(echo $TAG | cut -d '-' -f 1)
    POSTGIS_VERSION=$(echo $TAG | cut -d '-' -f 2)

    #env_and_volumes auslesen
    ENVVOL_IMAGE=$(sed -rn 's/^PGSQL_IMAGE=([^\n]+)$/\1/p' postgres/env_and_volumes)
    ENVVOL_TAG=$(sed -rn 's/^PGSQL_IMAGE_TAG=([^\n]+)$/\1/p' postgres/env_and_volumes)

    #vergleichen
    if [[ $IMAGE != $ENVVOL_IMAGE ]] || [[ $TAG != $ENVVOL_TAG ]]; then
      echo "Konfiguration unterscheidet sich von alter und wird neu geschrieben"
      echo "altes Image: $ENVVOL_IMAGE:$ENVVOL_TAG"
      echo "neues Image: $IMAGE:$TAG"

      #slash für sed escapen
      IMAGE_REPLACE=$(printf '%s\n' "$IMAGE" | sed -e 's/[\/&]/\\&/g')
      sed -ir "s/^[#]*\s*PGSQL_IMAGE=.*/PGSQL_IMAGE=$IMAGE_REPLACE/" postgres/env_and_volumes
      sed -ir "s/^[#]*\s*PGSQL_IMAGE_TAG=.*/PGSQL_IMAGE_TAG=$TAG/" postgres/env_and_volumes
    fi

  else
    #Image aus env_and_volumes auslesen
    echo "kein Image übergeben, verwende bisherige Konfiguration"
    IMAGE=$(sed -rn 's/^PGSQL_IMAGE=([^\n]+)$/\1/p' postgres/env_and_volumes)
    TAG=$(sed -rn 's/^PGSQL_IMAGE_TAG=([^\n]+)$/\1/p' postgres/env_and_volumes)

  fi

  echo "Starte Image $IMAGE:$TAG"

  #existieren die Verzeichnisse?
  PG_DATA_DIR=$DB_ROOT/postgresql/$IMAGE_$TAG/data
  PG_LOG_DIR=$DB_ROOT/postgresql/$IMAGE_$TAG/log

  if [ ! -d $PG_DATA_DIR ]; then
    mkdir -p $PG_DATA_DIR
    chown 999.root $PG_DATA_DIR
    chmod 700 $PG_DATA_DIR
  fi

  if [ ! -d $PG_LOG_DIR ]; then
    mkdir -p $PG_LOG_DIR
    chown 999.root $PG_LOG_DIR
    chmod 700 $PG_LOG_DIR
  fi

  #läuft ein Container mit Tag?
  if [[ $(docker ps --format '{{.Names}}' -f name=pgsql-server-$TAG) == "" ]]; then

    source postgres/env_and_volumes

    if [ "${START_WITH_DCM}" = "true" ] ; then
      echo "\ Erzeuge und Starte container pgsql-$TAG"

      if [ -z "$pgsql_config" ] ; then
        pgsql_config=""
      fi

      if [ -n "$PGSQL_HOST_PORT" ]; then
        pgsql_port="$PGSQL_PORT:5432"
      else
        pgsql_port="5432:5432"
      fi

      echo "
      docker run \
        -h ${SERVER_NAME}-PGSQL-SERVER-${TAG} \
        --name pgsql-server-${TAG} \
        --network=kvwmap_neue_container \
        --net-alias=pgsql \
        --restart=always \
        $pgsql_env_vars \
        $pgsql_volumes \
        -p $pgsql_port \
        -d ${IMAGE}:${TAG} \
        $pgsql_config
      "

      docker run \
        -h ${SERVER_NAME}-PGSQL-SERVER-${TAG} \
        --name pgsql-server-${TAG} \
        --network=kvwmap_neue_container \
        --net-alias=pgsql \
        --restart=always \
        $pgsql_env_vars \
        $pgsql_volumes \
        -p $pgsql_port \
        -d ${IMAGE}:${TAG} \
        $pgsql_config

    fi

  fi

}

#init_paths_vars

case $1 in
	paths)
		echo_path_vars
	;;
	mkdirs)
		prepare_host
	;;
	dump)
		dump_old_db_copy_dump $2
	;;
	strip-postgis)
		strip_postgis_functions
	;;
	strip-oid)
		strip_withoid
	;;
	start-new-db)
		start_new_container
	;;
	convert)
		convert_dump_format
	;;
	restore)
		restore_dump $2
	;;
	ls-db)
		list_databases
	;;
        run)
          case $2 in
            pgsql) run_pgsql_container $3
	    ;;
          esac
        ;;
	*)
		help
	;;
esac
