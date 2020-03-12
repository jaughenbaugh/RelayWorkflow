--------------------------------------------------------
--  DDL for View VW_PROCESS_RECORDS
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_PROCESS_RECORDS" ("OBJ", "ID_PROCESS", "ID_PROC_REC", "ID_RECORD") AS 
  select 'PROCESS' obj, id_record id_process, id_proc_rec, id_record 
from awf_process
union all
select 'NODE' obj, id_process, id_proc_rec, id_record
from awf_node
union all
select 'NODE_ACTION' obj, id_process, ID_PROC_REC, id_record
from awf_node_action
union all
select 'NODE_LINK' obj, id_process, ID_PROC_REC, id_record
from awf_node_link
union all
select 'CONDITIONS' obj, id_process, ID_PROC_REC, id_record
from awf_conditions
union all
select 'NODE_ASSIGN' obj, id_process, ID_PROC_REC, id_record
from awf_node_assignment
;
