--------------------------------------------------------
--  DDL for Package Body PKG_REST_SVCS
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "PKG_REST_SVCS" as
------------------------------------------------------------------------
  g_inst awf_instance%rowtype;
  g_istate awf_instance_state%rowtype;
  g_proc relay_proc_acct%rowtype; --awf_process%rowtype;

  type t_fqueue is table of tk_fqueue%rowtype;
  g_fqueue t_fqueue := t_fqueue(); 

  g_cur_que tk_fqueue%rowtype;
/*  
  type t_q_data is table of awf_inst_data%rowtype;
  g_inst_data t_q_data := t_q_data();
*/
  type t_rly_object is table of tk_object%rowtype;
  g_q_object t_rly_object := t_rly_object();

  type t_rly_obj is table of tk_obj_attr%rowtype;
  g_q_obj t_rly_obj := t_rly_obj();

  type t_rly_obj_idx is table of number index by pls_integer;
  g_q_obj_idx t_rly_obj_idx;

  g_ag_active number := 0;

  g_auth_set relay_account%rowtype;

  g_auth_check number;

  type t_resp_r is record(json_attr varchar2(4000)
                         ,json_val varchar2(4000)
                         ,err_val number);
  type t_resp_t is table of t_resp_r index by pls_integer;
  type t_resp_tt is table of t_resp_t index by varchar2(50);
  g_resp t_resp_tt;

  type t_resp_idx_tt is table of number index by varchar2(50);
  g_resp_idx t_resp_idx_tt;

  g_check_var varchar2(10);

  g_new_req number;
  -- public variable
--  g_json_resp tk_json_response;

  g_a varchar2(4000);
  g_b varchar2(4000);
  g_d varchar2(4000);
  g_e varchar2(4000);
  g_h varchar2(4000);
  g_i varchar2(4000);
  g_j varchar2(4000);
  g_k varchar2(4000);
  g_owner_data tk_json_obj := tk_json_obj();
  g_assignments tk_json_obj := tk_json_obj();
  g_res_req tk_json_obj := tk_json_obj();
  g_choices tk_json_obj := tk_json_obj();
  g_alerts tk_json_obj := tk_json_obj();
  g_err_log tk_json_obj := tk_json_obj();

  type t_rec_acct is table of tk_rec_acct%rowtype index by pls_integer;
  g_rec_acct t_rec_acct;
  g_rec_acct_alt1 t_coll_ref2; -- collection(rec_type)(rec_id):index

  g_errlog_ex clob; -- error log extract for exception
------------------------------------------------------------------------
-- REQUEST
/*
create or replace type tk_json_request as object 
(a varchar2(4000) -- request_id
,b varchar2(4000) -- internal_id
,c varchar2(4000) -- auth_id
,d varchar2(4000) -- process_name
,e varchar2(4000) -- object_id
,f varchar2(4000) -- input_assignment
,g varchar2(4000) -- input_choice
,i varchar2(4000) -- change_id
,owner_data tk_json_obj
,res_reply tk_json_obj);
*/
-- RESPONSE
/*
create or replace type tk_json_response as object 
(a varchar2(4000) -- request_id
,b varchar2(4000) -- internal_id
,d varchar2(4000) -- process_name
,e varchar2(4000) -- object_id
,h varchar2(4000) -- node_type
,i varchar2(4000) -- change_id
,j varchar2(4000) -- time limit
,k varchar2(4000) -- ind_conditional
,owner_data tk_json_obj
,assignments tk_json_obj
,res_req tk_json_obj
,choices tk_json_obj
,alerts tk_json_obj
,err_log tk_json_obj);
*/
------------------------------------------------------------------------
function f_get_errlog
return clob
as
  l_retvar clob := '';
begin

  for idx in 1..g_err_log.count loop

    l_retvar := l_retvar||g_err_log(idx).a||' : '||g_err_log(idx).b||chr(10);

  end loop;

  return l_retvar;
exception 
  when others then 
    raise;
end;
------------------------------------------------------------------------
procedure p_write_err
(p_attr in varchar2
,p_value in varchar2)
as
  l_idx number := 0;
begin
  g_err_log.extend;
  l_idx := g_err_log.count;
  g_err_log(l_idx) := tk_json_obj_attr(p_attr,p_value);
exception 
  when others then 
    raise;
end;
------------------------------------------------------------------------
function f_get_auth
(p_user_name in varchar2)
return varchar2
as
  l_retvar varchar2(4000);
begin

  -- if on prem then use this
--  l_retvar := relay_p_anydata.f_get_param_vc2('AUTH_ID');

  -- if SaaS then use this
  select r.acct_id
  into l_retvar
  from  awf_users u
       ,tk_rec_acct r
  where r.rec_id = u.id_record
    and r.rec_type = 1
    and upper(u.user_name) = upper(p_user_name);

  return l_retvar;
exception 
  when others then 
    raise;
end;
------------------------------------------------------------------------
procedure p_load_proc_meta
(p_id_process in number
,p_id_instance in number)
as
  l_program varchar2(200) := 'f_load_process';

  l_id_process number := p_id_process;
  l_id_instance number := p_id_instance;

  l_proc_alt1 number := 0;
  l_pvar_alt1 number := 0;
  l_node_alt1 number := 0;
  l_nact_alt1 number := 0;
  l_nact_alt2 number := 0;
  l_nass_alt1 number := 0;
  l_nass_alt2 number := 0;
  l_nlin_alt1 number := 0;
  l_nlin_alt2 number := 0;
  l_nlin_alt3 number := 0;
  l_cond_alt2 number := 0;
  l_act_alt1 number := 0;
  l_apv_alt1 number := 0;
  l_apv_alt2 number := 0;
  l_temp_alt1 number := 0;
  l_send_alt1 number := 0;
  l_role_alt1 number := 0;
  l_role_alt2 number := 0;
  l_pers_alt1 number := 0;
  l_pers_alt2 number := 0;
  l_ivar_alt1 number := 0;
  l_iass_alt1 number := 0;
  l_prole_alt1 number := 0;

begin

  -- load account array
  select * 
  bulk collect into g_rec_acct
  from tk_rec_acct
  where acct_id = g_auth_set.id_account;

  for idx in 1..g_rec_acct.count loop
    g_rec_acct_alt1(g_rec_acct(idx).rec_type)(g_rec_acct(idx).rec_id) := idx;
  end loop;

