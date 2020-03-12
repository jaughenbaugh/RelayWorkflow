--------------------------------------------------------
--  DDL for View VW_PROC_ACCT
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_PROC_ACCT" ("ID_RECORD", "ID_BASE_PROCESS", "PROCESS_NAME", "DESCRIPTION", "PROC_REVISION", "ID_REVISED_FROM", "ID_ROLE", "OBJ_OWNER", "OBJ_NAME", "ID_PROC_REC", "IND_ENABLED", "IND_ACTIVE", "IND_AUTO_INITIATE", "IND_ALLOW_MORE_INST", "ID_CHECK_STAMP", "ID_ROW", "ACCT_ID", "AUTH_ID") AS 
  select
  p.id_record,
  p.id_base_process,
  p.process_name,
  p.description,
  p.proc_revision,
  p.id_revised_from,
  p.id_role,
  p.obj_owner,
  p.obj_name,
  p.id_proc_rec,
  p.ind_enabled,
  p.ind_active,
  p.ind_auto_initiate,
  p.ind_allow_more_inst,
  p.id_check_stamp,
  p.rowid id_row,
  relay_p_anydata.f_get_param_vc2('ACCT_ID') acct_id,
  relay_p_anydata.f_get_param_vc2('AUTH_ID') auth_id
from
  awf_process p
-- on prem view
;
