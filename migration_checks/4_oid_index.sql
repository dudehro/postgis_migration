SELECT  ns.nspname || '.' || ci.relname     AS  index
        ,t.relname || '.' || a.attname      AS  tablecol
FROM    pg_index        i
JOIN    pg_class        ci  ON  i.indexrelid = ci.oid
JOIN    pg_class        t   ON  i.indrelid = t.oid
JOIN    pg_namespace    ns  ON  ci.relnamespace = ns.oid
JOIN    pg_attribute    a   ON  a.attrelid = t.oid
                                AND a.attnum = any(i.indkey)
WHERE   ns.nspname NOT IN ('pg_catalog','pg_toast')
AND     a.attnum < 0 --system columns, vermutlich oids
AND     lower(a.attname) LIKE '%oid%'
;