--  g_rec_acct(g_rec_acct_alt1('#')('#').rec_id

  -- BEGIN Instance
  begin

    select * 
    into g_instance
    from awf_instance
    where id_record = l_id_instance;

    select  * 
    into g_inst_state
    from awf_instance_state
    where id_instance = l_id_instance;

  exception
    when others then 
      null;
      p_write_err($$plsql_line,'REQUEST : NO_INSTANCE');
  end;

  select * 
  bulk collect into g_inst_links
  from awf_inst_node_links
  where id_instance = l_id_instance;

  select *
  bulk collect into g_inst_vars
  from awf_inst_vars
  where id_instance = l_id_instance;

  select *
  bulk collect into g_inst_assign
  from awf_inst_assign
  where id_instance = l_id_instance
    and code_status not in ('COMPLETED','CLOSED');
  -- END Instance

-->  dbms_output.put_line($$plsql_line||' '||l_id_process);

  select *
  bulk collect into g_process
  from vw_proc_proc a
  where id_parent = l_id_process
    and id_record = g_rec_acct(g_rec_acct_alt1('3')(l_id_process)).rec_id;

  for idx in 1..g_process.count loop
    g_proc_set.extend;
    g_proc_set(idx) := g_process(idx).id_record;
  end loop;

  select *
  bulk collect into g_proc_rec
  from vw_process_records
  where id_process in (select * from table(g_proc_set))
    and id_process = g_rec_acct(g_rec_acct_alt1('3')(l_id_process)).rec_id
  order by id_proc_rec;

  select * 
  bulk collect into g_proc_var 
  from awf_proc_vars 
  where id_process in (select * from table(g_proc_set))
    and id_process = g_rec_acct(g_rec_acct_alt1('3')(l_id_process)).rec_id
  order by var_name;

  select * 
  bulk collect into g_node 
  from awf_node 
  where id_process in (select * from table(g_proc_set))
    and id_process = g_rec_acct(g_rec_acct_alt1('3')(l_id_process)).rec_id
  order by id_proc_rec;

  select * 
  bulk collect into g_naction 
  from awf_node_action 
  where id_process in (select * from table(g_proc_set))
    and id_process = g_rec_acct(g_rec_acct_alt1('3')(l_id_process)).rec_id
  order by id_node_number, sequence;

  select * 
  bulk collect into g_nassign 
  from awf_node_assignment 
  where id_process in (select * from table(g_proc_set))
    and id_process = g_rec_acct(g_rec_acct_alt1('3')(l_id_process)).rec_id
  order by id_proc_rec;

  select * 
  bulk collect into g_nlink 
  from awf_node_link 
  where id_process in (select * from table(g_proc_set))
    and id_process = g_rec_acct(g_rec_acct_alt1('3')(l_id_process)).rec_id
  order by id_proc_rec;

  select * 
  bulk collect into g_cond 
  from awf_conditions 
  where id_process in (select * from table(g_proc_set))
    and id_process = g_rec_acct(g_rec_acct_alt1('3')(l_id_process)).rec_id
  order by id_proc_rec, id_record;

  select * 
  bulk collect into g_action 
  from vw_proc_actions 
  where id_process in (select * from table(g_proc_set))
    and id_process = g_rec_acct(g_rec_acct_alt1('3')(l_id_process)).rec_id
  order by action_name;

  select * 
  bulk collect into g_act_pv 
  from vw_proc_actpv
  where id_process in (select * from table(g_proc_set))
    and id_process = g_rec_acct(g_rec_acct_alt1('3')(l_id_process)).rec_id
  order by id_process, id_action, act_parameter;

  select * 
  bulk collect into g_comm_temp 
  from vw_proc_comm 
  where id_process in (select * from table(g_proc_set))
    and id_process = g_rec_acct(g_rec_acct_alt1('3')(l_id_process)).rec_id
  order by id_record;

  select * 
  bulk collect into g_comm_send 
  from vw_proc_send
  where id_process in (select * from table(g_proc_set))
    and id_process = g_rec_acct(g_rec_acct_alt1('3')(l_id_process)).rec_id
  order by id_template, send_to_type, send_to;

--  dbms_output.put_line('g_comm_send.count : '||g_comm_send.count);

  select * 
  bulk collect into g_roles 
  from awf_roles 
  where id_record in (select distinct id_role 
                      from vw_process_roles 
                      where id_process in (select * from table(g_proc_set))
                        and id_process = g_rec_acct(g_rec_acct_alt1('3')(l_id_process)).rec_id)
  order by role_name;

  select * 
  bulk collect into g_person 
  from vw_proc_person 
  where id_process in (select * from table(g_proc_set))
    and id_process = g_rec_acct(g_rec_acct_alt1('3')(l_id_process)).rec_id
  order by id_role, id_person;

  select * 
  bulk collect into g_proc_roles
  from vw_process_roles
  where id_process in (select * from table(g_proc_set))
    and id_process = g_rec_acct(g_rec_acct_alt1('3')(l_id_process)).rec_id;

  g_pdl_idx := greatest(g_process.count
                       ,g_proc_var.count
                       ,g_node.count
                       ,g_naction.count
                       ,g_nassign.count
                       ,g_nlink.count
                       ,g_cond.count
                       ,g_action.count
                       ,g_act_pv.count
                       ,g_comm_temp.count
                       ,g_comm_send.count
                       ,g_roles.count
                       ,g_person.count
                       ,g_inst_vars.count
                       ,g_inst_assign.count
                       ,g_proc_roles.count);

  for idx in 1..g_pdl_idx loop

    if g_process.count >= idx then
      g_proc_alt1(g_process(idx).id_record) := idx;
      l_proc_alt1 := l_proc_alt1 + 1;
    end if;

    if g_proc_var.count >= idx then
      g_pvar_alt1(g_proc_var(idx).id_process)(g_proc_var(idx).var_name) := idx;
      l_pvar_alt1 := l_pvar_alt1 + 1;
    end if;

    if g_node.count >= idx then
      g_node_alt1(g_node(idx).id_process)(g_node(idx).id_proc_rec) := idx;
      l_node_alt1 := l_node_alt1 + 1;
    end if;

    if g_naction.count >= idx then
      g_nact_alt1(g_naction(idx).id_process)(g_naction(idx).id_proc_rec) := idx;
      l_nact_alt1 := l_nact_alt1 + 1;

      if g_nact_alt2.exists(g_naction(idx).id_process)
        and g_nact_alt2(g_naction(idx).id_process).exists(g_naction(idx).id_node_number)
      then
        g_lvl3_idx := g_nact_alt2(g_naction(idx).id_process)(g_naction(idx).id_node_number).count + 1;
        g_nact_alt2(g_naction(idx).id_process)(g_naction(idx).id_node_number)(g_lvl3_idx) := idx;
        l_nact_alt2 := l_nact_alt2 + 1;
      else
        g_lvl3_idx := 1;
        g_nact_alt2(g_naction(idx).id_process)(g_naction(idx).id_node_number)(g_lvl3_idx) := idx;
        l_nact_alt2 := l_nact_alt2 + 1;
      end if;
    end if;

    if g_nassign.count >= idx then
      g_nass_alt1(g_nassign(idx).id_process)(g_nassign(idx).id_proc_rec) := idx;

      if g_nass_alt2.exists(g_nassign(idx).id_process)
        and g_nass_alt2(g_nassign(idx).id_process).exists(g_nassign(idx).node_number)
      then
        g_lvl3_idx := g_nass_alt2(g_nassign(idx).id_process)(g_nassign(idx).node_number).count + 1;
        g_nass_alt2(g_nassign(idx).id_process)(g_nassign(idx).node_number)(g_lvl3_idx) := idx;
        l_nass_alt2 := l_nass_alt2 + 1;
      else
        g_lvl3_idx := 1;
        g_nass_alt2(g_nassign(idx).id_process)(g_nassign(idx).node_number)(g_lvl3_idx) := idx;
        l_nass_alt2 := l_nass_alt2 + 1;
      end if;
    end if;

    if g_nlink.count >= idx then
      g_nlin_alt1(g_nlink(idx).id_process)(g_nlink(idx).id_proc_rec) := idx;
      l_nlin_alt1 := l_nlin_alt1 + 1;

      if g_nlin_alt2.exists(g_nlink(idx).id_process)
        and g_nlin_alt2(g_nlink(idx).id_process).exists(g_nlink(idx).id_parent_node)
      then
        g_lvl3_idx := g_nlin_alt2(g_nlink(idx).id_process)(g_nlink(idx).id_parent_node).count + 1;
        g_nlin_alt2(g_nlink(idx).id_process)(g_nlink(idx).id_parent_node)(g_lvl3_idx) := idx;
        l_nlin_alt2 := l_nlin_alt2 + 1;
      else
        g_lvl3_idx := 1;
        g_nlin_alt2(g_nlink(idx).id_process)(g_nlink(idx).id_parent_node)(g_lvl3_idx) := idx;
        l_nlin_alt2 := l_nlin_alt2 + 1;
      end if;

      if g_nlin_alt3.exists(g_nlink(idx).id_process)
        and g_nlin_alt3(g_nlink(idx).id_process).exists(g_nlink(idx).id_parent_node)
        and g_nlin_alt3(g_nlink(idx).id_process)(g_nlink(idx).id_parent_node).exists(g_nlink(idx).ind_is_positive)
      then
        g_lvl3_idx := g_nlin_alt2(g_nlink(idx).id_process)(g_nlink(idx).id_parent_node).count + 1;
        g_nlin_alt3(g_nlink(idx).id_process)(g_nlink(idx).id_parent_node)(g_nlink(idx).ind_is_positive)(g_lvl3_idx) := idx;
        l_nlin_alt3 := l_nlin_alt3 + 1;
      else
        g_lvl3_idx := 1;
        g_nlin_alt3(g_nlink(idx).id_process)(g_nlink(idx).id_parent_node)(g_nlink(idx).ind_is_positive)(g_lvl3_idx) := idx;
        l_nlin_alt3 := l_nlin_alt3 + 1;
      end if;

    end if;

    if g_cond.count >= idx then
      if g_cond_alt2.exists(g_cond(idx).id_process)
        and g_cond_alt2(g_cond(idx).id_process).exists(g_cond(idx).id_proc_rec)
      then
        g_lvl3_idx := g_cond_alt2(g_cond(idx).id_process)(g_cond(idx).id_proc_rec).count + 1;
        g_cond_alt2(g_cond(idx).id_process)(g_cond(idx).id_proc_rec)(g_lvl3_idx) := idx;
        l_cond_alt2 := l_cond_alt2 + 1;
      else
        g_lvl3_idx := 1;
        g_cond_alt2(g_cond(idx).id_process)(g_cond(idx).id_proc_rec)(g_lvl3_idx) := idx;
        l_cond_alt2 := l_cond_alt2 + 1;
      end if; 
    end if;

    if g_action.count >= idx then
      g_act_alt1(g_action(idx).id_process)(g_action(idx).action_name) := idx;
    end if;

    if g_act_pv.count >= idx then
      g_apv_alt1(g_act_pv(idx).id_process)(g_act_pv(idx).action_name)(g_act_pv(idx).act_parameter) := idx;
      l_apv_alt1 := l_apv_alt1 + 1;

      if g_apv_alt2.exists(g_act_pv(idx).id_process)
        and g_apv_alt2(g_act_pv(idx).id_process).exists(g_act_pv(idx).action_name)
      then
        g_lvl3_idx := g_apv_alt2(g_act_pv(idx).id_process)(g_act_pv(idx).action_name).count + 1;
        g_apv_alt2(g_act_pv(idx).id_process)(g_act_pv(idx).action_name)(g_lvl3_idx) := idx;
        l_apv_alt2 := l_apv_alt2 + 1;
      else
        g_lvl3_idx := 1;
        g_apv_alt2(g_act_pv(idx).id_process)(g_act_pv(idx).action_name)(g_lvl3_idx) := idx;
        l_apv_alt2 := l_apv_alt2 + 1;
      end if;
    end if;

    if g_comm_temp.count >= idx then
      g_temp_alt1(g_comm_temp(idx).id_process)(g_comm_temp(idx).id_record) := idx;
      l_temp_alt1 := l_temp_alt1 + 1;
    end if;

    if g_comm_send.count >= idx then
      if g_send_alt1.exists(g_comm_send(idx).id_process)
        and g_send_alt1(g_comm_send(idx).id_process).exists(g_comm_send(idx).id_template)
      then
        g_lvl3_idx := g_send_alt1(g_comm_send(idx).id_process)(g_comm_send(idx).id_template).count + 1;
        g_send_alt1(g_comm_send(idx).id_process)(g_comm_send(idx).id_template)(g_lvl3_idx) := idx;
        l_send_alt1 := l_send_alt1 + 1;
      else
        g_lvl3_idx := 1;
        g_send_alt1(g_comm_send(idx).id_process)(g_comm_send(idx).id_template)(g_lvl3_idx) := idx;
        l_send_alt1 := l_send_alt1 + 1;
      end if;

    end if;

    if g_roles.count >= idx then
      g_role_alt1(g_roles(idx).id_record) := idx;
      g_role_alt2(g_roles(idx).role_name) := idx;
      l_role_alt1 := l_role_alt1 + 1;
      l_role_alt2 := l_role_alt2 + 1;
    end if;

    if g_person.count >= idx then
      g_pers_alt1(g_person(idx).id_role)(g_person(idx).id_person) := idx;
      g_pers_alt2(g_person(idx).id_role)(g_person(idx).person_code) := idx;
      l_pers_alt1 := l_pers_alt1 + 1;
      l_pers_alt2 := l_pers_alt2 + 1;
    end if;

    if g_inst_vars.count >= idx then
      g_ivar_alt1(g_inst_vars(idx).id_instance)(g_inst_vars(idx).var_name) := idx;
      l_ivar_alt1 := l_ivar_alt1 + 1;
    end if;

    if g_inst_assign.count >= idx then
      g_iass_alt1(g_inst_assign(idx).id_instance)(g_inst_assign(idx).id_record) := idx;
      l_iass_alt1 := l_iass_alt1 + 1;
    end if;

    if g_proc_roles.count >= idx then

      if g_prole_alt1.exists(g_proc_roles(idx).id_process)
        and g_prole_alt1(g_proc_roles(idx).id_process).exists(g_proc_roles(idx).rectype)
        and g_prole_alt1(g_proc_roles(idx).id_process)(g_proc_roles(idx).rectype).exists(g_proc_roles(idx).rid)
      then
        g_lvl3_idx := g_prole_alt1(g_proc_roles(idx).id_process)(g_proc_roles(idx).rectype)(g_proc_roles(idx).rid).count + 1;
        g_prole_alt1(g_proc_roles(idx).id_process)(g_proc_roles(idx).rectype)(g_proc_roles(idx).rid)(g_lvl3_idx) := idx;
        l_prole_alt1 := l_prole_alt1 + 1;
      else
        g_lvl3_idx := 1;
        g_prole_alt1(g_proc_roles(idx).id_process)(g_proc_roles(idx).rectype)(g_proc_roles(idx).rid)(g_lvl3_idx) := idx;
        l_prole_alt1 := l_prole_alt1 + 1;
      end if;

    end if;

  end loop;

--  dbms_output.put_line($$plsql_line||' g_pers_alt1 : '||g_pers_alt1.count);

/*  
  -- test output
  p_write_err($$plsql_line,'g_pdl_idx: '||g_pdl_idx);
  p_write_err($$plsql_line,'g_process.count: '||g_process.count);
  p_write_err($$plsql_line,'-->l_proc_alt1: '||l_proc_alt1);
  p_write_err($$plsql_line,'g_proc_var.count: '||g_proc_var.count);
  p_write_err($$plsql_line,'-->l_pvar_alt1: '||l_pvar_alt1);
  p_write_err($$plsql_line,'g_node.count: '||g_node.count);
  p_write_err($$plsql_line,'-->l_node_alt1: '||l_node_alt1);
  p_write_err($$plsql_line,'g_naction.count: '||g_naction.count);
  p_write_err($$plsql_line,'-->l_nact_alt1: '||l_nact_alt1);
  p_write_err($$plsql_line,'-->l_nact_alt2: '||l_nact_alt2);
  p_write_err($$plsql_line,'g_nassign.count: '||g_nassign.count);
  p_write_err($$plsql_line,'-->l_nass_alt1: '||l_nass_alt1);
  p_write_err($$plsql_line,'-->l_nass_alt2: '||l_nass_alt2);
  p_write_err($$plsql_line,'g_nlink.count: '||g_nlink.count);
  p_write_err($$plsql_line,'-->l_nlin_alt1: '||l_nlin_alt1);
  p_write_err($$plsql_line,'-->l_nlin_alt2: '||l_nlin_alt2);
  p_write_err($$plsql_line,'-->l_nlin_alt3: '||l_nlin_alt3);
  p_write_err($$plsql_line,'g_cond.count: '||g_cond.count);
  p_write_err($$plsql_line,'-->l_cond_alt2: '||l_cond_alt2);
  p_write_err($$plsql_line,'g_action.count: '||g_action.count);
  p_write_err($$plsql_line,'-->l_act_alt1: '||l_act_alt1);
  p_write_err($$plsql_line,'g_act_pv.count: '||g_act_pv.count);
  p_write_err($$plsql_line,'-->l_apv_alt1: '||l_apv_alt1);
  p_write_err($$plsql_line,'-->l_apv_alt2: '||l_apv_alt2);
  p_write_err($$plsql_line,'g_comm_temp.count: '||g_comm_temp.count);
  p_write_err($$plsql_line,'-->l_temp_alt1: '||l_temp_alt1);
  p_write_err($$plsql_line,'g_comm_send.count: '||g_comm_send.count);
  p_write_err($$plsql_line,'-->l_send_alt1: '||l_send_alt1);
  p_write_err($$plsql_line,'g_roles.count: '||g_roles.count);
  p_write_err($$plsql_line,'-->l_role_alt1: '||l_role_alt1);
  p_write_err($$plsql_line,'-->l_role_alt2: '||l_role_alt2);
  p_write_err($$plsql_line,'g_person.count: '||g_person.count);
  p_write_err($$plsql_line,'-->l_pers_alt1: '||l_pers_alt1);
  p_write_err($$plsql_line,'-->l_pers_alt2: '||l_pers_alt2);
  p_write_err($$plsql_line,'g_inst_vars.count: '||g_inst_vars.count);
  p_write_err($$plsql_line,'-->l_ivar_alt1.count: '||l_ivar_alt1);
  p_write_err($$plsql_line,'g_inst_assign.count: '||g_inst_assign.count);
  p_write_err($$plsql_line,'-->l_iass_alt1.count: '||l_iass_alt1);
  p_write_err($$plsql_line,'l_prole_alt1.count: '||l_prole_alt1);
*/  

--/*
  if g_inst_vars.count = 0 then

    dbms_output.put_line($$plsql_line||' g_proc_var.count '||g_proc_var.count);

    --> insert inst_vars
    forall idx in 1..g_proc_var.count
    insert into awf_inst_vars
    values
    (relay_p_workflow.f_an_main
    ,g_inst.id_record
    ,g_proc_var(idx).var_type
    ,g_proc_var(idx).var_name
    ,g_proc_var(idx).default_var_value
    ,'PROC_VARS'
    ,null --rownum
    ,relay_p_workflow.f_an_stamp
    ,g_proc_var(idx).dflt_clob_value
    ,g_proc_var(idx).dflt_blob_value
    ,0);

  end if;

exception 
  when others then 
    raise;
end;
------------------------------------------------------------------------
function f_guid_gen
return varchar2 
as
  l_guid_byte varchar2(2);
  l_guid varchar2(4000) := '';
  l_version number(1) := 4;
  l_variant varchar2(1);
  pos1 number;
  pos2 number;
begin

  l_version := round(dbms_random.value(1,5));

  l_variant :=
    case round(dbms_random.value(1,4))
      when 1 then '8'
      when 2 then '9'
      when 3 then 'A'
      when 4 then 'B'
      else '0'
    end;

  pos1 := round(dbms_random.value(1,25));
  while pos1 in (7,12,13,17) loop
    pos1 := round(dbms_random.value(1,25));
  end loop;

  pos2 := pos1 + 6;

  for idx in 1..32 
  loop

    if idx not in (13,pos1,17,pos2) then
      l_guid_byte := trim(to_char(round(dbms_random.value(0,15)),'x'));
    elsif idx = pos1 then
      l_guid_byte := '0';
    elsif idx = pos2 then
      l_guid_byte := 'F';
    elsif idx = 13 then
      l_guid_byte := l_version;
    elsif idx = 17 then
      l_guid_byte := l_variant;
    end if;

    l_guid := l_guid||l_guid_byte;

  end loop;

  return upper(l_guid);
exception 
  when others then 
    raise;
end;
------------------------------------------------------------------------
function f_check_guid
(p_guid in varchar2)
return number
as

  l_retvar number := 0;

begin

  if regexp_count(p_guid,'0.{5}F') = 1 then
    l_retvar := 1;

  else 
    l_retvar := 0;

    p_write_err($$plsql_line,'INVALID INPUT');

  end if;

  return l_retvar;
exception 
  when others then 
    raise;
end;
------------------------------------------------------------------------
function f_get_post_run
(p_request_id in varchar2 default null)
return number
as
  l_retvar number;
  l_inst_id number;
  type t_json_attr is record( a varchar2(4000), b varchar2(4000));
  type t_json_obj is table of t_json_attr index by pls_integer;
  l_set t_json_obj;
begin
  p_write_err($$plsql_line,'g_json_req.a: '||g_json_req.a);

-- get the current queue
  select
        id_record,
        id_request,
        internal_id,
        flow_name,
        obj_name,
        node_type,
        change_id,
        timelimit,
        ind_condition
  into 
        l_inst_id
       ,g_a
       ,g_b 
       ,g_d
       ,g_e
       ,g_h
       ,g_i
       ,g_j
       ,g_k
  from tk_fqueue
  where id_request = nvl(p_request_id,g_json_req.a);

--  dbms_output.put_line($$plsql_unit||'.'||$$plsql_line||' g_h: '||g_h);

  p_write_err($$plsql_line,'l_inst_id: '||l_inst_id);

  -- check the instance data to see if it has changed
  -- sql to pull data that has changed ONLY (check_stamp does not match id_record)

  select tk_json_obj_attr(
         to_char(var_sequence)
        ,substr(relay_p_anydata.f_anydata_to_clob(var_value),1,4000))
  bulk collect into g_owner_data --g_json_resp.owner_data
  from awf_inst_data
  where id_instance = l_inst_id
    and ind_changed = 1;

  p_write_err($$plsql_line,'g_owner_data.count: '||g_owner_data.count);

/*  
  if l_set.count > 0 then

    for idx in 1..l_set.count loop

      g_json_resp.owner_data(idx) := tk_json_obj_attr(l_set(idx).a,l_set(idx).b);

    end loop;

  end if;
*/  
--  dbms_output.put_line($$plsql_unit||'.'||$$plsql_line||' g_h: '||g_h);
  -- get assignments and decision choices
  if g_h in ('TASK','DECISION') then
    -- add the assignments to the response
    select tk_json_obj_attr(p.person_code, na.description)
    bulk collect into g_assignments 
    from awf_node_assignment na
        ,awf_inst_assign ia
        ,awf_person p
    where ia.id_instance = l_inst_id
      and na.id_process = ia.id_process
      and na.id_proc_rec = ia.id_proc_rec
      and p.id_record = ia.id_assignee;  

--    dbms_output.put_line($$plsql_unit||'.'||$$plsql_line||' g_assignments.count: '||g_assignments.count);
/*
  if l_set.count > 0 then

    for idx in 1..l_set.count loop

      g_json_resp.owner_data(idx) := tk_json_obj_attr(l_set(idx).a,l_set(idx).b);

    end loop;

  end if;
*/    
    -- if rly sends the email then add resource request to response
    -- do not use at this time

    if g_h = 'DECISION' then
      -- add the choices to the response

      select tk_json_obj_attr(l.id_record, l.description)
      bulk collect into g_choices --l_set --g_json_resp.choices
      from awf_instance_state i
          ,awf_node_link l
      where id_instance = l_inst_id
        and l.id_process = i.id_process
        and l.id_parent_node = i.node_number
      order by l.sequence;
/*
      if l_set.count > 0 then

        for idx in 1..l_set.count loop

          g_json_resp.owner_data(idx) := tk_json_obj_attr(l_set(idx).a,l_set(idx).b);

        end loop;

      end if;
*/      
    end if;

  end if;

  -- load alerts into response

  return l_retvar;
/*
exception 
  when others then
    p_write_err($$plsql_line,'POST_RUN_DATA_ERROR');
    return 0;
*/
exception 
  when others then 
    raise;
end;
------------------------------------------------------------------------
function f_res_resp_chk
return number
as
  l_retvar number;
begin

  -- are they stored locally?

  if g_json_req.res_reply.count > 0 then 

--> TODO : FIX this    
  null;  
  end if;

  return l_retvar;
exception 
  when others then 
    raise;
end;
------------------------------------------------------------------------
function f_check_auth
return number
as
  l_valid number;
  l_retvar number;
begin

  if nvl(g_ind_op,0) = 0 then
    if g_json_req.c is not null then -- 2
      l_valid := f_check_guid(g_json_req.c);

      if l_valid = 1 then

        --switch to a view in WFaaS mode
/*
        if relay_p_anydata.f_get_param_vc2('AUTH_ID') = g_json_req.c then
          g_auth_set.ind_expired := 1;
        end if;
*/        
        select *
        into g_auth_set
        from relay_account a
        where id_auth = g_json_req.c;

        l_retvar := 1; 

      end if;

    else
      p_write_err($$plsql_line,'AUTH ID REQUIRED');
      l_retvar := 0;
    end if;
  else
    l_retvar := 1;
  end if;

  return l_retvar;
exception
  when no_data_found then
    p_write_err($$plsql_line,'AUTH FAILED');
    return 0;
end;
------------------------------------------------------------------------
function f_proc_allow
(p_auth_id in varchar2
,p_flow_name in varchar2)
return number
as
  l_retvar number;
begin
  select *
  into g_proc
  from relay_proc_acct --awf_process 
  where process_name = g_json_req.d --p_flow_name 
    and auth_id = g_json_req.c --p_auth_id 
    and ind_active = 1;

  l_retvar := 1;

  return l_retvar;
exception
  when no_data_found then
    p_write_err($$plsql_line,'PROCESS : NOT_FOUND');
    return 0;
  when others then
    p_write_err($$plsql_line,'PROCESS : OTHER ERROR');
    return 0;    
end;
------------------------------------------------------------------------
function f_build_inst
return number
as
  l_retvar number;
begin
  --> p_write_err($$plsql_line,'REQUEST : CHECKPOINT');

  -- load new instance values
  g_inst.id_record := awf_instance_seq.nextval();
  g_inst.ind_active := 1;
  g_inst.instance_orig := 'REST';
  g_inst.date_start := sysdate;
  g_inst.id_process := g_proc.id_record;
  g_inst.id_owner := g_json_req.b;
  g_inst.id_check_stamp := g_inst.id_record;

  -- load new instance state values
  g_istate.id_record := awf_main_seq.nextval();
  g_istate.id_instance := g_inst.id_record;
  g_istate.node_number := 2; --> find the start node properly
    -- maybe in the process view add field to get the start value quickly
  g_istate.ind_active := 0;
  g_istate.id_process := g_inst.id_process;
  g_istate.date_set := sysdate;
  g_istate.ind_ui_reqd := 0;
  g_istate.id_check_stamp := g_istate.id_record;   

  g_json_req.a := relay_p_vars.f_conv_hex(g_inst.id_record
                                        ||g_istate.id_record
                                        ||g_istate.id_process
                                        ||relay_p_vars.f_conv_to_ue(g_inst.date_start));

  l_retvar := 1;

  return l_retvar;
exception 
  when others then
    p_write_err($$plsql_line,'INSTANCE : ERROR');
    return -1;
end;
------------------------------------------------------------------------
function f_load_inst_data
return number
as
  l_retvar number;
  l_loop1 number;
  l_loop2 number;

  l_idx2 number;
  l_idx number;

begin

  -- load object attributes
  select *
  bulk collect into g_q_obj
  from tk_obj_attr a
  where id_object = (select id_record
                     from   tk_object
                     where  obj_name = g_json_req.e
                       and  auth_id = g_json_req.c);

  -- p_write_err($$plsql_line,'CHECKPOINT '||g_q_obj.count);

  -- p_write_err($$plsql_line,'CHECKPOINT '||g_json_req.owner_data.count);

  for idx in 1..g_json_req.owner_data.count loop

    l_idx := idx;

    for idx2 in 1..g_q_obj.count loop

      l_idx2 := idx2;

      if g_q_obj(l_idx2).seq_id = g_json_req.owner_data(idx).a then
--        g_inst_data.extend;
        g_inst_data(l_idx).id_record := awf_main_seq.nextval();
        g_inst_data(l_idx).id_record := awf_main_seq.nextval();
        g_inst_data(l_idx).id_instance := nvl(g_cur_que.id_record,g_inst.id_record);
        g_inst_data(l_idx).var_type := g_q_obj(l_idx2).attr_type;
        g_inst_data(l_idx).var_name := g_q_obj(l_idx2).attr_name;
        -- convert to anydata
        g_inst_data(l_idx).var_value := relay_p_anydata.f_clob_to_anydata(g_json_req.owner_data(l_idx).b,g_q_obj(l_idx2).attr_type);
        g_inst_data(l_idx).var_source := 'JSON_REQ';
        g_inst_data(l_idx).var_sequence := g_q_obj(l_idx2).seq_id;
        g_inst_data(l_idx).id_check_stamp := g_inst_data(l_idx).id_record;

        g_inst_data_alt1(g_inst_data(l_idx).var_name) := idx;
 /*       
        -- check to see if the internal_id and the key value are a match
        -- Preventing gaming an instance
        if g_q_obj(l_idx2).ind_key = 1
          and g_json_req.owner_data(l_idx).b != g_json_req.b 
        then
          p_write_err($$plsql_line,'ERROR: Record Mismatch');
        end if;
*/        
        null;
      end if;

    end loop;

  end loop;   

  -- p_write_err($$plsql_line,'CHECKPOINT '||g_json_req.owner_data.count);

  return l_retvar;

exception
  when others then
--/*
    p_write_err($$plsql_line,g_q_obj(l_idx2).attr_type);
    p_write_err($$plsql_line,g_q_obj(l_idx2).attr_name);
    p_write_err($$plsql_line,g_json_req.owner_data(l_idx).b);
    p_write_err($$plsql_line,g_q_obj(l_idx2).attr_type);
--*/
    raise;
end;
------------------------------------------------------------------------
function f_save_queue
return number
as
  l_retvar number;
begin
  if g_new_req = 1 then    
    insert into awf_instance values g_inst;
    insert into awf_instance_state values g_istate;

  end if;

--  dbms_output.put_line($$plsql_line||' '||g_inst_data.count);

  delete from awf_inst_data 
  where id_instance = g_inst_data(1).id_instance;

  forall idx in 1..g_inst_data.count
  insert into awf_inst_data
  values g_inst_data(idx);

  l_retvar := 1;

  return l_retvar;
exception 
  when others then 
    raise;
end;
------------------------------------------------------------------------
function f_check_req
return number
as
  l_retvar number;
  l_que_amt number;
  l_que_open number;
  l_que_id varchar2(50);
--  l_new_req number;
begin
  g_new_req := 0;
  if g_json_req.a is not null then
-->    if f_check_guid(g_json_req.a) = 1 then -- 4
      -- select any record from the queue that matched the request
      select *
      bulk collect into g_fqueue
      from tk_fqueue
      where id_request = g_json_req.a;

      -- 5
      -- if there is any match to the request 
      if g_fqueue.count > 0 then 
        -- if the existing request is closed not closed 
        if g_fqueue(1).node_type != 'CLOSED' then -- 6
          -- return good eval
          l_retvar := 1;
          g_cur_que := g_fqueue(1);

          -- if the change_id does not match then EXPIRED  
          if g_fqueue(1).change_id != g_json_req.i then
            p_write_err($$plsql_line,'REQUEST : EXPIRED');
            l_retvar := 0;
          else
            -- set internal instance id for processing   

            null;
          end if;

        else
          -- record error for closed request
          p_write_err($$plsql_line,'REQUEST : CLOSED'); -- 7
          l_retvar := 0;
        end if;
      else
        -- record error of non-existing request
        p_write_err($$plsql_line,'REQUEST : NO_EXIST'); -- 8
        l_retvar := 0;
      end if;
-->    else
--      p_write_err($$plsql_line,'INPUT : INVALID'); -- 8
--      l_retvar := 0;
--    end if;
  else
    --> p_write_err($$plsql_line,'REQUEST : CHECKPOINT');

    -- get queue data
    select * 
    bulk collect into g_fqueue
    from  tk_fqueue
    where internal_id = g_json_req.b
      and flow_name = g_json_req.d
      and obj_name = g_json_req.e;

    -- if there is existing requests
    if g_fqueue.count > 0 then

      l_que_amt := g_fqueue.count;
      l_que_open := 0;
      --> p_write_err($$plsql_line,'REQUEST : CHECKPOINT');

      -- cycle through them
      for idx in 1..g_fqueue.count loop

        if g_fqueue(idx).node_type != 'CLOSED' then
          l_que_open := l_que_open + 1;
          l_que_id := g_fqueue(idx).id_request;
          g_cur_que := g_fqueue(idx);
          --> p_write_err($$plsql_line,'REQUEST : CHECKPOINT');
        end if;

      end loop;

--      p_write_err($$plsql_line,'REQUEST : CHECKPOINT l_que_open: '||l_que_open);

      -- evaluate
      -- 1 open then error as duplicate
      if l_que_open > 0 then 
        l_retvar := 0;
        p_write_err($$plsql_line,'REQUEST : PREV_INST_RUNNING');
      -- if (either no history or history and more allowed) and none open 
      -- and account is not expired 
      elsif (l_que_amt = 0 
          or (l_que_amt > 0 and g_proc.ind_allow_more_inst = 1))
        and l_que_open = 0 
        and g_auth_set.ind_expired = 0
      then
--        g_json_req.a := f_guid_gen();
        g_new_req := 1;
        l_retvar := 1;
         --> p_write_err($$plsql_line,'REQUEST : CHECKPOINT');
      elsif l_que_open > 1 then
        p_write_err($$plsql_line,'REQUEST : TOO_MANY_OPEN');
        l_retvar := 0;
      elsif g_auth_set.ind_expired = 1 then
        p_write_err($$plsql_line,'ERROR : ACCOUNT_EXIRED');
        l_retvar := 0;
      else
        p_write_err($$plsql_line,'REQUEST : NO_MATCH_COND');
        l_retvar := 0;
      end if;

    else 
      l_retvar := 1;
      g_new_req := 1;
       --> p_write_err($$plsql_line,'REQUEST : CHECKPOINT');
    end if;

  end if;

  -- build new instance and request ID
  if g_new_req = 1
    and f_build_inst = 1 then
    l_retvar := 1;
    -- get the new instance request id    
    g_json_req.a := relay_p_vars.f_conv_hex(g_inst.id_record
                                          ||g_istate.id_record
                                          ||g_inst.id_process
                                          ||relay_p_vars.f_conv_to_ue(g_inst.date_start));
     --> p_write_err($$plsql_line,'REQUEST : CHECKPOINT');
  elsif g_new_req = 1
    and f_build_inst = 0 then
    p_write_err($$plsql_line,'REQUEST : INST_FAILED');
    l_retvar := 0;
  else
     --> p_write_err($$plsql_line,'REQUEST : CHECKPOINT');
    -->
    g_inst.id_record := g_fqueue(1).id_record;
    g_inst.id_process := g_fqueue(1).id_process;
    null;
  end if;

  if l_retvar = 1 
    and f_load_inst_data = 0 then
     --> p_write_err($$plsql_line,'REQUEST : CHECKPOINT');
    l_retvar := 0;
  else
     --> p_write_err($$plsql_line,'REQUEST : CHECKPOINT');
    null;
  end if;  

  return l_retvar;
exception 
  when others then 
    raise;
end;
------------------------------------------------------------------------
procedure relay_interface
(p_req_in in tk_json_request
,a out varchar2
,b out varchar2
,d out varchar2
,e out varchar2
,h out varchar2
,i out varchar2
,j out varchar2
,k out varchar2
,owner_data out tk_json_obj
,assignments out tk_json_obj
,res_req out tk_json_obj
,choices out tk_json_obj
,alerts out tk_json_obj
,err_log out tk_json_obj)
as
  l_chk_auth number;
  l_chk_req number;
  l_save_que number;
  l_post_run number;
  l_proc_allow number;
  l_check_var number;

  l_timer_start number;
  l_timer_end number;

begin

  l_timer_start := to_char(systimestamp,'YYYYMMDDHH24MISS.FF6');

  --p_write_err($$plsql_line,'REQUEST : RUN '||to_char(systimestamp,'YYYY.MM.DD.HH24.MI.SS.FF6'));
  g_json_req := p_req_in; -- 1
/*
  p_write_err($$plsql_line,'REQUEST');
  p_write_err($$plsql_line,'a '||g_json_req.a);
  p_write_err($$plsql_line,'b '||g_json_req.b);
  p_write_err($$plsql_line,'c '||g_json_req.c);
  p_write_err($$plsql_line,'d '||g_json_req.d);
  p_write_err($$plsql_line,'e '||g_json_req.e);
  p_write_err($$plsql_line,'f '||g_json_req.f);
  p_write_err($$plsql_line,'g '||g_json_req.g);
  p_write_err($$plsql_line,'i '||g_json_req.i);
  p_write_err($$plsql_line,'k '||g_json_req.k);
  p_write_err($$plsql_line,'owner_data.count '||g_json_req.owner_data.count);
  p_write_err($$plsql_line,'res_req.count '||g_json_req.res_reply.count);
*/
  l_check_var := f_check_auth; -- 2

  if l_check_var = 1 then
    l_check_var := f_proc_allow(g_json_req.a,g_json_req.d);
     --> p_write_err($$plsql_line,'REQUEST : CHECKPOINT');
    if l_check_var = 1 then
       --> p_write_err($$plsql_line,'REQUEST : CHECKPOINT');
      l_check_var := f_check_req;
      if l_check_var = 1 then
         --> p_write_err($$plsql_line,'REQUEST : CHECKPOINT');
        l_check_var := f_save_queue;
      end if;
    end if;
  end if;

  --p_write_err($$plsql_line,'REQUEST : CHECKPOINT - '||g_inst.id_process||':'||g_inst.id_record);
  -- load the process and the instance data 
--  dbms_output.put_line($$plsql_unit||'.'||$$plsql_line||' : '||g_inst.id_process);
--  dbms_output.put_line($$plsql_unit||'.'||$$plsql_line||' : '||g_inst.id_record);
  p_load_proc_meta(g_inst.id_process,g_inst.id_record);

   --> p_write_err($$plsql_line,'REQUEST : CHECKPOINT');

--> run the main program with the instance id as the input
  -- taking into account the inputs from the request
  -- do not run if resource reponse is present
  -- check any assignment response to see if condition amount is satisfied

--  dbms_output.put_line($$plsql_line||': '||g_instance.id_record);
--  dbms_output.put_line($$plsql_line||': '||g_instance.id_process);

  relay_p_workflow.run_workflow
  (p_id_instance => g_instance.id_record
  ,p_id_link => g_json_req.g
  ,p_id_assign => g_json_req.f);

  if l_check_var = 1 then
    -- check and retrieve queue data
    l_post_run := f_get_post_run;

    l_timer_end := to_char(systimestamp,'YYYYMMDDHH24MISS.FF6');
    p_write_err($$plsql_line,'Execution Time (internal) : '||to_char(l_timer_end-l_timer_start)||' (sec)');
  end if;

  a := g_a;
  b := g_b;
  d := g_d;
  e := g_e;
  h := g_h;
  i := g_i;
  j := g_j;
  k := g_k;
  owner_data := g_owner_data;
  assignments := g_assignments;
  res_req := g_res_req; -- not implemented
  choices := g_choices;
  alerts := g_alerts; -- not implemented
  err_log := g_err_log;
/*  
  p_write_err($$plsql_line,'RESPONSE');
  p_write_err($$plsql_line,'a '||a);
  p_write_err($$plsql_line,'b '||b);
  p_write_err($$plsql_line,'d '||d);
  p_write_err($$plsql_line,'e '||e);
  p_write_err($$plsql_line,'h '||h);
  p_write_err($$plsql_line,'i '||i);
  p_write_err($$plsql_line,'j '||j);
  p_write_err($$plsql_line,'k '||k);
  p_write_err($$plsql_line,'owner_data.count '||owner_data.count);
  p_write_err($$plsql_line,'assignments.count '||assignments.count);
  p_write_err($$plsql_line,'res_req.count '||res_req.count);
  p_write_err($$plsql_line,'choices.count '||choices.count);
  p_write_err($$plsql_line,'alerts.count '||alerts.count);
  p_write_err($$plsql_line,'err_log.count '||err_log.count);
*/  
  g_errlog_ex := f_get_errlog;

--  dbms_output.put_line(g_errlog_ex);

  insert into awf_error_log
  (id_record,error_log,date_log)
  values 
  (to_char(sysdate,'YYYYMMDDSSSSS'),g_errlog_ex,sysdate);
  err_log := g_err_log;

exception
  when others then
    g_errlog_ex := f_get_errlog;

--    dbms_output.put_line(g_errlog_ex);

    insert into awf_error_log
    (id_record,error_log,date_log)
    values 
    (to_char(sysdate,'YYYYMMDDSSSSS'),DBMS_UTILITY.FORMAT_ERROR_STACK||chr(10)||dbms_utility.format_error_backtrace||chr(10)||g_errlog_ex,sysdate);
    err_log := g_err_log;

    raise;
end;
------------------------------------------------------------------------
procedure p_get_instance
(p_id_request in varchar2
,a out varchar2
,b out varchar2
,d out varchar2
,e out varchar2
,h out varchar2
,i out varchar2
,j out varchar2
,k out varchar2
,owner_data out tk_json_obj
,assignments out tk_json_obj
,res_req out tk_json_obj
,choices out tk_json_obj
,alerts out tk_json_obj
,err_log out tk_json_obj)
as

  l_post_run number;

begin

  l_post_run := f_get_post_run(p_id_request);

  a := g_a;
  b := g_b;
  d := g_d;
  e := g_e;
  h := g_h;
  i := g_i;
  j := g_j;
  k := g_k;
  owner_data := g_owner_data;
  assignments := g_assignments;
  res_req := g_res_req; -- not implemented
  choices := g_choices;
  alerts := g_alerts; -- not implemented
  err_log := g_err_log;

exception 
  when others then 
    raise;
end;
------------------------------------------------------------------------
procedure p_kill_instance
(p_id_request in varchar2)
as
  l_id_queue number;
begin

  select id_record
  into l_id_queue
  from tk_fqueue
  where id_request = p_id_request;

  delete from awf_instance
  where id_record = l_id_queue;

  delete from awf_instance_state
  where id_instance = l_id_queue;

  delete from awf_inst_vars
  where id_instance = l_id_queue;

  delete from awf_inst_node_links
  where id_instance = l_id_queue;

  delete from awf_inst_log
  where id_instance = l_id_queue;

  delete from awf_inst_vars
  where id_instance = l_id_queue;

  delete from awf_inst_data
  where id_instance = l_id_queue;

  delete from awf_inst_assign
  where id_instance = l_id_queue;

  delete from awf_wf_record
  where id_instance = l_id_queue;

end;
------------------------------------------------------------------------
end;

/
