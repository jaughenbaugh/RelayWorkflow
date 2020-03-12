--------------------------------------------------------
--  DDL for View VW_METRIC_01
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_METRIC_01" ("ID_PROCESS", "ID_OWNER", "ID_INSTANCE", "ID_WORKFLOW_RUN", "RECORD_TYPE", "TTC3", "ID_PROC_REC", "ID_CHILD_REC", "DATE_START", "DATE_END") AS 
  SELECT
      wr1.id_process,
      wr1.id_owner,
      wr1.id_instance,
      wr1.id_workflow_run,
      wr1.record_type,
      abs(extract(second from wr2.date_record - wr1.date_record) 
        + extract(minute from wr2.date_record - wr1.date_record)*60 
        + extract(hour from wr2.date_record - wr1.date_record)*60*60 
        + extract(day from wr2.date_record - wr1.date_record)*24*60*60) ttc3,
      wr1.id_proc_rec,
      wr1.id_child_rec,
      to_date(to_char(wr1.date_record,'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS') date_start,
      to_date(to_char(wr2.date_record,'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS') date_end
FROM  (select * from awf_wf_record where record_subtype in ('CREATED','START','USED'))  wr1,
      (select * from awf_wf_record where record_subtype in ('END','COMPLETED','STOP','USED'))  wr2
where wr2.id_instance (+)= wr1.id_instance
  and wr2.id_workflow_run (+)= wr1.id_workflow_run
  and wr2.record_type (+)= wr1.record_type
  and nvl(wr2.id_proc_rec,-1) = nvl(wr1.id_proc_rec,-1)
order by wr1.id_instance, wr1.record_type
;
