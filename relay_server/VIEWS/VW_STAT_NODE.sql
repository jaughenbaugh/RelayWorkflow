--------------------------------------------------------
--  DDL for View VW_STAT_NODE
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_STAT_NODE" ("ID_INSTANCE", "ID_WORKFLOW_RUN", "ID_PROC_REC", "RECORD_TYPE", "TIME_BEGIN", "TIME_STOP", "DIFF", "DIFF_S") AS 
  select
   a.id_instance
  ,a.id_workflow_run
  ,a.id_proc_rec
  ,b.record_type
  ,a.date_record time_begin
  ,b.date_record time_stop
  ,b.date_record - a.date_record diff
  ,f_int_to_sec(b.date_record,a.date_record) diff_s
FROM
   awf_wf_record a
  ,awf_wf_record b
where 1=1
  and b.id_workflow_run = a.id_workflow_run
  and b.id_proc_rec = a.id_proc_rec
  and a.record_type = 'NODE'
  and b.record_type = a.record_type
  and a.record_subtype = 'START'
  and b.record_subtype = 'END'
order by id_workflow_run, id_proc_rec
;
