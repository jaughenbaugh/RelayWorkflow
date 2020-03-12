--------------------------------------------------------
--  DDL for View VW_USER_INST_STATE
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_USER_INST_STATE" ("ID_RECORD", "ID_INSTANCE", "NODE_NUMBER", "NODE_STATUS", "IND_ACTIVE", "ID_PROCESS", "DATE_SET", "IND_UI_REQD", "ID_LINK_FWD", "ID_CHECK_STAMP", "ID_ROW") AS 
  SELECT
    i."ID_RECORD",
    i."ID_INSTANCE",
    i."NODE_NUMBER",
    i."NODE_STATUS",
    i."IND_ACTIVE",
    i."ID_PROCESS",
    i."DATE_SET",
    i."IND_UI_REQD",
    i."ID_LINK_FWD",
    i."ID_CHECK_STAMP",
    i.rowid   id_row
  FROM
    awf_instance_state i,
    VW_USER_INSTANCE v9
  WHERE
    i.id_instance = v9.id_record
  ORDER BY
    i.id_instance
;
