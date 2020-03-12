--------------------------------------------------------
--  DDL for Package PKG_REST_SVCS
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "PKG_REST_SVCS" as 
------------------------------------------------------------------------
g_json_req tk_json_request;
g_json_resp tk_json_response;

g_ind_op number; -- move to pkg_variables

--BEGIN-PROCESSING-VARIABLES----------------------------------------------------

  g_proc_set tt_vc2 := tt_vc2();

  type t_coll_ref1 is table of number index by varchar2(50);
  type t_coll_ref2 is table of t_coll_ref1 index by varchar2(50); 
  type t_coll_ref3 is table of t_coll_ref2 index by varchar2(50); 
  type t_coll_ref4 is table of t_coll_ref3 index by varchar2(50);

  g_pdl_idx number;
  g_lvl3_idx number := 0;

  g_proc_alt1 t_coll_ref1; -- collection(id_process):index
  g_pvar_alt1 t_coll_ref2; -- collection(id_process)(id_proc_rec):index
  g_node_alt1 t_coll_ref2; -- collection(id_process)(id_proc_rec):index
  g_nact_alt1 t_coll_ref2; -- collection(id_process)(id_proc_rec):index
  g_nact_alt2 t_coll_ref3; -- collection(id_process)(id_node_number)(lvl3_idx):index
  g_nass_alt1 t_coll_ref2; -- collection(id_process)(id_proc_rec):index
  g_nass_alt2 t_coll_ref3; -- collection(id_process)(node_number)(lvl3_idx):index
  g_nlin_alt1 t_coll_ref2; -- collection(id_process)(id_proc_rec):index
  g_nlin_alt2 t_coll_ref3; -- collection(id_process)(id_parent_node)(lvl3_idx):index
  g_nlin_alt3 t_coll_ref4; -- collection(id_process)(id_parent_node)(pos/neg)(lvl3_idx):index
  g_cond_alt2 t_coll_ref3; -- collection(id_process)(id_proc_rec)(lvl3_idx):index
  g_act_alt1 t_coll_ref2; -- collection(id_process)(action_name):index
  g_apv_alt1 t_coll_ref3; -- collection(id_process)(action_name)(act_parameter):index
  g_apv_alt2 t_coll_ref3; -- collection(id_process)(action_name)(lvl3_idx):index
  g_temp_alt1 t_coll_ref2; -- collection(id_process)(id_template):index
  g_send_alt1 t_coll_ref3; -- collection(id_process)(id_template)(lvl3_idx):index
  g_role_alt1 t_coll_ref1; -- collection(id_record):index
  g_role_alt2 t_coll_ref1; -- collection(role_name):index
  g_pers_alt1 t_coll_ref2; -- collection(id_role)(id_person):index
  g_pers_alt2 t_coll_ref2; -- collection(id_role)(person_code):index

  type t_process is table of vw_proc_proc%rowtype index by pls_integer;
  g_process t_process;
  type t_proc_var is table of awf_proc_vars%rowtype index by pls_integer;
  g_proc_var t_proc_var;
  type t_node is table of awf_node%rowtype index by pls_integer;
  g_node t_node;
  type t_naction is table of awf_node_action%rowtype index by pls_integer;
  g_naction t_naction;
  type t_nassign is table of awf_node_assignment%rowtype index by pls_integer;
  g_nassign t_nassign;
  type t_nlink is table of awf_node_link%rowtype index by pls_integer;
  g_nlink t_nlink;
  type t_cond is table of awf_conditions%rowtype index by pls_integer;
  g_cond t_cond;
  type t_action is table of vw_proc_actions%rowtype index by pls_integer;
  g_action t_action;
  type t_act_pv is table of vw_proc_actpv%rowtype index by pls_integer;
  g_act_pv t_act_pv;
  type t_comm_temp is table of vw_proc_comm%rowtype index by pls_integer;
  g_comm_temp t_comm_temp;
  type t_comm_send is table of vw_proc_send%rowtype index by pls_integer;
  g_comm_send t_comm_send;
  type t_roles is table of awf_roles%rowtype index by pls_integer;
  g_roles t_roles;
  type t_person is table of vw_proc_person%rowtype index by pls_integer;
  g_person t_person;

  type t_proc_rec is table of vw_process_records%rowtype index by pls_integer;
  g_proc_rec t_proc_rec;

  type t_proc_roles is table of vw_process_roles%rowtype index by pls_integer;
  g_proc_roles t_proc_roles;
  g_prole_alt1 t_coll_ref4; -- g_prole_alt1(id_process)(rectype)(rid)(lvl3_idx):index

  g_instance awf_instance%rowtype;
  g_inst_ind number;

  g_inst_state awf_instance_state%rowtype;
  g_inst_state_ind number;

  type t_inst_vars is table of awf_inst_vars%rowtype index by pls_integer;
  g_inst_vars t_inst_vars;
  g_inst_vars_ind number := 0; -- indicator set if data changed
  g_inst_vars_del number := 0; -- indicator to delete the instance variables in clean-up
  g_ivar_alt1 t_coll_ref2; -- collection(id_instance)(var_name):index

  type t_inst_assign is table of awf_inst_assign%rowtype index by pls_integer;
  g_inst_assign t_inst_assign;
  g_inst_assign_ind number := 0; -- indicator set if data changed
  g_iass_alt1 t_coll_ref2; -- collection(id_instance)(id_record):index

  type t_inst_data is table of awf_inst_data%rowtype index by pls_integer;
  g_inst_data t_inst_data := t_inst_data();
  g_inst_data_ind number := 0; -- indicator set if data changed
  g_inst_data_alt1 t_coll_ref1; -- collection(var_name):index

  type t_inst_links is table of awf_inst_node_links%rowtype index by pls_integer;
  g_inst_links t_inst_links := t_inst_links();
  g_inst_links_ind varchar2(1); -- I/D
------------------------------------------------------------------------

function f_guid_gen 
return varchar2;

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
,err_log out tk_json_obj);

procedure p_load_proc_meta
(p_id_process in number
,p_id_instance in number);

function f_get_auth
(p_user_name in varchar2)
return varchar2;

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
,err_log out tk_json_obj);

procedure p_kill_instance
(p_id_request in varchar2);

------------------------------------------------------------------------  
end;

/
