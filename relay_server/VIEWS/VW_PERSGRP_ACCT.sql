--------------------------------------------------------
--  DDL for View VW_PERSGRP_ACCT
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_PERSGRP_ACCT" ("ID_RECORD", "GROUP_NAME", "DESCRIPTION", "GROUP_STATUS", "ACCT_ID", "AUTH_ID", "ID_ROW") AS 
  select
  p.id_record,
  p.group_name,
  p.description,
  p.group_status,
  to_number(relay_p_anydata.f_get_param_vc2('ACCT_ID')) acct_id,
  relay_p_anydata.f_get_param_vc2('AUTH_ID') auth_id,
  p.rowid id_row
from
  awf_person_group p
;
