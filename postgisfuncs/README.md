* select_postgisfuncs.sql
SELECT-Stmt liefert alle pgsql-Functionen die "$libdir/postgis-2.5" referenzieren

* rm_funcs_from_idx.sh
Nimmt eine mit "pg_dump -l " erstellte Index-Daten und kommentiert alle mit select_postgisfuncs.sql gefundenen Funktionen aus.
