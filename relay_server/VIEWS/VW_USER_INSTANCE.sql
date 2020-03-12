--------------------------------------------------------
--  DDL for View VW_USER_INSTANCE
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_USER_INSTANCE" ("ID_RECORD", "ID_PARENT", "IND_ACTIVE", "INSTANCE_ORIG", "DATE_START", "ID_PROCESS", "ID_OWNER", "ID_CHECK_STAMP", "ID_ROW") AS 
  SELECT
    i."ID_RECORD",
    i."ID_PARENT",
    i."IND_ACTIVE",
    i."INSTANCE_ORIG",
    i."DATE_START",
    i."ID_PROCESS",
    i."ID_OWNER",
    i."ID_CHECK_STAMP",
    i.rowid   id_row
  FROM
    awf_instance i,
    vw_user_proc v2
  WHERE
    i.id_process = v2.id_record
  ORDER BY
    i.id_process
;
