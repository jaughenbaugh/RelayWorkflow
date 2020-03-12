--------------------------------------------------------
--  DDL for View VW_INSTANCE_DATA
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_INSTANCE_DATA" ("ID_INSTANCE", "ID_PARENT_INSTANCE", "IND_INST_ACTIVE", "ID_OWNER", "ID_PROCESS", "PROCESS_NAME", "OBJ_OWNER", "OBJ_NAME", "IND_ALLOW_MORE_INST", "WFID") AS 
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
from  awf_instance ai
     ,awf_process ap
where ai.id_process = ap.id_record
;
