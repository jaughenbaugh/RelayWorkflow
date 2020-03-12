--------------------------------------------------------
--  DDL for View VW_ACTIVE_NODES
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_ACTIVE_NODES" ("ID_INSTANCE", "ID_PROCESS", "ID_PROC_REC", "NODE_TYPE", "NODE_NAME", "DESCRIPTION", "IND_DISP_IF_ONE", "AMT_FOR_TRUE", "IND_CONTINUE", "PROCESS_NAME", "UI_REQUIRED", "ID_OWNER", "TIME_WAIT", "COND") AS 
  select  i.id_instance,
        n.id_process, 
        n.id_proc_rec, 
        n.node_type, 
        n.node_name, 
        n.description, 
        n.ind_disp_if_one, 
        n.amt_for_true, 
        n.ind_continue, 
        i.process_name, 
        i.ui_required,
        i.id_owner,
        round(case interval_uom when 'DAYS' then 1 when 'HOURS' then 1/24 when 'MINUTES' then 1/24/60 else 0 end * interval,11) time_wait,
        (select count(*) from awf_conditions where id_process = i.id_process and id_proc_rec = i.node_number) cond
from    awf_node n
       ,vw_wf_instances i
where   n.id_process = i.id_process
  and   i.inst_active = 1
  and   n.node_type in ('DECISION','TASK','WAIT')
  and   i.node_number = n.id_proc_rec
;
