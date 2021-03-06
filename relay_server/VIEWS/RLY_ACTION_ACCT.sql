--------------------------------------------------------
--  DDL for View RLY_ACTION_ACCT
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "RLY_ACTION_ACCT" ("ID_RECORD", "ACTION_NAME", "DESCRIPTION", "OBJ_OWNER", "OBJ_NAME", "CODE_ACTION_TYPE", "ID_TEMPLATE", "PROG_OWNER", "PROG_NAME", "PROG_TYPE", "FUNC_RETVAR_NAME", "FUNC_RETVAR_TYPE", "ID_CHECK_STAMP", "IND_SAVE_DATA", "ACCT_ID", "AUTH_ID", "ID_ROW") AS 
  select "ID_RECORD","ACTION_NAME","DESCRIPTION","OBJ_OWNER","OBJ_NAME","CODE_ACTION_TYPE","ID_TEMPLATE","PROG_OWNER","PROG_NAME","PROG_TYPE","FUNC_RETVAR_NAME","FUNC_RETVAR_TYPE","ID_CHECK_STAMP","IND_SAVE_DATA","ACCT_ID","AUTH_ID","ID_ROW" 
from relay_action_acct
;
