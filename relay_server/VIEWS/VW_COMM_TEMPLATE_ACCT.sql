--------------------------------------------------------
--  DDL for View VW_COMM_TEMPLATE_ACCT
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_COMM_TEMPLATE_ACCT" ("ID_RECORD", "TEMPLATE_NAME", "DESCRIPTION", "OBJ_OWNER", "OBJECT_NAME", "SEND_FROM_EMAIL", "REPLY_TO_EMAIL", "SUBJECT_LINE", "MESSAGE_BODY_PT", "MESSAGE_BODY_HTML", "ID_CHECK_STAMP", "ACCT_ID", "AUTH_ID", "ID_ROW") AS 
  select
  t.id_record,
  t.template_name,
  t.description,
  t.obj_owner,
  t.object_name,
  t.send_from_email,
  t.reply_to_email,
  t.subject_line,
  t.message_body_pt,
  t.message_body_html,
  t.id_check_stamp,
  to_number(relay_p_anydata.f_get_param_vc2('ACCT_ID')) acct_id,
  relay_p_anydata.f_get_param_vc2('AUTH_ID') auth_id,
  t.rowid id_row
from
  awf_comm_template t
;
