--------------------------------------------------------
--  DDL for View VW_METRIC_ELEMENT
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_METRIC_ELEMENT" ("E_RANK", "ELEMENT", "ID_PROCESS", "ID_PARENT", "ID_CHILD", "E_ID", "E_TYPE", "E_NAME", "E_DESC") AS 
  select 0 e_rank, null element, null id_process, null id_parent, null id_child, null e_id, null e_type, null e_name, null e_desc
from dual
union all
select 1, 'PROCESS', id_record, null, null, id_proc_rec, null, process_name, description 
from awf_process
union all
select 2, 'NODE', id_process, null, null, id_proc_rec, node_type, node_name, description
from awf_node
union all
select 3, 'LINK', id_process, id_parent_node, id_child_node, id_proc_rec, case when ind_is_positive = 1 then 'POS' else 'NEG' end e_type, description, null e_desc
from awf_node_link
;
