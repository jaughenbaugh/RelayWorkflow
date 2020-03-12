--------------------------------------------------------
--  DDL for View VW_ACTNODE_LINKS
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_ACTNODE_LINKS" ("ID_PROCESS", "ID_PROC_REC", "SEQUENCE", "DESCRIPTION", "PROCESS_NAME", "ID_INSTANCE") AS 
  select nl.id_process
      ,nl.id_proc_rec
      ,nl.sequence
      ,nl.description
      ,an.process_name
      ,an.id_instance
from   awf_node_link nl,
       vw_active_nodes an,
       awf_inst_node_links inl
where  1=1
  and  nl.id_process = an.id_process
  and  nl.id_parent_node = an.id_proc_rec
  and  nl.ind_is_positive = 1
  and  inl.id_instance = an.id_instance
  and  inl.id_link = nl.id_proc_rec
order by sequence
;
