--------------------------------------------------------
--  DDL for View VW_NODE_LINK_D2D
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_NODE_LINK_D2D" ("TYPE", "ID", "ALPHA", "USERDATA", "CSSCLASS", "STROKE", "COLOR", "OUTLINESTROKE", "OUTLINECOLOR", "POLICY", "ROUTER", "RADIUS", "ID_PROCESS", "SOURCE_ID", "SOURCE_NAME", "TARGET_ID", "TARGET_NAME", "ID_RECORD", "ID_PARENT_NODE", "ID_CHILD_NODE", "DESCRIPTION", "IND_IS_POSITIVE", "SEQUENCE", "AMT_FOR_TRUE", "ID_CHECK_STAMP") AS 
  select  
        b.type
        ,c.id_proc_rec id
        ,b.alpha
        ,b.userdata
        ,b.cssclass
        ,b.stroke
        ,b.color
        ,b.outlinestroke
        ,b.outlinecolor
        ,b.policy
        ,b.router
        ,b.radius
        ,c.id_process
        ,d.node_id source_id
        ,d.name source_name
        ,e.node_id target_id
        ,e.name target_name
        ,c.ID_RECORD
        ,c.ID_PARENT_NODE
        ,c.ID_CHILD_NODE
        ,c.DESCRIPTION
        ,c.IND_IS_POSITIVE
        ,c.SEQUENCE
        ,c.AMT_FOR_TRUE
        ,c.ID_CHECK_STAMP
from    awf_d2d_data b --awf_d2d_connections b
        ,awf_node_link c
        ,vw_node_port_d2d d
        ,vw_node_port_d2d e
where   b.ind_is_positive = c.ind_is_positive
  and   c.id_process = d.id_process
  and   c.id_parent_node = d.node_id
  and   d.name = case when c.ind_is_positive = 1 then 'output0' else 'output1' end
  and   c.id_process = e.id_process
  and   c.id_child_node = e.node_id
  and   e.name like 'input%'
;
