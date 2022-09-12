# Create Schema with functions and views for every database
psql kvwmapsp kvwmap -f 0_create_schema.sql

# Tabellen mit WITH OIDs und Abhängigkeiten identifizieren
psql kvwmapsp kvwmap -f 1_fill_oid_tables.sql

# Abhängigkeiten löschen, OIDs entfernen
psql kvwmapsp kvwmap -f 2_disable_oids.sql

# pg_dump

# restore der OID-Tabellen aus Tabelle gdi_migration.oid_tables

# pg_restore
wird auf Fehler laufen weil Abhängigkeiten nicht erfüllt werden können

# 
