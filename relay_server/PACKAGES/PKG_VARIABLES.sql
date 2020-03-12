--------------------------------------------------------
--  DDL for Package PKG_VARIABLES
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "PKG_VARIABLES" as 
--WORKFLOW-VARIBALES---------------------------------------------------------------------
  g_imp_content blob;

  g_ind_run_code number := 0;
  g_lic_status varchar2(1000); --null;
  g_cert_key varchar2(1000) := null;

  g_wsc_src number := 1000;

  type ai_data_r is record (obj_owner awf_process.obj_owner%type
                           ,obj_name  awf_process.obj_name%type
                           ,id_owner  awf_instance.id_owner%type
                           ,owner_rowid rowid
                           ,id_enabled_object number --awf_eo.id_record%type
                           ,wfid_col  varchar2(50) --awf_eo.WFID%type
                           ,id_c_node awf_node.id_proc_rec%type
                           ,id_process awf_process.id_record%type
                           ,id_link_fwd awf_instance_state.id_link_fwd%type
                           ,ind_ui_reqd awf_instance_state.ind_ui_reqd%type
                           ,date_set awf_instance_state.date_set%type
                           ,workflow_index number
                           ,instance_log clob
                           ,error_log clob);
  type ai_data_t is table of ai_data_r index by pls_integer; 
  g_ai_data ai_data_t;

  g_wf_continue number := 0;
  g_wf_inbox number := 0;

  g_active_instance awf_instance.id_record%type;

  type t_io_values is table of awf_inst_vars%rowtype index by varchar2(128);
  type tt_io_values is table of t_io_values index by pls_integer;
  g_inst_own_values tt_io_values;

  type t_active_pv is table of sys.anydata index by varchar2(100);
  g_debug varchar2(100); -- := 'DEBUG'; --> TODO Set from Application

  type t_ei_set is table of awf_ei_text%rowtype index by varchar2(1000);
  g_ei_set t_ei_set;

  -- limit to the number of times a component of a flow can be used before 
  -- the system declares an uncontrolled cycle event (UCD) 
  g_ucd_limit number := 100;

--RESOURCE-VARIABLES---------------------------------------------------------------------
  g_person tt_person;
  g_person_group tt_person_group;
  g_group_member tt_group_member;
  g_roles tt_roles;
  g_active_process number;

  g_user_obj tt_all_obj;
  g_user_tab_cols tt_all_tab_cols;
  g_user_ident tt_all_ident;

  g_apps tt_app;
  g_pages tt_page;
  g_items tt_item;
-----------------------------------------------------------------------------------------    
function f_get_rel_role
(p_input in varchar2)
return varchar2;

function f_conv_to_ue
(p_input date)
return number;

function f_conv_hex
(p_input number)
return varchar2;
-----------------------------------------------------------------------------------------  
end pkg_variables;

/
