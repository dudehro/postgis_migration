
#!/bin/bash

while read DB
do
	echo $DB
	psql $DB postgres -f oid_objects.sql > oids_in.$DB.txt
done < <(psql postgres postgres -tc "select distinct datname from pg_catalog.pg_database")

exit 0
