--------------------------------------------------------
--  DDL for View VW_USER_INST_ASSIGN
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_USER_INST_ASSIGN" ("ID_RECORD", "PRIORITY", "ID_ASSIGNEE", "DATE_START", "DATE_DUE", "CODE_STATUS", "ID_INSTANCE", "ID_PROCESS", "ID_PROC_REC", "IND_DECISION", "ID_CHECK_STAMP", "ID_ROW", "PERSON_CODE") AS 
  SELECT
    i."ID_RECORD",
    i."PRIORITY",
    i."ID_ASSIGNEE",
    i."DATE_START",
    i."DATE_DUE",
    i."CODE_STATUS",
    i."ID_INSTANCE",
    i."ID_PROCESS",
    i."ID_PROC_REC",
    i."IND_DECISION",
    i."ID_CHECK_STAMP",
    i.rowid   id_row,
    i.person_code
  FROM
    awf_inst_assign i,
    VW_USER_INSTANCE v9
  WHERE
    i.id_instance = v9.id_record
  ORDER BY
    i.id_instance
;
