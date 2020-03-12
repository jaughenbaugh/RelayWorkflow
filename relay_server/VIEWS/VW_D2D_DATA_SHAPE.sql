--------------------------------------------------------
--  DDL for View VW_D2D_DATA_SHAPE
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_D2D_DATA_SHAPE" ("ID_RECORD", "ID_CHECK_STAMP", "TYPE_RECORD", "ID_SHAPE", "ID_PORT", "PORT_SEQ", "LINK_TYPE", "TYPE", "ID", "X", "Y", "WIDTH", "HEIGHT", "ALPHA", "ANGLE", "USERDATA", "CSSCLASS", "BGCOLOR", "COLOR", "STROKE", "DASHARRAY", "MAXFANOUT", "NAME", "PORT", "LOCATOR", "RADIUS", "IND_IS_POSITIVE", "PATH", "SHAPE_TYPE", "ROUTER", "POLICY", "OUTLINECOLOR", "OUTLINESTROKE") AS 
  SELECT
    "ID_RECORD"
  , "ID_CHECK_STAMP"
  , "TYPE_RECORD"
  , "ID_SHAPE"
  , "ID_PORT"
  , "PORT_SEQ"
  , "LINK_TYPE"
  , "TYPE"
  , "ID"
  , "X"
  , "Y"
  , "WIDTH"
  , "HEIGHT"
  , "ALPHA"
  , "ANGLE"
  , "USERDATA"
  , "CSSCLASS"
  , "BGCOLOR"
  , "COLOR"
  , "STROKE"
  , "DASHARRAY"
  , "MAXFANOUT"
  , "NAME"
  , "PORT"
  , "LOCATOR"
  , "RADIUS"
  , "IND_IS_POSITIVE"
  , "PATH"
  , "SHAPE_TYPE"
  , "ROUTER"
  , "POLICY"
  , "OUTLINECOLOR"
  , "OUTLINESTROKE"
  FROM
    awf_d2d_data
  WHERE
    type_record = 'SHAPE'
  ORDER BY
    id_record
;
