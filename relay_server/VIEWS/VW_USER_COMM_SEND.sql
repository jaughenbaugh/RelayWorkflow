--------------------------------------------------------
--  DDL for View VW_USER_COMM_SEND
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_USER_COMM_SEND" ("ID_RECORD", "ID_TEMPLATE", "SEND_TO_TYPE", "SEND_TO_GROUP", "SEND_TO", "ID_CHECK_STAMP", "ID_ROW") AS 
  SELECT
    c."ID_RECORD",
    c."ID_TEMPLATE",
    c."SEND_TO_TYPE",
    c."SEND_TO_GROUP",
    c."SEND_TO",
    c."ID_CHECK_STAMP",
    c.rowid   id_row
  FROM
    awf_comm_send_to c,
    VW_USER_COMM_TEMP v16
  WHERE
    c.id_template = v16.id_record
;
