--------------------------------------------------------
--  DDL for View RLY_PERSON_ACCT
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "RLY_PERSON_ACCT" ("ID_RECORD", "PERSON_CODE", "STATUS", "DISPLAY_NAME", "FIRST_NAME", "LAST_NAME", "ID_DELEGATE", "DATE_DELAGATE_START", "DATE_DELEGATE_END", "DATE_STATUS", "EMAIL_ADDRESS", "ID_CHECK_STAMP", "ACCT_ID", "AUTH_ID", "ID_ROW") AS 
  select "ID_RECORD","PERSON_CODE","STATUS","DISPLAY_NAME","FIRST_NAME","LAST_NAME","ID_DELEGATE","DATE_DELAGATE_START","DATE_DELEGATE_END","DATE_STATUS","EMAIL_ADDRESS","ID_CHECK_STAMP","ACCT_ID","AUTH_ID","ID_ROW"
from RELAY_PERSON_ACCT
;
