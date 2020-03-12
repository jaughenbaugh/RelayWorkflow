--------------------------------------------------------
--  DDL for Trigger T_AWF_INST_ASSIGN_BIU
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "T_AWF_INST_ASSIGN_BIU" before insert or update on awf_inst_assign 
referencing old as old new as new 
for each row 
begin
  insert into awf_inst_assign_status
  values
  (awf_main_seq.nextval, :new.id_record, sysdate, :new.code_status, awf_stamp_seq.nextval);
end;



/
ALTER TRIGGER "T_AWF_INST_ASSIGN_BIU" ENABLE;
