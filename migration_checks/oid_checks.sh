#!/bin/bash

export PGUSER=postgres
export PGDATABASE=postgres
#export PGPASSWORD=

# 'ALTER TABLE "' || ns.nspname || '"."' || c.relname || '" SET WITHOUT OIDS;' AS alter_sql

psql -f 
