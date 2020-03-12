--------------------------------------------------------
--  DDL for View VW_STAT_LINK
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_STAT_LINK" ("ID_INSTANCE", "ID_WORKFLOW_RUN", "ID_PROC_REC", "ID_CHILD_REC", "RECORD_TYPE", "RECORD_SUBTYPE", "TIME_BEGIN") AS 
  select
   a.id_instance
  ,a.id_workflow_run
  ,a.id_proc_rec
  ,a.id_child_rec
  ,a.record_type
  ,a.record_subtype
  ,a.date_record time_begin
FROM
   awf_wf_record a
where 1=1
  and a.record_type = 'LINK'
  and a.record_subtype = 'USED'
order by id_workflow_run, id_proc_rec
;
