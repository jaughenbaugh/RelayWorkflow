--------------------------------------------------------
--  DDL for View VW_USER_NODE_ASSIGN
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_USER_NODE_ASSIGN" ("ID_RECORD", "DESCRIPTION", "PRIORITY", "IND_NOTIFY_BY_EMAIL", "NODE_NUMBER", "ID_ROLE", "ID_ESCROLE", "ID_EMAIL_TEMPLATE", "ID_PROCESS", "ID_PROC_REC", "AMT_FOR_TRUE", "ID_CHECK_STAMP", "ID_ROW") AS 
  SELECT
    n."ID_RECORD",
    n."DESCRIPTION",
    n."PRIORITY",
    n."IND_NOTIFY_BY_EMAIL",
    n."NODE_NUMBER",
    n."ID_ROLE",
    n."ID_ESCROLE",
    n."ID_EMAIL_TEMPLATE",
    n."ID_PROCESS",
    n."ID_PROC_REC",
    n."AMT_FOR_TRUE",
    n."ID_CHECK_STAMP",
    n.rowid   id_row
  FROM
    awf_node_assignment n,
    vw_user_proc v2
  WHERE
    n.id_process = v2.id_record
  ORDER BY
    n.id_process,
    n.id_proc_rec
;
