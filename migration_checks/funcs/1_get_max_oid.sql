-- FUNCTION: gdi_migration.get_max_oid(name, name)

-- DROP FUNCTION IF EXISTS gdi_migration.get_max_oid(name, name);

CREATE OR REPLACE FUNCTION gdi_migration.get_max_oid(
    schema name,
    tabelle name)
RETURNS bigint
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
AS $BODY$
DECLARE
    ret bigint;
    stmt text;
BEGIN
stmt := 'SELECT max(oid) FROM ' || schema || '.' || tabelle || ';';
EXECUTE stmt INTO ret;
return ret;
END;
$BODY$;

ALTER FUNCTION gdi_migration.get_max_oid(name, name)
    OWNER TO kvwmap;
