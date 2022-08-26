SELECT  ns.nspname || '.' || p.proname  AS procname
        ,pg_get_functiondef(p.oid)
FROM    pg_proc         p
JOIN    pg_namespace    ns  ON  p.pronamespace = ns.oid
WHERE   ns.nspname NOT IN ('pg_catalog','information_schema')
AND     upper(pg_get_functiondef(p.oid)) LIKE '%.OID%'
AND     p.proisagg = FALSE
ORDER BY 1;
