--------------------------------------------------------
--  DDL for View VW_PROC_PROC
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_PROC_PROC" ("ID_PARENT", "ID_RECORD", "ID_BASE_PROCESS", "PROCESS_NAME", "DESCRIPTION", "PROC_REVISION", "ID_REVISED_FROM", "ID_ROLE", "OBJ_OWNER", "OBJ_NAME", "ID_PROC_REC", "IND_ENABLED", "IND_ACTIVE", "IND_AUTO_INITIATE", "IND_ALLOW_MORE_INST", "ID_CHECK_STAMP") AS 
  select s.id_parent, p."ID_RECORD",p."ID_BASE_PROCESS",p."PROCESS_NAME",p."DESCRIPTION",p."PROC_REVISION",p."ID_REVISED_FROM",p."ID_ROLE",p."OBJ_OWNER",p."OBJ_NAME",p."ID_PROC_REC",p."IND_ENABLED",p."IND_ACTIVE",p."IND_AUTO_INITIATE",p."IND_ALLOW_MORE_INST",p."ID_CHECK_STAMP"
from awf_process p
    ,(select distinct id_parent, id_process
      from (
            select p.id_record id_parent, id_record id_process
            from awf_process p
            union all                        
            select s.id_process id_parent, s.id_subprocess id_process
            from  awf_process p 
                 ,awf_node_subprocess s 
            where p.id_record = s.id_process
            ) a
      order by id_parent, id_process) s
where p.id_record = s.id_process
;
