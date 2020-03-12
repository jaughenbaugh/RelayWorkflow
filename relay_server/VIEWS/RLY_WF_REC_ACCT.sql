--------------------------------------------------------
--  DDL for View RLY_WF_REC_ACCT
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "RLY_WF_REC_ACCT" ("ID_RECORD", "ID_PROCESS", "ID_OWNER", "ID_INSTANCE", "ID_WORKFLOW_RUN", "RECORD_TYPE", "RECORD_SUBTYPE", "DATE_RECORD", "ID_PROC_REC", "ID_CHILD_REC", "NOTES", "ID_CHECK_STAMP", "ACCT_ID", "AUTH_ID", "ID_REQUEST") AS 
  select wr."ID_RECORD",wr."ID_PROCESS",wr."ID_OWNER",wr."ID_INSTANCE",wr."ID_WORKFLOW_RUN",wr."RECORD_TYPE",wr."RECORD_SUBTYPE",wr."DATE_RECORD",wr."ID_PROC_REC",wr."ID_CHILD_REC",wr."NOTES",wr."ID_CHECK_STAMP", q.acct_id, q.auth_id, q.id_request
from awf_wf_record wr
    ,RLY_FQUEUE_ACCT q
where q.id_record = wr.id_instance
order by wr.id_record
;
