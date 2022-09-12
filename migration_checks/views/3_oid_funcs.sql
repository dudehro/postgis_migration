CREATE OR REPLACE VIEW gdi_migration.oid_funcs AS
SELECT ns.nspname AS schema,
    ''::name AS tabelle,
    'f'::character(1) AS kind,
    pg_get_functiondef(p.oid) || ';'::text AS ddl_create,
    'DROP FUNCTION IF EXISTS '::text || ns.nspname::text || '.'::text || p.proname::text || '(' || pg_get_function_identity_arguments(p.oid) || ');'::text AS ddl_drop
FROM pg_proc p
JOIN pg_namespace ns ON p.pronamespace = ns.oid
WHERE (ns.nspname <> ALL (ARRAY['pg_catalog'::name, 'information_schema'::name, 'public'::name]))
AND upper(pg_get_functiondef(p.oid)) ~~ '%.OID%'::text
AND p.proisagg = false
ORDER BY ns.nspname;
