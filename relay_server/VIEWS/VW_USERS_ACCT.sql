--------------------------------------------------------
--  DDL for View VW_USERS_ACCT
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_USERS_ACCT" ("ID_RECORD", "ID_CHECK_STAMP", "USER_NAME", "USER_PW", "USER_STATUS", "USER_EMAIL", "LOGIN_FAILURES", "FIRST_NAME", "LAST_NAME", "IND_ADMIN", "IND_OWNER", "ACCT_ID", "AUTH_ID", "ID_ROW") AS 
  select
  id_record,
  id_check_stamp,
  user_name,
  user_pw,
  user_status,
  user_email,
  login_failures,
  first_name,
  last_name,
  ind_admin,
  ind_owner,
  to_number(relay_p_anydata.f_get_param_vc2('ACCT_ID')) acct_id,
  relay_p_anydata.f_get_param_vc2('AUTH_ID') auth_id,
  rowid id_row
from
  awf_users
;
