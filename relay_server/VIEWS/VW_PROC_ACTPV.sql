--------------------------------------------------------
--  DDL for View VW_PROC_ACTPV
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_PROC_ACTPV" ("ID_PROCESS", "ID_RECORD", "ID_CHECK_STAMP", "ID_SEQUENCE", "ACT_PARAMETER", "ACT_PARAM_TYPE", "ACT_PARAM_DIR", "ACT_VALUE", "OBJ_OWNER", "OBJ_NAME", "ACTION_NAME", "ACT_PAR_TARGET", "VAR_SOURCE_TYPE", "ID_ACTION") AS 
  select pa.id_process, ap."ID_RECORD",ap."ID_CHECK_STAMP",ap."ID_SEQUENCE",ap."ACT_PARAMETER",ap."ACT_PARAM_TYPE",ap."ACT_PARAM_DIR",ap."ACT_VALUE",ap."OBJ_OWNER",ap."OBJ_NAME",ap."ACTION_NAME",ap."ACT_PAR_TARGET",ap."VAR_SOURCE_TYPE",ap."ID_ACTION" 
  from awf_action_pv ap
      ,vw_proc_actions pa
  where ap.id_action = pa.id_record
  order by pa.id_process,ap.id_action,ap.act_parameter
;
