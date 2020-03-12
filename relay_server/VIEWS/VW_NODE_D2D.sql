--------------------------------------------------------
--  DDL for View VW_NODE_D2D
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_NODE_D2D" ("TYPE", "ID", "X", "Y", "WIDTH", "HEIGHT", "ALPHA", "USERDATA", "CSSCLASS", "PATH", "LABEL", "ID_PROCESS", "ID_SHAPE", "SHAPE_TYPE", "ID_RECORD", "NODE_TYPE", "NODE_NAME", "DESCRIPTION", "IND_DISP_IF_ONE", "AMT_FOR_TRUE", "INTERVAL", "INTERVAL_UOM", "IND_CONTINUE", "ID_SUBPROCESS", "ID_CHECK_STAMP", "ID_ROW") AS 
  select  a.type,
        b.id_proc_rec id,
        b.layout_column x,
        b.layout_row y,
        a.width,
        a.height,
        a.alpha,
        a.userdata,
        a.cssclass,
        a.path,
        b.node_name label,
        b.id_process,
        a.id_shape, --a.id_record id_shape,
        a.shape_type,
        b.id_record,
        b.node_type,
        b.NODE_NAME,
        b.DESCRIPTION,
        b.IND_DISP_IF_ONE,
        b.AMT_FOR_TRUE,
        b.INTERVAL,
        b.INTERVAL_UOM,
        b.IND_CONTINUE,
        b.ID_SUBPROCESS,
        b.ID_CHECK_STAMP,
        b.rowid id_row
from    awf_d2d_data a --awf_d2d_shapes a
       ,awf_node b
where   b.node_type = a.shape_type
  and   a.type_record = 'SHAPE'
;
