--------------------------------------------------------
--  DDL for View RLY_FQUEUE_ACCT
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "RLY_FQUEUE_ACCT" ("ID_RECORD", "ID_REQUEST", "INTERNAL_ID", "FLOW_NAME", "ID_PROCESS", "OBJ_NAME", "NODE_TYPE", "CHANGE_ID", "TIMELIMIT", "IND_CONDITION", "ACCT_ID", "AUTH_ID") AS 
  select
  q.id_record,
  q.id_request,
  q.internal_id,
  q.flow_name,
  q.id_process,
  q.obj_name,
  q.node_type,
  q.change_id,
  q.timelimit,
  q.ind_condition,
  pa.acct_id,
  pa.auth_id
from
  tk_fqueue q
 ,RELAY_PROC_ACCT pa 
where pa.id_record = q.id_process
;
