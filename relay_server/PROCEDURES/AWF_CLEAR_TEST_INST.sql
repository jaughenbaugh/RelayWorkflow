--------------------------------------------------------
--  DDL for Procedure AWF_CLEAR_TEST_INST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "AWF_CLEAR_TEST_INST" AS 
BEGIN
  delete from AWF_ERROR_LOG;
  delete from AWF_INST_ASSIGN;
  delete from AWF_INST_ASSIGN_STATUS;
  delete from AWF_INST_LOG;
  delete from AWF_INST_VARS;
  delete from AWF_INSTANCE;
  delete from AWF_INSTANCE_STATE;
  delete from AWF_WF_RECORD;
  delete from AWF_INST_NODE_LINKS;
  delete from AWF_LOGGER_LOG;
  delete from AWF_INST_DATA;
END AWF_CLEAR_TEST_INST;

/
