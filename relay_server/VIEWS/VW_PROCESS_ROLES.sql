--------------------------------------------------------
--  DDL for View VW_PROCESS_ROLES
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_PROCESS_ROLES" ("ID_PROCESS", "ID_ROLE", "RID", "RECTYPE") AS 
  select distinct id_process, id_role, rid, rectype
from (select id_process, id_role, id_proc_rec rid, 'ASSIGNMENT' rectype from awf_node_assignment
      union all
      select id_process, id_escrole, id_proc_rec rid, 'ESCALATION' rectype from awf_node_assignment
      union all
      select id_record, id_role, id_proc_rec rid, 'PROCESS' rectype from awf_process
      union all
      select na.id_process, to_number(cst.send_to), cst.id_template rid, 'TEMPLATE' rectype
      from   awf_node_action na
            ,awf_action a
            ,awf_comm_template ct
            ,awf_comm_send_to cst
      where  1=1
        and  a.action_name = na.action_name
        and  cst.id_template = a.id_template
        and  cst.send_to_type = 'ROLE'
      union all
      select na.id_process, to_number(cst.send_to), cst.id_template rid, 'TEMPLATE' rectype
      from   awf_node_assignment na
            ,awf_comm_template ct
            ,awf_comm_send_to cst
      where  1=1
        and  cst.id_template = na.id_email_template
        and  cst.send_to_type = 'ROLE') a
where id_role is not null
order by id_process
;
