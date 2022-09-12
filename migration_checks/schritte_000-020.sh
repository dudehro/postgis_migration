#!/bin/bash

export PGUSER=kvwmap
export PGDATABASE=kvwmapsp
#export PGPASSWORD=

#1 gdi_migration Schema anlegen
psql -f 000_create_schema.sql
#2 Abhängigkeiten+Tabellen ermitteln
psql -f 010_fill_oid_tables.sql
#3 abhängige Objekte DROPen
psql -f 020_drop_dependencies.sql
#4 OIDs entfernen
# psql -f 030_disable_oids.sql
