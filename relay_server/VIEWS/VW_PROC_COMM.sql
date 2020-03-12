--------------------------------------------------------
--  DDL for View VW_PROC_COMM
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_PROC_COMM" ("ID_PROCESS", "ID_RECORD", "TEMPLATE_NAME", "DESCRIPTION", "OBJ_OWNER", "OBJECT_NAME", "SEND_FROM_EMAIL", "REPLY_TO_EMAIL", "SUBJECT_LINE", "MESSAGE_BODY_PT", "MESSAGE_BODY_HTML", "ID_CHECK_STAMP") AS 
  select p.id_process, t."ID_RECORD",t."TEMPLATE_NAME",t."DESCRIPTION",t."OBJ_OWNER",t."OBJECT_NAME",t."SEND_FROM_EMAIL",t."REPLY_TO_EMAIL",t."SUBJECT_LINE",t."MESSAGE_BODY_PT",t."MESSAGE_BODY_HTML",t."ID_CHECK_STAMP" 
from   awf_comm_template t
      ,(select distinct id_process, id_template from 
        (select id_process, id_email_template id_template
         from awf_node_assignment
         union all
         select id_process, id_template
         from vw_proc_actions)) p
where  t.id_record = p.id_template
;
