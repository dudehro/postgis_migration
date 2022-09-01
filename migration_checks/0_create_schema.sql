\c kvwmapsp;
CREATE SCHEMA gdi_migration;
CREATE TABLE gdi_migration.oid_dependencies
    (   schema      name,
        tabelle     name,
        kind        character(1),
        ddl_create  text,
        ddl_drop    text,
        sort        int
    );
CREATE TABLE gdi_migration.oid_tables
    (   schema      name,
        tabelle     name,
        max_oid     bigint
    );
\i views/1_oid_constraints.sql
\i views/2_oid_views.sql
\i views/3_oid_funcs.sql
\i views/4_oid_index.sql
\i funcs/1_get_max_oid.sql
