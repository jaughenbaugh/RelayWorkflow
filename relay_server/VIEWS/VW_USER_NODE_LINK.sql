--------------------------------------------------------
--  DDL for View VW_USER_NODE_LINK
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_USER_NODE_LINK" ("ID_RECORD", "ID_PARENT_NODE", "ID_CHILD_NODE", "DESCRIPTION", "IND_IS_POSITIVE", "SEQUENCE", "AMT_FOR_TRUE", "ID_PROCESS", "ID_PROC_REC", "ID_CHECK_STAMP", "ID_ROW") AS 
  SELECT
    n."ID_RECORD",
    n."ID_PARENT_NODE",
    n."ID_CHILD_NODE",
    n."DESCRIPTION",
    n."IND_IS_POSITIVE",
    n."SEQUENCE",
    n."AMT_FOR_TRUE",
    n."ID_PROCESS",
    n."ID_PROC_REC",
    n."ID_CHECK_STAMP",
    n.rowid   id_row
  FROM
    awf_node_link n,
    vw_user_proc v2
  WHERE
    n.id_process = v2.id_record
  ORDER BY
    n.id_process,
    n.id_proc_rec
;
