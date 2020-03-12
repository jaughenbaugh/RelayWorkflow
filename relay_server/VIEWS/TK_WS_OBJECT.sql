--------------------------------------------------------
--  DDL for View TK_WS_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "TK_WS_OBJECT" ("OBJ_ID", "AUTH_ID", "OBJ_NAME", "IND_ACTIVE", "OBJ_ATTR_ID", "ATTR_NAME", "ATTR_TYPE", "SEQ_ID", "IND_UPD", "IND_KEY") AS 
  SELECT
   a.id_record obj_id
  ,a.auth_id
  ,a.obj_name
--  ,a.table_owner
--  ,a.table_name
  ,a.ind_active
  ,b.id_record obj_attr_id
  ,b.attr_name
  ,b.attr_type
  ,b.seq_id
  ,b.ind_upd
  ,b.ind_key
FROM
   tk_object a
  ,tk_obj_attr b
where 1=1
  and b.id_object = a.id_record
order by seq_id
;
