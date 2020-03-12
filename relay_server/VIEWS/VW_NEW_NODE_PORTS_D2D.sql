--------------------------------------------------------
--  DDL for View VW_NEW_NODE_PORTS_D2D
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_NEW_NODE_PORTS_D2D" ("TYPE", "ID", "WIDTH", "HEIGHT", "ALPHA", "ANGLE", "USERDATA", "CSSCLASS", "BGCOLOR", "COLOR", "STROKE", "DASHARRAY", "MAXFANOUT", "NAME", "PORT", "LOCATOR", "NODE_ID", "SHAPE_TYPE") AS 
  SELECT
        b.type,
        a.id||'-'||abs(b.id) id,
        b.width,
        b.height,
        b.alpha,
        b.angle,
        b.userdata,
        b.cssclass,
        b.bgcolor,
        b.color,
        b.stroke,
        'null' dasharray,
        b.maxfanout,
        b.name,
        b.port,
        b.locator,
        a.id node_id,
        a.shape_type
FROM   vw_new_node_d2d a,
       awf_d2d_data b, --awf_d2d_ports b,
       awf_d2d_data c --awf_d2d_shape_ports c
where  b.id_port = c.id_port
  and  a.id_shape = c.id_shape
  and  b.type_record = 'PORT'
  and  c.type_record = 'SHAPE_PORTS'
;
