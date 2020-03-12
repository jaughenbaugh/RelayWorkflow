--------------------------------------------------------
--  DDL for View VW_METRIC_TTP
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_METRIC_TTP" ("E_RANK", "ELEMENT", "ID_PROCESS", "ID_PARENT", "ID_CHILD", "E_ID", "E_TYPE", "E_NAME", "E_DESC", "ID_INSTANCE", "DATE_START", "ID_OWNER", "TTC3", "ID_WORKFLOW_RUN") AS 
  select 
       pe."E_RANK",pe."ELEMENT",pe."ID_PROCESS",pe."ID_PARENT",pe."ID_CHILD",pe."E_ID",pe."E_TYPE",pe."E_NAME",pe."E_DESC"
      ,ai.id_record id_instance
      ,ai.date_start
      ,ai.id_owner
      ,m1.ttc3
      ,m1.id_workflow_run
from 
      vw_metric_element pe
     ,awf_instance ai
     ,vw_metric_01 m1
where 1=1 
  and m1.id_instance = ai.id_record 
  and m1.id_proc_rec = case when pe.element = 'PROCESS' then ai.id_record else pe.e_id end
  and m1.record_type = case when pe.element = 'PROCESS' then 'INSTANCE' else pe.element end
  and ai.id_process = pe.id_process
  and ai.ind_active = 0
  and pe.element is not null
order by pe.id_process, ai.id_record, pe.e_rank, pe.e_id
;
