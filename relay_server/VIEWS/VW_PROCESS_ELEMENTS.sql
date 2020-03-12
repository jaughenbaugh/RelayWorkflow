--------------------------------------------------------
--  DDL for View VW_PROCESS_ELEMENTS
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_PROCESS_ELEMENTS" ("ID_RECORD", "PROCESS_NAME", "PROC_REVISION", "PROC_VARS", "NODES", "NODE_LINKS", "LINK_VERTICES", "NODE_ACTIONS", "NODE_ASSIGNMENTS", "NODE_SUBPROCESSES") AS 
  select 
       --p.*
       p.id_record
      ,p.process_name
      ,p.proc_revision
      ,(select count(*) from awf_proc_vars where id_process = p.id_record) proc_vars
      ,(select count(*) from awf_node where id_process = p.id_record) nodes
      ,(select count(*) from awf_node_link where id_process = p.id_record) node_links
      ,(select count(*) from awf_node_link_vertex where id_process = p.id_record) link_vertices
      ,(select count(*) from awf_node_action where id_process = p.id_record) node_actions
      ,(select count(*) from awf_node_assignment where id_process = p.id_record) node_assignments
      ,(select count(*) from awf_node_subprocess where id_process = p.id_record) node_subprocesses
from   awf_process p
;
