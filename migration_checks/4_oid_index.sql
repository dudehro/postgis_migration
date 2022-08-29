SELECT  ns.nspname || '.' || ci.relname     AS  "index"
        ,ns.nspname                         AS  "schema"
        ,t.relname                          AS  "table"
        --,a.attname                            AS  table_col
        ,pg_get_indexdef(i.indexrelid)      AS  ddl_create
        ,'DROP INDEX IF EXISTS ' || ns.nspname || '.' || ci.relname || ';' AS ddl_drop
FROM    pg_index        i
JOIN    pg_class        ci  ON  i.indexrelid = ci.oid
JOIN    pg_class        t   ON  i.indrelid = t.oid
JOIN    pg_namespace    ns  ON  ci.relnamespace = ns.oid
JOIN    pg_attribute    a   ON  a.attrelid = t.oid
                                AND a.attnum = any(i.indkey)
WHERE   ns.nspname NOT IN ('pg_catalog','pg_toast')
AND     a.attnum < 0 --system columns, vermutlich oids
AND     a.attname = 'oid'
;
