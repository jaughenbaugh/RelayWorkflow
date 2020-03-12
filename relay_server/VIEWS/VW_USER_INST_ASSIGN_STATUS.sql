--------------------------------------------------------
--  DDL for View VW_USER_INST_ASSIGN_STATUS
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_USER_INST_ASSIGN_STATUS" ("ID_RECORD", "ID_ASSIGNMENT", "DATE_STATUS", "CODE_STATUS", "ID_CHECK_STAMP", "ID_ROW") AS 
  SELECT
    i."ID_RECORD",
    i."ID_ASSIGNMENT",
    i."DATE_STATUS",
    i."CODE_STATUS",
    i."ID_CHECK_STAMP",
    i.rowid   id_row
  FROM
    awf_inst_assign_status i,
    VW_USER_INST_ASSIGN v11
  WHERE
    i.id_assignment = v11.id_record
  ORDER BY
    i.id_assignment
;
