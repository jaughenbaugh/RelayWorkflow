--------------------------------------------------------
--  DDL for View VW_ROLE_ACCT
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_ROLE_ACCT" ("ID_RECORD", "ROLE_NAME", "DESCRIPTION", "ROLE_TYPE", "IND_BROADCAST", "VALUE", "ID_CHECK_STAMP", "IND_REL_DATA", "OBJ_COL", "ACCT_ID", "AUTH_ID", "ID_ROW") AS 
  select
  p.id_record,
  p.role_name,
  p.description,
  p.role_type,
  p.ind_broadcast,
  p.value,
  p.id_check_stamp,
  p.ind_rel_data,
  p.obj_col,
  to_number(relay_p_anydata.f_get_param_vc2('ACCT_ID')) acct_id,
  relay_p_anydata.f_get_param_vc2('AUTH_ID') auth_id,
  p.rowid id_row
from
  awf_roles p
;
