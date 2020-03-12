--------------------------------------------------------
--  DDL for View VW_NEW_NODE_D2D
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_NEW_NODE_D2D" ("ID_SHAPE", "TYPE", "ID", "X", "Y", "WIDTH", "HEIGHT", "ALPHA", "USERDATA", "CSSCLASS", "PATH", "SHAPE_TYPE") AS 
  SELECT id_shape,
       TYPE,
       to_char(sysdate,'SSSSS') ID,
       0 X,
       0 Y,
       WIDTH,
       HEIGHT,
       ALPHA,
       USERDATA,
       CSSCLASS,
       PATH,
       SHAPE_TYPE
FROM   AWF_D2D_DATA
where type_record = 'SHAPE'
;
