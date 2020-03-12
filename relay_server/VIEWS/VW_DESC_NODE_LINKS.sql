--------------------------------------------------------
--  DDL for View VW_DESC_NODE_LINKS
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_DESC_NODE_LINKS" ("ID_PROCESS", "ID_LINK", "DESCRIPTION", "SEQUENCE", "IND_LINK_COND", "ID_INSTANCE") AS 
  select  nl.id_process
       ,nl.id_proc_rec id_link
       ,nl.description
       ,nl.sequence
       ,case relay_p_workflow.f_eval_conditions
              (nl.id_proc_rec
              ,n.amt_for_true
              ,i.id_record)
        when -2 then 1
        when 1 then 1
        when 0 then 0
        else -1 end ind_link_cond,
        i.id_record id_instance
from    awf_node_link nl
       ,awf_node n
       ,awf_instance i
       ,awf_instance_state s
where   n.id_proc_rec = nl.id_parent_node
  and   n.id_process = nl.id_process
  and   n.node_type = 'DECISION'
  and   s.id_instance = i.id_record
  and   i.id_process = n.id_process
  and   i.ind_active = 1
  and   nl.ind_is_positive = 1
order by id_process, sequence
;
