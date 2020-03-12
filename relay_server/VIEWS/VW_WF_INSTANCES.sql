--------------------------------------------------------
--  DDL for View VW_WF_INSTANCES
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_WF_INSTANCES" ("ID_INSTANCE", "INST_ACTIVE", "ID_OWNER", "ID_PROCESS", "DATE_START", "PROCESS_NAME", "IND_ENABLED", "PROC_ACTIVATED", "IND_ALLOW_MORE_INST", "NODE_NUMBER", "NODE_STATUS", "INST_RUNNING", "DATE_SET", "UI_REQUIRED", "ASSIGNMENT") AS 
  select  i.id_record id_instance
       ,i.ind_active inst_active
       ,i.id_owner
       ,i.id_process
       ,i.date_start
       ,p.process_name 
       ,p.ind_enabled
       ,p.ind_active proc_activated
       ,p.ind_allow_more_inst
       ,s.node_number
       ,s.node_status
       ,s.ind_active inst_running
       ,s.date_set
       ,s.ind_ui_reqd ui_required
       ,(select description 
         from   awf_node_assignment 
         where  id_process = i.id_process 
          and   node_number = s.node_number) assignment
from    awf_instance i
       ,awf_instance_state s
       ,relay_proc_acct p --awf_process p
where   p.id_record = i.id_process
  and   s.id_instance = i.id_record
  and   to_char(p.acct_id) = case 
                               when length(v('G_USR_AUTH')) > 0 then v('G_USR_AUTH')
                               else to_char(p.acct_id) --relay_p_anydata.f_get_param_vc2('ACCT_ID')
                             end
;
