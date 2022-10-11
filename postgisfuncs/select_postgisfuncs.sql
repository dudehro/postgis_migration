SELECT	CASE typns.nspname
			WHEN 'pg_catalog' THEN
				'FUNCTION ' || ns.nspname || ' ' || func.proname || '(' || string_agg(typ.typname, ', ') || ')'
			ELSE
				'FUNCTION ' || ns.nspname || ' ' || func.proname || '(' || string_agg(typns.nspname|| '.' ||typ.typname, ', ') || ')'
		END functionname
FROM	pg_proc func
JOIN	pg_namespace	ns		ON	func.pronamespace = ns.oid
JOIN	pg_type			typ 	ON	typ.oid = ANY(func.proargtypes)
JOIN	pg_namespace	typns	ON	typns.oid = typ.typnamespace
AND		func.probin = '$libdir/postgis-2.5'
--AND		func.proname = 'box2df_out'
GROUP BY func.proname, ns.nspname, typns.nspname
