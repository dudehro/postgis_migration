\c kvwmapsp;
CREATE SCHEMA gdi_migration;
CREATE TABLE gdi_migration.oid_tables
    (   schema      name,
        tabelle     name,
        kind        character(1),
        ddl_create  text,
        ddl_drop    text,
        sort        int
    );
