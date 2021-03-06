--------------------------------------------------------
--  DDL for View RLY_PROCESS_ACCT
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "RLY_PROCESS_ACCT" ("ID_RECORD", "ID_BASE_PROCESS", "PROCESS_NAME", "DESCRIPTION", "PROC_REVISION", "ID_REVISED_FROM", "ID_ROLE", "OBJ_OWNER", "OBJ_NAME", "ID_PROC_REC", "IND_ENABLED", "IND_ACTIVE", "IND_AUTO_INITIATE", "IND_ALLOW_MORE_INST", "ID_CHECK_STAMP", "ID_ROW", "ACCT_ID", "AUTH_ID") AS 
  select "ID_RECORD","ID_BASE_PROCESS","PROCESS_NAME","DESCRIPTION","PROC_REVISION","ID_REVISED_FROM","ID_ROLE","OBJ_OWNER","OBJ_NAME","ID_PROC_REC","IND_ENABLED","IND_ACTIVE","IND_AUTO_INITIATE","IND_ALLOW_MORE_INST","ID_CHECK_STAMP","ID_ROW","ACCT_ID","AUTH_ID"
from RELAY_PROC_ACCT
;
