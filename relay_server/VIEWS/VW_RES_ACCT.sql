--------------------------------------------------------
--  DDL for View VW_RES_ACCT
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_RES_ACCT" ("RES_TYPE", "ID_RECORD", "ROLE_DESC", "ACCT_ID", "AUTH_ID") AS 
  select
  'GROUP' res_type,
  id_record,
  group_name||': '||description role_desc,
  acct_id,
  auth_id
from
  relay_persgrp_acct
where group_status = 1
union all  
select
  'PERSON' res_type,
  id_record,
  first_name||' '||last_name||' ('||email_address||')' role_desc,
  acct_id,
  auth_id
from
  relay_person_acct
where status = 'ACTIVE'
;
