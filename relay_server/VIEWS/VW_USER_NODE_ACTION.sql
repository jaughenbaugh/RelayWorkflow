--------------------------------------------------------
--  DDL for View VW_USER_NODE_ACTION
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_USER_NODE_ACTION" ("ID_RECORD", "ACTION_NAME", "ID_RELATIONSHIP", "SEQUENCE", "AMT_FOR_TRUE", "IND_STOP_ON_ERROR", "ID_PROCESS", "ID_PROC_REC", "ID_NODE_NUMBER", "ID_CHECK_STAMP", "ID_ROW") AS 
  SELECT
    n."ID_RECORD",
    n."ACTION_NAME",
    n."ID_RELATIONSHIP",
    n."SEQUENCE",
    n."AMT_FOR_TRUE",
    n."IND_STOP_ON_ERROR",
    n."ID_PROCESS",
    n."ID_PROC_REC",
    n."ID_NODE_NUMBER",
    n."ID_CHECK_STAMP",
    n.rowid   id_row
  FROM
    awf_node_action n,
    vw_user_proc v2
  WHERE
    n.id_process = v2.id_record
  ORDER BY
    n.id_process,
    n.id_proc_rec
;
