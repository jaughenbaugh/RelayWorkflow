--------------------------------------------------------
--  DDL for Package Body PKG_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "PKG_WORKFLOW" 
is
/*******************************************************************************
-- PACKAGE: pkg_workflow_new
--
-- PURPOSE:
--
-- SVN: $Id: $
-- $HeadURL: $
--
--------------------------------------------------------------------------------
-- REVISION HISTORY:
--
--   DATE        VERSION NAME               DESCRIPTION
--   ----------- ------- ------------------ ------------------------------------
--   23-MAR-2016 0.1.0   Jason Aughenbaugh  Initial revision
*******************************************************************************/
--GLOBALS-----------------------------------------------------------------------
  g_pkg_active number := 0;

  --cross-reference types
  type t_coll_ref1 is table of number index by varchar2(50);
  type t_coll_ref2 is table of t_coll_ref1 index by varchar2(50); 
  type t_coll_ref3 is table of t_coll_ref2 index by varchar2(50); 
  type t_coll_ref4 is table of t_coll_ref3 index by varchar2(50);

--BEGIN-WORKFLOW-VARIABLES------------------------------------------------------

  g_instance_comp number := 0;
  -- instance variables
  g_wf_p_process_name awf_process.process_name%type;
  g_wf_p_id_owner awf_instance.id_owner%type;
  g_id_active_process awf_process.id_record%type;

  g_ind_allow_more_inst awf_process.ind_allow_more_inst%type;

  type awf_node_t is table of awf_node%rowtype index by pls_integer;
  g_awf_node awf_node_t;

  -- owner definition
  type t_tab_cols_t is table of sys.all_tab_cols%rowtype index by varchar2(128);
  type t_tab_cols_tt is table of t_tab_cols_t index by pls_integer;
  g_owner_def t_tab_cols_tt;

  -- built-in datatype data
  type tt_bidt is table of varchar2(100) index by pls_integer;
  g_bidt tt_bidt;

  -- logging types
  type t_log_t1 is table of awf_inst_log%rowtype index by pls_integer;
  type t_log_t2 is table of t_log_t1 index by pls_integer;
  type t_log_t3 is table of t_log_t2 index by pls_integer;
  g_log t_log_t3; -- g_log(relay_p_vars.g_active_instance)(runtime_id)(#).column_name

  g_log_id number := 0;
  g_seq_id number := 0;

  type t_proc_rec is table of number index by pls_integer;
  g_proc_rec_amt t_proc_rec := t_proc_rec();
  g_proc_rec_hist t_proc_rec := t_proc_rec();
  g_proc_hist_flat clob;


--BEGIN-ASSIGNMENT-VARIABLES----------------------------------------------------

--BEGIN-ANYDATA-/-SUBSTITUTION-STRING-VARIABLES---------------------------------
  type relations_t is table of awf_relationships%rowtype index by pls_integer;
  g_relations relations_t;

  type rel_chain_r is record (rel_name awf_relationships.rel_name%type
                             ,rel_chain varchar2(4000)
                             ,rel_rowids varchar2(4000)
                             ,rowid_count number);
  type rel_chain_t is table of rel_chain_r index by pls_integer;
  type rel_chain_tt is table of rel_chain_t index by pls_integer;
  g_rel_chain rel_chain_tt; -- g_rel_chain(g_rel_level)(g_rowid_set_idx)

  type subst_vars_r is record (row_ids varchar2(4000)
                              ,rel_name awf_relationships.rel_name%type);
  type subst_vars_t is table of subst_vars_r index by varchar2(4000);
--  type subst_vars_t is table of varchar2(4000) index by varchar2(4000);
  type subst_vars_tt is table of subst_vars_t index by pls_integer;
  g_subst_vars subst_vars_tt; -- g_subst_vars(instance_id)(subst_var_name)

  g_rel_level number := 1;
  g_rowid_set_idx number := 0;
  g_object_owner varchar2(50);
  g_object_name varchar2(50);
  g_owner_rowid varchar2(50);
  g_ind_proceed number := 0;

  type svars_r is record(orig_variable varchar2(4000)
                        ,svar_function varchar2(100)
                        ,svar_rel_chain varchar2(4000)
                        ,svar_column_name varchar2(50)
                        ,svar_variable varchar2(50)
                        ,svar_value clob
                        ,svar_notes clob
                        ,svar_ind_replace number
                        ,svar_ind_u number
                        ,svar_ind_id number
                        ,svar_ind_error number);
  type svars_t is table of svars_r index by pls_integer;
  g_svars svars_t;

  type t_ad_methods is table of awf_ad_methods%rowtype index by pls_integer;
  g_ad_methods t_ad_methods;

  g_adm_alt1 t_coll_ref1; --g_adm_alt1(code_type)

--BEGIN-RESOURCE-VARIABLES------------------------------------------------------

--  g_person tt_person;
--  g_person_group tt_person_group;
--  g_group_member tt_group_member;
--  g_roles tt_roles;
  gp_lic_status varchar2(1000);
  g_p_sql clob;

  g_pg_sql clob;

  g_gm_sql clob;

  g_r_sql clob;

--BEGIN-NOTIFICATIONS-VARIABLES-------------------------------------------------
  g_workspace_id number := -1;

  g_to varchar2(4000);
  g_cc varchar2(4000);
  g_bcc varchar2(4000);

--BEGIN-CONDITIONS-VARIABLES----------------------------------------------------
  g_inst_data vw_instance_data%rowtype;

--BEGIN-ACTIONS-VARIABLES-------------------------------------------------------
  g_active_pv t_active_pv;

  type t_actions is table of awf_action%rowtype index by varchar2(4000);
  g_actions t_actions;

  type t1_action_pv is table of awf_action_pv%rowtype index by pls_integer;
  type t2_action_pv is table of t1_action_pv index by varchar2(100);
  g_actions_pv t2_action_pv;

  type t_wf_rec is table of awf_wf_record%rowtype index by pls_integer; -- l_log_id
  type t2_wf_rec is table of t_wf_rec index by pls_integer; -- g_id_wf_run
  g_wf_record t2_wf_rec;

--BEGIN-NODES-VARIABLES---------------------------------------------------------
  g_assignment awf_node_assignment%rowtype;
--------------------------------------------------------------------------------
  g_version varchar2(100) := '#VERSION#';
--PROGRAMS----------------------------------------------------------------------
function f_get_version
return varchar2
as
begin
  return g_version;
end ;
--------------------------------------------------------------------------------
function f_get_log_id
return number as
begin
  g_log_id := g_log_id + 1;
  return g_log_id;
end ;
--------------------------------------------------------------------------------
function f_an_main
return number as
begin
  return awf_main_seq.nextval;
end ;
--------------------------------------------------------------------------------
function f_an_stamp
return number as
begin
  return awf_stamp_seq.nextval;
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
--  l_active_instance number := 0;

begin
  if g_log.exists(g_workflow_index) then
--    dbms_output.put_line($$PLSQL_LINE||': 1 EXISTS');
    if g_log(g_workflow_index).exists(p_runtime_id) then
--      dbms_output.put_line($$PLSQL_LINE||': 2 EXISTS');
      l_log_id := g_log(g_workflow_index)(p_runtime_id).last+1;
    else
--      dbms_output.put_line($$PLSQL_LINE||': 2 NOT EXISTS');
      null;
    end if;
  else 
--    dbms_output.put_line($$PLSQL_LINE||': 1 NOT EXISTS');
    null;
  end if;

  g_seq_id := g_seq_id + 1;

  g_log(g_workflow_index)(p_runtime_id)(l_log_id).id_seq := g_seq_id;
  g_log(g_workflow_index)(p_runtime_id)(l_log_id).id_instance := relay_p_vars.g_active_instance;
  g_log(g_workflow_index)(p_runtime_id)(l_log_id).id_workflow_index := g_workflow_index;
  g_log(g_workflow_index)(p_runtime_id)(l_log_id).program := p_program;
  g_log(g_workflow_index)(p_runtime_id)(l_log_id).position := p_position;
  g_log(g_workflow_index)(p_runtime_id)(l_log_id).runtime_id := p_runtime_id;
  g_log(g_workflow_index)(p_runtime_id)(l_log_id).log_type := p_log_type;
  g_log(g_workflow_index)(p_runtime_id)(l_log_id).log_entry := p_log_entry
    || case when upper(p_log_type) = 'ERROR' then chr(10)||dbms_utility.format_error_stack()||chr(10)||dbms_utility.format_error_backtrace end;
  g_log(g_workflow_index)(p_runtime_id)(l_log_id).program_unit := $$plsql_unit;
  g_log(g_workflow_index)(p_runtime_id)(l_log_id).log_time := systimestamp;

--exception
  --when others then
    --raise;
end ;
--------------------------------------------------------------------------------
procedure p_write_err_log
as
  l_log clob;
  l_loop1 number;
begin
        for idx in 1..g_log(g_workflow_index).count loop

          forall idx3 in 1..g_log(g_workflow_index)(idx).count
          insert into awf_inst_log
            (PROGRAM_UNIT
            ,PROGRAM
            ,POSITION
            ,RUNTIME_ID
            ,LOG_TYPE
            ,LOG_ENTRY
            ,LOG_TIME
            ,ID_SEQ
            ,ID_INSTANCE
            ,ID_WORKFLOW_INDEX)
          values (g_log(g_workflow_index)(idx)(idx3).PROGRAM_UNIT
                 ,g_log(g_workflow_index)(idx)(idx3).PROGRAM
                 ,g_log(g_workflow_index)(idx)(idx3).POSITION
                 ,g_log(g_workflow_index)(idx)(idx3).RUNTIME_ID
                 ,g_log(g_workflow_index)(idx)(idx3).LOG_TYPE
                 ,g_log(g_workflow_index)(idx)(idx3).LOG_ENTRY
                 ,g_log(g_workflow_index)(idx)(idx3).LOG_TIME
                 ,g_log(g_workflow_index)(idx)(idx3).ID_SEQ
                 ,nvl(g_log(g_workflow_index)(idx)(idx3).ID_INSTANCE,relay_p_vars.g_active_instance)
                 ,g_log(g_workflow_index)(idx)(idx3).ID_WORKFLOW_INDEX);

          null;
        end loop;

end ;
--------------------------------------------------------------------------------
procedure p_write_wf_log
as
  l_log clob;
  l_loop1 number;
begin

  apex_json.initialize_clob_output;

        l_loop1 := g_log.first;

        for idx in 1..g_log(g_workflow_index).count loop
              for idx2 in 1..g_log(g_workflow_index)(idx).count loop
                if g_log(g_workflow_index)(idx)(idx2).log_type like 'LOG%' then
                  apex_json.open_object();
                    apex_json.write('log_index',idx||'.'||idx2);
                    apex_json.write('log_sequence',g_log(g_workflow_index)(idx)(idx2).id_seq);
                    apex_json.write('instance_id',relay_p_vars.g_active_instance);
                    apex_json.write('wf_index',g_workflow_index);
                    apex_json.write('runtime_id',g_log(g_workflow_index)(idx)(idx2).runtime_id);
                    apex_json.write('log_type',g_log(g_workflow_index)(idx)(idx2).log_type);
                    apex_json.write('log_time',to_char(g_log(g_workflow_index)(idx)(idx2).log_time,'YYYY.MM.DD.HH24.MI.SS'));
                    apex_json.write('log_entry',g_log(g_workflow_index)(idx)(idx2).log_entry);
                  apex_json.close_object(); --log_entry
                end if;
              end loop;
        end loop;

  l_log := apex_json.get_clob_output;

  relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).instance_log := relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).instance_log||chr(10)||l_log;

  apex_json.free_output;

  update awf_instance
  set instance_log = relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).instance_log
  where id_record = relay_p_vars.g_active_instance;

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

  if g_wf_record.exists(g_workflow_index) then
    l_log_id := g_wf_record(g_workflow_index).last+1;
  else 
    null;
  end if;

  g_wf_record(g_workflow_index)(l_log_id).id_record := awf_main_seq.nextval;
  g_wf_record(g_workflow_index)(l_log_id).id_process := case when relay_p_vars.g_active_instance is null then null else relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_process end;
  g_wf_record(g_workflow_index)(l_log_id).id_owner := case when relay_p_vars.g_active_instance is null then null else relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_owner end;
  g_wf_record(g_workflow_index)(l_log_id).id_instance := relay_p_vars.g_active_instance;
  g_wf_record(g_workflow_index)(l_log_id).id_workflow_run := g_workflow_index;
  g_wf_record(g_workflow_index)(l_log_id).record_type := p_record_type;
  g_wf_record(g_workflow_index)(l_log_id).record_subtype := p_record_subtype;
  g_wf_record(g_workflow_index)(l_log_id).date_record := systimestamp;
  g_wf_record(g_workflow_index)(l_log_id).id_proc_rec := p_id_proc_rec;
  g_wf_record(g_workflow_index)(l_log_id).id_child_rec := p_id_child_rec;
  g_wf_record(g_workflow_index)(l_log_id).notes := p_notes;
  g_wf_record(g_workflow_index)(l_log_id).id_check_stamp := awf_stamp_seq.nextval;
--/*  
  tk_p_api.p_inst_stat(case p_record_type 
                         when 'ASSIGNMENT' then 1
                         when 'START' then 2
                         when 'WAIT' then 3
                         when 'DECISION' then 4
                         when 'TASK' then 5
                         when 'LINK' then 6
                         when 'NODE' then 7
                         when 'NODE_PROCESSING' then 8
                         when 'LINK' then 9
                         when 'PRODUCT_LICENSE' then 10
                         when 'PRODUCT' then 11
                         when 'WF_RUN' then 12
                         when 'NODES' then 13
                         when 'NODE' then 14
                         when 'INSTANCE' then 15
                         else 0
                       end
                      ,case p_record_subtype
                        when 'START' then 1
                        when 'END' then 2
                        when 'ERROR_INPUT' then 3
                        when 'INITIATED' then 4
                        when 'ERROR' then 5
                        when 'CONTINUE' then 6
                        when 'PAUSED' then 7
                        when 'USED' then 8
                        when 'CLOSED' then 9
                        when 'END' then 10
                        when 'FAILED' then 11
                        when 'VIOLATED' then 12
                        when 'EXCEEDED' then 13
                        when 'UNLICENSED' then 14
                        when 'LICENSED' then 15
                        when 'BYPASSED' then 16
                        when 'STOP' then 17
                        else 0
                       end  
                      ,case p_record_type
                        when 'INSTANCE' then -1
                        when 'WF_RUN' then -2
                        when 'NODES' then -3
                        else p_id_proc_rec
                       end);
--*/
end ;
--------------------------------------------------------------------------------
procedure p_write_wf_rec
as
begin

  forall idx in 1..g_wf_record(g_workflow_index).count
  insert into awf_wf_record
  values (
     g_wf_record(g_workflow_index)(idx).id_record
--> nvl over nvl     
    ,nvl(nvl(g_wf_record(g_workflow_index)(idx).id_process,relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_process),-1)
    ,nvl(nvl(g_wf_record(g_workflow_index)(idx).id_owner,relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_owner),-1)
    ,nvl(g_wf_record(g_workflow_index)(idx).id_instance,relay_p_vars.g_active_instance)
    ,g_wf_record(g_workflow_index)(idx).id_workflow_run
    ,g_wf_record(g_workflow_index)(idx).record_type
    ,g_wf_record(g_workflow_index)(idx).record_subtype
    ,g_wf_record(g_workflow_index)(idx).date_record
    ,g_wf_record(g_workflow_index)(idx).id_proc_rec
    ,g_wf_record(g_workflow_index)(idx).id_child_rec
    ,g_wf_record(g_workflow_index)(idx).notes
    ,g_wf_record(g_workflow_index)(idx).id_check_stamp
    );

  tk_p_api.p_write_istat;

end ;
--------------------------------------------------------------------------------
function p_rec_hist_eval
(p_id_proc_rec in number)
return number
as
  l_program varchar2(200) := 'p_rec_hist_eval';
  l_log_id number := f_get_log_id;

  l_idx number := 0;
  l_iloop exception;
  l_retvar number;
begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  l_idx := g_proc_rec_hist.count+1;
  g_proc_rec_hist(l_idx) := p_id_proc_rec;
  g_proc_hist_flat := nvl(g_proc_hist_flat,'')||case when l_idx > 1 then ',' end||p_id_proc_rec;

  if g_proc_rec_amt.exists(p_id_proc_rec) then
    g_proc_rec_amt(p_id_proc_rec) := g_proc_rec_amt(p_id_proc_rec)+1;
  else
    g_proc_rec_amt(p_id_proc_rec) := 1;
  end if;

  if g_proc_rec_amt(p_id_proc_rec) >= relay_p_vars.g_ucd_limit then
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR', 'Uncontrolled Cycle Detected (UCD)');
    for idx in 1..ceil(dbms_lob.getlength(g_proc_hist_flat)/3900) loop
      p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR_LOG', 'UCD-'||idx||': '||dbms_lob.substr(g_proc_hist_flat,3900,idx));
    end loop;
    raise l_iloop;
  else 
    l_retvar := 0;
  end if;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return : '||l_retvar);

  return l_retvar;
exception 
  when l_iloop then 
    return -1;
end;
--------------------------------------------------------------------------------
procedure p_load_bidt
as
  l_program varchar2(200) := 'p_load_bidt';
  l_log_id number := f_get_log_id;

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  g_bidt(1) := 'VARCHAR2';
  g_bidt(2) := 'NUMBER';
  g_bidt(12) := 'DATE';
  g_bidt(13) := 'DATE';
  g_bidt(21) := 'BINARY_FLOAT';
  g_bidt(22) := 'BINARY_DOUBLE';
  g_bidt(23) := 'RAW';
  g_bidt(24) := 'LONG RAW';
  g_bidt(69) := 'ROWID';
  g_bidt(96) := 'CHAR';
  g_bidt(112) := 'CLOB';
  g_bidt(113) := 'BLOB';
  g_bidt(114) := 'BFILE';
  g_bidt(180) := 'TIMESTAMP';
  g_bidt(181) := 'TIMESTAMP WITH TIME ZONE';
  g_bidt(182) := 'INTERVAL YEAR TO MONTH';
  g_bidt(183) := 'INTERVAL DAY TO SECOND';
  g_bidt(208) := 'UROWID';
  g_bidt(231) := 'TIMESTAMP WITH LOCAL TIME ZONE';

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END');

exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    raise;
end ;
--------------------------------------------------------------------------------
procedure p_load_adm
as
  l_program varchar2(200) := 'p_load_atm';
  l_log_id number := f_get_log_id;

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  select *
  bulk collect into g_ad_methods
  from awf_ad_methods;

  for idx in 1..g_ad_methods.count loop
    g_adm_alt1(g_ad_methods(idx).code_datatype) := idx;
  end loop;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END');
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    raise;
end;
--------------------------------------------------------------------------------
function f_get_datatype
(p_dump_input in varchar2)
return varchar2
as
  l_program varchar2(200) := 'f_get_datatype';
  l_log_id number := f_get_log_id;

  l_dt_code varchar2(5);
  l_retvar varchar2(4000);
begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  --> TODO: Remove before flight
  p_load_bidt;
  -->

  l_dt_code := substr(p_dump_input,5,instr(p_dump_input,' ',1,1)-5);
  l_retvar := g_bidt(l_dt_code);

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||l_retvar);

  return l_retvar;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_dump_input: '||p_dump_input);
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    raise;
end ;
--------------------------------------------------------------------------------
function f_get_ad_method
(p_dtype in varchar2
,p_method in varchar2)
return varchar2
as
  l_program varchar2(200) := 'f_get_ad_method';
  l_log_id number := f_get_log_id;

  l_a_method varchar2(100);
  l_c_method varchar2(100);
  invalid_method exception;

  l_retvar varchar2(4000);
begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  if p_method = 'ACCESS' then
    l_retvar := g_ad_methods(g_adm_alt1(upper(p_dtype))).ad_access;
  elsif p_method = 'CONVERT' then
    l_retvar := g_ad_methods(g_adm_alt1(upper(p_dtype))).ad_convert;
  else
    raise invalid_method;
  end if;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||l_retvar);
  return l_retvar;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_dtype: '||p_dtype);
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_method: '||p_method);
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    raise;
    return '-1';
end ;
--------------------------------------------------------------------------------
function f_get_var_value
(p_action_dt in varchar2
,p_value sys.anydata)
return sys.anydata
as
  l_program varchar2(200) := 'f_get_var_value';
  l_log_id number := f_get_log_id;

  l_retvar sys.anydata;
  l_proc_var varchar2(100);

  var_not_found exception;

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  -- decode the variable reference
  l_proc_var := sys.anydata.accessvarchar2(p_value);

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_proc_var: '||l_proc_var);

  -- check to see if the variable is a valid part of the instance
  if relay_p_vars.g_inst_own_values(relay_p_vars.g_active_instance).exists(l_proc_var) then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'VAR Found');

    l_retvar := relay_p_vars.g_inst_own_values(relay_p_vars.g_active_instance)(l_proc_var).var_value;
  else
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'VAR not Found');
    -- if not then raise an error
    raise var_not_found;
  end if;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: (anydata)');
  return l_retvar;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_action_dt: '||p_action_dt);
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_value: (anydata)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    raise;
end ;
--------------------------------------------------------------------------------
function f_active_process
(p_id_process in awf_process.id_record%type default null)
return awf_process.id_record%type
as
begin
  return nvl(relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_process,p_id_process);
end;
--------------------------------------------------------------------------------
function f_an_instance
return number
as
  l_retvar number;
begin
  l_retvar := awf_instance_seq.nextval;
  return l_retvar;
end ;
--------------------------------------------------------------------------------
procedure p_set_inst_state
(p_id_instance in number
,p_ind_active in number)
as

  pragma autonomous_transaction;

begin

  -- set here to prevent additional execution of the instance while active

  update awf_instance_state
  set ind_active = p_ind_active
  where id_instance = p_id_instance;

  commit;

end ;
--------------------------------------------------------------------------------
function f_get_cre_instance
(p_id_instance in awf_instance.id_record%type)
return number
as
  l_program varchar2(200) := 'f_get_cre_instance';
  l_log_id number := f_get_log_id;

  l_ind_active_inst number := 0;
  g_hash varchar2(100) := '#HASH#';
  l_ind_prev_inst number := 0;

  l_id_instance awf_instance.id_record%type;
  l_start_id awf_node.id_proc_rec%type;

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  relay_p_vars.g_active_instance := p_id_instance;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'relay_p_vars.g_active_instance: '||relay_p_vars.g_active_instance);

  relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_process := relay_p_rest.g_process(relay_p_rest.g_proc_alt1(relay_p_rest.g_instance.id_process)).id_record;
  relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).obj_owner  := relay_p_rest.g_process(relay_p_rest.g_proc_alt1(relay_p_rest.g_instance.id_process)).obj_owner;
  relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).obj_name := relay_p_rest.g_process(relay_p_rest.g_proc_alt1(relay_p_rest.g_instance.id_process)).obj_name;
  relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_owner := relay_p_rest.g_instance.id_owner;
  relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).instance_log := relay_p_rest.g_instance.instance_log;
  relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).error_log := null;
  relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node := relay_p_rest.g_inst_state.node_number;
  relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).date_set := relay_p_rest.g_inst_state.date_set;
  relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).ind_ui_reqd := relay_p_rest.g_inst_state.ind_ui_reqd;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_process: '
              ||relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_process);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).obj_owner: '
            ||relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).obj_owner);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).obj_name: '
            ||relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).obj_name);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_owner: '
            ||relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_owner);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node: '
            ||relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).date_set: '
            ||relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).date_set);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).ind_ui_reqd: '
            ||relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).ind_ui_reqd);

  -- set instance state to active in memory 
  relay_p_rest.g_inst_state.ind_active := 1;

  -- set instance state to active in state table to prevent double execution of the instance while active
  p_set_inst_state(p_id_instance => relay_p_vars.g_active_instance
                  ,p_ind_active => 1); 

  p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'INSTANCE:START:'||relay_p_vars.g_active_instance);
  p_build_wf_rec('INSTANCE','START',relay_p_vars.g_active_instance,null,null);

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: 1');
  return 1;

exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_id_instance: '||p_id_instance);
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    return -1;
    raise;
end ;
--------------------------------------------------------------------------------
function f_write_owner_updates
(p_ind_owner_only in number default 0)
return number
as
  l_program varchar2(200) := 'f_write_owner_updates';
  l_log_id number := f_get_log_id;

  l_loop1 number := 0;
  l_loop2 number := 0;

  type tr_inst_values is record (id_record number, var_value sys.anydata, var_clob clob, var_blob blob, var_type varchar2(30));
  type tt_inst_values is table of tr_inst_values index by pls_integer;
  l_inst_values tt_inst_values;

  l_set_list clob;
  l_rec_set clob;

  l_code_upd clob;

  l_code clob;
  l_id_process number;
  l_id_instance number;
  l_obj_owner varchar2(50);
  l_obj_name varchar2(50);

  l_ov_idx varchar2(500);

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  l_id_process := relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_process;
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_id_process: '||l_id_process);
  l_id_instance := relay_p_vars.g_active_instance;
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_id_instance: '||l_id_instance);
  l_obj_owner := relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).obj_owner;
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_obj_owner: '||l_obj_owner);
  l_obj_name := relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).obj_name;
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_obj_name : '||l_obj_name);

  if relay_p_vars.g_inst_own_values(l_id_instance).count > 0 then
    for idx in 1..relay_p_vars.g_inst_own_values(l_id_instance).count loop
      if idx = 1 then 
        l_ov_idx := relay_p_vars.g_inst_own_values(l_id_instance).first;
      else
        l_ov_idx := relay_p_vars.g_inst_own_values(l_id_instance).next(l_ov_idx);
      end if;

      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_ov_idx: '||l_ov_idx);

      if relay_p_vars.g_inst_own_values(l_id_instance)(l_ov_idx).ind_changed = 1 then

        p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'relay_p_vars.g_inst_own_values(l_id_instance)(l_ov_idx).ind_changed: '
                                                              ||relay_p_vars.g_inst_own_values(l_id_instance)(l_ov_idx).ind_changed);

        p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'relay_p_vars.g_inst_own_values(l_id_instance)(l_ov_idx).var_source: '
                                                              ||relay_p_vars.g_inst_own_values(l_id_instance)(l_ov_idx).var_source);

        case relay_p_vars.g_inst_own_values(l_id_instance)(l_ov_idx).var_source
          when 'JSON_REQ' then
            if relay_p_rest.g_inst_data.exists(relay_p_rest.g_inst_data_alt1(l_ov_idx)) 
            then
              p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'CHECKPOINT');
              relay_p_rest.g_inst_data(relay_p_rest.g_inst_data_alt1(l_ov_idx)) := relay_p_vars.g_inst_own_values(l_id_instance)(l_ov_idx);
              p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'ind_changed: '||relay_p_rest.g_inst_data(relay_p_rest.g_inst_data_alt1(l_ov_idx)).ind_changed);
            end if;
          when 'PROC_VARS' then
            if relay_p_rest.g_inst_vars.exists(relay_p_rest.g_ivar_alt1(l_id_instance)(l_ov_idx))
            then
              p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'CHECKPOINT');
              relay_p_rest.g_inst_vars(relay_p_rest.g_ivar_alt1(l_id_instance)(l_ov_idx)) := relay_p_vars.g_inst_own_values(l_id_instance)(l_ov_idx);
              p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'ind_changed: '||relay_p_rest.g_inst_vars(relay_p_rest.g_inst_data_alt1(l_ov_idx)).ind_changed);
            end if;
          else 
            null;
        end case;  

      end if;

    end loop;
  end if;

  -- write the instance data to table
  forall idx in 1..relay_p_rest.g_inst_data.count 
  update awf_inst_data
  set var_value = case when relay_p_rest.g_inst_data(idx).var_type not in ('BLOB','CLOB') then relay_p_rest.g_inst_data(idx).var_value else null end
     ,clob_value = case when relay_p_rest.g_inst_data(idx).var_type = 'CLOB' then relay_p_rest.g_inst_data(idx).clob_value else null end
     ,blob_value = case when relay_p_rest.g_inst_data(idx).var_type = 'BLOB' then relay_p_rest.g_inst_data(idx).blob_value else null end
     ,ind_changed = relay_p_rest.g_inst_data(idx).ind_changed
  where id_record = relay_p_rest.g_inst_data(idx).id_record;

  -- write the instance variables to table
  forall idx in 1..relay_p_rest.g_inst_vars.count
  update awf_inst_vars
  set var_value = case when relay_p_rest.g_inst_vars(idx).var_type not in ('BLOB','CLOB') then relay_p_rest.g_inst_vars(idx).var_value else null end
     ,clob_value = case when relay_p_rest.g_inst_vars(idx).var_type = 'CLOB' then relay_p_rest.g_inst_vars(idx).clob_value else null end
     ,blob_value = case when relay_p_rest.g_inst_vars(idx).var_type = 'BLOB' then relay_p_rest.g_inst_vars(idx).blob_value else null end
     ,ind_changed = relay_p_rest.g_inst_vars(idx).ind_changed
  where id_record = relay_p_rest.g_inst_vars(idx).id_record;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: 1');
  return 1;

exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_ind_owner_only: '||p_ind_owner_only);
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    return -1;
end ;
--------------------------------------------------------------------------------
procedure p_close_instance
(p_final_value in number)
as
  l_program varchar2(200) := 'p_close_instance';
  l_log_id number := f_get_log_id;
begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  -- if ind_active = 0 it is closed, -1 closed from error
  relay_p_rest.g_instance.ind_active := p_final_value;
--/*  
  update  awf_instance
  set     ind_active = p_final_value
--          instance_log = relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).instance_log
  where   id_record = relay_p_vars.g_active_instance;
--*/
  g_instance_comp := 1;

  p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'INSTANCE:CLOSE:'||relay_p_vars.g_active_instance);

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END');

exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_final_value: '||p_final_value);
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    raise;
end ;
--------------------------------------------------------------------------------
procedure p_pause_instance
as
  l_program varchar2(200) := 'p_pause_instance';
  l_log_id number := f_get_log_id;
begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  relay_p_rest.g_inst_state.ind_active := 0;
  relay_p_rest.g_inst_state.ind_ui_reqd := relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).ind_ui_reqd;

  relay_p_rest.g_inst_ind := 1;
  relay_p_rest.g_inst_state_ind := 1;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END');
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    raise;
end ;
--------------------------------------------------------------------------------
--LOAD-DATASETS-----------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function f_load_owner_data
(p_ind_owner_only in number default 0)
return number
as
  l_program varchar2(200) := 'f_load_owner_data';
  l_log_id number := f_get_log_id;

  l_retvar number;

  l_code_base clob;
  l_code clob;

  l_id_process number;
  l_id_instance number;
  l_obj_owner varchar2(50);
  l_obj_name varchar2(50);

  l_sel_vars clob;
  l_into_vars clob;
  l_inst_vars number;

  l_cycle number := 0;

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

--  l_code_base := relay_p_vars.g_ei_set('RWF02').text;

  l_id_process := relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_process;
  l_id_instance := relay_p_vars.g_active_instance;
  l_obj_owner := relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).obj_owner;
  l_obj_name := relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).obj_name;

  if relay_p_rest.g_inst_vars.count = 0 then
    if relay_p_rest.g_inst_vars.count != relay_p_rest.g_proc_var.count then
      -- copy proc_vars to inst_vars
      for idx in 1..relay_p_rest.g_proc_var.count loop
        relay_p_rest.g_inst_vars(idx).id_record := f_an_main();
        relay_p_rest.g_inst_vars(idx).id_instance := relay_p_rest.g_instance.id_record;
        relay_p_rest.g_inst_vars(idx).var_type := relay_p_rest.g_proc_var(idx).var_type;
        relay_p_rest.g_inst_vars(idx).var_name := relay_p_rest.g_proc_var(idx).var_name;
        relay_p_rest.g_inst_vars(idx).var_value := relay_p_rest.g_proc_var(idx).default_var_value;
        relay_p_rest.g_inst_vars(idx).var_source := 'PROC_VARS';
        relay_p_rest.g_inst_vars(idx).var_sequence := idx;
        relay_p_rest.g_inst_vars(idx).id_check_stamp := relay_p_rest.g_inst_vars(idx).id_record;
        relay_p_rest.g_inst_vars(idx).clob_value := relay_p_rest.g_proc_var(idx).dflt_clob_value;
        relay_p_rest.g_inst_vars(idx).blob_value := relay_p_rest.g_proc_var(idx).dflt_blob_value;
        relay_p_rest.g_inst_vars(idx).ind_changed := 0;
      end loop;
    end if;
  end if;

  if relay_p_rest.g_inst_vars.count > 0 then
    for idx in 1..relay_p_rest.g_inst_vars.count loop
      relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_vars(idx).var_name).id_record := relay_p_rest.g_inst_vars(idx).id_record;
      relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_vars(idx).var_name).id_instance := relay_p_rest.g_inst_vars(idx).id_instance;
      relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_vars(idx).var_name).var_type := relay_p_rest.g_inst_vars(idx).var_type;
      relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_vars(idx).var_name).var_name := relay_p_rest.g_inst_vars(idx).var_name;
      relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_vars(idx).var_name).var_source := relay_p_rest.g_inst_vars(idx).var_source;
      relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_vars(idx).var_name).var_sequence := relay_p_rest.g_inst_vars(idx).var_sequence;
      relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_vars(idx).var_name).id_check_stamp := relay_p_rest.g_inst_vars(idx).id_check_stamp;
      relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_vars(idx).var_name).var_value := relay_p_rest.g_inst_vars(idx).var_value;
      relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_vars(idx).var_name).blob_value := relay_p_rest.g_inst_vars(idx).blob_value;
      relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_vars(idx).var_name).clob_value := relay_p_rest.g_inst_vars(idx).clob_value;
      relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_vars(idx).var_name).ind_changed := 0;

      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'IDX.VAR_SOURCE:IDX.VAR_NAME:IDX:VAR_TYPE | '||
                relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_vars(idx).var_name).var_source||':'||
                relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_vars(idx).var_name).var_name||':'||
                relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_vars(idx).var_name).var_type);
    end loop;
  end if;

  if relay_p_rest.g_inst_data.count > 0 then
    for idx in 1..relay_p_rest.g_inst_data.count loop
      relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_data(idx).var_name).id_record := relay_p_rest.g_inst_data(idx).id_record;
      relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_data(idx).var_name).id_instance := relay_p_rest.g_inst_data(idx).id_instance;
      relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_data(idx).var_name).var_type := relay_p_rest.g_inst_data(idx).var_type;
      relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_data(idx).var_name).var_name := relay_p_rest.g_inst_data(idx).var_name;
      relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_data(idx).var_name).var_source := relay_p_rest.g_inst_data(idx).var_source;
      relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_data(idx).var_name).var_sequence := relay_p_rest.g_inst_data(idx).var_sequence;
      relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_data(idx).var_name).id_check_stamp := relay_p_rest.g_inst_data(idx).id_check_stamp;
      relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_data(idx).var_name).var_value := relay_p_rest.g_inst_data(idx).var_value;
      relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_data(idx).var_name).blob_value := relay_p_rest.g_inst_data(idx).blob_value;
      relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_data(idx).var_name).clob_value := relay_p_rest.g_inst_data(idx).clob_value;
      relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_vars(idx).var_name).ind_changed := 0;

      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'IDX.VAR_SOURCE:IDX.VAR_NAME:IDX:VAR_TYPE | '||
                relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_data(idx).var_name).var_source||':'||
                relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_data(idx).var_name).var_name||':'||
                relay_p_vars.g_inst_own_values(l_id_instance)(relay_p_rest.g_inst_data(idx).var_name).var_type);
    end loop;
  end if;

  l_retvar := 1;
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||l_retvar);

  return l_retvar;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_ind_owner_only: '||p_ind_owner_only);
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    return -1;
end ;
--------------------------------------------------------------------------------
--BEGIN-BUILDER-PROGRAMS--------------------------------------------------------
--------------------------------------------------------------------------------
function f_an_proc
(p_id_process in awf_process.id_record%type)
return number
as
  l_retvar number;
begin

  SELECT  id_proc_rec + 1
  INTO    l_retvar
  FROM    vw_proc_rec_index
  where   id_process = p_id_process;

  return l_retvar;
end ;
--------------------------------------------------------------------------------
--END-BUILDER-PROGRAMS----------------------------------------------------------
--------------------------------------------------------------------------------
--BEGIN-ANYDATA-/-SUBSTITUTION-STRING-PROGRAMS----------------------------------
--------------------------------------------------------------------------------
function f_get_element_type
(p_element in varchar2
,p_prev_element in varchar2 default null)
return varchar2
as
  l_program varchar2(200) := 'f_get_element_type';
  l_log_id number := f_get_log_id;

  l_is_relationship number;
  l_is_column number;
  l_is_col_tab number;
  l_is_col_var number;
  l_is_function number;
  l_is_variable number;
  l_ind_result number;

  l_rel_c_owner varchar2(50);
  l_rel_c_object varchar2(50);

  l_retvar varchar2(4000);
begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  -- get count of relationships that match
  select count(*)
  into l_is_relationship
  from awf_relationships
  where rel_name = p_element;

  -- get count of allowed functions that match
  select count(*)
  into   l_is_function
  from   awf_function
  where  function = p_element;

  -- if a previous element id fed in then load the relationship info
  if p_prev_element is not null then
    select  c_owner, c_object
    into    l_rel_c_owner, l_rel_c_object
    from    awf_relationships
    where   rel_name = p_prev_element;
  end if;

  -- get a count of the number of table attributes that match the element on the previous element (relationship)
  select count(*)
  into   l_is_col_tab
  from   sys.all_tab_cols
  where  column_name = p_element
    and  owner = nvl(l_rel_c_owner,relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).obj_owner)
    and  table_name = nvl(l_rel_c_object,relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).obj_name);

--/* -- remove if saving prior to subvars
  -- if this is the first element then
  if l_rel_c_owner is null then
    select count(*)
    into   l_is_col_var
    from   awf_inst_vars
    where  id_instance = relay_p_vars.g_active_instance
      and  var_name = p_element;
  end if;
--*/

  -- add up the columns or variable that match the element
  l_is_column := nvl(l_is_col_tab,0)+nvl(l_is_col_var,0);

  -- get the number of process variables that match
  select count(*)
  into   l_is_variable
  from   awf_inst_vars
  where  id_instance = relay_p_vars.g_active_instance;

  l_ind_result := (l_is_relationship + l_is_column + l_is_function);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_ind_result: '||l_ind_result);

  case when l_ind_result != 1 then
          l_retvar := -1;
          p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'ID ERROR'||'p_element:'||p_element||chr(10)||
                                          'l_is_relationship:'||l_is_relationship||chr(10)||
                                          'l_is_column:'||l_is_column||chr(10)||
                                          'l_is_function:'||l_is_function);
       else
          case
            when l_is_relationship > 0 then
              l_retvar := 'RELATIONSHIP';
            when l_is_column > 0 then
              l_retvar := 'COLUMN';
            when l_is_function > 0 then
              l_retvar := 'FUNCTION';
            when l_is_variable > 0 then
              l_retvar := 'VARIABLE';
          end case;
  end case;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||l_retvar);

  return l_retvar;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_element: '||p_element);
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_prev_element: '||p_prev_element);
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    raise;
end ;
--------------------------------------------------------------------------------
procedure p_process_variables
as
  l_program varchar2(200) := 'p_process_variables';
  l_log_id number := f_get_log_id;

  l_variable varchar2(4000);
  l_var_elements number;
  l_element varchar2(100);
  l_element_type varchar2(50);

  l_ind_is_relation number;
  l_ind_is_function number;
  l_ind_is_column number;

  l_rel_pos1 number;
  l_rel_pos2 number;

  l_element_loc number;
  l_var_verify_notes clob;

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  for idx in 1..g_svars.count loop

    -- trim the ':' off the variable
    l_variable := replace(g_svars(idx).orig_variable,':','');
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_variable: '||l_variable);

    -- assess the amount of elements in the variable
    l_var_elements := regexp_count(l_variable,'\.');
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_var_elements: '||l_var_elements);

    -- get the first element
    if l_var_elements > 0 then
      l_element := substr(l_variable,1,instr(l_variable,'.',1,1)-1);
    else
      l_element := substr(l_variable,1,length(l_variable));
    end if;
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_element: '||l_element);

    -- if first element is a
    case f_get_element_type(p_element => l_element)
      when 'COLUMN' then
        g_svars(idx).svar_column_name := l_element;
      when 'VARIABLE' then
        g_svars(idx).svar_variable := l_element;
      when 'FUNCTION' then
        g_svars(idx).svar_function := l_element;
        l_rel_pos1 := instr(l_variable,'.',1,1)+1;
      when 'RELATIONSHIP' then
        l_rel_pos1 := 1;
      else null;
    end case;

    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'First f_get_element_type completed');

    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_var_elements: '||l_var_elements);

    -- get the last element
    if l_var_elements > 0 then

      -- set locator for the last element
      l_element_loc := instr(l_variable,'.',1,l_var_elements)+1;
      -- get the last element in the variable
      l_element := substr(l_variable,l_element_loc,length(l_variable)-l_element_loc+1);
      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_element: '||l_element);

      -- if last element is a
      case f_get_element_type(p_element => l_element)
        when 'COLUMN' then
          g_svars(idx).svar_column_name := l_element;
          l_rel_pos2 := instr(l_variable,'.',1,l_var_elements)-1;
        when 'FUNCTION' then
          g_svars(idx).svar_notes := nvl(g_svars(idx).svar_notes,'')||chr(10)||'ERROR : Last element is a function';
          g_svars(idx).svar_ind_error := 1;
          l_rel_pos2 := instr(l_variable,'.',1,l_var_elements)-1;
        when 'RELATIONSHIP' then
          l_rel_pos2 := length(l_variable);
        else null;
      end case;
      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Second f_get_element_type completed');
    else
      l_rel_pos2 := length(l_variable);
    end if;

    if l_var_elements > 0
      or f_get_element_type(p_element => l_element) = 'RELATIONSHIP' then
      -- get the relationship chain from the variable
      g_svars(idx).svar_rel_chain := substr(l_variable,l_rel_pos1,l_rel_pos2-l_rel_pos1+1);
      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'g_subst_vars(idx).svar_rel_chain: '||g_svars(idx).svar_rel_chain);
    end if;

    -- verify that the relationship chain is valid
    if g_svars(idx).svar_rel_chain is not null then
      if g_subst_vars(relay_p_vars.g_active_instance).exists(g_svars(idx).svar_rel_chain) then
        null;
      else
        g_svars(idx).svar_notes := nvl(g_svars(idx).svar_notes,'')||chr(10)||'ERROR : Relationship Chain does not exist';
        g_svars(idx).svar_ind_error := 1;
      end if;
    end if;

    if g_svars(idx).svar_function is not null
      and g_svars(idx).svar_rel_chain is not null
      and g_svars(idx).svar_column_name is not null then
      -- if svar has a relationship chain , and a column name, and a function
      -- this can be used to get an aggregate value from the database to replace
      -- the referenced svar

      g_svars(idx).svar_ind_replace := 1;
      g_svars(idx).svar_ind_id := 0;
      g_svars(idx).svar_ind_u := 0;

    elsif g_svars(idx).svar_rel_chain is not null
      and g_svars(idx).svar_column_name is null then
      -- if svar only contains a relationship chain
      -- this can be used for inserts or deletes on the related table

      g_svars(idx).svar_ind_u := 0;
      g_svars(idx).svar_ind_id := 1;
      g_svars(idx).svar_ind_replace := 0;

    elsif g_svars(idx).svar_rel_chain is not null
      and g_svars(idx).svar_column_name is not null
      and g_svars(idx).svar_function is null then
      -- if svar contains a relationship chain and a column name, but no function
      -- this svar can be used to update the related records

      g_svars(idx).svar_ind_u := 1;
      g_svars(idx).svar_ind_id := 0;
      g_svars(idx).svar_ind_replace := 0;

    elsif g_svars(idx).svar_column_name is not null
      and g_svars(idx).svar_rel_chain is null
      and g_svars(idx).svar_function is null then
      -- if svar only contains a column_name
      -- this allows the svar to be replaced by the value of the owner column

      g_svars(idx).svar_ind_u := 0;
      g_svars(idx).svar_ind_id := 0;
      g_svars(idx).svar_ind_replace := 1;

    elsif g_svars(idx).svar_column_name is null
      and g_svars(idx).svar_rel_chain is null
      and g_svars(idx).svar_function is null
      and g_svars(idx).svar_variable is not null then
      -- if svar only contains a variable reference
      -- this allows the svar to be replaced by the value of the variable

      g_svars(idx).svar_ind_u := 0;
      g_svars(idx).svar_ind_id := 0;
      g_svars(idx).svar_ind_replace := 1;

    else
      -- otherwise mark the svar as not a proper variable
      g_svars(idx).svar_notes := nvl(g_svars(idx).svar_notes,'')||chr(10)||'ERROR : Variable not functional';
      g_svars(idx).svar_ind_u := 0;
      g_svars(idx).svar_ind_id := 0;
      g_svars(idx).svar_ind_replace := 0;
    end if;

    l_var_verify_notes := chr(10)||'l_variable: '||l_variable||chr(10)||g_svars(idx).svar_notes;

  end loop;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END');
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    null;
end ;
--------------------------------------------------------------------------------
procedure p_load_rel_coll
(p_object_owner in varchar2
,p_object_name in varchar2
,p_rel_chain in varchar2
,p_rowid_set in varchar2)
as
  l_program varchar2(200) := 'p_load_rel_coll';
  l_log_id number := f_get_log_id;

  l_refcur sys_refcursor;
  l_code clob;
  l_code_rel clob;
  l_code_rowid clob;

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  l_code_rel := relay_p_vars.g_ei_set('RWF04').text; 
  l_code_rowid := relay_p_vars.g_ei_set('RWF05').text;

  -- clear relationships
  g_relations.delete;

  -- load ei code from base to get relationships
  l_code := l_code_rel;
  -- replace values
  l_code := replace(l_code,'{OBJ_OWNER}',p_object_owner);
  l_code := replace(l_code,'{OBJ_NAME}',p_object_name);

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_code: '||l_code);

  -- execute code in a cursor, bc into g_relations, close
  open l_refcur for l_code;
  fetch l_refcur bulk collect into g_relations;
  close l_refcur;

  -- loop the g_relations
  for idx in 1..g_relations.count loop

    g_rowid_set_idx := g_rowid_set_idx + 1;

    -- Load base code to retrieve rowids for each relationship
    l_code := l_code_rowid;
    -- Replace values in the code
    l_code := replace(l_code,'{REL_NAME}',g_relations(idx).rel_name);
    l_code := replace(l_code,'{CHAIN_VAR}',case when p_rel_chain is null then '' else p_rel_chain||'.' end||g_relations(idx).rel_name);
    l_code := replace(l_code,'{REF_LEVEL}',g_rel_level);
    l_code := replace(l_code,'{P_TABLE}',g_relations(idx).p_owner||'.'||g_relations(idx).p_object);
    l_code := replace(l_code,'{C_TABLE}',g_relations(idx).c_owner||'.'||g_relations(idx).c_object);
    l_code := replace(l_code,'{P_ROWID_LIST}',p_rowid_set);
    l_code := replace(l_code,'{REL_CLAUSE}',g_relations(idx).where_clause);

    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_code: '||l_code);

    -- execute the code into the collection
    execute immediate l_code into g_rel_chain(g_rel_level)(g_rowid_set_idx);

    -- log collection variables
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'g_rel_level : '||g_rel_level);
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'g_rowid_set_idx :'||g_rowid_set_idx);
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'g_rel_chain(g_rel_level)(g_rowid_set_idx) : '||g_rel_chain(g_rel_level)(g_rowid_set_idx).rel_name);
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'g_rel_chain(g_rel_level)(g_rowid_set_idx) : '||g_rel_chain(g_rel_level)(g_rowid_set_idx).rel_chain);
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'g_rel_chain(g_rel_level)(g_rowid_set_idx) : '||g_rel_chain(g_rel_level)(g_rowid_set_idx).rel_rowids);
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'g_rel_chain(g_rel_level)(g_rowid_set_idx) : '||g_rel_chain(g_rel_level)(g_rowid_set_idx).rowid_count);

    --> if there is one or more rowids found then allow the process to proceed to the next level
    if g_rel_chain(g_rel_level)(g_rowid_set_idx).rowid_count > 0 then
      g_ind_proceed := 1;
    end if;

  end loop;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END');
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_object_owner: '||p_object_owner);
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_object_name: '||p_object_name);
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_rel_chain: '||p_rel_chain);
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_rowid_set: '||p_rowid_set);
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    raise;
end ;
--------------------------------------------------------------------------------
procedure p_load_subst_variables
as
  l_program varchar2(200) := 'p_load_subst_variables';
  l_log_id number := f_get_log_id;

  l_rel_chain varchar2(4000);
  l_rel_rowids varchar2(4000);
  l_rel_name awf_relationships.rel_name%type;

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  if g_subst_vars.exists(relay_p_vars.g_active_instance) then
    g_subst_vars(relay_p_vars.g_active_instance).delete;
  end if;

  for idx in 1..g_rel_chain.count loop

    for idx2 in 1..g_rel_chain(idx).count loop

      l_rel_chain := g_rel_chain(idx)(idx2).rel_chain;
      l_rel_rowids := g_rel_chain(idx)(idx2).rel_rowids;
      l_rel_name := g_rel_chain(idx)(idx2).rel_name;

      g_subst_vars(relay_p_vars.g_active_instance)(l_rel_chain).row_ids := l_rel_rowids;
      g_subst_vars(relay_p_vars.g_active_instance)(l_rel_chain).rel_name := l_rel_name;

    end loop;

  end loop;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END');
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    raise;
end ;
--------------------------------------------------------------------------------
procedure p_get_substitution_vars
as
  l_program varchar2(200) := 'p_get_substitution_vars';
  l_log_id number := f_get_log_id;

  -- this procedure runs through the relationships of the owner object until
  -- it discovers if related records exist, records rowids and continues the
  -- cycle until all possible relationship chains are documented

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  g_rel_level := 1;
  g_rowid_set_idx := 0;

  -- get global varibles, local
  g_object_owner := relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).obj_owner;
  g_object_name := relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).obj_name;
  g_owner_rowid := ''''||relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).owner_rowid||'''';

  -- get the initial record in the collection of variables
  p_load_rel_coll(p_object_owner => g_object_owner
                 ,p_object_name => g_object_name
                 ,p_rel_chain => null
                 ,p_rowid_set => g_owner_rowid);

  -- if the initial variable suggests that child records exist then
  if g_ind_proceed = 1 then
    -- loop until there is no more
    loop
      -- set the relative level of the variable recorded
      g_rel_level := g_rel_level + 1;
      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'g_rel_level : '||g_rel_level);
      --> TODO: ?
      g_rowid_set_idx := 0;
      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'g_rowid_set_idx : '||g_rowid_set_idx);
      -- set ind_proceed to 0 to stop the loop if it is not updated
      g_ind_proceed := 0;

      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'g_rel_chain(g_rel_level-1).count : '||g_rel_chain(g_rel_level-1).count);

      for idx in 1..g_rel_chain(g_rel_level-1).count loop

        if g_rel_chain(g_rel_level-1)(idx).rowid_count > 0 then

          select c_owner
                ,c_object
          into   g_object_owner
                ,g_object_name
          from   awf_relationships
          where  rel_name = g_rel_chain(g_rel_level-1)(idx).rel_name;

          p_load_rel_coll(p_object_owner => g_object_owner
                         ,p_object_name => g_object_name
                         ,p_rel_chain => g_rel_chain(g_rel_level-1)(idx).rel_chain
                         ,p_rowid_set => g_rel_chain(g_rel_level-1)(idx).rel_rowids);

        end if;

      end loop;

      exit when g_ind_proceed = 0;
    end loop;

  end if;

  p_load_subst_variables;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END');

exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    raise;
end ;
--------------------------------------------------------------------------------
function f_relation_exist
(p_rel_chain varchar2)
return number
as
  l_program varchar2(200) := 'f_relation_exist';
  l_log_id number := f_get_log_id;

  l_retvar number;
begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  if g_subst_vars(relay_p_vars.g_active_instance).exists(p_rel_chain) then
    l_retvar := 1;
  else
    l_retvar := 0;
  end if;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||l_retvar);

  return l_retvar;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_rel_chain: '||p_rel_chain);
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    raise;
end ;
--------------------------------------------------------------------------------
function f_get_row_ids
(p_rel_chain varchar2)
return varchar2
as
  l_program varchar2(200) := 'f_get_row_ids';
  l_log_id number := f_get_log_id;

  l_retvar varchar2(4000);
begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  if g_subst_vars(relay_p_vars.g_active_instance).exists(p_rel_chain) then
    l_retvar := g_subst_vars(relay_p_vars.g_active_instance)(p_rel_chain).row_ids;
  else
    l_retvar := 0;
  end if;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||l_retvar);

  return l_retvar;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_rel_chain: '||p_rel_chain);
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    raise;
end ;
--------------------------------------------------------------------------------
function f_get_rel_name
(p_rel_chain varchar2)
return varchar2
as
  l_program varchar2(200) := 'f_get_rel_name';
  l_log_id number := f_get_log_id;

  l_retvar varchar2(4000);
begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  if g_subst_vars(relay_p_vars.g_active_instance).exists(p_rel_chain) then
    l_retvar := g_subst_vars(relay_p_vars.g_active_instance)(p_rel_chain).rel_name;
  else
    l_retvar := 0;
  end if;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||l_retvar);

  return l_retvar;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_rel_chain: '||p_rel_chain);
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    raise;
end ;
--------------------------------------------------------------------------------
procedure p_parse_svars
(p_text_input clob)
as
  l_program varchar2(200) := 'p_parse_svars';
  l_log_id number := f_get_log_id;

  -- This procedure is designed to take in the entire text that might have
  -- substitution variables and capture the ones that are valid into a collection

  l_retvar clob;
  l_eval_vars number; -- number of suspected variables to evaluate

  l_pos1 number := 0;
  l_pos2 number := 0;

  l_extract_var varchar2(4000);
  l_checkvar number;

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  --> clear the g_svars
  g_svars.delete;

  -- return variable is initially loaded with the input value
  l_retvar := p_text_input;

  -- gets the reference number of potential variables
  l_eval_vars := regexp_count(p_text_input,'\:');
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_eval_vars : '||l_eval_vars);

  -- cycle the possible variables
  for idx in 1..l_eval_vars loop
    l_checkvar := null;

    -- position 1 is a colon (:)
    l_pos1 := regexp_instr(p_text_input,'\:',1,idx);
/*
    -- position 2 is in (space, tab, CR, or LF)
    l_pos2 := regexp_instr(p_text_input,'[ ,'||chr(10)||','||chr(13)||','||chr(9)||',\:]',l_pos1,1);
*/
    -- position 2 is another colon (:)
--    l_pos2 := regexp_instr(p_text_input,'\:',l_pos1+1,1);
    l_pos2 := regexp_instr(p_text_input,'\:',1,idx+1)+1;

    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_pos1:l_pos2 : ('||l_pos1||':'||l_pos2||')');

    l_extract_var := dbms_lob.substr(p_text_input,l_pos2-l_pos1,l_pos1);

    l_checkvar := regexp_count(l_extract_var,'['||chr(32)||','||chr(10)||','||chr(13)||','||chr(9)||']');
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_checkvar: '||l_checkvar);

    -- if there is nothing past the colon then continue (not a variable)
    if l_pos2-l_pos1 = 1
      or l_checkvar > 0 then
      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Skipped: *'||p_text_input||'*');
      continue;
    end if;

    -- extract the variable into a local collection for evaluation
    g_svars(g_svars.count+1).orig_variable := l_extract_var;

  end loop;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'g_svars.count: '||g_svars.count);

  -- process the captured variables
--  p_process_variables; sent to calling program

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END');
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_text_input: '||p_text_input);
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    raise;
end ;
--------------------------------------------------------------------------------
function f_replace_values
(p_input in clob
,p_input_type varchar2) -- [text or expression]
return clob
as
  l_program varchar2(200) := 'f_replace_values';
  l_log_id number := f_get_log_id;
  l_retvar clob;

  l_pattern varchar2(100) := ':\S+?:';
  l_count number; 
  l_subst_var varchar2(1000);
  l_subst_val clob;
  l_subst_exist number;
  l_pos1 number := 1;
  l_idx1 number := 0;
  l_var_type varchar2(200);
  l_amt2cycle number;

  type t_subst_ti is table of varchar2(4000) index by pls_integer;
  type t_subst_tv is table of varchar2(4000) index by varchar2(4000);
  l_subst_i t_subst_ti;
  l_subst_v t_subst_tv;

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  -- copy input to working variable
  l_retvar := p_input;
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'p_input: '||l_retvar);

  -- count the occurences of substitution patterns
  l_count := regexp_count(l_retvar,l_pattern,l_pos1);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_count: '||l_count);

  -- extract all substitutions from the input
  for idx in 1..l_count loop
    -- extract each substitution
    l_subst_var := upper(regexp_substr(l_retvar,l_pattern,l_pos1,idx));
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_subst_var: '||l_subst_var);

    begin 
      -- check to see if it has already been collected 
      if l_subst_v.exists(upper(l_subst_var)) then
        -- if yes, do nothing
        null;

        p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_subst_v.exists(upper(l_subst_var))');
      else
        -- if no, then add it to the collection(s)
        l_idx1 := l_idx1 + 1;
        l_subst_i(l_idx1) := l_subst_var;
        l_subst_v(l_subst_i(l_idx1)) := l_subst_var;

        p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_subst_v.(not)exists(upper(l_subst_var))');
      end if;
    exception
      when others then
        null;
    end;

  end loop;

  begin

    if l_subst_i.count > 0 then 
      l_amt2cycle := 1; 
    else 
      l_amt2cycle := 0;
    end if;

  exception
    when others then
      l_amt2cycle := 0;
  end;

  if l_amt2cycle = 1 then

    -- cycle through the collected substitutions
    for idx in 1..l_subst_i.count loop

      -- check if the substitution is valid
        -- ignore if not in list
      if relay_p_vars.g_inst_own_values(relay_p_vars.g_active_instance).exists(ltrim(rtrim(l_subst_i(idx),':'),':')) then
        -- set replacement value equal to the substitution, just in case
        l_subst_val := l_subst_i(idx);
        -- get the variable type for processing
        l_var_type := relay_p_vars.g_inst_own_values(relay_p_vars.g_active_instance)(ltrim(rtrim(l_subst_i(idx),':'),':')).var_type;

        if l_var_type not in ('CLOB','BLOB') then -- if not BLOB or CLOB then convert anydata to CLOB
          l_subst_val := relay_p_anydata.f_anydata_to_clob(p_input => relay_p_vars.g_inst_own_values(relay_p_vars.g_active_instance)(ltrim(rtrim(l_subst_i(idx),':'),':')).var_value);
        elsif l_var_type = 'CLOB' then -- if CLOB then get directly
          l_subst_val := relay_p_vars.g_inst_own_values(relay_p_vars.g_active_instance)(ltrim(rtrim(l_subst_i(idx),':'),':')).clob_value;
        else -- if BLOB, ignore
          null; --> LOG Attempted BLOB use as Sub
        end if;

        -- If Valid then replace substitution in the input 
        l_retvar := regexp_replace(l_retvar,l_subst_i(idx),l_subst_val,l_pos1,0,'i');

      else
        p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'VARIABLE DOES NOT EXIST');
      end if;

    end loop;

  end if;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||l_retvar);
  return l_retvar;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_input: '||p_input);
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_input_type: '||p_input_type);
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    raise;  
end;
--------------------------------------------------------------------------------
function f_run_expression
(p_expression in clob)
return anydata
as
  l_program varchar2(200) := 'f_run_expression';
  l_log_id number := f_get_log_id;

  l_retvar anydata;
  l_anydata sys.anydata;
  l_code_dt_base clob;
  l_code_val_base clob;
  l_code clob;
  l_result varchar2(4000);
  l_dump clob;
  l_expression clob;

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  l_code_dt_base := relay_p_vars.g_ei_set('RWF08').text;

  l_code_val_base := relay_p_vars.g_ei_set('RWF09').text;

  -- process any substution variables in the expression
  l_expression := f_replace_values
                  (p_input => p_expression
                  ,p_input_type => 'EXPRESSION');

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_code: '||l_code);
  l_result := f_get_ad_method(p_dtype => 'CLOB'
--  l_result := f_get_ad_method(p_dtype => 112 --f_get_datatype(p_dump_input => l_dump) --if removed the the function and the BIDT are dead code
                             ,p_method => 'CONVERT');

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_result: '||l_result);

  -- load the base code to execute the expression into an anydata type, replace values
  l_code := l_code_val_base;
  l_code := replace(l_code,'{EXPR}',l_expression);
  l_code := replace(l_code,'{FUNCTION}',l_result);

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_code: '||l_code);

  -- execute expression into an anydata type, update local variable, return
  execute immediate l_code into l_anydata;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'anydata.type: '||l_anydata.gettypename);

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: (anydata)');

  return l_retvar;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_expression: '||p_expression);
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    raise;
end ;
--------------------------------------------------------------------------------
function f_get_param_vc2
(p_parameter varchar2)
return varchar2
as
  l_program varchar2(200) := 'f_get_param_vc2';
  l_log_id number := f_get_log_id;

  l_retvar varchar2(4000);
begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  select anydata.accessvarchar2(parameter_value)
  into   l_retvar
  from   awf_parameters
  where  parameter_name = p_parameter;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||l_retvar);

  return l_retvar;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_parameter: '||p_parameter);
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    raise;
end ;
--------------------------------------------------------------------------------
--END-RESOURCE-PROGRAMS---------------------------------------------------------
--BEGIN-NOTIFICATIONS-PROGRAMS--------------------------------------------------
--------------------------------------------------------------------------------
procedure p_load_send_to
(p_id_template awf_comm_template.id_record%type)
as
  l_program varchar2(200) := 'p_load_send_to';
  l_log_id number := f_get_log_id;

  l_id_template number := p_id_template;
  l_id_process number;
  l_send_idx number;
  l_pers_idx number;

  type t_record_used is table of varchar2(200) index by varchar2(200);
  l_person_used t_record_used;
  l_role_used t_record_used;

  l_person vw_proc_person%rowtype;

  l_send_to vw_proc_send%rowtype;

  type t_email_coll is table of varchar2(4000) index by varchar2(4000);
  l_to t_email_coll;
  l_cc t_email_coll;
  l_bc t_email_coll;

  l_email_c varchar2(4000);

  l_assign_role number := 0;

  l_comm_send relay_p_rest.t_comm_send;
  l_send_alt1 relay_p_rest.t_coll_ref3;

  l_cs_idx number;
begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  l_id_process := relay_p_rest.g_instance.id_process;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_id_process : '||l_id_process);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_id_template : '||l_id_template);

-->!  Find a way to add the ROLE from an assignment into this mix

  l_comm_send := relay_p_rest.g_comm_send;
  l_send_alt1 := relay_p_rest.g_send_alt1;  

  if g_assignment.id_role is not null then

    l_cs_idx := l_comm_send.count+1;

    l_assign_role := 1;
    l_comm_send(l_cs_idx).id_record := 0;
    l_comm_send(l_cs_idx).id_template := g_assignment.id_email_template;
    l_comm_send(l_cs_idx).send_to_type := 'ROLE';
    l_comm_send(l_cs_idx).send_to_group := 'TO';
    l_comm_send(l_cs_idx).send_to := g_assignment.id_role;
    l_comm_send(l_cs_idx).id_check_stamp := 0;

    l_send_alt1(l_id_process)(l_id_template)(l_send_alt1(l_id_process)(l_id_template).count+1) := l_cs_idx;

  end if;

  for idx in 1..l_send_alt1(l_id_process)(l_id_template).count loop

    l_pers_idx := 0;

    l_send_idx := l_send_alt1(l_id_process)(l_id_template)(idx);

    l_send_to := l_comm_send(l_send_idx);

    if l_role_used.exists(l_send_to.send_to) then
      -- do nothing
      null;
    else 
      l_role_used(l_send_to.send_to) := l_send_to.send_to;

      if l_send_to.send_to_type = 'EMAIL' then

        case l_send_to.send_to_group
          when 'TO' then
            l_to(l_send_to.send_to) := l_send_to.send_to;
          when 'CC' then
            l_cc(l_send_to.send_to) := l_send_to.send_to;
          when 'BCC' then
            l_bc(l_send_to.send_to) := l_send_to.send_to;
          else 
            p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'SEND_TO_EMAIL INVALID');
        end case;

      elsif l_send_to.send_to_type = 'PERSON' then

        l_person := relay_p_rest.g_person(relay_p_rest.g_pers_alt1(l_send_to.send_to)(l_send_to.send_to));

        case l_send_to.send_to_group
          when 'TO' then
            l_to(l_person.email_address) := l_person.email_address;
          when 'CC' then
            l_cc(l_person.email_address) := l_person.email_address;
          when 'BCC' then
            l_bc(l_person.email_address) := l_person.email_address;
          else 
            p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'SEND_TO_PERSON INVALID');
        end case;

      elsif l_send_to.send_to_type like 'ROLE%' then

        for idx2 in 1..relay_p_rest.g_pers_alt1(l_send_to.send_to).count loop
          if l_pers_idx = 0 then
            l_pers_idx := relay_p_rest.g_pers_alt1(l_send_to.send_to).first;
          else
            l_pers_idx := relay_p_rest.g_pers_alt1(l_send_to.send_to).next(l_pers_idx);
          end if;

          l_person := relay_p_rest.g_person(relay_p_rest.g_pers_alt1(l_send_to.send_to)(l_pers_idx));

          if l_person_used.exists(l_person.id_person) then
            --do nothing
            null;
          else
            l_person_used(l_person.id_person) := l_person.id_person;

            case l_send_to.send_to_group
              when 'TO' then
                l_to(l_person.email_address) := l_person.email_address;
              when 'CC' then
                l_cc(l_person.email_address) := l_person.email_address;
              when 'BCC' then
                l_bc(l_person.email_address) := l_person.email_address;
              else 
                p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'SEND_TO_ROLE INVALID');
            end case;

            null;
          end if;

        end loop;
      elsif l_send_to.send_to_type = 'GROUP' then

        for idx2 in 1..relay_p_rest.g_pers_alt1(l_send_to.send_to).count loop
          if l_pers_idx = 0 then
            l_pers_idx := relay_p_rest.g_pers_alt1(l_send_to.send_to).first;
          else
            l_pers_idx := relay_p_rest.g_pers_alt1(l_send_to.send_to).next(l_pers_idx);
          end if;

          l_person := relay_p_rest.g_person(relay_p_rest.g_pers_alt1(l_send_to.send_to)(l_pers_idx));

          if l_person_used.exists(l_person.id_person) then
            --do nothing
            null;
          else
            l_person_used(l_person.id_person) := l_person.id_person;

            case l_send_to.send_to_group
              when 'TO' then
                l_to(l_person.email_address) := l_person.email_address;
              when 'CC' then
                l_cc(l_person.email_address) := l_person.email_address;
              when 'BCC' then
                l_bc(l_person.email_address) := l_person.email_address;
              else 
                p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'SEND_TO_ROLE INVALID');
            end case;

            null;
          end if;

        end loop;
      end if;

    end if;

  end loop;

  for idx in 1..l_to.count loop
    -- load the email to line
    if idx = 1 then
      l_email_c := l_to.first;
      g_to := l_email_c;
    else 
      l_email_c := l_to.next(l_email_c);
      g_to := g_to||','||l_email_c;
    end if;

  end loop;

  for idx in 1..l_cc.count loop
    -- load the email to line
    if idx = 1 then
      l_email_c := l_cc.first;
      if l_to.exists(l_email_c) then
        null;
      else 
        g_cc := l_email_c;
      end if;
    else 
      l_email_c := l_cc.next(l_email_c);
      if l_to.exists(l_email_c) then
        null;
      else 
        g_cc := g_cc||','||l_email_c;
      end if;
    end if;

  end loop;

  for idx in 1..l_bc.count loop
    -- load the email to line
    if idx = 1 then
      l_email_c := l_bc.first;
      if l_to.exists(l_email_c) 
        or l_cc.exists(l_email_c) then
        null;
      else 
        g_bcc := l_email_c;
      end if;
    else 
      l_email_c := l_bc.next(l_email_c);
      if l_to.exists(l_email_c) 
        or l_cc.exists(l_email_c) then
        null;
      else 
        g_bcc := g_bcc||','||l_email_c;
      end if;
    end if;

  end loop;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'g_to: '||g_to);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'g_cc: '||g_cc);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'g_bcc: '||g_bcc);

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END');

exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_id_template: '||p_id_template);
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    raise;
end ;
--------------------------------------------------------------------------------
function f_body_check
(p_text clob)
return clob
as
  l_program varchar2(200) := 'f_body_check';
  l_log_id number := f_get_log_id;

  l_text clob;
  l_cr_count number;
  l_pos1 number;
  l_pos2 number;
  l_br_amt number;
  l_space_found number;

  l_retvar clob;
begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  -- check the lines to see if there is a cr at minimum every 1000 characters
  -- surround clob with CR
  l_text := chr(10)||p_text||chr(10);

  -- check to see how many cr are present
  l_cr_count := regexp_count(l_text,chr(10));
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_cr_count: '||l_cr_count);

  -- loop through the lines and check for length of the line
  for idx in 1..l_cr_count-1 loop

    l_pos1 := dbms_lob.instr(l_text,chr(10),1,idx);
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_pos1: '||l_pos1);
    l_pos2 := dbms_lob.instr(l_text,chr(10),1,idx+1);
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_pos2: '||l_pos2);

    if l_pos2-l_pos1 > 1000 then
      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'additional CR required');

      -- if longer than 1000 then insert a CR every 900 within the line
      l_br_amt := floor((l_pos2-l_pos1)/900);
      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_br_amt: '||l_br_amt);

      for idx2 in 1..l_br_amt loop

        l_space_found := dbms_lob.instr(l_text,' ',l_pos1+900*idx2,1);
        dbms_lob.fragment_replace(lob_loc => l_text
                                 ,old_amount => 1
                                 ,new_amount => 4
                                 ,offset => l_space_found
                                 ,buffer => '[CR]');

      end loop;

    end if;

  end loop;

  l_text := replace(l_text,'[CR]',chr(10));

  l_retvar := l_text;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||l_retvar);

  return l_retvar;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_text: '||p_text);
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    raise;
end ;
--------------------------------------------------------------------------------
function f_send_notification
(p_id_template awf_comm_template.id_record%type)
return number
as
  l_program varchar2(200) := 'f_send_notification';
  l_log_id number := f_get_log_id;

  l_comm_template vw_proc_comm%rowtype;

  l_retvar number;
begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'g_workspace_id: '||g_workspace_id);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'c_app_id: '||v('APP_ID'));

  if nvl(v('APP_ID'),-1) = -1 then
    apex_util.set_security_group_id(p_security_group_id => g_workspace_id);
  end if;

  -- load the comm template
  l_comm_template := relay_p_rest.g_comm_temp(relay_p_rest.g_temp_alt1(relay_p_rest.g_instance.id_process)(p_id_template));

  -- load the recipient list
  p_load_send_to(p_id_template);

  -- if an assignment is involved
  if g_assignment.id_role is not null then 
    l_comm_template.message_body_pt := 'WORKFLOW Assignment: '||g_assignment.description||chr(10)||l_comm_template.message_body_pt;
    l_comm_template.message_body_html := '<p><b>'||'WORKFLOW Assignment: '||g_assignment.description
                                       ||'</b></p>'||chr(10)||l_comm_template.message_body_html;
    l_comm_template.subject_line := '[WORKFLOW Assignment] '||l_comm_template.subject_line;
  end if;

  -- make subsitutions for body texts
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_comm_template.message_body_pt:'||l_comm_template.message_body_pt);
  if length(l_comm_template.message_body_pt) > 0 then
    l_comm_template.message_body_pt := f_replace_values(l_comm_template.message_body_pt,'TEXT');
  end if;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_comm_template.message_body_html:'||l_comm_template.message_body_html);
  if length(l_comm_template.message_body_html) > 0 then
    l_comm_template.message_body_html := f_replace_values(l_comm_template.message_body_html,'TEXT');
  end if;

  -- make subsitutions for subject text
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_comm_template.subject_line:'||l_comm_template.subject_line);
  if length(l_comm_template.message_body_html) > 0 then
    l_comm_template.subject_line := f_replace_values(l_comm_template.subject_line,'TEXT');

  end if;

  -- Check to make sure body text has CR at maximum every 1000 char
  l_comm_template.message_body_pt := f_body_check(l_comm_template.message_body_pt);
  l_comm_template.message_body_html := f_body_check(l_comm_template.message_body_html);

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'g_to:'||g_to);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_comm_template.send_from_email:'||l_comm_template.send_from_email);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_comm_template.message_body_pt:'||l_comm_template.message_body_pt);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_comm_template.message_body_html:'||l_comm_template.message_body_html);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_comm_template.subject_line:'||l_comm_template.subject_line);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'g_cc:'||g_cc);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'g_bcc:'||g_bcc);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_comm_template.subject_line:'||l_comm_template.subject_line);

  -- Issue the email
  apex_mail.send
  (p_to => g_to
  ,p_from => l_comm_template.send_from_email
  ,p_body => l_comm_template.message_body_pt
  ,p_body_html => l_comm_template.message_body_html
  ,p_subj => l_comm_template.subject_line
  ,p_cc => g_cc
  ,p_bcc => g_bcc
  ,p_replyto => l_comm_template.reply_to_email);

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'EMAIL SENT');

  apex_mail.push_queue;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'QUEUE PUSHED');

  l_retvar :=  1;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||l_retvar);
  return l_retvar;
exception
  when others then
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
  p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_id_template: '||p_id_template);
  p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
  return -1;
end ;
--------------------------------------------------------------------------------
--END-NOTIFICATIONS-PROGRAMS----------------------------------------------------
--------------------------------------------------------------------------------
--BEGIN-ASSIGNMENT-PROGRAMS-----------------------------------------------------
--------------------------------------------------------------------------------
function f_assign_exists
(p_id_process in number
,p_id_node in number)
return varchar2
as

  l_retvar varchar2(1000);
  l_checkvar number;
  l_rowid varchar2(1000);

begin

  select count(*), min(rowid)
  into l_checkvar, l_rowid
  from awf_node_assignment
  where id_process = p_id_process
    and node_number = p_id_node;

  if l_checkvar = 0 then
    l_retvar := '0';
  elsif l_checkvar = 1 then
    l_retvar := l_rowid;
  else l_retvar := l_rowid;
  end if;

  return l_retvar;
/*
exception
  when others then 
    return '-1';
*/
end;
--------------------------------------------------------------------------------
procedure p_esc_assignments
as
  l_program varchar2(200) := 'p_esc_assignments';
  l_log_id number := f_get_log_id;

  type assignment_r is record (id_process number, id_proc_rec number);
  type assignment_t is table of assignment_r index by pls_integer;
  l_active_assign assignment_t;

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

/*
  select  distinct id_process, id_proc_rec
  bulk collect into l_active_assign
  from    awf_inst_assign
  --> TODO: Place work here
*/

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END');
  null;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    raise;
end ;
--------------------------------------------------------------------------------
function f_create_assignments
(p_ind_decision in awf_inst_assign.ind_decision%type default null)
return number
as
  l_program varchar2(200) := 'f_create_assignments';
  l_log_id number := f_get_log_id;

  l_checkvar number := 0;

  l_retvar number;
  type inst_assign_t is table of awf_inst_assign%rowtype index by pls_integer;
  l_inst_assign inst_assign_t;

  l_ts_var varchar2(4000);

  l_node_number number;
  l_id_process number;

  l_assign awf_node_assignment%rowtype;
  l_loop1 number := 0;

  l_pers_idx number;

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  l_node_number := g_awf_node(relay_p_vars.g_active_instance).id_proc_rec;
  l_id_process := g_awf_node(relay_p_vars.g_active_instance).id_process;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'relay_p_rest.g_nass_alt2(l_id_process)(l_node_number).count: '||relay_p_rest.g_nass_alt2(l_id_process)(l_node_number).count);

  for idx in 1..relay_p_rest.g_nass_alt2(l_id_process)(l_node_number).count loop

    l_loop1 := l_loop1 + 1;

    g_assignment := relay_p_rest.g_nassign(relay_p_rest.g_nass_alt2(l_id_process)(l_node_number)(l_loop1));

    for idx2 in 1..relay_p_rest.g_pers_alt1(g_assignment.id_role).count loop
      if idx2 = 1 then
        l_pers_idx := relay_p_rest.g_pers_alt1(g_assignment.id_role).first;
      else
        l_pers_idx := relay_p_rest.g_pers_alt1(g_assignment.id_role).next(l_pers_idx);
      end if;

      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_pers_idx: '||l_pers_idx);

      l_inst_assign(idx2).ID_RECORD := f_an_main;
      l_inst_assign(idx2).PRIORITY := g_assignment.priority;
      l_inst_assign(idx2).ID_ASSIGNEE := relay_p_rest.g_person(relay_p_rest.g_pers_alt1(g_assignment.id_role)(l_pers_idx)).id_person;
      l_inst_assign(idx2).DATE_START := sysdate;
      l_inst_assign(idx2).DATE_DUE := sysdate + (g_awf_node(relay_p_vars.g_active_instance).interval / 60 / 24);
      l_inst_assign(idx2).CODE_STATUS := 'INITIATED';
      l_inst_assign(idx2).ID_INSTANCE := relay_p_vars.g_active_instance;
      l_inst_assign(idx2).ID_PROCESS := relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_process;
      l_inst_assign(idx2).ID_PROC_REC := g_assignment.id_proc_rec;
      l_inst_assign(idx2).IND_DECISION := p_ind_decision;
      l_inst_assign(idx2).ID_CHECK_STAMP := f_an_stamp;
      l_inst_assign(idx2).PERSON_CODE := relay_p_rest.g_person(relay_p_rest.g_pers_alt1(g_assignment.id_role)(l_pers_idx)).person_code;

    end loop;

    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_inst_assign.count: '||l_inst_assign.count);

    forall idx2 in 1..l_inst_assign.count
    insert into awf_inst_assign
    values l_inst_assign(idx2);

    -- send notification email if set
    if g_assignment.ind_notify_by_email = 1 then
      if f_send_notification(g_assignment.id_email_template) = 1 then
        p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'Assignment Notification Sent');
      else
        p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR', 'Assignment Notification ERROR');
      end if;
    end if;

    g_assignment := null;

  end loop;

  l_retvar := 1;
  p_build_wf_rec('ASSIGNMENT','INITIATED',relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node,null,null);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||l_retvar);
  return l_retvar;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_ind_decision: '||p_ind_decision);
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    return -1;
end ;
--------------------------------------------------------------------------------
function f_eval_assignments
(p_ind_decision in number default 0)
return number
as
  l_program varchar2(200) := 'f_eval_assignments';
  l_log_id number := f_get_log_id;

  l_retvar number;
  l_assign_count number;
  l_amt_for_true number;
  l_cre_assign number;
  l_assign_opened number;
  l_assign_comp number;

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  -- get the current situation stats of the task assignments
  select 
          count(a.id_record)
         ,max(b.amt_for_true)
         ,sum(case when a.code_status != 'INITIATED' then 1 else 0 end) opened
         ,sum(case when a.code_status = 'COMPLETED' then 1 else 0 end) completed
  into    l_assign_count, l_amt_for_true, l_assign_opened, l_assign_comp
  from    awf_inst_assign a
         ,awf_node_assignment b
         ,awf_node c
  where   1=1
    and   a.id_proc_rec = b.id_proc_rec
    and   a.id_process = b.id_process
    and   c.id_proc_rec = b.node_number
    and   c.id_process = b.id_process
    and   a.id_proc_rec = g_awf_node(relay_p_vars.g_active_instance).id_proc_rec
    and   a.id_process = g_awf_node(relay_p_vars.g_active_instance).id_process
    and   a.code_status != 'CLOSED';

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_assign_count:'||l_assign_count);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_amt_for_true:'||l_amt_for_true);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_assign_opened:'||l_assign_opened);

  -- if no assignments exist or are active then create a set of assignments
  if l_assign_count = 0 then
    -- create assignments
    l_cre_assign := f_create_assignments(p_ind_decision);
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_cre_assign:'||l_cre_assign);

    l_retvar := 0;
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_retvar:'||l_retvar);

    p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'ASSIGNMENT:CREATED:'||g_awf_node(relay_p_vars.g_active_instance).id_proc_rec);

    if l_cre_assign = -1 then
      l_retvar := -1;

      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'ERROR: Assignment Creation:');
      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_retvar:'||l_retvar);
    end if;

  elsif l_assign_count > 0 -- if there are active assignments
    -- and one of the following conditions exist
    -- amount fot true = ANY (0) and at least one assignment has been completed
    and ((l_amt_for_true = 0 and nvl(l_assign_comp,0) > 0)
    -- amount fot true = ALL (-1) and all are completed
    or (l_amt_for_true = -1 and nvl(l_assign_comp,0) = l_assign_count)

    or (case when l_amt_for_true = 0 then -5 else l_amt_for_true end = nvl(l_assign_comp,0))) -- amount for true is not zero and the number of assignments are equal to it
    then

    l_retvar := 1;
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_retvar:'||l_retvar);

    update awf_inst_assign
    set    code_status = 'CLOSED'
    where  id_process = relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_process
      and  id_proc_rec = relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node;

    p_build_wf_rec('ASSIGNMENT','CLOSED',relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node,null,null);
    p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'ASSIGNMENT:CLOSED:'||g_awf_node(relay_p_vars.g_active_instance).id_proc_rec);

  else
    l_retvar := 0;
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_retvar:'||l_retvar);
    p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'NO ASSIGNMENTS CREATED OR ALTERED:'||g_awf_node(relay_p_vars.g_active_instance).id_proc_rec);
  end if;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||l_retvar);
  return l_retvar;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR) Return -1');
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    return -1;
end ;
--------------------------------------------------------------------------------
--END-ASSIGNMENT-PROGRAMS-------------------------------------------------------
--------------------------------------------------------------------------------
--BEGIN-CONDITIONS-PROGRAMS-----------------------------------------------------
--------------------------------------------------------------------------------
function f_test_condition
(p_condition in awf_conditions.condition%type
,p_id_instance in awf_instance.id_record%type default null)
return number
as
  l_program varchar2(200) := 'f_test_condition';
  l_log_id number := f_get_log_id;

  l_test_result number;

  l_stmt        clob;

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  l_stmt := 'BEGIN :1 := case when [CONDITION] then 1 else 0 end; END;';
/*  
  l_stmt := 'select  count(*)
             from    [OWNER].[OBJECT]
             where   [KEYCOL] = [KEYVAL]
               and   [CONDITION]';
*/
  -- sanitize p_condition substitution variables (maybe a separate function)
/*
  -- prep l_stmt for
  l_stmt := replace(l_stmt,'[OWNER]',nvl(g_inst_data.obj_owner, relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).obj_owner));
  l_stmt := replace(l_stmt,'[OBJECT]',nvl(g_inst_data.obj_name, relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).obj_name));
  l_stmt := replace(l_stmt,'[KEYCOL]',nvl(g_inst_data.wfid, relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).wfid_col));
  l_stmt := replace(l_stmt,'[KEYVAL]',nvl(g_inst_data.id_owner, relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_owner));
*/
  l_stmt := replace(l_stmt,'[CONDITION]',p_condition);

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_stmt: '||l_stmt);

  -- execute the condition and return the result
  execute immediate l_stmt using out l_test_result;

  -- if the returned count is less than 1 then return 0 (not passed)
  case
    when l_test_result < 1 then
      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: 0');
      return 0;
    else
      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: 1');
      return 1; -- otherwise return 1 (passed)
  end case;

exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_condition: '||p_condition);
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_id_instance: '||p_id_instance);
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');

    return -1;
end ;
--------------------------------------------------------------------------------
function f_eval_conditions
(p_id_proc_rec in awf_conditions.id_proc_rec%type
,p_amt_for_true in awf_node.amt_for_true%type
,p_id_instance in awf_instance.id_record%type default null)
return number
as
  l_program varchar2(200) := 'f_eval_conditions';
  l_log_id number := f_get_log_id;

  l_retvar  number;
  l_cum_tr    number := 0;
  l_amt_cond  number := 0;
  l_test_result number;

  l_loop1 number := 0;

  type t_cond_t is table of awf_conditions%rowtype index by pls_integer;
  l_cond t_cond_t;

  l_id_process number;

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'p_id_proc_rec: '||p_id_proc_rec);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'p_amt_for_true: '||p_amt_for_true);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'p_id_instance: '||p_id_instance);

  l_id_process := relay_p_rest.g_instance.id_process;

  p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'EVAL_COND:START:'||l_id_process||'.'||p_id_proc_rec);

  if relay_p_rest.g_cond_alt2.exists(l_id_process)
    and relay_p_rest.g_cond_alt2(l_id_process).exists(p_id_proc_rec)
    and relay_p_rest.g_cond_alt2(l_id_process)(p_id_proc_rec).count > 0 then
    for idx in 1..relay_p_rest.g_cond_alt2(l_id_process)(p_id_proc_rec).count
    loop

      l_cond(idx) := relay_p_rest.g_cond(relay_p_rest.g_cond_alt2(l_id_process)(p_id_proc_rec)(idx));

    end loop; 
  end if;

  for idx in 1..l_cond.count loop

    l_loop1 := l_loop1 + 1;
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_loop1: '||l_loop1||':'||l_cond(idx).id_process||':'||l_cond(idx).id_proc_rec);

    p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'TEST_COND:START:'||l_cond(idx).id_proc_rec);

    l_amt_cond := l_amt_cond + 1;

    l_test_result := f_test_condition(f_replace_values(l_cond(idx).condition,'EXPRESSION'), p_id_instance);

    case
      when l_test_result <= 0
        and l_cond(idx).ind_must_be = 1 then
        p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', '|'||g_workflow_index||'| Required Condition Failed');
        return 0;
      when l_test_result = 1 then
        l_cum_tr := l_cum_tr + 1;
      else null;
    end case;

    p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'TEST_COND:COMPLETE:'||l_cond(idx).id_proc_rec);

  end loop;

  case
    when l_loop1 = 0 then
      l_retvar := -2;
      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'TEST_COND:NO CONDITIONS');
    when p_amt_for_true = -1
      and l_cum_tr = l_amt_cond then
      l_retvar := 1;
    when p_amt_for_true = 0
      and l_cum_tr >= 1 then
      l_retvar := 1;
    when p_amt_for_true > 0
      and l_cum_tr >= p_amt_for_true then
      l_retvar := 1;
    else
      l_retvar := 0;
  end case;

--  g_inst_data := null;
  l_cond.delete;

  p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'COND_EVAL:COMPLETE:'||p_id_proc_rec);

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||l_retvar);
  return l_retvar;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_id_proc_rec: '||p_id_proc_rec);
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_amt_for_true: '||p_amt_for_true);
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_id_instance: '||p_id_instance);
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    return -1;
end ;
--------------------------------------------------------------------------------
--END-CONDITIONS-PROGRAMS-------------------------------------------------------
--BEGIN-ACTIONS-PROGRAMS--------------------------------------------------------
--------------------------------------------------------------------------------
function f_set_value
(p_action_name in varchar2)
return number
as
  l_program varchar2(200) := 'f_set_value';
  l_log_id number := f_get_log_id;

  l_retvar number;

  invalid_var_src_type exception;
  var_not_exist exception;
  l_code_base clob;

  l_code clob;
  l_param vw_proc_actpv%rowtype; --varchar2(50);
  l_anydata anydata;
  l_clobdata clob;
  l_blobdata blob;

  l_p_idx number;

  --> TODO: f_run_expression(p_expression => anydata.accessvarchar2(act_value))
begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'p_action_name: '||p_action_name);

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'g_actions_pv(p_action_name).count: '
             ||relay_p_rest.g_apv_alt2(relay_p_rest.g_instance.id_process)(p_action_name).count);

  -- cycle each parameter / value
  for idx in 1..relay_p_rest.g_apv_alt2(relay_p_rest.g_instance.id_process)(p_action_name).count loop

    l_p_idx := relay_p_rest.g_apv_alt2(relay_p_rest.g_instance.id_process)(p_action_name)(idx);
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_p_idx: '||l_p_idx);

    l_param := relay_p_rest.g_act_pv(l_p_idx);
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_param: '||l_param.act_parameter);

    if relay_p_vars.g_inst_own_values(relay_p_vars.g_active_instance).exists(l_param.act_parameter) then

      if l_param.var_source_type in ('VALUE','VARIABLE') then
        l_anydata := l_param.act_value;
      elsif l_param.var_source_type = 'EXPRESSION' then
        l_anydata := f_run_expression(p_expression => anydata.accessvarchar2(l_param.act_value));
      else
        raise invalid_var_src_type;
      end if;

      if relay_p_vars.g_inst_own_values(relay_p_vars.g_active_instance)(l_param.act_parameter).var_type not in ('CLOB','BLOB') then
        relay_p_vars.g_inst_own_values(relay_p_vars.g_active_instance)(l_param.act_parameter).var_value := l_anydata;
        relay_p_vars.g_inst_own_values(relay_p_vars.g_active_instance)(l_param.act_parameter).ind_changed := 1;
        p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'ind_changed: '||relay_p_vars.g_inst_own_values(relay_p_vars.g_active_instance)(l_param.act_parameter).ind_changed);
      elsif relay_p_vars.g_inst_own_values(relay_p_vars.g_active_instance)(l_param.act_parameter).var_type = 'CLOB' then
        relay_p_vars.g_inst_own_values(relay_p_vars.g_active_instance)(l_param.act_parameter).clob_value := relay_p_anydata.f_anydata_to_clob(l_anydata);
        relay_p_vars.g_inst_own_values(relay_p_vars.g_active_instance)(l_param.act_parameter).ind_changed := 1;
        p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'ind_changed: '||relay_p_vars.g_inst_own_values(relay_p_vars.g_active_instance)(l_param.act_parameter).ind_changed);
      elsif relay_p_vars.g_inst_own_values(relay_p_vars.g_active_instance)(l_param.act_parameter).var_type = 'BLOB' then
        --relay_p_vars.g_inst_own_values(relay_p_vars.g_active_instance)(l_param.act_parameter).blob_value := l_blobdata;
        null;
      end if;

    else
      raise var_not_exist;
    end if;

  end loop;

  l_retvar := 1;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||l_retvar);
  return l_retvar;

exception
  when others then  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
  p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_action_name: '||p_action_name);
  p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    return -1;
