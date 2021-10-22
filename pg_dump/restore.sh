#!/bin/bash

mkdir logs
#1. Rollen + Tablespace einlesen
psql -U postgres -f roles_tablespaces.dump 1>> logs/1_schema_rollen.stdout  2>> logs/schema_rollen.errout

#2. einzelne DB-Dumps einlesen
while read DUMP_FILE
do
	pg_restore -U postgres -d postgres -CO ${DUMP_FILE} &> logs/${DUMP_FILE}.stdout 2>> logs/${DUMP_FILE}.errout
done < <(find . -type f -name "schema_data.*.dump")
