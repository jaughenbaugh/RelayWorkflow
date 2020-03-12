--------------------------------------------------------
--  DDL for View VW_USER_NODE_SUBPROC
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_USER_NODE_SUBPROC" ("ID_RECORD", "ID_CHECK_STAMP", "ID_PROCESS", "ID_PROC_REC", "ID_NODE", "ID_SUBPROCESS", "EXEC_ACTION", "SUBPROCESS_SEQ", "ID_ROW") AS 
  SELECT
    n."ID_RECORD",
    n."ID_CHECK_STAMP",
    n."ID_PROCESS",
    n."ID_PROC_REC",
    n."ID_NODE",
    n."ID_SUBPROCESS",
    n."EXEC_ACTION",
    n."SUBPROCESS_SEQ",
    n.rowid   id_row
  FROM
    awf_node_subprocess n,
    vw_user_proc v2
  WHERE
    n.id_process = v2.id_record
  ORDER BY
    n.id_process,
    n.id_proc_rec
;
