--------------------------------------------------------
--  DDL for View VW_PROC_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_PROC_ACTIONS" ("ID_PROCESS", "ID_RECORD", "ACTION_NAME", "DESCRIPTION", "OBJ_OWNER", "OBJ_NAME", "CODE_ACTION_TYPE", "ID_TEMPLATE", "PROG_OWNER", "PROG_NAME", "PROG_TYPE", "FUNC_RETVAR_NAME", "FUNC_RETVAR_TYPE", "ID_CHECK_STAMP", "IND_SAVE_DATA") AS 
  select p.id_record id_process, a."ID_RECORD",a."ACTION_NAME",a."DESCRIPTION",a."OBJ_OWNER",a."OBJ_NAME",a."CODE_ACTION_TYPE",a."ID_TEMPLATE",a."PROG_OWNER",a."PROG_NAME",a."PROG_TYPE",a."FUNC_RETVAR_NAME",a."FUNC_RETVAR_TYPE",a."ID_CHECK_STAMP",a."IND_SAVE_DATA" 
from   awf_action a
      ,awf_process p
where 1=1 
  and a.action_name in (select distinct action_name
                         from awf_node_action
                         where id_process = p.id_record
                           and action_name = a.action_name)
--  and a.obj_owner = p.obj_owner
  and a.obj_name = p.obj_name
;
