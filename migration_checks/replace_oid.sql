for table t do

ALTER TABLE t ADD newoid bigint NOT NULL;
UPDATE t SET newoid = oid;
ALTER TABLE t SET WITHOUT OIDS;

done

nach dem upgrade:

for table t do

ALTER TABLE t RENAME newoid TO oid;
CREATE SEQUENCE t_oid_seq OWNED BY t.oid;
ALTER TABLE t ALTER oid SET DEFAULT nextval('t_oid_seq');
SELECT max(oid) FROM t;
SELECT setval('t_oid_seq', max(oid) );

done
