SELECT 'ALTER TABLE "' || n.nspname || '"."' || c.relname || '" SET WITHOUT OIDS;'
FROM pg_catalog.pg_class c
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE 1=1
AND c.relkind = 'r'
AND c.relhasoids = true
AND n.nspname <> 'pg_catalog'
order by n.nspname, c.relname;
