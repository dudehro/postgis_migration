#!/bin/bash

declare -a dump_tables
export dump_tables=( "kvwmapsp" )

function dump_database(){

	#Rollen + Tablespace
	echo "Dump Rollen und Tablespace"
	pg_dumpall -U postgres --globals-only -f roles_tablespaces.dump

	#alle Datenbanken mit Schemen und Daten
	while read DB
	do
		for element in "${dump_tables[@]}"; do
			if [[ $element == "$DB" ]]; then
				echo "Dump DB ${DB}"
				pg_dump -U postgres --create --exclude-table='shp_export_*' --format=custom -f schema_data.${DB}.dump "${DB}"
				break
			fi
		done
	done < <(psql -U postgres -t -c "select distinct datname from pg_catalog.pg_database where datname not like 'template%';")
}

if [ $(basename $(pwd)) == "pg_dump" ]; then
	dump_database
else
	echo "Script wird nicht in pg_dump ausgeführt, Abbruch!"
fi
