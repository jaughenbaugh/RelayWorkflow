--------------------------------------------------------
--  DDL for View VW_PROC_REC_INDEX
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_PROC_REC_INDEX" ("ID_PROCESS", "ID_PROC_REC") AS 
  select id_process, max(id_proc_rec) id_proc_rec
from vw_process_records
group by id_process
;
