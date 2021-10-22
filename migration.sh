#!/bin/bash

function help(){
cat<<"EOF"
ls-db
	listet zu dumpende Datenbanken auf
strip-postgis
	optional, entfernt postgis-Objekte aus custom-Text Dump
convert
	Custom-Format Dumps werden zu Plain-Text Dumps
strip-oid
	optional, entfernt SET default_with_oids aus plain-Text Dump
EOF
}

function list_databases(){
	while read DB
	do
		echo "$DB"
	done < <(docker exec pgsql-server bash -c "psql -U postgres -t -c \"select distinct datname from pg_catalog.pg_database where datname not like 'template%';\"")
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

case $1 in
	strip-postgis)
		strip_postgis_functions
	;;
	strip-oid)
		strip_withoid
	;;
	convert)
		convert_dump_format
	;;
	ls-db)
		list_databases
	;;
	*)
		help
	;;
esac
