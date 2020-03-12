--------------------------------------------------------
--  DDL for View VW_ACTION_ACCT
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_ACTION_ACCT" ("ID_RECORD", "ACTION_NAME", "DESCRIPTION", "OBJ_OWNER", "OBJ_NAME", "CODE_ACTION_TYPE", "ID_TEMPLATE", "PROG_OWNER", "PROG_NAME", "PROG_TYPE", "FUNC_RETVAR_NAME", "FUNC_RETVAR_TYPE", "ID_CHECK_STAMP", "IND_SAVE_DATA", "ACCT_ID", "AUTH_ID", "ID_ROW") AS 
  select
  id_record,
  action_name,
  description,
  obj_owner,
  obj_name,
  code_action_type,
  id_template,
  prog_owner,
  prog_name,
  prog_type,
  func_retvar_name,
  func_retvar_type,
  id_check_stamp,
  ind_save_data,
  to_number(relay_p_anydata.f_get_param_vc2('ACCT_ID')) acct_id,
  relay_p_anydata.f_get_param_vc2('AUTH_ID') auth_id,
  rowid id_row
from
  awf_action
;
