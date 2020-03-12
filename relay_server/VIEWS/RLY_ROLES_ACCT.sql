--------------------------------------------------------
--  DDL for View RLY_ROLES_ACCT
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "RLY_ROLES_ACCT" ("ID_RECORD", "ROLE_NAME", "DESCRIPTION", "ROLE_TYPE", "IND_BROADCAST", "VALUE", "ID_CHECK_STAMP", "IND_REL_DATA", "OBJ_COL", "ACCT_ID", "AUTH_ID", "ID_ROW") AS 
  select "ID_RECORD","ROLE_NAME","DESCRIPTION","ROLE_TYPE","IND_BROADCAST","VALUE","ID_CHECK_STAMP","IND_REL_DATA","OBJ_COL","ACCT_ID","AUTH_ID","ID_ROW"
from RELAY_ROLE_ACCT pg
;
