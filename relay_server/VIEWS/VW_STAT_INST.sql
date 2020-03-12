--------------------------------------------------------
--  DDL for View VW_STAT_INST
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_STAT_INST" ("ID_INSTANCE", "ID_WORKFLOW_RUN", "RECORD_TYPE", "RECORD_SUBTYPE", "TIME_BEGIN", "TIME_STOP", "DIFF", "DIFF_S", "GAP_TS", "DIFF_GAP") AS 
  select
   a.id_instance
  ,a.id_workflow_run
  ,b.record_type
  ,b.record_subtype
  ,a.date_record time_begin
  ,b.date_record time_stop
  ,b.date_record - a.date_record diff
  ,f_int_to_sec(b.date_record,a.date_record) diff_s
  ,case when lead(a.id_instance,1) over (order by a.id_instance,a.id_workflow_run) = a.id_instance then
          lead(a.date_record,1) over (order by a.id_instance,a.id_workflow_run)
        else null --b.date_record 
   end gap_ts
  ,f_int_to_sec(case when lead(a.id_instance,1) over (order by a.id_instance,a.id_workflow_run) = a.id_instance then
                       lead(a.date_record,1) over (order by a.id_instance,a.id_workflow_run)
                     else b.date_record 
                end
               ,b.date_record) diff_gap
FROM
   awf_wf_record a
  ,awf_wf_record b
where 1=1
  and b.id_workflow_run = a.id_workflow_run
  and a.record_type = 'INSTANCE'
  and b.record_type = a.record_type
  and a.record_subtype = 'START'
  and b.record_subtype in ('CLOSED','PAUSED')
;
