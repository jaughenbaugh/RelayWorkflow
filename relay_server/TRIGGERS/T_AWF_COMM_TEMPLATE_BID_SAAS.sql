--------------------------------------------------------
--  DDL for Trigger T_AWF_COMM_TEMPLATE_BID_SAAS
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "T_AWF_COMM_TEMPLATE_BID_SAAS" 
before insert or delete on awf_comm_template
referencing old as old new as new 
for each row 
begin
  if inserting then 
    insert into tk_rec_acct
    values
    (relay_p_workflow.f_an_main()
    ,7
    ,:new.id_record
    ,v('G_USR_AUTH'));
  elsif deleting then 
    delete from tk_rec_acct
    where rec_id = :old.id_record
      and rec_type = 7
      and acct_id = v('G_USR_AUTH');
  end if;
end;




/
ALTER TRIGGER "T_AWF_COMM_TEMPLATE_BID_SAAS" ENABLE;
