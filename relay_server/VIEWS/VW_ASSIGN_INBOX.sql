--------------------------------------------------------
--  DDL for View VW_ASSIGN_INBOX
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_ASSIGN_INBOX" ("ID_ASSIGNMENT", "ID_ASSIGNEE", "CODE_STATUS", "PRIORITY", "PROCESS_NAME", "ASSIGNMENT", "ID_OWNER", "NODE_TYPE", "ID_PROCESS", "IND_DECISION", "PERSON_CODE", "ID_INSTANCE") AS 
  select  ia.id_record id_assignment
       ,ia.id_assignee
       ,ia.code_status
       ,ia.priority
       ,ar.process_name
       ,na.description assignment
       ,wi.id_owner
       ,an.node_type
       ,wi.id_process
       ,ia.ind_decision
       ,ia.person_code
       ,wi.id_instance
from    awf_process ar
       ,vw_wf_instances wi
       ,awf_inst_assign ia
       ,awf_node_assignment na
       ,vw_active_nodes an
where   1=1
  and   wi.process_name = ar.process_name
  and   ia.id_instance = wi.id_instance
  and   na.id_process = ia.id_process
  and   na.id_proc_rec = ia.id_proc_rec
  and   an.id_process = ia.id_process
  and   an.id_proc_rec = wi.node_number
  and   an.id_owner = wi.id_owner
  and   ar.ind_enabled = 1
  and   ia.code_status != 'CLOSED'
  and   wi.inst_active = 1
;
