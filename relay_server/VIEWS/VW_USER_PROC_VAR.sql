--------------------------------------------------------
--  DDL for View VW_USER_PROC_VAR
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_USER_PROC_VAR" ("ID_RECORD", "ID_PROCESS", "VAR_NAME", "VAR_TYPE", "NOTES", "IND_ACTIVE", "ID_CHECK_STAMP", "DEFAULT_VAR_VALUE", "DVAR_VALUE_TYPE", "ID_ROW") AS 
  SELECT
    pv."ID_RECORD",
    pv."ID_PROCESS",
    pv."VAR_NAME",
    pv."VAR_TYPE",
    pv."NOTES",
    pv."IND_ACTIVE",
    pv."ID_CHECK_STAMP",
    relay_p_anydata.f_anydata_to_clob(pv.DEFAULT_VAR_VALUE) "DEFAULT_VAR_VALUE",
    pv."DVAR_VALUE_TYPE",
    pv.rowid   id_row
  FROM
    awf_proc_vars pv,
    vw_user_proc v3
  WHERE
    pv.id_process = v3.id_record
;
