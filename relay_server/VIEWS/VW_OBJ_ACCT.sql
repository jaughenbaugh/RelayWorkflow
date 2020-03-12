--------------------------------------------------------
--  DDL for View VW_OBJ_ACCT
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_OBJ_ACCT" ("ID_RECORD", "AUTH_ID", "OBJ_NAME", "IND_ACTIVE", "DESCRIPTION", "ACCT_ID", "ID_ROW") AS 
  select
  o.id_record,
  relay_p_anydata.f_get_param_vc2('AUTH_ID') auth_id,
  o.obj_name,
  o.ind_active,
  o.description,
  to_number(relay_p_anydata.f_get_param_vc2('ACCT_ID')) acct_id,
  o.rowid id_row
from
  tk_object o
;
