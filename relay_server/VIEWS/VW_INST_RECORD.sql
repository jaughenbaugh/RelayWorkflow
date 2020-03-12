--------------------------------------------------------
--  DDL for View VW_INST_RECORD
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_INST_RECORD" ("RUN_INDEX", "ENTRY_ID", "RECORD_TYPE", "RECORD_SUBTYPE", "ENTRY_DATE", "OBJECT_ID", "ID_INSTANCE", "ID_PROCESS", "PROCESS_NAME") AS 
  select  wr.id_workflow_run run_index
       ,wr.id_record entry_id
       ,wr.record_type 
       ,wr.record_subtype
       ,wr.date_record entry_date
       ,wr.id_proc_rec object_id
       ,wi.id_instance
       ,wi.id_process
       ,wi.process_name
from    awf_wf_record wr
       ,vw_wf_instances wi
where   wi.id_instance = wr.id_instance
order by wr.id_workflow_run, wr.id_record
;
