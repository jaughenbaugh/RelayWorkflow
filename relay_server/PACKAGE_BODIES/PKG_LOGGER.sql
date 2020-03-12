--------------------------------------------------------
--  DDL for Package Body PKG_LOGGER
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "PKG_LOGGER" as
--------------------------------------------------------------------------------
  g_log_index number := 0;

  type t_log_t1 is table of awf_logger_log%rowtype index by pls_integer;
  type t_log_t2 is table of t_log_t1 index by pls_integer;
  type t_log_t3 is table of t_log_t2 index by pls_integer;
  g_log t_log_t3; -- g_log(relay_p_vars.g_active_instance)(runtime_id)(#).column_name

  g_log_id number := 0;
  g_seq_id number := 0;

  type t_wf_rec is table of awf_wf_record%rowtype index by pls_integer; -- l_log_id
  type t2_wf_rec is table of t_wf_rec index by pls_integer; -- g_id_wf_run
  g_wf_record t2_wf_rec;
--------------------------------------------------------------------------------
function f_get_log_id
return number as
begin
  g_log_id := g_log_id + 1;
  return g_log_id;
end ;
--------------------------------------------------------------------------------
procedure p_build_log
(p_program in varchar2
,p_position in number
,p_runtime_id in number
,p_log_type in varchar2
,p_log_entry in clob default '')
as

  l_log_id number := 1;

begin
  if g_log_index = 0 then
    g_log_index := relay_p_workflow.f_an_main();
  end if;

  if g_log.exists(g_log_index) then
    if g_log(g_log_index).exists(p_runtime_id) then
      l_log_id := g_log(g_log_index)(p_runtime_id).last+1;
    else
      null;
    end if;
  else 
    null;
  end if;

  g_seq_id := g_seq_id + 1;

  g_log(g_log_index)(p_runtime_id)(l_log_id).id_seq := g_seq_id;
  g_log(g_log_index)(p_runtime_id)(l_log_id).id_instance := relay_p_vars.g_active_instance;
  g_log(g_log_index)(p_runtime_id)(l_log_id).id_log_index := g_log_index;
  g_log(g_log_index)(p_runtime_id)(l_log_id).program := p_program;
  g_log(g_log_index)(p_runtime_id)(l_log_id).position := p_position;
  g_log(g_log_index)(p_runtime_id)(l_log_id).runtime_id := p_runtime_id;
  g_log(g_log_index)(p_runtime_id)(l_log_id).log_type := p_log_type;
  g_log(g_log_index)(p_runtime_id)(l_log_id).log_entry := p_log_entry
    || case when upper(p_log_type) = 'ERROR' then chr(10)||dbms_utility.format_error_stack()||chr(10)||dbms_utility.format_error_backtrace end;
  g_log(g_log_index)(p_runtime_id)(l_log_id).program_unit := $$plsql_unit;
  g_log(g_log_index)(p_runtime_id)(l_log_id).log_time := systimestamp;

end ;
--------------------------------------------------------------------------------
procedure p_write_err_log
as
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_log clob;
  l_loop1 number;
begin
  for idx in 1..g_log(g_log_index).count loop

    forall idx3 in 1..g_log(g_log_index)(idx).count
    insert into awf_logger_log
      (PROGRAM_UNIT
      ,PROGRAM
      ,POSITION
      ,RUNTIME_ID
      ,LOG_TYPE
      ,LOG_ENTRY
      ,LOG_TIME
      ,ID_SEQ
      ,ID_INSTANCE
      ,ID_LOG_INDEX)
    values (g_log(g_log_index)(idx)(idx3).PROGRAM_UNIT
           ,g_log(g_log_index)(idx)(idx3).PROGRAM
           ,g_log(g_log_index)(idx)(idx3).POSITION
           ,g_log(g_log_index)(idx)(idx3).RUNTIME_ID
           ,g_log(g_log_index)(idx)(idx3).LOG_TYPE
           ,g_log(g_log_index)(idx)(idx3).LOG_ENTRY
           ,g_log(g_log_index)(idx)(idx3).LOG_TIME
           ,g_log(g_log_index)(idx)(idx3).ID_SEQ
           ,nvl(g_log(g_log_index)(idx)(idx3).ID_INSTANCE,relay_p_vars.g_active_instance)
           ,g_log(g_log_index)(idx)(idx3).ID_LOG_INDEX);

    null;
  end loop;

  g_log_index := 0;
  commit;
end ;
--------------------------------------------------------------------------------
procedure p_build_wf_rec
(p_record_type in varchar2
,p_record_subtype in varchar2
,p_id_proc_rec number default null
,p_id_child_rec number default null
,p_notes varchar2 default null)
as
  l_log_id number := 1;
begin
  -- example
  -- p_build_wf_rec(record_type,record_subtype,id_proc_rec,id_child_rec,notes);

  if g_wf_record.exists(g_log_index) then
    l_log_id := g_wf_record(g_log_index).last+1;
  else 
    null;
  end if;

  g_wf_record(g_log_index)(l_log_id).id_record := awf_main_seq.nextval;
  g_wf_record(g_log_index)(l_log_id).id_process := case when relay_p_vars.g_active_instance is null then null else relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_process end;
  g_wf_record(g_log_index)(l_log_id).id_owner := case when relay_p_vars.g_active_instance is null then null else relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_owner end;
  g_wf_record(g_log_index)(l_log_id).id_instance := relay_p_vars.g_active_instance;
  g_wf_record(g_log_index)(l_log_id).id_workflow_run := g_log_index;
  g_wf_record(g_log_index)(l_log_id).record_type := p_record_type;
  g_wf_record(g_log_index)(l_log_id).record_subtype := p_record_subtype;
  g_wf_record(g_log_index)(l_log_id).date_record := systimestamp;
  g_wf_record(g_log_index)(l_log_id).id_proc_rec := p_id_proc_rec;
  g_wf_record(g_log_index)(l_log_id).id_child_rec := p_id_child_rec;
  g_wf_record(g_log_index)(l_log_id).notes := p_notes;
  g_wf_record(g_log_index)(l_log_id).id_check_stamp := awf_stamp_seq.nextval;

end ;
--------------------------------------------------------------------------------
procedure p_write_wf_rec
as
begin

  forall idx in 1..g_wf_record(g_log_index).count
  insert into awf_wf_record
  values (
     g_wf_record(g_log_index)(idx).id_record
    ,nvl(g_wf_record(g_log_index)(idx).id_process,relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_process)
    ,nvl(g_wf_record(g_log_index)(idx).id_owner,relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_owner)
    ,nvl(g_wf_record(g_log_index)(idx).id_instance,relay_p_vars.g_active_instance)
    ,g_wf_record(g_log_index)(idx).id_workflow_run
    ,g_wf_record(g_log_index)(idx).record_type
    ,g_wf_record(g_log_index)(idx).record_subtype
    ,g_wf_record(g_log_index)(idx).date_record
    ,g_wf_record(g_log_index)(idx).id_proc_rec
    ,g_wf_record(g_log_index)(idx).id_child_rec
    ,g_wf_record(g_log_index)(idx).notes
    ,g_wf_record(g_log_index)(idx).id_check_stamp
    );

end ;
--------------------------------------------------------------------------------
end ;

/
