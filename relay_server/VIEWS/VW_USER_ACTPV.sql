--------------------------------------------------------
--  DDL for View VW_USER_ACTPV
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_USER_ACTPV" ("ID_RECORD", "ID_CHECK_STAMP", "ID_SEQUENCE", "ACT_PARAMETER", "ACT_PARAM_TYPE", "ACT_PARAM_DIR", "ACT_VALUE", "OBJ_OWNER", "OBJ_NAME", "ACTION_NAME", "ACT_PAR_TARGET", "VAR_SOURCE_TYPE", "ID_ROW") AS 
  SELECT 
-- comment after the select keyword
    pv."ID_RECORD",
    pv."ID_CHECK_STAMP",
    pv."ID_SEQUENCE",
    pv."ACT_PARAMETER",
    pv."ACT_PARAM_TYPE",
    pv."ACT_PARAM_DIR",
    case when pv.ACT_VALUE is not null then relay_p_anydata.f_anydata_to_clob(pv.ACT_VALUE) else null end ACT_VALUE,
    pv."OBJ_OWNER",
    pv."OBJ_NAME",
    pv."ACTION_NAME",
    pv."ACT_PAR_TARGET",
    pv."VAR_SOURCE_TYPE",
    pv.rowid   id_row
  FROM
    awf_action_pv pv,
    RELAY_USER_ACTIONS v1
  WHERE
    pv.action_name = v1.action_name
;
