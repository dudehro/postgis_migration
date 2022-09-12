CREATE OR REPLACE FUNCTION gdi_migration.execute_ddl(
	ddl_stmt character varying)
RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE
AS $BODY$
BEGIN
    EXECUTE ddl_stmt;
    RETURN '';
EXCEPTION WHEN OTHERS THEN
	RETURN SQLERRM;
END;
$BODY$;
