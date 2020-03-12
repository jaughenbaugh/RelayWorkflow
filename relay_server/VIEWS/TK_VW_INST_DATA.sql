--------------------------------------------------------
--  DDL for View TK_VW_INST_DATA
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "TK_VW_INST_DATA" ("ID_RECORD", "ID_INSTANCE", "VAR_TYPE", "VAR_NAME", "VAR_VALUE", "VAR_SOURCE", "VAR_SEQUENCE", "IND_CHANGED") AS 
  SELECT
  id_record,
  id_instance,
  var_type,
  var_name,
  pkg_anydata.f_anydata_to_clob(var_value) var_value,
  var_source,
  var_sequence,
  ind_changed
FROM
  awf_inst_data
;
