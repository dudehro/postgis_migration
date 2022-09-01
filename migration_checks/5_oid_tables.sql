\c kvwmapsp
INSERT INTO gdi_migration.oid_dependencies (schema, tabelle, kind, ddl_create, ddl_drop, sort)
SELECT schema, "table", kind, ddl_create, ddl_drop, 1
FROM    gdi_migration.oid_constraints;

INSERT INTO gdi_migration.oid_dependencies (schema, tabelle, kind, ddl_create, ddl_drop, sort)
SELECT  schema, tabelle, kind, ddl_create, ddl_drop, sort
FROM    gdi_migration.oid_views;

INSERT INTO gdi_migration.oid_dependencies (schema, tabelle, kind, ddl_create, ddl_drop, sort)
SELECT  schema, tabelle, kind, ddl_create, ddl_drop, 1
FROM    gdi_migration.oid_funcs;

INSERT INTO gdi_migration.oid_dependencies (schema, tabelle, kind, ddl_create, ddl_drop, sort)
SELECT  schema, "table", 'i', ddl_create, ddl_drop, 1
FROM    gdi_migration.oid_index;

INSERT INTO gdi_migration.oid_tables (schema, tabelle, max_oid)
SELECT  DISTINCT schema, tabelle, gdi_migration.get_max_oid(schema, tabelle)
FROM    gdi_migration.oid_dependencies d
WHERE   d.schema != ''
AND     d.tabelle != ''
AND     gdi_migration.get_max_oid(d.schema, d.tabelle) IS NOT NULL
ORDER BY 1,2
;
