--------------------------------------------------------
--  DDL for View VW_USER_PROC_COND
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_USER_PROC_COND" ("ID_RECORD", "CONDITION", "ID_RELATIONSHIP", "OBJ_OWNER", "OBJECT", "IND_MUST_BE", "ID_PROCESS", "ID_PROC_REC", "ID_CHECK_STAMP", "ID_ROW") AS 
  SELECT
    c."ID_RECORD",
    c."CONDITION",
    c."ID_RELATIONSHIP",
    c."OBJ_OWNER",
    c."OBJECT",
    c."IND_MUST_BE",
    c."ID_PROCESS",
    c."ID_PROC_REC",
    c."ID_CHECK_STAMP",
    c.rowid   id_row
  FROM
    awf_conditions c,
    vw_user_proc v1
  WHERE
    c.id_process = v1.id_record
  ORDER BY
    c.id_process,
    c.id_proc_rec
;
