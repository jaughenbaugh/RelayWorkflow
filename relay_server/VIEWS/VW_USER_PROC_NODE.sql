--------------------------------------------------------
--  DDL for View VW_USER_PROC_NODE
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_USER_PROC_NODE" ("ID_RECORD", "ID_PROCESS", "ID_PROC_REC", "NODE_TYPE", "LAYOUT_COLUMN", "LAYOUT_ROW", "NODE_NAME", "DESCRIPTION", "IND_DISP_IF_ONE", "AMT_FOR_TRUE", "INTERVAL", "INTERVAL_UOM", "IND_CONTINUE", "ID_SUBPROCESS", "ID_CHECK_STAMP", "ID_ROW") AS 
  SELECT n."ID_RECORD",
    n."ID_PROCESS",
    n."ID_PROC_REC",
    n."NODE_TYPE",
    n."LAYOUT_COLUMN",
    n."LAYOUT_ROW",
    n."NODE_NAME",
    n."DESCRIPTION",
    n."IND_DISP_IF_ONE",
    n."AMT_FOR_TRUE",
    n."INTERVAL",
    n."INTERVAL_UOM",
    n."IND_CONTINUE",
    n."ID_SUBPROCESS",
    n."ID_CHECK_STAMP",
    n.rowid id_row
  FROM awf_node n,
    vw_user_proc v2
  WHERE n.id_process = v2.id_record
  ORDER BY n.id_process,
    n.id_proc_rec
;
