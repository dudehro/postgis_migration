SELECT  ns.nspname                          AS "schema"
        ,''                                 AS "tabelle"
        ,'f'                                AS "kind"
        ,pg_get_functiondef(p.oid) || ';'   AS ddl_create
        ,'DROP FUNCTION IF EXISTS ' || ns.nspname || '.' || p.proname || ';' AS ddl_drop
FROM    pg_proc         p
JOIN    pg_namespace    ns  ON  p.pronamespace = ns.oid
WHERE   ns.nspname NOT IN ('pg_catalog','information_schema','public')
AND     upper(pg_get_functiondef(p.oid)) LIKE '%.OID%'
AND     p.proisagg = FALSE
ORDER BY 1;
