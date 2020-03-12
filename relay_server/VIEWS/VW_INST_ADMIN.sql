--------------------------------------------------------
--  DDL for View VW_INST_ADMIN
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_INST_ADMIN" ("ID_INSTANCE", "ID_PARENT_INSTANCE", "IND_INST_ACTIVE", "ID_OWNER", "ID_PROCESS", "PROCESS_NAME", "OBJ_OWNER", "OBJ_NAME", "IND_ALLOW_MORE_INST", "WFID", "NODE_NUMBER", "IND_ACTIVE", "DATE_START", "DATE_SET", "IND_UI_REQD", "AUTH_ID", "ACCT_ID") AS 
  select ai.id_record id_instance
      ,ai.id_parent id_parent_instance
      ,ai.ind_active ind_inst_active
      ,ai.id_owner 
      ,ap.id_record id_process
      ,ap.process_name
      ,ap.obj_owner
      ,ap.obj_name
      ,ap.ind_allow_more_inst
      ,null wfid --TODO
      ,ais.node_number
      ,ais.ind_active
      ,ai.date_start
      ,ais.date_set
      ,ais.ind_ui_reqd
      ,fq.auth_id
      ,fq.acct_id
from  awf_instance ai
     ,awf_process ap
     ,awf_instance_state ais
     ,rly_fqueue_acct fq
where ai.id_process = ap.id_record
  and ais.id_instance = ai.id_record
  and fq.id_record = ai.id_record
;
