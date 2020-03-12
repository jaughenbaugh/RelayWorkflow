--------------------------------------------------------
--  DDL for View RLY_OBJ_ACCT
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "RLY_OBJ_ACCT" ("ID_RECORD", "AUTH_ID", "OBJ_NAME", "IND_ACTIVE", "DESCRIPTION", "ACCT_ID", "ID_ROW") AS 
  SELECT
    "ID_RECORD",
    "AUTH_ID",
    "OBJ_NAME",
    "IND_ACTIVE",
    "DESCRIPTION",
    "ACCT_ID",
    "ID_ROW"
  FROM
    relay_obj_acct
;
