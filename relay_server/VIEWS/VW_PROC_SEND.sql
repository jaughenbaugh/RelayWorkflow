--------------------------------------------------------
--  DDL for View VW_PROC_SEND
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_PROC_SEND" ("ID_PROCESS", "ID_RECORD", "ID_TEMPLATE", "SEND_TO_TYPE", "SEND_TO_GROUP", "SEND_TO", "ID_CHECK_STAMP") AS 
  select t.id_process, s."ID_RECORD",s."ID_TEMPLATE",s."SEND_TO_TYPE",s."SEND_TO_GROUP",s."SEND_TO",s."ID_CHECK_STAMP" 
from awf_comm_send_to s 
    ,vw_proc_comm t
where s.id_template = t.id_record
order by id_template, send_to_type, send_to
;