end;
--------------------------------------------------------------------------------
function f_run_method
(p_action_name in varchar2)
return number
as
  l_program varchar2(200) := 'f_run_method';
  l_log_id number := f_get_log_id;

  l_retvar number;

  l_chk_var number;
  proc_not_found exception;

  l_active_pv t_active_pv;
  l_def_lvars clob;
  l_load_l_vars clob;
  l_pv_set clob;
  l_to_iv_stmts clob;

  l_code_base clob;

  l_code clob;

  write_data_error exception;
  load_data_error exception;

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'g_actions(p_action_name).prog_owner: '||g_actions(p_action_name).prog_owner);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'g_actions(p_action_name).prog_name: '||g_actions(p_action_name).prog_name);

  l_code_base := relay_p_vars.g_ei_set('RWF15').text;

  -- check to see if program exists
    -- if no then raise exception
  select count(*)
  into l_chk_var
  from all_procedures
  where upper(owner||'.'||object_name||case when procedure_name is not null then '.'||procedure_name else '' end) = upper(g_actions(p_action_name).prog_owner||'.'||g_actions(p_action_name).prog_name);

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_chk_var: '||l_chk_var);

  if l_chk_var = 0 then
    raise proc_not_found;
  else l_chk_var := null;
  end if;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Program Exists');

  -- write owner data / vars back to tables before running programs that could alter the same data

  if g_actions(p_action_name).ind_save_data = 1 then
    l_chk_var := f_write_owner_updates(1);

    if l_chk_var in (0,-1) then
      raise write_data_error;
    else l_chk_var := null;
    end if;

    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Owner Data Saved');

  end if;

  -- load replacement variables
  for idx1 in (select  *
               from    awf_action_pv
               where   obj_owner = g_actions(p_action_name).obj_owner
                 and   obj_name = g_actions(p_action_name).obj_name
                 and   action_name = p_action_name
               order by id_sequence)
  loop

    l_def_lvars := nvl(l_def_lvars,'')||'l_'||idx1.act_parameter||' '||idx1.act_param_type||case when idx1.act_param_type = 'VARCHAR2' then '(4000)' else '' end||';'||chr(10);
    l_load_l_vars := nvl(l_load_l_vars,'')||
                       case when idx1.act_param_dir like '%IN%'
                              and idx1.act_value is not null then
                       'l_'||idx1.act_parameter||' := '
                       --todo: ADD CASE for not LOB dt
                       ||'sys.anydata.'||f_get_ad_method(p_dtype => idx1.act_param_type, p_method => 'ACCESS')||'(l_active_pv('''||idx1.act_parameter||'''));'
                       --todo: ADD CASE for CLOB
                       --todo: ADD CASE for BLOB
                       else '' end||chr(10);
    l_pv_set := nvl(l_pv_set,'')||idx1.act_parameter||' => l_'||idx1.act_parameter||chr(10);
    l_to_iv_stmts := nvl(l_to_iv_stmts,'')||
                       case when idx1.act_param_dir like '%OUT%' then
                       --todo: ADD CASE for not LOB
                        'relay_p_vars.g_inst_own_values(relay_p_vars.g_active_instance)('''||idx1.act_par_target||''').var_value := sys.anydata.'
                        ||f_get_ad_method(p_dtype => idx1.act_param_type, p_method => 'CONVERT')
                        ||'(l_'||idx1.act_parameter||');'
                       --todo: ADD CASE for CLOB
                       --todo: ADD CASE for BLOB
                       else '' end||
                       chr(10);

  end loop;
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Listagg Variables loaded');

  -- load the code variable from base, replace values
  l_code := l_code_base;
  l_code := replace(l_code,'{DEF_L_VARS}', l_def_lvars);
  l_code := replace(l_code,'{LOAD_L_VARS}', l_load_l_vars);
  l_code := replace(l_code,'{PV_SET}', l_pv_set);
  l_code := replace(l_code,'{OWNER}', g_actions(p_action_name).prog_owner);
  l_code := replace(l_code,'{PROGRAM}', g_actions(p_action_name).prog_name);
  l_code := replace(l_code,'{TO_IV_STMTS}', l_to_iv_stmts);

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Main Replacements Done');

  if g_actions(p_action_name).prog_type = 'FUNCTION' then
    l_code := replace(l_code,chr(45)||chr(45)||'{FUNC}', '');
    l_code := replace(l_code,'{RETVAR_DT}', case when g_actions(p_action_name).func_retvar_type = 'VARCHAR2' then g_actions(p_action_name).func_retvar_type||'(4000)'
                                                 else g_actions(p_action_name).func_retvar_type end);
    l_code := replace(l_code,'{RV_INST_VAR}', g_actions(p_action_name).func_retvar_name);
    l_code := replace(l_code,'{DT_VAR}', f_get_ad_method(p_dtype => g_actions(p_action_name).func_retvar_type
                                                                     ,p_method => 'CONVERT'));
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Function Replacements Done');

  end if;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Code Built');
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_code: '||l_code);

  -- process and load parameter collection
  for idx in (select act_parameter
                    ,var_source_type
                    ,act_param_type
                    ,act_value
              from  awf_action_pv
              where obj_owner = g_actions(p_action_name).obj_owner
                and obj_name = g_actions(p_action_name).obj_name
                and action_name = g_actions(p_action_name).action_name
              order by id_sequence) loop

    l_active_pv(idx.act_parameter) :=
      case nvl(idx.var_source_type,'VALUE')
      when 'VALUE' then idx.act_value
      when 'VARIABLE' then f_get_var_value(p_action_dt => idx.act_param_type, p_value => idx.act_value)
      when 'EXPRESSION' then f_run_expression(p_expression => anydata.accessvarchar2(idx.act_value))
      else null end;

    -- l_active_pv(idx.act_parameter) := idx.act_value;
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'idx.act_parameter: '||idx.act_parameter);

  end loop;

  g_active_pv := l_active_pv;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_active_pv.count '||l_active_pv.count);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'g_active_pv.count '||g_active_pv.count);

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Parameter Collection Loaded');

  -- execute program
  execute immediate l_code;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Program Run');

  -- reload owner data / vars after running programs that could alter the same data

  if g_actions(p_action_name).ind_save_data = 1 then
    l_chk_var := f_load_owner_data(1);

    if l_chk_var in (0,-1) then
      raise load_data_error;
    else l_chk_var := null;
    end if;

    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Owner Data Retrieved');

  end if;

  l_retvar := 1;
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||l_retvar);
  return l_retvar;
exception
  when others then
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
  p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_action_name: '||p_action_name);
  p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    return -1;
end ;
--------------------------------------------------------------------------------
function f_run_alert
return number
as
  l_program varchar2(200) := 'f_run_alert';
  l_log_id number := f_get_log_id;

  l_retvar number;
begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  --> TODO: Logic

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||l_retvar);
  return l_retvar;
exception
  when others then
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
  p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    return -1;
end ;
--------------------------------------------------------------------------------
function f_run_notification
(p_action_name in varchar2)
return number
as
  l_program varchar2(200) := 'f_run_notification';
  l_log_id number := f_get_log_id;
  l_id_template number;

  l_retvar number;
  l_id_process number;
begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  l_id_process := relay_p_rest.g_instance.id_process;
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_id_process: '||l_id_process);

  -- get id from g_actions(action_name)
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'p_action_name: '||p_action_name);
  l_id_template := relay_p_rest.g_action(relay_p_rest.g_act_alt1(l_id_process)(p_action_name)).id_template;

  -- send notification
  l_retvar := f_send_notification(p_id_template => l_id_template);

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||l_retvar);
  return l_retvar;
exception
  when others then
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
  p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    return -1;
end ;
--------------------------------------------------------------------------------
function f_run_app_action
return number
as
  l_program varchar2(200) := 'f_run_app_action';
  l_log_id number := f_get_log_id;

  l_retvar number;
begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  --> TODO: Logic

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||l_retvar);
  return l_retvar;
exception
  when others then
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
  p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    return -1;
end ;
--------------------------------------------------------------------------------
function f_load_actions
return number
as
  l_program varchar2(200) := 'f_load_actions';
  l_log_id number := f_get_log_id;
  l_retvar number;

  l_l1_idx number;
  l_l2_idx number;

  l_process number;
  l_action varchar2(4000);

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  l_process := relay_p_rest.g_instance.id_process;

  if relay_p_rest.g_act_alt1.count > 0
    and relay_p_rest.g_act_alt1(l_process).count > 0 then
    for idx in 1..relay_p_rest.g_act_alt1(l_process).count loop
      if idx = 1 then
        l_l1_idx := relay_p_rest.g_act_alt1(l_process).first;
      else
        l_l1_idx := relay_p_rest.g_act_alt1(l_process).next(l_l1_idx);
      end if;

      l_action := relay_p_rest.g_action(l_l1_idx).action_name;

      g_actions(l_action).id_record := relay_p_rest.g_action(l_l1_idx).id_record;
      g_actions(l_action).action_name := relay_p_rest.g_action(l_l1_idx).action_name;
      g_actions(l_action).description := relay_p_rest.g_action(l_l1_idx).description;
      g_actions(l_action).obj_owner := relay_p_rest.g_action(l_l1_idx).obj_owner;
      g_actions(l_action).obj_name := relay_p_rest.g_action(l_l1_idx).obj_name;
      g_actions(l_action).code_action_type := relay_p_rest.g_action(l_l1_idx).code_action_type;
      g_actions(l_action).id_template := relay_p_rest.g_action(l_l1_idx).id_template;
      g_actions(l_action).prog_owner := relay_p_rest.g_action(l_l1_idx).prog_owner;
      g_actions(l_action).prog_name := relay_p_rest.g_action(l_l1_idx).prog_name;
      g_actions(l_action).prog_type := relay_p_rest.g_action(l_l1_idx).prog_type;
      g_actions(l_action).func_retvar_name := relay_p_rest.g_action(l_l1_idx).func_retvar_name;
      g_actions(l_action).func_retvar_type := relay_p_rest.g_action(l_l1_idx).func_retvar_type;
      g_actions(l_action).id_check_stamp := relay_p_rest.g_action(l_l1_idx).id_check_stamp;
      g_actions(l_action).ind_save_data := relay_p_rest.g_action(l_l1_idx).ind_save_data;

      if relay_p_rest.g_apv_alt2(l_process)(l_action).count > 0 then
        for idx2 in 1..relay_p_rest.g_apv_alt2(l_process)(l_action).count loop
          if idx = 1 then
            l_l2_idx := relay_p_rest.g_apv_alt2(l_process)(l_action).first;
          else
            l_l2_idx := relay_p_rest.g_apv_alt2(l_process)(l_action).next(l_l2_idx);
          end if;

          p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_l2_idx : '||l_l2_idx);

          g_actions_pv(l_action)(l_l2_idx).id_record := relay_p_rest.g_act_pv(l_l2_idx).id_record;
          g_actions_pv(l_action)(l_l2_idx).id_check_stamp := relay_p_rest.g_act_pv(l_l2_idx).id_check_stamp;
          g_actions_pv(l_action)(l_l2_idx).id_sequence := relay_p_rest.g_act_pv(l_l2_idx).id_sequence;
          g_actions_pv(l_action)(l_l2_idx).act_parameter := relay_p_rest.g_act_pv(l_l2_idx).act_parameter;
          g_actions_pv(l_action)(l_l2_idx).act_param_type := relay_p_rest.g_act_pv(l_l2_idx).act_param_type;
          g_actions_pv(l_action)(l_l2_idx).act_param_dir := relay_p_rest.g_act_pv(l_l2_idx).act_param_dir;
          g_actions_pv(l_action)(l_l2_idx).act_value := relay_p_rest.g_act_pv(l_l2_idx).act_value;
          g_actions_pv(l_action)(l_l2_idx).obj_owner := relay_p_rest.g_act_pv(l_l2_idx).obj_owner;
          g_actions_pv(l_action)(l_l2_idx).obj_name := relay_p_rest.g_act_pv(l_l2_idx).obj_name;
          g_actions_pv(l_action)(l_l2_idx).action_name := relay_p_rest.g_act_pv(l_l2_idx).action_name;
          g_actions_pv(l_action)(l_l2_idx).act_par_target := relay_p_rest.g_act_pv(l_l2_idx).act_par_target;
          g_actions_pv(l_action)(l_l2_idx).var_source_type := relay_p_rest.g_act_pv(l_l2_idx).var_source_type;
          g_actions_pv(l_action)(l_l2_idx).id_action := relay_p_rest.g_act_pv(l_l2_idx).id_action;

        end loop;
      end if;

    end loop;
  end if;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_actions.count: '||g_actions.count);

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_actions_pv.count: '||g_actions_pv.count);

  l_retvar := 1;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||l_retvar);

  return l_retvar;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');

    return -1;
    raise;
end ;
--------------------------------------------------------------------------------
function f_run_actions
return number
as
  l_program varchar2(200) := 'f_run_actions';
  l_log_id number := f_get_log_id;

  type t_node_actions is table of awf_node_action%rowtype index by pls_integer;
  l_node_actions t_node_actions;
  type t_na_idx is table of number index by pls_integer;
  l_na_idx t_na_idx;

  l_cond_return number;
  l_action_return number;

  l_retvar number;
  l_id_process number;
  l_id_node number;

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  l_id_process := relay_p_rest.g_instance.id_process;
  l_id_node := relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node;

  -- load all the actions associated with the current node
  for idx in 1..relay_p_rest.g_nact_alt2(l_id_process)(l_id_node).count loop
    l_node_actions(idx) := relay_p_rest.g_naction(relay_p_rest.g_nact_alt2(l_id_process)(l_id_node)(idx));
    l_na_idx(idx) := relay_p_rest.g_nact_alt2(l_id_process)(l_id_node)(idx);
  end loop;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_node_actions.count: '||l_node_actions.count);

  for idx in 1..l_node_actions.count loop

    l_cond_return := f_eval_conditions
                     (p_id_proc_rec => l_node_actions(idx).id_proc_rec
                     ,p_amt_for_true => l_node_actions(idx).amt_for_true);

    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_cond_return: '||l_cond_return);

    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_na_idx(idx): '||l_na_idx(idx));

    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'relay_p_rest.g_action(l_na_idx(idx)).code_action_type: '||relay_p_rest.g_action(l_na_idx(idx)).code_action_type);

    if l_cond_return in (0,-1) then
      p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'ACTION:CONDITION:FAILED:'||nvl(l_node_actions(idx).id_proc_rec,-1));
      p_build_wf_rec('CONDITION','FAILED',nvl(l_node_actions(idx).id_proc_rec,-1),null,null);
      null;
    else
      case relay_p_rest.g_action(l_na_idx(idx)).code_action_type
        when 'SET_VALUE' then
          l_action_return := f_set_value(p_action_name => l_node_actions(idx).action_name);          
        when 'RUN_METHOD' then
-->          l_action_return := f_run_method(p_action_name => l_node_actions(idx).action_name);
          null;
        when 'ALERT' then
          null;
        when 'NOTIFICATION' then
          l_action_return := f_run_notification(p_action_name => l_node_actions(idx).action_name);
          null;
        else
          l_action_return := -2; -- denotes that the action type was invalid
      end case;
    end if;

    case l_action_return
      when -2 then
        p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'ACTION:BAD_TYPE:'||nvl(l_node_actions(idx).id_proc_rec,-1));
        null;
      when -1 then
        p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'ACTION:ERROR:'||nvl(l_node_actions(idx).id_proc_rec,-1));
        null;
      when 1 then
        p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'ACTION:SUCCESS:'||nvl(l_node_actions(idx).id_proc_rec,-1));
        null;
      else
        p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'ACTION:BAD_RETURN:'||nvl(l_node_actions(idx).id_proc_rec,-1));
        null;
    end case;

  end loop;

  l_retvar := 1;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||l_retvar);

  return l_retvar;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    return -1;
    raise;
end ;
--------------------------------------------------------------------------------
--END-ACTIONS-PROGRAMS----------------------------------------------------------
--BEGIN-NODES-PROGRAMS----------------------------------------------------------
--------------------------------------------------------------------------------
function f_condition_node
return number
as
  l_program varchar2(200) := 'f_condition_node';
  l_log_id number := f_get_log_id;

  l_id_c_node number := relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node;

  l_retvar number;
  l_cond_return number;

  l_ind_is_positive number;

  l_id_proc_rec number;

  l_nl_idx number;

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  -- check the node conditions
  l_cond_return := f_eval_conditions
      (p_id_proc_rec => l_id_c_node
      ,p_amt_for_true => g_awf_node(relay_p_vars.g_active_instance).amt_for_true);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Node Conditions Checked');

  -- if false then neg, if true then get positive
  case
    when l_cond_return in (-1,0) then
      l_ind_is_positive := 0;
      if l_cond_return = -1 then
        p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Node Condition Error');
        null;
      end if;
    when l_cond_return in (-2,1) then
      l_ind_is_positive := 1;
  end case;


  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG',relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_process
                                                ||' : '||relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node
                                                ||' : '||l_ind_is_positive);

  l_nl_idx := relay_p_rest.g_nlin_alt3(relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_process)
                                      (relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node)
                                      (l_ind_is_positive)(1);

  l_id_proc_rec := relay_p_rest.g_nlink(l_nl_idx).id_proc_rec;
  relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node := relay_p_rest.g_nlink(l_nl_idx).id_child_node;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Node Link Identified');

  p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'LINK:USED:'||l_id_proc_rec);
  p_build_wf_rec('LINK','USED',l_id_proc_rec,relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node,null);

  if l_id_proc_rec is not null
    and (p_rec_hist_eval(l_id_proc_rec) = -1 
      or p_rec_hist_eval(relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node) = -1) 
  then
    l_retvar := -1;
  end if;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||l_retvar);
  return l_retvar;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'NODE:FAILED');

    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    return -1;
end ;
--------------------------------------------------------------------------------
--> MITIGATE loops from inputs
function f_decision_node
(p_id_link in awf_node_link.id_proc_rec%type default null
,p_id_assign in awf_inst_assign.id_record%type default null)
return number
as
  l_program varchar2(200) := 'f_decision_node';
  l_log_id number := f_get_log_id;

  l_id_c_node number;

  l_retvar number;
  l_id_link number;
  l_avail_links number := 0;
  l_cond_return number;
  l_eval_assignments number;

  l_id_proc_rec number;
  l_assign_cre number;

  assignment_cre_error exception;
  l_loop1 number := 0;
  l_loop2 number := 0;

  l_nlink awf_node_link%rowtype;
  l_nl_idx number;

  l_id_process number;

  input_not_exist exception;
  link_error exception;
begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  l_id_c_node := relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node;

  l_id_process := relay_p_rest.g_instance.id_process;

  if p_id_link is null 
    and not(relay_p_rest.g_inst_links.exists(1))
  then

    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Evaluating Links');

    -- evaluate the links
    for idx in 1..relay_p_rest.g_nlin_alt2(l_id_process)(l_id_c_node).count loop

      l_nl_idx := relay_p_rest.g_nlin_alt2(l_id_process)(l_id_c_node)(idx);
      l_nlink := relay_p_rest.g_nlink(l_nl_idx);

      l_loop1 := l_loop1 + 1;
      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_loop1: '||l_loop1||':'||l_nlink.id_process||':'||l_nlink.id_proc_rec);

      -- check link conditions
      l_cond_return := f_eval_conditions
                       (p_id_proc_rec => l_nlink.id_proc_rec
                       ,p_amt_for_true => g_awf_node(relay_p_vars.g_active_instance).amt_for_true);

      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_cond_return: '||l_cond_return||':'||$$plsql_line);

      p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'CONDITIONS: '||l_cond_return||':'||l_nlink.id_process||':'||l_nlink.id_proc_rec);

      -- if the link is available
      if l_cond_return in (-1,0) then
        p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Link NOT Available');
        if l_cond_return = -1 then
          p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Node Condition Error');
          null;
        end if;
        p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'LINK:INVALID:'||nvl(p_id_link,l_nlink.id_proc_rec));
      elsif l_cond_return in (-2,1) then

        p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Link Available');
        l_id_link := l_nlink.id_proc_rec;
        l_avail_links := l_avail_links + 1;
        p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'LINK:VALID:'||nvl(p_id_link,l_nlink.id_proc_rec));

        l_loop2 := l_loop2 + 1;
        relay_p_rest.g_inst_links(l_loop2).id_record := f_an_main;
        relay_p_rest.g_inst_links(l_loop2).id_check_stamp := f_an_stamp;
        relay_p_rest.g_inst_links(l_loop2).id_instance := relay_p_vars.g_active_instance;
        relay_p_rest.g_inst_links(l_loop2).id_node := l_nlink.id_parent_node;
        relay_p_rest.g_inst_links(l_loop2).id_link := l_nlink.id_proc_rec;
        relay_p_rest.g_inst_links(l_loop2).link_sequence := l_loop2;

      end if;

      relay_p_rest.g_inst_links_ind := 'I';

    end loop;

    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_avail_links: '||l_avail_links);

    -- if 0 or 1 links and continue is allowed then
    if (l_avail_links = 0 or l_avail_links = 1) 
      and g_awf_node(relay_p_vars.g_active_instance).ind_disp_if_one = 0
      then

      p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'No Positive Links Available');

      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Next Node Checkpoint: '||$$plsql_line);

      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'IND Continue: '||g_awf_node(relay_p_vars.g_active_instance).ind_continue||':'||$$plsql_line);

      if l_avail_links = 1 then 
        l_id_proc_rec := l_id_link;
      else 
        l_nl_idx := relay_p_rest.g_nlin_alt3(l_id_process)(l_id_c_node)(0)(1);
        l_id_proc_rec := relay_p_rest.g_nlink(l_nl_idx).id_proc_rec;
      end if;

      relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node := relay_p_rest.g_nlink(l_nl_idx).id_child_node;

      p_build_wf_rec('LINK','USED',l_id_proc_rec,relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node,null);
      p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'LINK:USED:'||l_id_proc_rec);

      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Next Node: '||relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node);

      l_retvar := 1;

      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_retvar: '||l_retvar||':'||$$plsql_line);

      p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'DECISION:BYPASSED:'||l_id_c_node);

    else
      -- issue assignment
      l_eval_assignments := f_eval_assignments(p_ind_decision => 1);

      relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).ind_ui_reqd := 1;
      relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).date_set := sysdate;

      if l_eval_assignments = -1 then
        raise assignment_cre_error;
      end if;

      -- write choices to table
      forall idx in 1..relay_p_rest.g_inst_links.count
      insert into awf_inst_node_links
      values relay_p_rest.g_inst_links(idx);

      -- pause instance
      p_pause_instance;
      relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).ind_ui_reqd := 1;
      relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).date_set := sysdate;
      relay_p_vars.g_wf_continue := 1;

      p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'INSTANCE:PAUSED:'||l_id_c_node);
      p_build_wf_rec('INSTANCE','PAUSED',relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node,null,null);

      l_retvar := 0;

      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_retvar: '||l_retvar||':'||$$plsql_line);

      p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'DECISION:REQUIRED:'||l_id_c_node);

    end if;

  else
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'id_parent_node: '||g_awf_node(relay_p_vars.g_active_instance).id_proc_rec);
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'id_process: '||g_awf_node(relay_p_vars.g_active_instance).id_process);
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'p_id_link: '||p_id_link);

    if relay_p_rest.g_nlin_alt1(g_awf_node(relay_p_vars.g_active_instance).id_process).exists(p_id_link) then

      if p_id_assign is not null then

        if relay_p_rest.g_iass_alt1.exists(relay_p_vars.g_active_instance)
          and relay_p_rest.g_iass_alt1(relay_p_vars.g_active_instance).exists(p_id_assign) then

          relay_p_rest.g_inst_assign(relay_p_rest.g_iass_alt1(relay_p_vars.g_active_instance)(p_id_assign)).code_status := 'COMPLETED';
          relay_p_rest.g_inst_assign_ind := 1;

          p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'ASSIGNMENT:COMPLETE:'||nvl(p_id_assign,-1));
          p_build_wf_rec('ASSIGNMENT','COMPLETED',relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node,null,null);

        else

          p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'INPUT ASSIGNMENT DOES NOT EXIST');
          p_build_wf_rec('ASSIGNMENT','ERROR-INPUT',relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node,null,null);
          raise input_not_exist;

        end if;

      end if;

      relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node := relay_p_rest.g_nlink(relay_p_rest.g_nlin_alt1(g_awf_node(relay_p_vars.g_active_instance).id_process)(p_id_link)).id_child_node;

      p_build_wf_rec('LINK','USED',l_id_proc_rec,relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node,null);

      forall idx in 1..relay_p_rest.g_inst_links.count
      delete from awf_inst_node_links
      where id_record = relay_p_rest.g_inst_links(idx).id_record;

      relay_p_rest.g_inst_links.delete;
      relay_p_rest.g_inst_links_ind := 'D';

      l_retvar := 1;
      relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_link_fwd := null;

      -- close all assignments
      for idx in 1..relay_p_rest.g_inst_assign.count loop
        if relay_p_rest.g_inst_assign(idx).code_status != 'COMPLETED' then
          relay_p_rest.g_inst_assign(idx).code_status := 'CLOSED';
          relay_p_rest.g_inst_assign_ind := 1;
        end if;
      end loop;

      forall idx in 1..relay_p_rest.g_inst_assign.count
      update awf_inst_assign
      set code_status = relay_p_rest.g_inst_assign(idx).code_status
      where id_record = relay_p_rest.g_inst_assign(idx).id_record;

      relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).ind_ui_reqd := 0;
      p_build_wf_rec('ASSIGNMENT','CLOSED',relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node,null,null);

      p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'ASSIGNMENT:CLOSED:'||l_id_c_node);
      p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'LINK:USED'||l_id_proc_rec);
      p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'DECISION:COMPLETE:'||l_id_c_node);
    else
      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'INPUT LINK DOES NOT EXIST');
      p_build_wf_rec('DECISION','ERROR-INPUT',relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node,null,null);
      raise input_not_exist;
    end if;
  end if;

  if l_id_proc_rec is not null
    and (p_rec_hist_eval(l_id_proc_rec) = -1 
      or p_rec_hist_eval(relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node) = -1) 
  then
    l_retvar := -1;
  end if;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||l_retvar);
  return l_retvar;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'NODE:FAILED');

    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    return -1;
end ;
--------------------------------------------------------------------------------
function f_task_node
(p_id_assign in awf_inst_assign.id_record%type default null)
return number
as
  l_program varchar2(200) := 'f_task_node';
  l_log_id number := f_get_log_id;

  l_retvar number;
  l_cond_return number;
  l_eval_assignments number;

  l_id_proc_rec number;
  l_id_c_node number;

  l_assign_idx number;
  l_nl_idx number;

  l_id_instance number;

  input_not_exist exception;

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'p_id_assign:'||p_id_assign);

  l_id_c_node := relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node;
  l_id_instance := relay_p_rest.g_instance.id_record;

  -- if the task already exists and has been submitted as complete then complete it.
  if p_id_assign is not null then

    if relay_p_rest.g_iass_alt1.exists(l_id_instance)
      and relay_p_rest.g_iass_alt1(l_id_instance).exists(p_id_assign) then

      relay_p_rest.g_inst_assign(relay_p_rest.g_iass_alt1(l_id_instance)(p_id_assign)).code_status := 'COMPLETED';

      p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'ASSIGNMENT:COMPLETE:'||nvl(p_id_assign,-1));
      p_build_wf_rec('ASSIGNMENT','COMPLETED',relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node,null,null);

      l_retvar := 1;
    else
      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'INPUT ASSIGNMENT DOES NOT EXIST');
      p_build_wf_rec('ASSIGNMENT','ERROR-INPUT',relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node,null,null);
      raise input_not_exist;
    end if;
  else
    -- check the node conditions
    l_cond_return := f_eval_conditions
        (p_id_proc_rec => relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node
        ,p_amt_for_true => g_awf_node(relay_p_vars.g_active_instance).amt_for_true);

    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_cond_return:'||l_cond_return);

    if l_cond_return = -1 then

      l_retvar := 0;
      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'TASK Condition Error');
      p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'CONDITION:ERROR:'||l_id_c_node);
    elsif l_cond_return in (1) then

      if g_awf_node(relay_p_vars.g_active_instance).ind_continue = 1 then
        l_retvar := 1;
        p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'ASSIGNMENT:BYPASSED:'||l_id_c_node);
        p_build_wf_rec('ASSIGNMENT','BYPASSED',relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node,null,null);
      else 

        l_retvar := 0;
      end if;
    else 

    l_retvar := 0;

    end if;

  end if;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_retvar:'||l_retvar);

  -- check for assignment
  if l_retvar = 0 then

    l_eval_assignments := f_eval_assignments;
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_eval_assignments:'||l_eval_assignments);

    if l_eval_assignments = 1 then

      l_retvar := 1;
    elsif l_eval_assignments = 0 then

      l_retvar := 0;
    elsif l_eval_assignments = -1 then

      l_retvar := 0;
      p_build_wf_rec('ASSIGNMENT','ERROR',relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node,null,null);
      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Eval Assignment Error:');
      p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_retvar:'||l_retvar);
    end if;

  end if;

  if l_retvar = 1 then

    for idx in 1..relay_p_rest.g_inst_assign.count loop

      if relay_p_rest.g_inst_assign(idx).code_status != 'COMPLETED' then
        relay_p_rest.g_inst_assign(idx).code_status := 'CLOSED';
      end if;

    end loop;

    forall idx in 1..relay_p_rest.g_inst_assign.count
    update awf_inst_assign
    set code_status = relay_p_rest.g_inst_assign(idx).code_status
    where id_record = relay_p_rest.g_inst_assign(idx).id_record;

    p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'ASSIGNMENT:CLOSED:'||l_id_c_node);
    p_build_wf_rec('ASSIGNMENT','CLOSED',relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node,null,null);

    l_nl_idx := relay_p_rest.g_nlin_alt3(relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_process)
                                        (relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node)
                                        (1)(1);

    l_id_proc_rec := relay_p_rest.g_nlink(l_nl_idx).id_proc_rec;
    relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node := relay_p_rest.g_nlink(l_nl_idx).id_child_node;

    relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).ind_ui_reqd := 0;

    p_build_wf_rec('LINK','USED',l_id_proc_rec,relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node,null);
    p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'LINK:USED:'||l_id_proc_rec);

  elsif l_retvar = 0 then

    p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'ASSIGNMENT:COMPLETE:'||l_id_c_node);

    p_pause_instance;
    relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).ind_ui_reqd := 1;
    relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).date_set := sysdate;
    relay_p_vars.g_wf_inbox := 1;

    p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'INSTANCE:PAUSED:'||l_id_c_node);
    p_build_wf_rec('INSTANCE','PAUSED',relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node,null,null);

  end if;

  if l_id_proc_rec is not null
    and (p_rec_hist_eval(l_id_proc_rec) = -1 
      or p_rec_hist_eval(relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node) = -1) 
  then
    l_retvar := -1;
  end if;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||l_retvar);
  return l_retvar;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'NODE:FAILED');

    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');

    return -1;
end ;
--------------------------------------------------------------------------------
function f_wait_node
return number
as
  l_program varchar2(200) := 'f_wait_node';
  l_log_id number := f_get_log_id;

  l_retvar number;
  l_id_c_node number := relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node;
  l_cond_return number := 0;

  l_cond_count number := 0;
  l_ind_continue number := g_awf_node(relay_p_vars.g_active_instance).ind_continue;

  l_interval number;
  l_interval_uom varchar2(100);

  l_timelimit number;
  l_timelimit_exp number;

  l_id_proc_rec number;
  l_nl_idx number;

  l_id_process number;

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');


  l_id_process := relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_process;
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_id_process: '||l_id_process);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_id_c_node: '||l_id_c_node);

  -- get the amount of conditions for the wait node
  if relay_p_rest.g_cond_alt2.exists(l_id_process)
    and relay_p_rest.g_cond_alt2(l_id_process).exists(l_id_c_node) then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'relay_p_rest.g_cond_alt2(l_id_process).exists(l_id_c_node): > 0');
    l_cond_count := relay_p_rest.g_cond_alt2(l_id_process)(l_id_c_node).count;
  end if;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_cond_count: '||l_cond_count);

  -- if there are wait conditions then evaluate them
  if l_cond_count > 0 then
    -- check the node conditions
    l_cond_return := f_eval_conditions
      (p_id_proc_rec => l_id_c_node
      ,p_amt_for_true => g_awf_node(relay_p_vars.g_active_instance).amt_for_true);

  end if;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_cond_return: '||l_cond_return);

  l_interval := g_awf_node(relay_p_vars.g_active_instance).interval;
  l_interval_uom := g_awf_node(relay_p_vars.g_active_instance).interval_uom;

  -- check if a timelimit was set for the wait node
  if l_interval is not null
    and l_interval_uom is not null then

    l_interval := case g_awf_node(relay_p_vars.g_active_instance).interval_uom
                    when 'SECONDS' then l_interval/60/60/24
                    when 'MINUTES' then l_interval/60/24
                    when 'HOURS' then l_interval/24
                    when 'DAYS' then l_interval
                    else l_interval
                  end;

    l_timelimit := 1;

    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_interval: '||l_interval);
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).date_set: '||to_char(relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).date_set,'YYYYMMDDHH24MISS'));
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'sysdate: '||to_char(sysdate,'YYYYMMDDHH24MISS'));
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'sysdate: '||to_char(sysdate+l_interval,'YYYYMMDDHH24MISS'));

    if nvl(relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).date_set,sysdate) + (l_interval) <= sysdate then
      l_timelimit_exp := 1;
    else l_timelimit_exp := 0;
    end if;

  else
    l_timelimit := 0;
    l_timelimit_exp := 0;
  end if;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_timelimit: '||l_timelimit);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'l_timelimit_exp: '||l_timelimit_exp);

  case
    when l_timelimit = 1 -- has a timelimit
      and l_cond_count = 0 -- there are no conditions
      and l_timelimit_exp = 1 -- the timelimit has expired
    then
      l_retvar := 1;
    when l_timelimit = 0 -- has a timelimit
      and l_cond_count > 0 -- there are conditions
      and l_cond_return in (-2,1) -- the conditions are met
    then
      l_retvar := 1;
    when l_timelimit = 1 -- has a timelimit
      and l_cond_count > 0 -- has conditions
--      and l_ind_continue = 1 -- is allowed to continue
      and (l_timelimit_exp = 1 -- either timelimit is expired
          or l_cond_return in (-2,1)) -- or conditions are met
    then
      l_retvar := 1;
    when l_cond_count > 0 -- there are conditions
      and l_cond_return = -1 -- the conditions produced an error
    then
      p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'WAIT:ERROR '||nvl(l_id_proc_rec,-1));
      l_retvar := 0;
    else
      l_retvar := 0;
  end case;

  if l_retvar = 1 then
    if relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).date_set is null then
      p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'WAIT:BYPASSED');
      p_build_wf_rec('WAIT','BYPASSSED',relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node,null,null);
    else
      p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'WAIT:RELEASED');
      p_build_wf_rec('WAIT','RELEASED',relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node,null,null);
    end if;

    l_nl_idx := relay_p_rest.g_nlin_alt3(relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_process)
                                        (relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node)
                                        (1)(1);

    l_id_proc_rec := relay_p_rest.g_nlink(l_nl_idx).id_proc_rec;
    relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node := relay_p_rest.g_nlink(l_nl_idx).id_child_node;

    p_build_wf_rec('LINK','USED',l_id_proc_rec,relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node,null);
    p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'LINK:USED:'||nvl(l_id_proc_rec,-1));

    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node: '
                ||relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node);

    -- remove any timelimit
    relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).date_set := null;

  elsif relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).date_set is null then

    -- set the pause date of the wait node if required
    relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).date_set := sysdate;
    p_build_wf_rec('WAIT','START',relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node,null,null);

  else

    p_build_wf_rec('WAIT','CONTINUE',relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node,null,null);

  end if;

  if l_retvar = 0 then
    p_pause_instance;
    p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'INSTANCE:PAUSED:'||l_id_c_node);
    p_build_wf_rec('INSTANCE','PAUSED',relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node,null,null);

  end if;

  if l_id_proc_rec is not null
    and (p_rec_hist_eval(l_id_proc_rec) = -1 
      or p_rec_hist_eval(relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node) = -1) 
  then
    l_retvar := -1;
  end if;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||l_retvar);
  return l_retvar;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'NODE:FAILED');

    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    return -1;
end ;
--------------------------------------------------------------------------------
function f_start_node
return number
as
  l_program varchar2(200) := 'f_start_node';
  l_log_id number := f_get_log_id;

  l_retvar number;
  l_path varchar(4000);

  l_id_proc_rec number;
  l_id_c_node number := relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node;

  l_nl_idx number;

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  l_nl_idx := relay_p_rest.g_nlin_alt3(relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_process)
                                        (relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node)
                                        (1)(1);

  l_id_proc_rec := relay_p_rest.g_nlink(l_nl_idx).id_proc_rec;
  relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node := relay_p_rest.g_nlink(l_nl_idx).id_child_node;

  -- set the next node from the single link
  p_build_wf_rec('LINK','USED',l_id_proc_rec,relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node,null);

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Next Node Identified');

  p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'LINK:USED:'||l_id_proc_rec);

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node: '
            ||relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node);

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||1);

  l_retvar := 1;

  if l_id_proc_rec is not null
    and (p_rec_hist_eval(l_id_proc_rec) = -1 
      or p_rec_hist_eval(relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node) = -1) 
  then
    l_retvar := -1;
  end if;

  return l_retvar;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'NODE:FAILED');

    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    return -1;
end ;
--------------------------------------------------------------------------------
function f_stop_node
return number
as
  l_program varchar2(200) := 'f_stop_node';
  l_log_id number := f_get_log_id;

  l_retvar number;
begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  -- clear current node
  relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node := null;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Instance Cleared');

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node:'
            ||relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node);

  p_build_wf_rec('INSTANCE','CLOSED',relay_p_vars.g_active_instance,null,null);
  -- update instance active = 0
  p_close_instance(0);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||0);

  return 0;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'NODE:FAILED');

    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
    return -1;
end ;
--------------------------------------------------------------------------------
function f_subprocess_node
return number
as
  l_program varchar2(200) := 'f_subprocess_node';
  l_log_id number := f_get_log_id;

  l_retvar number;
begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  -- TODO : Node Logic

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return: '||l_retvar);
  return l_retvar;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'NODE:FAILED');

    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
  return -1;
end ;
--------------------------------------------------------------------------------
function f_action_node
return number
as
  l_program varchar2(200) := 'f_action_node';
  l_log_id number := f_get_log_id;

  l_check_var number;
  l_retvar number;
  action_node_error exception;
  l_id_proc_rec number;

  l_nl_idx number;

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  -- run actions for the node
  l_check_var := f_run_actions;

  -- action returns in error then raise
  if l_check_var in (0,-1) then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'ACTION:ERROR');
    raise action_node_error;
  else l_check_var := null;
  end if;

  -- set the next node from the single link
  l_nl_idx := relay_p_rest.g_nlin_alt3(relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_process)
                                        (relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node)
                                        (1)(1);

  l_id_proc_rec := relay_p_rest.g_nlink(l_nl_idx).id_proc_rec;
  relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node := relay_p_rest.g_nlink(l_nl_idx).id_child_node;

  p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'LINK:USED:'||l_id_proc_rec);

  l_retvar := 1;

  if l_id_proc_rec is not null
    and (p_rec_hist_eval(l_id_proc_rec) = -1 
      or p_rec_hist_eval(relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node) = -1) 
  then
    l_retvar := -1;
  end if;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END Return:'||l_retvar);
  return l_retvar;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'NODE:FAILED');

    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');
-->    p_build_wf_rec('NODE:ACTION','ERROR',l_id_proc_rec,null,null);
    return -1;
end ;
--------------------------------------------------------------------------------
function f_matrix_node
return number
as
  l_program varchar2(200) := 'f_matrix_node';
  l_log_id number := f_get_log_id;

  l_retvar number;
  l_id_c_node number := relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node;
  l_cond_return number;

  l_nlink awf_node_link%rowtype;
  l_nl_idx number;

  l_id_process number;
  l_id_proc_rec number;
begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'START');

  l_id_process := relay_p_rest.g_instance.id_process;

  -- loop through the links attached to the node exit when conditions are true
  for idx in 1..relay_p_rest.g_nlin_alt2(l_id_process)(l_id_c_node).count loop

    l_nl_idx := relay_p_rest.g_nlin_alt2(l_id_process)(l_id_c_node)(idx);
    l_nlink := relay_p_rest.g_nlink(l_nl_idx);

    l_cond_return := f_eval_conditions
      (p_id_proc_rec => l_nlink.id_proc_rec
      ,p_amt_for_true => l_nlink.amt_for_true);

    if l_cond_return not in (-1,0)
      or l_nlink.ind_is_positive = 0 then
      l_retvar := 1;
      relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node := l_nlink.id_child_node;
      p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'LINK_USED:'||l_nlink.id_proc_rec);
      l_id_proc_rec := l_nlink.id_proc_rec;
    end if;

    exit when l_cond_return not in (-1,0)
            or l_nlink.ind_is_positive = 0;
  end loop;

  if l_id_proc_rec is not null
    and (p_rec_hist_eval(l_id_proc_rec) = -1 
      or p_rec_hist_eval(relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node) = -1) 
  then
    l_retvar := -1;
  end if;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END');
  return l_retvar;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'NODE:FAILED');

    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');

    return -1;
end ;
--------------------------------------------------------------------------------
function f_process_node
(p_id_link in awf_node_link.id_proc_rec%type default null
,p_id_assign in awf_inst_assign.id_record%type default null)
return number
as
  l_program varchar2(200) := 'f_process_node';
  l_log_id number := f_get_log_id;

  l_retvar number := 1;

  l_error varchar2(100);

  node_not_defined exception;
  error_proc_node exception;

  l_node_retvar number;

  l_id_c_node number := relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node;

  l_node_idx number;

begin
  p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'START:'||l_id_c_node);
  p_build_wf_rec('NODE','START',l_id_c_node,null,null);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'p_id_link:'||p_id_link);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'p_id_assign:'||p_id_assign);

  l_node_idx := relay_p_rest.g_node_alt1(relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_process)
                                        (relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node);

  g_awf_node(relay_p_vars.g_active_instance) := relay_p_rest.g_node(l_node_idx);

  -- find out what type of node it is
  -- each will return (1) if the process is to continue, (0) if the process is to stop, (-1) for errors
  case g_awf_node(relay_p_vars.g_active_instance).node_type
    when 'START' then -- always returns 1 or (-1)
      p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'NODE:START');
      l_node_retvar := f_start_node;
    when 'STOP' then -- always returns 0 or (-1)
      p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'NODE:STOP');
      l_node_retvar := f_stop_node;
    when 'CONDITION' then -- always returns 1 or (-1)
      p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'NODE:CONDITION');
      l_node_retvar := f_condition_node;
    when 'DECISION' then  -- can return 1 or 0 or (-1)  
      p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'NODE:DECISION');
      l_node_retvar := f_decision_node(p_id_link => p_id_link, p_id_assign => p_id_assign);
    when 'TASK' then -- can return 1 or 0 or (-1)
      p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'NODE:TASK');
      l_node_retvar := f_task_node(p_id_assign => p_id_assign);    
    when 'WAIT' then -- can return 1 or 0 or (-1)
      p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'NODE:WAIT');
      l_node_retvar := f_wait_node;
--> SP not implemented
    when 'SUBPROCESS' then -- can return 1 or 0 or (-1)
      p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'NODE:SUBPROCESS');
      l_node_retvar := f_subprocess_node;
    when 'ACTION' then -- always returns 1 or (-1)
      p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'NODE:ACTION');
      l_node_retvar := f_action_node;
    when 'MATRIX' then -- always returns 1 or (-1)
      p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'NODE:MATRIX');
      l_node_retvar := f_matrix_node;
    else
      l_error := 'node_not_defined';
      raise node_not_defined;
  end case;

  if l_node_retvar = 0 then
    l_retvar := 0;
  elsif l_node_retvar = -1 then
    l_error := 'error_proc_node';
    raise error_proc_node;
  end if;

  p_build_wf_rec('NODE','END',l_id_c_node,null,null);
  p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'END:'||l_id_c_node);

  return l_retvar;
exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'NODE_PROCESSING:FAILED');
    p_build_wf_rec('NODE_PROCESSING','FAILED',l_id_c_node,null,null);
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_id_link: '||p_id_link);
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_id_assign: '||p_id_assign);
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');

    return -1;
end ;
--------------------------------------------------------------------------------
--END-NODE-PROGRAMS-------------------------------------------------------------
--------------------------------------------------------------------------------
--> LICENSE PROGRAM
procedure p_run_license
as

  license_violation exception;
  license_exceeded exception;

  l_dec_var varchar2(1000);
  l_ek_var varchar2(128);
  l_mk_var varchar2(128);
  l_h_var varchar2(128);
  l_cek_var varchar2(128);
  l_cuk_var varchar2(128);
  l_lk_var varchar2(128);
  l_pid_var varchar2(128);  
  l_ck_rv varchar2(1000);

  l_act_proc_amt number;
  l_proc_limit number := 2;

begin
  -- compare the license variables
  if relay_p_vars.g_lic_status != gp_lic_status then 
    p_build_wf_rec('PRODUCT_LICENSE','VIOLATED',null,null,null);
--    dbms_output.put_line('LICENSE_VIOLATION');
    raise license_violation;
  end if;

  -- run licensing evaluation
  l_pid_var := f_get_param_vc2('PRODUCT_ID');

  select sys_context('USERENV', 'DB_NAME')||
         sys_context('USERENV', 'SERVER_HOST')||
         lower(sys_context('USERENV', 'DB_UNIQUE_NAME')) sc_value
  into  l_ek_var
  from  DUAL;

  l_ck_rv := relay_p_hutil.sha1_vc((l_h_var))||l_pid_var;

  l_ck_rv := relay_p_hutil.sha1_vc((l_ck_rv));

  relay_p_vars.g_cert_key := l_ck_rv;

  l_cuk_var := f_get_param_vc2('CUSTOMER_KEY');
  l_lk_var := f_get_param_vc2('LICENSE_KEY');

  l_mk_var := null;

  for idx in 1..least(length(nvl(l_cuk_var,'XXXXXXX')),length(nvl(relay_p_vars.g_cert_key,'XXXXXXX'))) --length(nvl(l_cek_var,'XXXXXXX')))
  loop
    l_mk_var := nvl(l_mk_var,'')||substr(relay_p_vars.g_cert_key,idx,1);
    l_mk_var := nvl(l_mk_var,'')||substr(l_cuk_var,idx,1);
  end loop;

  l_h_var := relay_p_hutil.sha1_vc((l_mk_var));
  l_h_var := relay_p_hutil.sha1_vc((l_h_var));

  if l_h_var = l_lk_var then
    l_dec_var := 'LICENSED';
  else
    l_dec_var := 'UNLICENSED';
  end if;

  relay_p_vars.g_lic_status := l_dec_var;
  gp_lic_status := l_dec_var;

  -- Check Licensing Status
  if gp_lic_status = 'UNLICENSED' then
    select count(*)
    into l_act_proc_amt
    from awf_process 
    where ind_active = 1;

    if l_act_proc_amt > l_proc_limit then
      p_build_wf_rec('PRODUCT_LICENSE','EXCEEDED',null,null,null);
--      dbms_output.put_line('LICENSE_EXCEEDED');
      raise license_exceeded;  
    else 
      p_build_wf_rec('PRODUCT','UNLICENSED',null,null,null);
--      dbms_output.put_line('UNLICENSED');
    end if;
  else 
    p_build_wf_rec('PRODUCT','LICENSED',null,null,null);
--    dbms_output.put_line('LICENSED');
  end if;

  relay_p_vars.g_lic_status := null;
  gp_lic_status := null;
  relay_p_vars.g_cert_key := null;

end ; 
--------------------------------------------------------------------------------
procedure p_pkg_reset
as
begin
  -- reset all global variables for new run
  if g_pkg_active = 1 then  
    -- PUBLIC
    relay_p_vars.g_imp_content := null;
--    relay_p_vars.g_ind_run_code := 0;
    relay_p_vars.g_lic_status := null;
    relay_p_vars.g_cert_key := null;
    if relay_p_vars.g_ai_data.count > 0 then relay_p_vars.g_ai_data.delete; end if;
    relay_p_vars.g_active_instance := null;
    if relay_p_vars.g_inst_own_values.count > 0 then relay_p_vars.g_inst_own_values.delete; end if;

    -- PRIVATE
    g_workflow_index := 1;
--    if g_request.count > 0 then g_request.delete; end if;
  --  g_request_idx := null;
    g_instance_comp := 0;
--    g_wf_p_process_name := null;
    g_wf_p_id_owner := null;
    g_id_active_process := null;
    g_ind_allow_more_inst := null;
    if g_awf_node.count > 0 then g_awf_node.delete; end if;
    if g_owner_def.count > 0 then g_owner_def.delete; end if;
    if g_bidt.count > 0 then g_bidt.delete; end if;
    if g_log.count > 0 then g_log.delete; end if;
    g_log_id := 0;
    g_seq_id := 0;
    if g_relations.count > 0 then g_relations.delete; end if;
    if g_rel_chain.count > 0 then g_rel_chain.delete; end if;
    if g_subst_vars.count > 0 then g_subst_vars.delete; end if;
    g_rel_level := 1;
    g_rowid_set_idx := 0;
    g_object_owner := null;
    g_object_name := null;
    g_owner_rowid := null;
    g_ind_proceed := null;
    if g_svars.count > 0 then g_svars.delete; end if;
--    if g_person.count > 0 then g_person.delete; end if;
--    if g_person_group.count > 0 then g_person_group.delete; end if;
--    if g_group_member.count > 0 then g_group_member.delete; end if;
--    if g_roles.count > 0 then g_roles.delete; end if;
    gp_lic_status := null;
    g_to := null;
    g_cc := null;
    g_bcc := null;
    g_inst_data := null;
    if g_active_pv.count > 0 then g_active_pv.delete; end if;
    if g_actions.count > 0 then g_actions.delete; end if;
    if g_actions_pv.count > 0 then g_actions_pv.delete; end if;
    if g_wf_record.count > 0 then g_wf_record.delete; end if;

    g_pkg_active := 0;
  end if;

end ;
--------------------------------------------------------------------------------
--MAIN-PROGRAM------------------------------------------------------------------
procedure run_workflow
(p_id_instance in awf_instance.id_record%type
,p_id_link in awf_node_link.id_proc_rec%type default null
,p_id_assign in awf_inst_assign.id_record%type default null)
as
  l_program varchar2(200) := 'run_workflow';
  l_log_id number;

  l_node_return number := 1;
  l_inst_return number;
  l_load_ds_return number;
  l_od_write number;
  l_check_var number;

  l_error varchar2(100);
  inst_get_cre_error exception;
  load_dataset_error exception;
  node_error exception;
  no_owner_def exception;
  load_owner_data_error exception;
  owner_data_write exception;
  load_actions_error exception;

  l_id_link number := p_id_link;
  l_id_assign number := p_id_assign;

begin

  p_pkg_reset;

  g_pkg_active := 1;

  relay_p_vars.g_ind_run_code := 0;

  g_log_id := 0;

  l_log_id := f_get_log_id;

  g_log.delete;

  -- load workflow index
  g_workflow_index := awf_wfindex_seq.nextval;

  p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'Workflow START');
  p_build_wf_rec('WF_RUN','START',null,null,null);
  p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'p_id_instance:'||p_id_instance);
  p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'p_id_link:'||p_id_link);
  p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'p_id_assign:'||p_id_assign);

--/* **
  -- set workspace_id
  select min(workspace_id)
  into g_workspace_id
  from apex_workspaces;

  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Workspace ID Loaded');
--*/
  -- load Oracle Built-In datatype collection
  p_load_bidt;
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'BIDT Loaded');

  p_load_adm;
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'AD Methods Loaded');

  -- get or create instance for process and owner
  l_inst_return := f_get_cre_instance(p_id_instance);

  relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).workflow_index := g_workflow_index;

  -- if l_inst_return is -1 then raise instance creation error
  if l_inst_return = -1 then
    l_error := 'inst_get_cre_error';
    raise inst_get_cre_error;
  end if;
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Instance Found / Created');

  -- load process and owner data
  l_load_ds_return := f_load_owner_data;

  if l_load_ds_return = -1 then
    raise load_owner_data_error; 
    null;
  else l_load_ds_return := null;
  end if;
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Owner Data Loaded');

  -- cycle through process until it has come to a pause or stop
  p_build_wf_rec('NODES','START',null,null,null);
  loop

    l_node_return := f_process_node(p_id_link => p_id_link, p_id_assign => p_id_assign);
    exit when l_node_return in (0,-1);

  end loop;
  p_build_wf_rec('NODES','END',null,null,null);
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Node Processing Completed');

  -- if the process returns an error then raise node_error
  if l_node_return = 0 then
    p_build_wf_rec('INSTANCE','STOP',relay_p_vars.g_active_instance,null,null);
  elsif l_node_return = -1 then
    p_build_wf_rec('NODE','ERROR',relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node,null,null);
    l_error := 'node_error';
    raise node_error;
  end if;

--> TODO : Instance GAME detection


  -- otherwise set instance state active = 0
  relay_p_rest.g_inst_state.ind_active := 0;
  relay_p_rest.g_inst_state.date_set := relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).date_set;
  relay_p_rest.g_inst_state.node_number := relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node;
  relay_p_rest.g_inst_state.ind_ui_reqd := relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).ind_ui_reqd;
  relay_p_rest.g_inst_state_ind := 1;
--/*
  update  awf_instance_state
  set     ind_active = 0,
          date_set = relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).date_set,
          node_number = relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).id_c_node,
          ind_ui_reqd = relay_p_vars.g_ai_data(relay_p_vars.g_active_instance).ind_ui_reqd
  where   id_instance = relay_p_vars.g_active_instance;
--*/
  p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Instance State Updated');

  -- write the owner record updates
  l_od_write := f_write_owner_updates;

  if l_od_write = -1 then
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Owner Update Failed');
    raise owner_data_write;
  end if;

  -- if instance closed then clean-up
  if g_instance_comp = 1 then
    -- instance variables
-->    delete from awf_inst_vars where id_instance = relay_p_vars.g_active_instance;
    null;
  end if;

  -- set run code indicator = 1 (workflow run success)
  if relay_p_vars.g_wf_continue = 1 then
    relay_p_vars.g_ind_run_code := 2;
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Run Continued');
    relay_p_vars.g_wf_continue := 0;
  elsif relay_p_vars.g_wf_inbox = 1 then
    relay_p_vars.g_ind_run_code := 3;
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Send to Inbox');
    relay_p_vars.g_wf_inbox := 0;
  else  
    relay_p_vars.g_ind_run_code := 1;
    p_build_log(l_program, $$plsql_line, l_log_id, 'DEBUG', 'Run Successful');
  end if;

  p_build_wf_rec('WF_RUN','END',null,null,null);
  p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'Workflow END');
  p_write_wf_rec;
--  p_write_wf_log;

  if relay_p_vars.g_debug = 'DEBUG' then
    p_write_err_log;
  end if;

  g_wf_record.delete;
  g_log.delete; 

  p_pkg_reset;

exception
  when others then
    p_build_log(l_program, $$plsql_line, l_log_id, 'LOG', 'END (ERROR)');
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_id_instance: '||p_id_instance);
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_id_link: '||p_id_link);
    p_build_log(l_program, $$plsql_line, l_log_id, 'PARAM', 'p_id_assign: '||p_id_assign);
    p_build_log(l_program, $$plsql_line, l_log_id, 'ERROR');

    p_write_wf_rec;
    p_write_err_log;

    p_close_instance(-1);

    g_wf_record.delete;
    g_log.delete;

    p_pkg_reset;

    -- set run code indicator to 0 (workflow run error)
    relay_p_vars.g_ind_run_code := 0;

end ;
--------------------------------------------------------------------------------
function f_run_workflow
(p_id_instance in awf_instance.id_record%type
,p_id_link in awf_node_link.id_proc_rec%type default null
,p_id_assign in awf_inst_assign.id_record%type default null)
return number
as

  l_retvar number;

begin

  run_workflow(p_id_instance => p_id_instance
              ,p_id_link => p_id_link
              ,p_id_assign => p_id_assign);

  l_retvar := relay_p_vars.g_ind_run_code;

  return l_retvar;
end ;
--------------------------------------------------------------------------------
--END OF OPERATIONAL PROGRAMS
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- import / export process
--------------------------------------------------------------------------------
function f_blobtoclob
(p_blob_in in blob)
return clob 
is

  l_file_clob clob;
  l_file_size integer := dbms_lob.lobmaxsize;
  l_dest_offset integer := 1;
  l_src_offset integer := 1;
  l_blob_csid number := dbms_lob.default_csid;
  l_lang_context number := dbms_lob.default_lang_ctx;
  l_warning integer;
  l_length number;

begin

  dbms_lob.createtemporary(l_file_clob, true);

  dbms_lob.converttoclob(l_file_clob,
                         p_blob_in,
                         l_file_size,
                         l_dest_offset,
                         l_src_offset,
                         l_blob_csid,
                         l_lang_context,
                         l_warning);

  return l_file_clob;

exception
  when others then
    dbms_output.put_line('Error found');
end ;
--------------------------------------------------------------------------------
function f_clobtoblob
(p_clob_in in clob)
return blob 
is

  l_file_blob blob;
  l_file_size integer := dbms_lob.lobmaxsize;
  l_dest_offset integer := 1;
  l_src_offset integer := 1;
  l_blob_csid number := dbms_lob.default_csid;
  l_lang_context number := dbms_lob.default_lang_ctx;
  l_warning integer;
  l_length number;

begin

  dbms_lob.createtemporary(l_file_blob, true);

  dbms_lob.converttoblob(l_file_blob,
                         p_clob_in,
                         l_file_size,
                         l_dest_offset,
                         l_src_offset,
                         l_blob_csid,
                         l_lang_context,
                         l_warning);

  return l_file_blob;

exception
  when others then
    dbms_output.put_line('Error found');
end ;
--------------------------------------------------------------------------------
function f_process_export
(p_id_process in number)
return blob
as
  l_json clob;
  l_id_process number := p_id_process; -- := 3805; 
  l_incl_eo_data number; -- := 0; 

  l_blob blob;

begin

  apex_json.initialize_clob_output;
  ------------------------------------------------------------------------------
  apex_json.open_array(); -- processes 

    for idx1 in (select * from awf_process where id_record = l_id_process) loop
      apex_json.open_object(); -- process
        apex_json.write('a',idx1.id_record);
        apex_json.write('b',idx1.id_base_process);
        apex_json.write('c',idx1.process_name);
        apex_json.write('d',idx1.description);
        apex_json.write('e',idx1.proc_revision);
        apex_json.write('f',idx1.id_revised_from);
        apex_json.write('g',idx1.id_role);
        apex_json.write('h',idx1.obj_owner);
        apex_json.write('i',idx1.obj_name);
        apex_json.write('j',idx1.id_proc_rec);
        apex_json.write('k',idx1.ind_enabled);
        apex_json.write('l',idx1.ind_active);
        apex_json.write('m',idx1.ind_auto_initiate);
        apex_json.write('n',idx1.ind_allow_more_inst);
        apex_json.write('o',idx1.id_check_stamp);
        ------------------------------------------------------------------------
        apex_json.open_array('proc_vars'); 
        for idx2 in (select * from awf_proc_vars where id_process = idx1.id_record order by id_record) loop
          apex_json.open_object(); -- proc_var
            apex_json.write('a',idx2.id_record);
            apex_json.write('b',idx2.id_process);
            apex_json.write('c',idx2.var_name);
            apex_json.write('d',idx2.var_type);
            apex_json.write('e',idx2.notes);
            apex_json.write('f',idx2.ind_active);
            apex_json.write('h',replace(relay_p_anydata.f_anydata_to_clob(idx2.default_var_value),chr(10),'~'));
            apex_json.write('i',idx2.dvar_value_type);
            apex_json.write('j',idx2.id_check_stamp);
            apex_json.open_array('ca'); --clob array
              if dbms_lob.getlength(idx2.dflt_clob_value) > 0 then
                for idx3 in 1..ceil(dbms_lob.getlength(idx2.dflt_clob_value)/3900) loop
                  apex_json.open_object(); -- clob segment
                    apex_json.write('k'||idx3,dbms_lob.substr(idx2.dflt_clob_value,3900,case when idx3 = 1 then 1 else ((idx3-1)*3900) end));
                  apex_json.close_object(); -- clob segment
                end loop;
              end if;
            apex_json.close_array(); --clob array
            apex_json.open_array('ba'); --blob array
              if dbms_lob.getlength(idx2.dflt_blob_value) > 0 then
                for idx3 in 1..ceil(dbms_lob.getlength(idx2.dflt_blob_value)/1900) loop
                  apex_json.close_object(); -- blob segment
                    apex_json.write('k'||idx3,dbms_lob.substr(idx2.dflt_blob_value,1900,case when idx3 = 1 then 1 else ((idx3-1)*1900) end));
                  apex_json.close_object(); -- blob segment
                end loop;
              end if;  
            apex_json.close_array(); --blob array
          apex_json.close_object(); --process
        end loop;
        apex_json.close_array(); -- proc_vars
        ------------------------------------------------------------------------
        apex_json.open_array('nodes');
        for idx2 in (select * from awf_node where id_process = idx1.id_record order by id_proc_rec) loop
          apex_json.open_object(); -- node
            apex_json.write('a',idx2.id_record);
            apex_json.write('b',idx2.id_process);
            apex_json.write('c',idx2.id_proc_rec);
            apex_json.write('d',idx2.node_type);
            apex_json.write('e',idx2.layout_column);
            apex_json.write('f',idx2.layout_row);
            apex_json.write('g',idx2.node_name);
            apex_json.write('h',idx2.description);
            apex_json.write('i',idx2.ind_disp_if_one);
            apex_json.write('j',idx2.amt_for_true);
            apex_json.write('k',idx2.interval);
            apex_json.write('l',idx2.interval_uom);
            apex_json.write('m',idx2.ind_continue);
            apex_json.write('n',idx2.id_subprocess);
            apex_json.write('o',idx2.id_check_stamp);
          apex_json.close_object(); -- node
        end loop;
        apex_json.close_array(); -- nodes
        ------------------------------------------------------------------------
        apex_json.open_array('links');
        for idx2 in (select * from awf_node_link where id_process = idx1.id_record order by id_proc_rec) loop
          apex_json.open_object(); -- link
            apex_json.write('a',idx2.id_record);
            apex_json.write('b',idx2.id_parent_node);
            apex_json.write('c',idx2.id_child_node);
            apex_json.write('d',idx2.description);
            apex_json.write('e',idx2.ind_is_positive);
            apex_json.write('f',idx2.sequence);
            apex_json.write('g',idx2.amt_for_true);
            apex_json.write('h',idx2.id_process);
            apex_json.write('i',idx2.id_proc_rec);
            apex_json.write('j',idx2.id_check_stamp);
          apex_json.close_object(); -- link
        end loop;
        apex_json.close_array(); -- links
        ------------------------------------------------------------------------
        apex_json.open_array('link_vertices');
        for idx2 in (select * from awf_node_link_vertex where id_process = idx1.id_record order by id_proc_rec) loop
          apex_json.open_object(); --link_vertex
            apex_json.write('a',idx2.id_record);
            apex_json.write('b',idx2.id_process);
            apex_json.write('c',idx2.id_proc_rec);
            apex_json.write('d',idx2.vertex_seq);
            apex_json.write('e',idx2.x_pos);
            apex_json.write('f',idx2.y_pos);
            apex_json.write('g',idx2.id_check_stamp);
          apex_json.close_object(); --link_vertex
        end loop;
        apex_json.close_array(); --link_vertices
        ------------------------------------------------------------------------
        apex_json.open_array('node_actions');
        for idx2 in (select * from awf_node_action where id_process = idx1.id_record order by id_proc_rec) loop
          apex_json.open_object(); -- node_action
            apex_json.write('a',idx2.id_record);
            apex_json.write('b',idx2.action_name);
            apex_json.write('c',idx2.id_relationship);
            apex_json.write('d',idx2.sequence);
            apex_json.write('e',idx2.amt_for_true);
            apex_json.write('f',idx2.ind_stop_on_error);
            apex_json.write('g',idx2.id_process);
            apex_json.write('h',idx2.id_proc_rec);
            apex_json.write('i',idx2.id_node_number);
            apex_json.write('j',idx2.id_check_stamp);
          apex_json.close_object(); -- node_action
        end loop;
        apex_json.close_array(); -- node_actions
        ------------------------------------------------------------------------
        apex_json.open_array('node_assignments');
        for idx2 in (select * from awf_node_assignment where id_process = idx1.id_record order by id_proc_rec) loop
          apex_json.open_object(); -- node_assignment
            apex_json.write('a',idx2.id_record);
            apex_json.write('b',idx2.description);
            apex_json.write('c',idx2.priority);
            apex_json.write('d',idx2.ind_notify_by_email);
            apex_json.write('e',idx2.node_number);
            apex_json.write('f',idx2.id_role);
            apex_json.write('g',idx2.id_escrole);
            apex_json.write('h',idx2.id_email_template);
            apex_json.write('i',idx2.id_process);
            apex_json.write('j',idx2.id_proc_rec);
            apex_json.write('k',idx2.amt_for_true);
            apex_json.write('l',idx2.id_check_stamp);
          apex_json.close_object(); -- node_assignment
        end loop;
        apex_json.close_array(); -- node_assignments
        ------------------------------------------------------------------------
        apex_json.open_array('node_subprocesses');
        for idx2 in (select * from awf_node_subprocess where id_process = idx1.id_record order by id_proc_rec) loop
          apex_json.open_object(); -- node_subprocess
            apex_json.write('a',idx2.id_record);
            apex_json.write('b',idx2.id_check_stamp);
            apex_json.write('c',idx2.id_process);
            apex_json.write('d',idx2.id_proc_rec);
            apex_json.write('e',idx2.id_node);
            apex_json.write('f',idx2.id_subprocess);
            apex_json.write('g',idx2.exec_action);
            apex_json.write('h',idx2.subprocess_seq);
          apex_json.close_object(); -- node_subprocess
        end loop;
        apex_json.close_array(); -- node_subprocesses
        ------------------------------------------------------------------------
        apex_json.open_array('conditions');
        for idx2 in (select * from awf_conditions where id_process = idx1.id_record order by id_proc_rec) loop
          apex_json.open_object(); -- condition
            apex_json.write('a',idx2.ID_RECORD);
            apex_json.write('b',idx2.CONDITION);
            apex_json.write('c',idx2.ID_RELATIONSHIP);
            apex_json.write('d',idx2.OBJ_OWNER);
            apex_json.write('e',idx2.OBJECT);
            apex_json.write('f',idx2.IND_MUST_BE);
            apex_json.write('g',idx2.ID_PROCESS);
            apex_json.write('h',idx2.ID_PROC_REC);
            apex_json.write('i',idx2.ID_CHECK_STAMP);
          apex_json.close_object(); --condition
        end loop;
        apex_json.close_array(); -- conditions
        ------------------------------------------------------------------------
      apex_json.close_object(); --process
    end loop;
  apex_json.close_array(); -- processes
  ------------------------------------------------------------------------------
  l_json := apex_json.get_clob_output;
  l_json := replace(l_json,chr(10),'');

  l_blob := f_clobtoblob(l_json);

  return l_blob;
end ;
--------------------------------------------------------------------------------
function f_process_import
(p_json in blob)
return number
as
--  p_merge_version number := 0;

  existing_proc_rev exception;
  no_enabled_object exception;
  no_conditions exception;

  l_id_process number;
  l_json clob;
  j apex_json.t_values;
  l_anydata anydata;
  l_check_var number := 0;

  type t_process is table of awf_process%rowtype index by pls_integer;
  l_process t_process;

  type t_proc_vars is table of awf_proc_vars%rowtype index by pls_integer;
  type tt_proc_vars is table of t_proc_vars index by pls_integer;
  l_proc_vars tt_proc_vars;

  type t_node is table of awf_node%rowtype index by pls_integer;
  type tt_node is table of t_node index by pls_integer;
  l_node tt_node;

  type t_node_link is table of awf_node_link%rowtype index by pls_integer;
  type tt_node_link is table of t_node_link index by pls_integer;
  l_node_link tt_node_link;

  type t_node_link_vertex is table of awf_node_link_vertex%rowtype index by pls_integer;
  type tt_node_link_vertex is table of t_node_link_vertex index by pls_integer;
  l_node_link_vertex tt_node_link_vertex;

  type t_node_action is table of awf_node_action%rowtype index by pls_integer;
  type tt_node_action is table of t_node_action index by pls_integer;
  l_node_action tt_node_action;

  type t_node_assignment is table of awf_node_assignment%rowtype index by pls_integer;
  type tt_node_assignment is table of t_node_assignment index by pls_integer;
  l_node_assignment tt_node_assignment;

  type t_node_subprocess is table of awf_node_subprocess%rowtype index by pls_integer;
  type tt_node_subprocess is table of t_node_subprocess index by pls_integer;
  l_node_subprocess tt_node_subprocess;

  type t_conditions is table of awf_conditions%rowtype index by pls_integer;
  type tt_conditions is table of t_conditions index by pls_integer;
  l_conditions tt_conditions;

  l_count number;
  l_datatype varchar2(128);

  l_dflt_var_value clob;
begin

  l_json := f_blobtoclob(p_json);

  -- no clobs in objects for anydata
--  l_json := p_json;

  -- parse the json
  apex_json.parse(j, l_json);

  -- for each process identified
  for idx1 in 1..apex_json.get_count(p_path => '.', p_values => j) loop
    -- load the process information
    l_process(idx1).id_record := apex_json.get_varchar2(p_path => '['||idx1||'].a', p_values => j);
    l_process(idx1).id_base_process := apex_json.get_varchar2(p_path => '['||idx1||'].b', p_values => j);
    l_process(idx1).process_name := apex_json.get_varchar2(p_path => '['||idx1||'].c', p_values => j);
    l_process(idx1).description := apex_json.get_varchar2(p_path => '['||idx1||'].d', p_values => j);
    l_process(idx1).proc_revision := apex_json.get_varchar2(p_path => '['||idx1||'].e', p_values => j);
    l_process(idx1).id_revised_from := apex_json.get_varchar2(p_path => '['||idx1||'].f', p_values => j);
    l_process(idx1).id_role := apex_json.get_varchar2(p_path => '['||idx1||'].g', p_values => j);
    l_process(idx1).obj_owner := apex_json.get_varchar2(p_path => '['||idx1||'].h', p_values => j);
    l_process(idx1).obj_name := apex_json.get_varchar2(p_path => '['||idx1||'].i', p_values => j);
    l_process(idx1).id_proc_rec := apex_json.get_varchar2(p_path => '['||idx1||'].j', p_values => j);
    l_process(idx1).ind_enabled := apex_json.get_varchar2(p_path => '['||idx1||'].k', p_values => j);
    l_process(idx1).ind_active := apex_json.get_varchar2(p_path => '['||idx1||'].l', p_values => j);
    l_process(idx1).ind_auto_initiate := apex_json.get_varchar2(p_path => '['||idx1||'].m', p_values => j);
    l_process(idx1).ind_allow_more_inst := apex_json.get_varchar2(p_path => '['||idx1||'].n', p_values => j);
    l_process(idx1).id_check_stamp := apex_json.get_varchar2(p_path => '['||idx1||'].o', p_values => j);

    -- check for existing process version for same owner/object
    if l_process.count > 0 then 

      select  count(*) 
      into    l_check_var
      from    awf_process 
      where   process_name = l_process(idx1).process_name
        and   proc_revision = l_process(idx1).proc_revision
        and   obj_owner = l_process(idx1).obj_owner
        and   obj_name = l_process(idx1).obj_name;

      if l_check_var > 0 then
        raise existing_proc_rev;
      end if;  

      -- TODO:  add proper check for object
/*
      select  count(*) 
      into    l_check_var
      from    awf_eo
      where   obj_owner = l_process(idx1).obj_owner
        and   obj_name = l_process(idx1).obj_name;

      if l_check_var = 0 then
        raise no_enabled_object;
        null;
      end if;
*/
      -- get new key value
      l_id_process := awf_main_seq.nextval;
      -- change the process id to the new id
      l_process(idx1).id_record := l_id_process;

    end if;

    -- extract the process variables 
    if apex_json.get_count(p_path => '['||idx1||'].proc_vars', p_values => j) > 0 then
      for idx2 in 1..apex_json.get_count(p_path => '['||idx1||'].proc_vars', p_values => j) loop
        l_proc_vars(idx1)(idx2).id_record := awf_main_seq.nextval; --apex_json.get_varchar2(p_path => '['||idx1||'].proc_vars['||idx2||'].a', p_values => j);
        l_proc_vars(idx1)(idx2).id_process := l_id_process; --apex_json.get_varchar2(p_path => '['||idx1||'].proc_vars['||idx2||'].b', p_values => j);
        l_proc_vars(idx1)(idx2).var_name := apex_json.get_varchar2(p_path => '['||idx1||'].proc_vars['||idx2||'].c', p_values => j);
        l_proc_vars(idx1)(idx2).var_type := apex_json.get_varchar2(p_path => '['||idx1||'].proc_vars['||idx2||'].d', p_values => j);
        l_proc_vars(idx1)(idx2).notes := apex_json.get_varchar2(p_path => '['||idx1||'].proc_vars['||idx2||'].e', p_values => j);
        l_proc_vars(idx1)(idx2).ind_active := apex_json.get_varchar2(p_path => '['||idx1||'].proc_vars['||idx2||'].f', p_values => j);
        l_proc_vars(idx1)(idx2).id_check_stamp := apex_json.get_varchar2(p_path => '['||idx1||'].proc_vars['||idx2||'].g', p_values => j);
-->
        l_proc_vars(idx1)(idx2).default_var_value := case when l_proc_vars(idx1)(idx2).var_type like '%LOB' then null else relay_p_anydata.f_clob_to_anydata(apex_json.get_clob(p_path => '['||idx1||'].proc_vars['||idx2||'].h', p_values => j),l_proc_vars(idx1)(idx2).var_type) end;
-->
        l_proc_vars(idx1)(idx2).dvar_value_type := apex_json.get_varchar2(p_path => '['||idx1||'].proc_vars['||idx2||'].i', p_values => j);
        --l_proc_vars(idx1)(idx2).dflt_clob_value := case when l_proc_vars(idx1)(idx2).var_type = 'CLOB' then apex_json.get_clob(p_path => '['||idx1||'].proc_vars['||idx2||'].h', p_values => j) else null end;
        -- do not populate the blob column
      end loop;
    end if;

    --extract the nodes
    if apex_json.get_count(p_path => '['||idx1||'].nodes', p_values => j) > 0 then
      for idx2 in 1..apex_json.get_count(p_path => '['||idx1||'].nodes', p_values => j) loop
        l_node(idx1)(idx2).id_record := awf_main_seq.nextval; --apex_json.get_varchar2(p_path => '['||idx1||'].nodes['||idx2||'].a', p_values => j);
        l_node(idx1)(idx2).id_process := l_id_process; --apex_json.get_varchar2(p_path => '['||idx1||'].nodes['||idx2||'].b', p_values => j);
        l_node(idx1)(idx2).id_proc_rec := apex_json.get_varchar2(p_path => '['||idx1||'].nodes['||idx2||'].c', p_values => j);
        l_node(idx1)(idx2).node_type := apex_json.get_varchar2(p_path => '['||idx1||'].nodes['||idx2||'].d', p_values => j);
        l_node(idx1)(idx2).layout_column := apex_json.get_varchar2(p_path => '['||idx1||'].nodes['||idx2||'].e', p_values => j);
        l_node(idx1)(idx2).layout_row := apex_json.get_varchar2(p_path => '['||idx1||'].nodes['||idx2||'].f', p_values => j);
        l_node(idx1)(idx2).node_name := apex_json.get_varchar2(p_path => '['||idx1||'].nodes['||idx2||'].g', p_values => j);
        l_node(idx1)(idx2).description := apex_json.get_varchar2(p_path => '['||idx1||'].nodes['||idx2||'].h', p_values => j);
        l_node(idx1)(idx2).ind_disp_if_one := apex_json.get_varchar2(p_path => '['||idx1||'].nodes['||idx2||'].i', p_values => j);
        l_node(idx1)(idx2).amt_for_true := apex_json.get_varchar2(p_path => '['||idx1||'].nodes['||idx2||'].j', p_values => j);
        l_node(idx1)(idx2).interval := apex_json.get_varchar2(p_path => '['||idx1||'].nodes['||idx2||'].k', p_values => j);
        l_node(idx1)(idx2).interval_uom := apex_json.get_varchar2(p_path => '['||idx1||'].nodes['||idx2||'].l', p_values => j);
        l_node(idx1)(idx2).ind_continue := apex_json.get_varchar2(p_path => '['||idx1||'].nodes['||idx2||'].m', p_values => j);
        l_node(idx1)(idx2).id_subprocess := apex_json.get_varchar2(p_path => '['||idx1||'].nodes['||idx2||'].n', p_values => j);
        l_node(idx1)(idx2).id_check_stamp := apex_json.get_varchar2(p_path => '['||idx1||'].nodes['||idx2||'].o', p_values => j);
      end loop;
    end if;

    -- extract the node links
    if apex_json.get_count(p_path => '['||idx1||'].links', p_values => j) > 0 then
      for idx2 in 1..apex_json.get_count(p_path => '['||idx1||'].links', p_values => j) loop
        l_node_link(idx1)(idx2).id_record := awf_main_seq.nextval; --apex_json.get_varchar2(p_path => '['||idx1||'].links['||idx2||'].a', p_values => j);
        l_node_link(idx1)(idx2).id_parent_node := apex_json.get_varchar2(p_path => '['||idx1||'].links['||idx2||'].b', p_values => j);
        l_node_link(idx1)(idx2).id_child_node := apex_json.get_varchar2(p_path => '['||idx1||'].links['||idx2||'].c', p_values => j);
        l_node_link(idx1)(idx2).description := apex_json.get_varchar2(p_path => '['||idx1||'].links['||idx2||'].d', p_values => j);
        l_node_link(idx1)(idx2).ind_is_positive := apex_json.get_varchar2(p_path => '['||idx1||'].links['||idx2||'].e', p_values => j);
        l_node_link(idx1)(idx2).sequence := apex_json.get_varchar2(p_path => '['||idx1||'].links['||idx2||'].f', p_values => j);
        l_node_link(idx1)(idx2).amt_for_true := apex_json.get_varchar2(p_path => '['||idx1||'].links['||idx2||'].g', p_values => j);
        l_node_link(idx1)(idx2).id_process := l_id_process; --apex_json.get_varchar2(p_path => '['||idx1||'].links['||idx2||'].h', p_values => j);
        l_node_link(idx1)(idx2).id_proc_rec := apex_json.get_varchar2(p_path => '['||idx1||'].links['||idx2||'].i', p_values => j);
        l_node_link(idx1)(idx2).id_check_stamp := apex_json.get_varchar2(p_path => '['||idx1||'].links['||idx2||'].j', p_values => j);
      end loop;
    end if;

    -- extract the link corners (vertex)
    if apex_json.get_count(p_path => '['||idx1||'].link_vertices', p_values => j) > 0 then
      for idx2 in 1..apex_json.get_count(p_path => '['||idx1||'].link_vertices', p_values => j) loop
        l_node_link_vertex(idx1)(idx2).id_record := awf_main_seq.nextval; --apex_json.get_varchar2(p_path => '['||idx1||'].link_vertices['||idx2||'].a', p_values => j);
        l_node_link_vertex(idx1)(idx2).id_process := l_id_process; --apex_json.get_varchar2(p_path => '['||idx1||'].link_vertices['||idx2||'].b', p_values => j);
        l_node_link_vertex(idx1)(idx2).id_proc_rec := apex_json.get_varchar2(p_path => '['||idx1||'].link_vertices['||idx2||'].c', p_values => j);
        l_node_link_vertex(idx1)(idx2).vertex_seq := apex_json.get_varchar2(p_path => '['||idx1||'].link_vertices['||idx2||'].d', p_values => j);
        l_node_link_vertex(idx1)(idx2).x_pos := apex_json.get_varchar2(p_path => '['||idx1||'].link_vertices['||idx2||'].e', p_values => j);
        l_node_link_vertex(idx1)(idx2).y_pos := apex_json.get_varchar2(p_path => '['||idx1||'].link_vertices['||idx2||'].f', p_values => j);
        l_node_link_vertex(idx1)(idx2).id_check_stamp := apex_json.get_varchar2(p_path => '['||idx1||'].link_vertices['||idx2||'].g', p_values => j);
      end loop;
    end if;

    -- extract the node actions 
    if apex_json.get_count(p_path => '['||idx1||'].node_actions', p_values => j) > 0 then
      for idx2 in 1..apex_json.get_count(p_path => '['||idx1||'].node_actions', p_values => j) loop
        l_node_action(idx1)(idx2).id_record := awf_main_seq.nextval; --apex_json.get_varchar2(p_path => '['||idx1||'].node_actions['||idx2||'].a', p_values => j);
        l_node_action(idx1)(idx2).action_name := apex_json.get_varchar2(p_path => '['||idx1||'].node_actions['||idx2||'].b', p_values => j);
        l_node_action(idx1)(idx2).id_relationship := apex_json.get_varchar2(p_path => '['||idx1||'].node_actions['||idx2||'].c', p_values => j);
        l_node_action(idx1)(idx2).sequence := apex_json.get_varchar2(p_path => '['||idx1||'].node_actions['||idx2||'].d', p_values => j);
        l_node_action(idx1)(idx2).amt_for_true := apex_json.get_varchar2(p_path => '['||idx1||'].node_actions['||idx2||'].e', p_values => j);
        l_node_action(idx1)(idx2).ind_stop_on_error := apex_json.get_varchar2(p_path => '['||idx1||'].node_actions['||idx2||'].f', p_values => j);
        l_node_action(idx1)(idx2).id_process := l_id_process; --apex_json.get_varchar2(p_path => '['||idx1||'].node_actions['||idx2||'].g', p_values => j);
        l_node_action(idx1)(idx2).id_proc_rec := apex_json.get_varchar2(p_path => '['||idx1||'].node_actions['||idx2||'].h', p_values => j);
        l_node_action(idx1)(idx2).id_node_number := apex_json.get_varchar2(p_path => '['||idx1||'].node_actions['||idx2||'].i', p_values => j);
        l_node_action(idx1)(idx2).id_check_stamp := apex_json.get_varchar2(p_path => '['||idx1||'].node_actions['||idx2||'].j', p_values => j);
      end loop;
    end if;

    -- extract the node assignments
    if apex_json.get_count(p_path => '['||idx1||'].node_assignments', p_values => j) > 0 then
      for idx2 in 1..apex_json.get_count(p_path => '['||idx1||'].node_assignments', p_values => j) loop
        l_node_assignment(idx1)(idx2).id_record := awf_main_seq.nextval; --apex_json.get_varchar2(p_path => '['||idx1||'].node_assignments['||idx2||'].a', p_values => j);
        l_node_assignment(idx1)(idx2).description := apex_json.get_varchar2(p_path => '['||idx1||'].node_assignments['||idx2||'].b', p_values => j);
        l_node_assignment(idx1)(idx2).priority := apex_json.get_varchar2(p_path => '['||idx1||'].node_assignments['||idx2||'].c', p_values => j);
        l_node_assignment(idx1)(idx2).ind_notify_by_email := apex_json.get_varchar2(p_path => '['||idx1||'].node_assignments['||idx2||'].d', p_values => j);
        l_node_assignment(idx1)(idx2).node_number := apex_json.get_varchar2(p_path => '['||idx1||'].node_assignments['||idx2||'].e', p_values => j);
        l_node_assignment(idx1)(idx2).id_role := apex_json.get_varchar2(p_path => '['||idx1||'].node_assignments['||idx2||'].f', p_values => j);
        l_node_assignment(idx1)(idx2).id_escrole := apex_json.get_varchar2(p_path => '['||idx1||'].node_assignments['||idx2||'].g', p_values => j);
        l_node_assignment(idx1)(idx2).id_email_template := apex_json.get_varchar2(p_path => '['||idx1||'].node_assignments['||idx2||'].h', p_values => j);
        l_node_assignment(idx1)(idx2).id_process := l_id_process; --apex_json.get_varchar2(p_path => '['||idx1||'].node_assignments['||idx2||'].i', p_values => j);
        l_node_assignment(idx1)(idx2).id_proc_rec := apex_json.get_varchar2(p_path => '['||idx1||'].node_assignments['||idx2||'].j', p_values => j);
        l_node_assignment(idx1)(idx2).amt_for_true := apex_json.get_varchar2(p_path => '['||idx1||'].node_assignments['||idx2||'].k', p_values => j);
        l_node_assignment(idx1)(idx2).id_check_stamp := apex_json.get_varchar2(p_path => '['||idx1||'].node_assignments['||idx2||'].l', p_values => j);
      end loop;
    end if;

    -- extract the node sub-processes
    if apex_json.get_count(p_path => '['||idx1||'].node_subprocesses', p_values => j) > 0 then
      for idx2 in 1..apex_json.get_count(p_path => '['||idx1||'].node_subprocesses', p_values => j) loop
        l_node_subprocess(idx1)(idx2).id_record := awf_main_seq.nextval; --apex_json.get_varchar2(p_path => '['||idx1||'].node_subprocesses['||idx2||'].a', p_values => j);
        l_node_subprocess(idx1)(idx2).id_check_stamp := apex_json.get_varchar2(p_path => '['||idx1||'].node_subprocesses['||idx2||'].b', p_values => j);
        l_node_subprocess(idx1)(idx2).id_process := l_id_process; --apex_json.get_varchar2(p_path => '['||idx1||'].node_subprocesses['||idx2||'].c', p_values => j);
        l_node_subprocess(idx1)(idx2).id_proc_rec := apex_json.get_varchar2(p_path => '['||idx1||'].node_subprocesses['||idx2||'].d', p_values => j);
        l_node_subprocess(idx1)(idx2).id_node := apex_json.get_varchar2(p_path => '['||idx1||'].node_subprocesses['||idx2||'].e', p_values => j);
        l_node_subprocess(idx1)(idx2).id_subprocess := apex_json.get_varchar2(p_path => '['||idx1||'].node_subprocesses['||idx2||'].f', p_values => j);
        l_node_subprocess(idx1)(idx2).exec_action := apex_json.get_varchar2(p_path => '['||idx1||'].node_subprocesses['||idx2||'].g', p_values => j);
        l_node_subprocess(idx1)(idx2).subprocess_seq := apex_json.get_varchar2(p_path => '['||idx1||'].node_subprocesses['||idx2||'].h', p_values => j);
      end loop;
    end if;

    -- extract the conditions
    if apex_json.get_count(p_path => '['||idx1||'].conditions', p_values => j) > 0 then
      for idx2 in 1..apex_json.get_count(p_path => '['||idx1||'].conditions', p_values => j) loop
        l_conditions(idx1)(idx2).id_record := awf_main_seq.nextval;
        l_conditions(idx1)(idx2).condition := apex_json.get_varchar2(p_path => '['||idx1||'].conditions['||idx2||'].b', p_values => j);
        l_conditions(idx1)(idx2).ind_must_be := apex_json.get_varchar2(p_path => '['||idx1||'].conditions['||idx2||'].f', p_values => j);
        l_conditions(idx1)(idx2).id_process := l_id_process;
        l_conditions(idx1)(idx2).id_proc_rec := apex_json.get_varchar2(p_path => '['||idx1||'].conditions['||idx2||'].h', p_values => j);
        l_conditions(idx1)(idx2).id_check_stamp := awf_stamp_seq.nextval;
      end loop;
    else 
      raise no_conditions;
    end if;

    -- load process data to wf tables
    if l_process.exists(idx1) then    

      forall idx2 in 1..l_process.count
      insert into awf_process
      values l_process(idx2);

      if l_proc_vars.exists(idx1) then
        for idx2 in 1..l_proc_vars(idx1).count loop

--          l_dflt_var_value := anydata.accessClob(l_proc_vars(idx1)(idx2).default_var_value);

          insert into awf_proc_vars
          values (
            l_proc_vars(idx1)(idx2).id_record,
            l_proc_vars(idx1)(idx2).id_process,
            l_proc_vars(idx1)(idx2).var_name,
            l_proc_vars(idx1)(idx2).var_type,
            l_proc_vars(idx1)(idx2).notes,
            l_proc_vars(idx1)(idx2).ind_active,
            l_proc_vars(idx1)(idx2).id_check_stamp,
            l_proc_vars(idx1)(idx2).default_var_value,
            l_proc_vars(idx1)(idx2).dvar_value_type,
            l_proc_vars(idx1)(idx2).dflt_clob_value,
            l_proc_vars(idx1)(idx2).dflt_blob_value
                 );

        end loop;           
      end if;

      if l_node.exists(idx1) then
        forall idx2 in 1..l_node(idx1).count
        insert into awf_node
        values l_node(idx1)(idx2);
      end if;

      if l_node_link.exists(idx1) then
        forall idx2 in 1..l_node_link(idx1).count
        insert into awf_node_link
        values l_node_link(idx1)(idx2);
      end if; 

      if l_node_link_vertex.exists(idx1) then
        forall idx2 in 1..l_node_link_vertex(idx1).count
        insert into awf_node_link_vertex
        values l_node_link_vertex(idx1)(idx2);
      end if;

      if l_node_action.exists(idx1) then
        forall idx2 in 1..l_node_action(idx1).count
        insert into awf_node_action
        values l_node_action(idx1)(idx2);
      end if;

      if l_node_assignment.exists(idx1) then
        forall idx2 in 1..l_node_assignment(idx1).count
        insert into awf_node_assignment
        values l_node_assignment(idx1)(idx2);
      end if;

      if l_node_subprocess.exists(idx1) then
        forall idx2 in 1..l_node_subprocess(idx1).count
        insert into awf_node_subprocess
        values l_node_subprocess(idx1)(idx2);
      end if;

      -- write the conditions to the db
      if l_conditions.exists(idx1) then
        forall idx2 in 1..l_conditions(idx1).count
        insert into awf_conditions
        values l_conditions(idx1)(idx2);
      end if;

    end if;

  end loop;   


  return l_id_process;

--exception 
/*
  when existing_proc_rev then
    dbms_output.put_line('ERROR: Process/Revision Already Exists');
  when no_enabled_object then
    dbms_output.put_line('ERROR: No Enabled Object has been defined for this Process');
*/
  --when others then 
    --raise;
end ;
--------------------------------------------------------------------------------
function f_proc_copy
(p_id_process in number
,p_action in varchar2
,p_name in varchar2 default null
,p_description in varchar2 default null
,p_output out varchar2)
return number
as
  l_retvar number;
  l_id_process number;
  l_id_check_stamp number;
  l_rev_num number := 0;
  l_ind_rev_dup varchar2(3) := p_action;

  type t_process is table of awf_process%rowtype index by pls_integer;
  l_process t_process;
  type t_proc_var is table of awf_proc_vars%rowtype index by pls_integer;
  l_proc_var t_proc_var;
  type t_node is table of awf_node%rowtype index by pls_integer;
  l_node t_node;
  type t_node_link is table of awf_node_link%rowtype index by pls_integer;
  l_node_link t_node_link;
  type t_node_link_vertex is table of awf_node_link_vertex%rowtype index by pls_integer;
  l_node_link_vertex t_node_link_vertex;
  type t_node_action is table of awf_node_action%rowtype index by pls_integer;
  l_node_action t_node_action;
  type t_node_assignment is table of awf_node_assignment%rowtype index by pls_integer;
  l_node_assignment t_node_assignment;
  type t_node_subprocess is table of awf_node_subprocess%rowtype index by pls_integer;
  l_node_subprocess t_node_subprocess;
  type t_conditions is table of awf_conditions%rowtype index by pls_integer;
  l_conditions t_conditions;

begin
  l_id_process := awf_main_seq.nextval();
  l_id_check_stamp := awf_stamp_seq.nextval();

  select max(PROC_REVISION)+1 proc_rev 
  into   l_rev_num
  from   awf_process
  where  id_base_process = (select id_base_process 
                            from   awf_process 
                            where  id_record = p_id_process);

  -- get data
    -- process
    SELECT 
      l_id_process ID_RECORD,
      case l_ind_rev_dup when 'DUP' then l_id_process else ID_BASE_PROCESS end ID_BASE_PROCESS,
      case l_ind_rev_dup when 'DUP' then p_name else process_name end PROCESS_NAME,
      case l_ind_rev_dup when 'DUP' then p_description else DESCRIPTION end description,
      case l_ind_rev_dup when 'DUP' then 1 else l_rev_num end PROC_REVISION,
      case l_ind_rev_dup when 'DUP' then null else id_record end ID_REVISED_FROM,
      ID_ROLE,
      OBJ_OWNER,
      OBJ_NAME,
      ID_PROC_REC,
      0 IND_ENABLED,
      0 IND_ACTIVE,
      0 IND_AUTO_INITIATE,
      IND_ALLOW_MORE_INST,
      l_id_check_stamp ID_CHECK_STAMP
    bulk collect into l_process
    FROM AWF_PROCESS 
    where id_record = p_id_process;

    -- variables
    SELECT 
      awf_main_seq.nextval ID_RECORD,
      l_id_process ID_PROCESS,
      VAR_NAME,
      VAR_TYPE,
      NOTES,
      IND_ACTIVE,
      l_id_check_stamp ID_CHECK_STAMP,
      DEFAULT_VAR_VALUE,
      DVAR_VALUE_TYPE,
      DFLT_CLOB_VALUE,
      DFLT_BLOB_VALUE
    bulk collect into l_proc_var
    FROM AWF_PROC_VARS
    where id_process = p_id_process ;

    -- nodes
    SELECT 
      awf_main_seq.nextval ID_RECORD,
      l_id_process ID_PROCESS,
      ID_PROC_REC,
      NODE_TYPE,
      LAYOUT_COLUMN,
      LAYOUT_ROW,
      NODE_NAME,
      DESCRIPTION,
      IND_DISP_IF_ONE,
      AMT_FOR_TRUE,
      INTERVAL,
      INTERVAL_UOM,
      IND_CONTINUE,
      ID_SUBPROCESS,
      l_id_check_stamp ID_CHECK_STAMP
    bulk collect into l_node
    FROM AWF_NODE
    where id_process = p_id_process ;

    -- links
    SELECT 
      awf_main_seq.nextval ID_RECORD,
      ID_PARENT_NODE,
      ID_CHILD_NODE,
      DESCRIPTION,
      IND_IS_POSITIVE,
      SEQUENCE,
      AMT_FOR_TRUE,
      l_id_process ID_PROCESS,
      ID_PROC_REC,
      l_id_check_stamp ID_CHECK_STAMP
    bulk collect into l_node_link
    FROM AWF_NODE_LINK
    where id_process = p_id_process ;

    -- link vertices
    SELECT 
      awf_main_seq.nextval ID_RECORD,
      l_id_process ID_PROCESS,
      ID_PROC_REC,
      VERTEX_SEQ,
      X_POS,
      Y_POS,
      l_id_check_stamp ID_CHECK_STAMP
    bulk collect into l_node_link_vertex
    FROM AWF_NODE_LINK_VERTEX
    where id_process = p_id_process ;

    -- actions
    SELECT 
      awf_main_seq.nextval ID_RECORD,
      ACTION_NAME,
      ID_RELATIONSHIP,
      SEQUENCE,
      AMT_FOR_TRUE,
      IND_STOP_ON_ERROR,
      l_id_process ID_PROCESS,
      ID_PROC_REC,
      ID_NODE_NUMBER,
      l_id_check_stamp ID_CHECK_STAMP
    bulk collect into l_node_action
    FROM AWF_NODE_ACTION
    where id_process = p_id_process ;

    -- assignments
    SELECT 
      awf_main_seq.nextval ID_RECORD,
      DESCRIPTION,
      PRIORITY,
      IND_NOTIFY_BY_EMAIL,
      NODE_NUMBER,
      ID_ROLE,
      ID_ESCROLE,
      ID_EMAIL_TEMPLATE,
      l_id_process ID_PROCESS,
      ID_PROC_REC,
      AMT_FOR_TRUE,
      l_id_check_stamp ID_CHECK_STAMP
    bulk collect into l_node_assignment
    FROM AWF_NODE_ASSIGNMENT
    where id_process = p_id_process ;

    -- sub-processes
    SELECT 
      awf_main_seq.nextval ID_RECORD,
      l_id_check_stamp ID_CHECK_STAMP,
      l_id_process ID_PROCESS,
      ID_PROC_REC,
      ID_NODE,
      ID_SUBPROCESS,
      EXEC_ACTION,
      SUBPROCESS_SEQ
    bulk collect into l_node_subprocess
    FROM AWF_NODE_SUBPROCESS
    where id_process = p_id_process ;

    -- conditions
    SELECT 
      awf_main_seq.nextval ID_RECORD,
      CONDITION,
      ID_RELATIONSHIP,
      OBJ_OWNER,
      OBJECT,
      IND_MUST_BE,
      l_id_process ID_PROCESS,
      ID_PROC_REC,
      l_id_check_stamp ID_CHECK_STAMP
    bulk collect into l_conditions
    FROM AWF_CONDITIONS
    where id_process = p_id_process;

  -- write data
    -- process
    forall idx in 1..l_process.count
    insert into awf_process
    values l_process(idx);

    -- variables
    forall idx in 1..l_proc_var.count
    insert into awf_proc_vars
    values l_proc_var(idx);

    -- nodes
    forall idx in 1..l_node.count
    insert into awf_node
    values l_node(idx);

    -- links
    forall idx in 1..l_node_link.count
    insert into awf_node_link
    values l_node_link(idx);

    -- link vertices
    forall idx in 1..l_node_link_vertex.count
    insert into awf_node_link_vertex
    values l_node_link_vertex(idx);

    -- actions
    forall idx in 1..l_node_action.count
    insert into awf_node_action
    values l_node_action(idx);

    -- assignments
    forall idx in 1..l_node_assignment.count
    insert into awf_node_assignment
    values l_node_assignment(idx);

    -- sub-processes
    forall idx in 1..l_node_subprocess.count
    insert into awf_node_subprocess
    values l_node_subprocess(idx);

    -- conditions
    forall idx in 1..l_conditions.count
    insert into awf_conditions
    values l_conditions(idx);

    l_retvar := l_id_process;

    p_output := l_process.count
                ||':'||l_proc_var.count
                ||':'||l_node.count
                ||':'||l_node_link.count
                ||':'||l_node_link_vertex.count
                ||':'||l_node_action.count
                ||':'||l_node_assignment.count
                ||':'||l_node_subprocess.count
                ||':'||l_conditions.count;

    return l_retvar;
exception 
  when others then
    return -1;
end ;
--------------------------------------------------------------------------------
procedure p_delete_process
(p_id_process varchar2)
as
  l_id_process number;
begin
  null;
  -- get id_record from process using the rowid in param
    select id_record 
    into l_id_process
    from awf_process
    where rowid = p_id_process;

  -- delete metadata
    -- awf_conditions
    delete from awf_conditions where id_process = l_id_process;
    -- awf_node_assignment
    delete from awf_node_assignment where id_process = l_id_process;
    -- awf_node_subprocess
    delete from awf_node_subprocess where id_process = l_id_process;
    -- awf_node_link_vertex
    delete from awf_node_link_vertex where id_process = l_id_process;
    -- awf_node_link
    delete from awf_node_link where id_process = l_id_process;
    -- awf_node_action
    delete from awf_node_action where id_process = l_id_process;
    -- awf_node
    delete from awf_node where id_process = l_id_process;
    -- awf_proc_vars
    delete from awf_proc_vars where id_process = l_id_process;
    -- awf_process
    delete from awf_process where id_record = l_id_process;
    -- awf_wf_record
    delete from awf_wf_record where id_process = l_id_process;
  -- delete instance data
    -- awf_inst_assign_status
    delete from awf_inst_assign_status
    where id_assignment in (select id_assignment 
                            from awf_inst_assign
                            where id_process = l_id_process);
    -- awf_inst_assign
    delete from awf_inst_assign where id_process = l_id_process;
    -- awf_inst_log
    delete from awf_inst_log where id_instance in (select id_record 
                                                   from awf_instance 
                                                   where id_process = l_id_process);
    -- awf_inst_node_links
    delete from awf_inst_node_links where id_instance in (select id_record 
                                                   from awf_instance 
                                                   where id_process = l_id_process);
    -- awf_inst_log
    delete from awf_inst_log where id_instance in (select id_record 
                                                   from awf_instance 
                                                   where id_process = l_id_process);
    -- awf_inst_vars
    delete from awf_inst_vars where id_instance in (select id_record 
                                                   from awf_instance 
                                                   where id_process = l_id_process);
    -- awf_instance_state
    delete from awf_instance_state where id_instance in (select id_record 
                                                   from awf_instance 
                                                   where id_process = l_id_process);
    -- awf_instance
    delete from awf_instance where id_process = l_id_process;

end ;
--------------------------------------------------------------------------------
end ;

/
