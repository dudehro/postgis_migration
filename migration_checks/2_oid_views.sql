WITH RECURSIVE views AS (

    SELECT  v.oid::regclass    AS "view"
            ,v.relkind = 'm' AS is_materialized
            ,1 AS level
            --,'CREATE OR REPLACE VIEW ' || ns.nspname ||'.'|| v.oid::regclass || ' AS ' || pg_get_viewdef(v.oid,true) || ';' AS alterstmt
            --ALTER TABLE fachdaten.v_kreisstrassenallee OWNER TO kvwmap; fehlt noch
    FROM    pg_attribute    AS a
    JOIN    pg_depend       AS d    ON  d.refobjsubid = a.attnum
                                    AND d.refobjid = a.attrelid
    JOIN    pg_class    AS c    ON  a.attrelid = c.oid
    JOIN    pg_namespace    AS ns   ON  ns.oid = c.relnamespace
    JOIN    pg_rewrite  AS r    ON  r.oid = d.objid
    JOIN    pg_class        AS v    ON  v.oid = r.ev_class
    JOIN    pg_class        AS t    ON  d.refobjid = t.oid
    WHERE   v.relkind IN ('v','m')
    AND     d.classid = 'pg_rewrite'::regclass
    AND     d.refclassid = 'pg_class'::regclass
    AND     d.deptype = 'n'    -- normal dependency
    AND     a.attname = 'oid'
    AND     a.attnum < 0

    UNION
       -- von Views abhängige Views
    SELECT   v.oid::regclass,
             v.relkind = 'm',
             views.level + 1
    FROM     views
    JOIN     pg_depend   AS d    ON d.refobjid = views.view
    JOIN     pg_rewrite  AS r    ON r.oid = d.objid
    JOIN     pg_class    AS v    ON v.oid = r.ev_class
    WHERE    v.relkind IN ('v', 'm')
    AND      d.classid = 'pg_rewrite'::regclass
    AND      d.refclassid = 'pg_class'::regclass
    AND      d.deptype = 'n'
    AND      v.oid <> views.view  -- bitte keine Schleife
)

SELECT  CASE WHEN is_materialized
            THEN 'm'
            ELSE 'v'
        END                              AS kind
        ,views.level                     AS sort
        ,format('CREATE%s VIEW %s AS%s',
              CASE WHEN is_materialized
                   THEN ' MATERIALIZED'
                   ELSE ''
              END,
            view,
            pg_get_viewdef(view))        AS ddl_create
        ,format('DROP VIEW %s;', view)   AS ddl_drop
FROM    views
GROUP BY view, is_materialized, level
ORDER BY level ASC
