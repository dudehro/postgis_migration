CREATE OR REPLACE FUNCTION gdi_migration.disable_oid(
	schema name,
	tabelle name)
RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
AS $BODY$
DECLARE
    stmt text;
BEGIN
    stmt := 'ALTER TABLE ' || schema || '.' || tabelle || ' ADD newoid bigint;';
    EXECUTE stmt;
    stmt := 'UPDATE ' || schema || '.' || tabelle || ' SET newoid = oid;';
    EXECUTE stmt;
    stmt := 'ALTER TABLE ' || schema || '.' || tabelle || ' ALTER COLUMN newoid NOT NULL;';
    EXECUTE stmt;
	stmt := 'ALTER TABLE ' || schema || '.' || tabelle || ' SET WITHOUT OIDS;';
    EXECUTE stmt;
	COMMIT TRANSACTION;
    RETURN true;
EXCEPTION WHEN OTHERS THEN
	ROLLBACK TRANSACTION;
	raise notice 'function disable_oids(%, %) raised error: %', schema, tabelle, SQLERRM;
	RETURN false;
END;
$BODY$;
