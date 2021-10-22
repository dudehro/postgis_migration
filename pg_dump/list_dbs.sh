#!/bin/bash

psql -U postgres -t -c "select distinct datname from pg_catalog.pg_database where datname not like 'template%';"
