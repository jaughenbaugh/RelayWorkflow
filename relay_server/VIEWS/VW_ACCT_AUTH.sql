--------------------------------------------------------
--  DDL for View VW_ACCT_AUTH
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_ACCT_AUTH" ("ID_RECORD", "ID_ACCOUNT", "ID_AUTH", "DATE_MOD", "IND_EXPIRED", "ALLOWANCE") AS 
  select 1000 id_record
      ,relay_p_anydata.f_get_param_vc2('ACCT_ID') id_account
      ,relay_p_anydata.f_get_param_vc2('AUTH_ID') id_auth
      ,sysdate date_mod
      ,0 ind_expired
      ,999999 allowance
from dual
;
