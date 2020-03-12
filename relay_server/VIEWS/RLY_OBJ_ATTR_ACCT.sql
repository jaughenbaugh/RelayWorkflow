--------------------------------------------------------
--  DDL for View RLY_OBJ_ATTR_ACCT
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "RLY_OBJ_ATTR_ACCT" ("ID_RECORD", "ID_OBJECT", "OBJ_NAME", "ATTR_NAME", "ATTR_TYPE", "SEQ_ID", "IND_UPD", "IND_KEY", "ACCT_ID", "AUTH_ID") AS 
  select
    a."ID_RECORD",
    a."ID_OBJECT",
    o.obj_name,
    a."ATTR_NAME",
    a."ATTR_TYPE",
    a."SEQ_ID",
    a."IND_UPD",
    a."IND_KEY",
    o.acct_id,
    o.auth_id
  from
    tk_obj_attr      a,
    relay_obj_acct   o
  where
    o.id_record = a.id_object
;
