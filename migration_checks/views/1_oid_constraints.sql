CREATE OR REPLACE VIEW gdi_migration.oid_constraints AS
SELECT  'c'::char(1)    AS "kind"
        ,ns.nspname     AS "schema"
        ,c.relname      AS "table"
--        ,attr.attname   AS "column"
--        ,con.conname    AS "constraint"
        ,'ALTER TABLE IF EXISTS ' || ns.nspname || '.' || c.relname || ' ADD CONSTRAINT ' || con.conname || ' ' || pg_get_constraintdef(con.oid) || ';' ddl_create
        ,'ALTER TABLE IF EXISTS ' || ns.nspname || '.' || c.relname || ' DROP CONSTRAINT IF EXISTS ' || con.conname || ';'      ddl_drop
FROM    pg_catalog.pg_class c
JOIN    pg_catalog.pg_namespace ns      ON ns.oid = c.relnamespace
JOIN    pg_catalog.pg_constraint con    ON c.oid = con.conrelid
JOIN    pg_catalog.pg_attribute  attr   ON  (
                                                (attr.attnum = any(con.conkey) AND con.confkey IS NULL)
                                            OR
                                                (attr.attnum = any(con.confkey) AND con.conkey IS NULL)
                                            )
                                            AND c.oid = attr.attrelid
WHERE   ns.nspname NOT IN ('pg_catalog')
AND     attr.attnum < 1 /*system columns wie oid*/
AND     lower(attr.attname) LIKE '%oid%'
;
