--------------------------------------------------------
--  DDL for View VW_PERSON_ACCT
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_PERSON_ACCT" ("ID_RECORD", "PERSON_CODE", "STATUS", "DISPLAY_NAME", "FIRST_NAME", "LAST_NAME", "ID_DELEGATE", "DATE_DELAGATE_START", "DATE_DELEGATE_END", "DATE_STATUS", "EMAIL_ADDRESS", "ID_CHECK_STAMP", "ACCT_ID", "AUTH_ID", "ID_ROW") AS 
  select
  p.id_record,
  p.person_code,
  p.status,
  p.display_name,
  p.first_name,
  p.last_name,
  p.id_delegate,
  p.date_delagate_start,
  p.date_delegate_end,
  p.date_status,
  p.email_address,
  p.id_check_stamp,
  to_number(relay_p_anydata.f_get_param_vc2('ACCT_ID')) acct_id,
  relay_p_anydata.f_get_param_vc2('AUTH_ID') auth_id,
  p.rowid id_row
from
  awf_person p
;
