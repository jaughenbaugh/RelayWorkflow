--------------------------------------------------------
--  DDL for Package PKG_AWF_API
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "PKG_AWF_API" as
--------------------------------------------------------------------------------
function f_get_version
return varchar2;

  PROCEDURE p_AWF_ACTION(
    p_id_record        IN OUT awf_action.id_record%type ,
    p_action_name      IN OUT awf_action.action_name%type ,
    p_description      IN OUT awf_action.description%type ,
    p_obj_owner        IN OUT awf_action.obj_owner%type ,
    p_obj_name         IN OUT awf_action.obj_name%type ,
    p_code_action_type IN OUT awf_action.code_action_type%type ,
    p_id_template      IN OUT awf_action.id_template%type ,
    p_prog_owner       IN OUT awf_action.prog_owner%type ,
    p_prog_name        IN OUT awf_action.prog_name%type ,
    p_prog_type        IN OUT awf_action.prog_type%type ,
    p_func_retvar_name IN OUT awf_action.func_retvar_name%type ,
    p_func_retvar_type IN OUT awf_action.func_retvar_type%type ,
    p_id_check_stamp   IN OUT awf_action.id_check_stamp%type ,
    p_ind_save_data    IN OUT awf_action.ind_save_data%type ,
    p_id_row           IN VARCHAR2 ,
    p_operation        IN VARCHAR2);

  PROCEDURE p_AWF_ACTION_PV(
    p_id_record       IN OUT awf_action_pv.id_record%type ,
    p_id_check_stamp  IN OUT awf_action_pv.id_check_stamp%type ,
    p_id_sequence     IN OUT awf_action_pv.id_sequence%type ,
    p_act_parameter   IN OUT awf_action_pv.act_parameter%type ,
    p_act_param_type  IN OUT awf_action_pv.act_param_type%type ,
    p_act_param_dir   IN OUT awf_action_pv.act_param_dir%type ,
    p_act_value       IN OUT CLOB ,
    p_obj_owner       IN OUT awf_action_pv.obj_owner%type ,
    p_obj_name        IN OUT awf_action_pv.obj_name%type ,
    p_action_name     IN OUT awf_action_pv.action_name%type ,
    p_act_par_target  IN OUT awf_action_pv.act_par_target%type ,
    p_var_source_type IN OUT awf_action_pv.var_source_type%type ,
    p_id_row          IN VARCHAR2 ,
    p_operation       IN VARCHAR2);

  PROCEDURE p_AWF_AD_METHODS(
    p_id_record      IN OUT awf_ad_methods.id_record%type ,
    p_id_check_stamp IN OUT awf_ad_methods.id_check_stamp%type ,
    p_code_datatype  IN OUT awf_ad_methods.code_datatype%type ,
    p_ad_access      IN OUT awf_ad_methods.ad_access%type ,
    p_ad_convert     IN OUT awf_ad_methods.ad_convert%type ,
    p_ind_common_dt  IN OUT awf_ad_methods.ind_common_dt%type ,
    p_id_row         IN VARCHAR2 ,
    p_operation      IN VARCHAR2);

  PROCEDURE p_AWF_COMM_SEND_TO(
    p_id_record        IN OUT awf_comm_send_to.id_record%type ,
    p_id_template      IN OUT awf_comm_send_to.id_template%type ,
    p_send_to_type     IN OUT awf_comm_send_to.send_to_type%type ,
    p_send_to_group    IN OUT awf_comm_send_to.send_to_group%type ,
    p_send_to          IN OUT awf_comm_send_to.send_to%type ,
    p_id_check_stamp   IN OUT awf_comm_send_to.id_check_stamp%type ,
    p_id_row           IN VARCHAR2 ,
    p_operation        IN VARCHAR2);

  PROCEDURE p_AWF_COMM_TEMPLATE(
    p_id_record         IN OUT awf_comm_template.id_record%type ,
    p_template_name     IN OUT awf_comm_template.template_name%type ,
    p_description       IN OUT awf_comm_template.description%type ,
    p_obj_owner         IN OUT awf_comm_template.obj_owner%type ,
    p_object_name       IN OUT awf_comm_template.object_name%type ,
    p_send_from_email   IN OUT awf_comm_template.send_from_email%type ,
    p_reply_to_email    IN OUT awf_comm_template.reply_to_email%type ,
    p_subject_line      IN OUT awf_comm_template.subject_line%type ,
    p_message_body_pt   IN OUT awf_comm_template.message_body_pt%type ,
    p_message_body_html IN OUT awf_comm_template.message_body_html%type ,
    p_id_check_stamp    IN OUT awf_comm_template.id_check_stamp%type ,
    p_id_row            IN VARCHAR2 ,
    p_operation         IN VARCHAR2);

  PROCEDURE p_AWF_CONDITIONS(
    p_id_record       IN OUT awf_conditions.id_record%type ,
    p_condition       IN OUT awf_conditions.condition%type ,
    p_id_relationship IN OUT awf_conditions.id_relationship%type ,
    p_obj_owner       IN OUT awf_conditions.obj_owner%type ,
    p_object          IN OUT awf_conditions.object%type ,
    p_ind_must_be     IN OUT awf_conditions.ind_must_be%type ,
    p_id_process      IN OUT awf_conditions.id_process%type ,
    p_id_proc_rec     IN OUT awf_conditions.id_proc_rec%type ,
    p_id_check_stamp  IN OUT awf_conditions.id_check_stamp%type ,
    p_id_row          IN VARCHAR2 ,
    p_operation       IN VARCHAR2);

  PROCEDURE p_AWF_D2D_DATA(
    p_id_record       IN OUT awf_d2d_data.id_record%type ,
    p_id_check_stamp  IN OUT awf_d2d_data.id_check_stamp%type ,
    p_type_record     IN OUT awf_d2d_data.type_record%type ,
    p_id_shape        IN OUT awf_d2d_data.id_shape%type ,
    p_id_port         IN OUT awf_d2d_data.id_port%type ,
    p_port_seq        IN OUT awf_d2d_data.port_seq%type ,
    p_link_type       IN OUT awf_d2d_data.link_type%type ,
    p_type            IN OUT awf_d2d_data.type%type ,
    p_id              IN OUT awf_d2d_data.id%type ,
    p_x               IN OUT awf_d2d_data.x%type ,
    p_y               IN OUT awf_d2d_data.y%type ,
    p_width           IN OUT awf_d2d_data.width%type ,
    p_height          IN OUT awf_d2d_data.height%type ,
    p_alpha           IN OUT awf_d2d_data.alpha%type ,
    p_angle           IN OUT awf_d2d_data.angle%type ,
    p_userdata        IN OUT awf_d2d_data.userdata%type ,
    p_cssclass        IN OUT awf_d2d_data.cssclass%type ,
    p_bgcolor         IN OUT awf_d2d_data.bgcolor%type ,
    p_color           IN OUT awf_d2d_data.color%type ,
    p_stroke          IN OUT awf_d2d_data.stroke%type ,
    p_dasharray       IN OUT awf_d2d_data.dasharray%type ,
    p_maxfanout       IN OUT awf_d2d_data.maxfanout%type ,
    p_name            IN OUT awf_d2d_data.name%type ,
    p_port            IN OUT awf_d2d_data.port%type ,
    p_locator         IN OUT awf_d2d_data.locator%type ,
    p_radius          IN OUT awf_d2d_data.radius%type ,
    p_ind_is_positive IN OUT awf_d2d_data.ind_is_positive%type ,
    p_path            IN OUT awf_d2d_data.path%type ,
    p_shape_type      IN OUT awf_d2d_data.shape_type%type ,
    p_router          IN OUT awf_d2d_data.router%type ,
    p_policy          IN OUT awf_d2d_data.policy%type ,
    p_outlinecolor    IN OUT awf_d2d_data.outlinecolor%type ,
    p_outlinestroke   IN OUT awf_d2d_data.outlinestroke%type ,
    p_id_row          IN VARCHAR2 ,
    p_operation       IN VARCHAR2);

  PROCEDURE p_AWF_DATATYPES(
    p_id_record      IN OUT awf_datatypes.id_record%type ,
    p_data_type      IN OUT awf_datatypes.data_type%type ,
    p_id_check_stamp IN OUT awf_datatypes.id_check_stamp%type ,
    p_id_row         IN VARCHAR2 ,
    p_operation      IN VARCHAR2);

  PROCEDURE p_AWF_DT_FUNC(
    p_id_record      IN OUT awf_dt_func.id_record%type ,
    p_id_datatype    IN OUT awf_dt_func.id_datatype%type ,
    p_id_function    IN OUT awf_dt_func.id_function%type ,
    p_id_check_stamp IN OUT awf_dt_func.id_check_stamp%type ,
    p_id_row         IN VARCHAR2 ,
    p_operation      IN VARCHAR2);

  PROCEDURE p_AWF_ERROR_LOG(
    p_id_record   IN OUT awf_error_log.id_record%type ,
    p_id_instance IN OUT awf_error_log.id_instance%type ,
    p_id_wf_run   IN OUT awf_error_log.id_wf_run%type ,
    p_error_log   IN OUT awf_error_log.error_log%type ,
    p_date_log    IN OUT awf_error_log.date_log%type ,
    p_id_stamp    IN OUT awf_error_log.id_stamp%type ,
    p_id_row      IN VARCHAR2 ,
    p_operation   IN VARCHAR2);

  PROCEDURE p_AWF_FUNCTION(
    p_id_record      IN OUT awf_function.id_record%type ,
    p_function       IN OUT awf_function.function%type ,
    p_description    IN OUT awf_function.description%type ,
    p_id_check_stamp IN OUT awf_function.id_check_stamp%type ,
    p_ind_dateformat IN OUT awf_function.ind_dateformat%type ,
    p_id_row         IN VARCHAR2 ,
    p_operation      IN VARCHAR2);

  PROCEDURE p_AWF_GROUP_MEMBERS(
    p_id_record         IN OUT awf_group_members.id_record%type ,
    p_id_person_group   IN OUT awf_group_members.id_person_group%type ,
    p_id_delegate_of    IN OUT awf_group_members.id_delegate_of%type ,
    p_member_sequence   IN OUT awf_group_members.member_sequence%type ,
    p_ind_group_default IN OUT awf_group_members.ind_group_default%type ,
    p_id_group_member   IN OUT awf_group_members.id_group_member%type ,
    p_id_check_stamp    IN OUT awf_group_members.id_check_stamp%type ,
    p_id_row            IN VARCHAR2 ,
    p_operation         IN VARCHAR2);

  PROCEDURE p_AWF_INSTANCE(
    p_id_record      IN OUT awf_instance.id_record%type ,
    p_id_parent      IN OUT awf_instance.id_parent%type ,
    p_ind_active     IN OUT awf_instance.ind_active%type ,
    p_instance_orig  IN OUT awf_instance.instance_orig%type ,
    p_date_start     IN OUT awf_instance.date_start%type ,
    p_id_process     IN OUT awf_instance.id_process%type ,
    p_id_owner       IN OUT awf_instance.id_owner%type ,
    p_id_check_stamp IN OUT awf_instance.id_check_stamp%type ,
    p_instance_log   IN OUT awf_instance.instance_log%type ,
    p_id_row         IN VARCHAR2 ,
    p_operation      IN VARCHAR2);

  PROCEDURE p_AWF_INSTANCE_STATE(
    p_id_record      IN OUT awf_instance_state.id_record%type ,
    p_id_instance    IN OUT awf_instance_state.id_instance%type ,
    p_node_number    IN OUT awf_instance_state.node_number%type ,
    p_node_status    IN OUT awf_instance_state.node_status%type ,
    p_ind_active     IN OUT awf_instance_state.ind_active%type ,
    p_id_process     IN OUT awf_instance_state.id_process%type ,
    p_date_set       IN OUT awf_instance_state.date_set%type ,
    p_ind_ui_reqd    IN OUT awf_instance_state.ind_ui_reqd%type ,
    p_id_link_fwd    IN OUT awf_instance_state.id_link_fwd%type ,
    p_id_check_stamp IN OUT awf_instance_state.id_check_stamp%type ,
    p_id_row         IN VARCHAR2 ,
    p_operation      IN VARCHAR2);

  PROCEDURE p_AWF_INST_ASSIGN(
    p_id_record      IN OUT awf_inst_assign.id_record%type ,
    p_priority       IN OUT awf_inst_assign.priority%type ,
    p_id_assignee    IN OUT awf_inst_assign.id_assignee%type ,
    p_date_start     IN OUT awf_inst_assign.date_start%type ,
    p_date_due       IN OUT awf_inst_assign.date_due%type ,
    p_code_status    IN OUT awf_inst_assign.code_status%type ,
    p_id_instance    IN OUT awf_inst_assign.id_instance%type ,
    p_id_process     IN OUT awf_inst_assign.id_process%type ,
    p_id_proc_rec    IN OUT awf_inst_assign.id_proc_rec%type ,
    p_ind_decision   in out awf_inst_assign.ind_decision%type ,
    p_id_check_stamp in out awf_inst_assign.id_check_stamp%type,
    p_person_code in out awf_inst_assign.person_code%type ,
    p_id_row         IN VARCHAR2 ,
    p_operation      IN VARCHAR2);

  PROCEDURE p_AWF_INST_ASSIGN_STATUS(
    p_id_record      IN OUT awf_inst_assign_status.id_record%type ,
    p_id_assignment  IN OUT awf_inst_assign_status.id_assignment%type ,
    p_date_status    IN OUT awf_inst_assign_status.date_status%type ,
    p_code_status    IN OUT awf_inst_assign_status.code_status%type ,
    p_id_check_stamp IN OUT awf_inst_assign_status.id_check_stamp%type ,
    p_id_row         IN VARCHAR2 ,
    p_operation      IN VARCHAR2);

  PROCEDURE p_AWF_INST_LOG(
    p_id_instance       IN OUT awf_inst_log.id_instance%type ,
    p_id_workflow_index IN OUT awf_inst_log.id_workflow_index%type ,
    p_id_seq            IN OUT awf_inst_log.id_seq%type ,
    p_runtime_id        IN OUT awf_inst_log.runtime_id%type ,
    p_program_unit      IN OUT awf_inst_log.program_unit%type ,
    p_position          IN OUT awf_inst_log.position%type ,
    p_program           IN OUT awf_inst_log.program%type ,
    p_log_type          IN OUT awf_inst_log.log_type%type ,
    p_log_entry         IN OUT awf_inst_log.log_entry%type ,
    p_log_time          IN OUT awf_inst_log.log_time%type ,
    p_id_row            IN VARCHAR2 ,
    p_operation         IN VARCHAR2);

  PROCEDURE p_AWF_INST_NODE_LINKS(
    p_id_record      IN OUT awf_inst_node_links.id_record%type ,
    p_id_check_stamp IN OUT awf_inst_node_links.id_check_stamp%type ,
    p_id_instance    IN OUT awf_inst_node_links.id_instance%type ,
    p_id_node        IN OUT awf_inst_node_links.id_node%type ,
    p_id_link        IN OUT awf_inst_node_links.id_link%type ,
    p_link_sequence  IN OUT awf_inst_node_links.link_sequence%type ,
    p_id_row         IN VARCHAR2 ,
    p_operation      IN VARCHAR2);

  PROCEDURE p_AWF_INST_VARS(
    p_id_record      IN OUT awf_inst_vars.id_record%type ,
    p_id_instance    IN OUT awf_inst_vars.id_instance%type ,
    p_var_type       IN OUT awf_inst_vars.var_type%type ,
    p_var_name       IN OUT awf_inst_vars.var_name%type ,
    p_var_value      IN OUT CLOB ,
    p_var_source     IN OUT awf_inst_vars.var_source%type ,
    p_var_sequence   IN OUT awf_inst_vars.var_sequence%type ,
    p_id_check_stamp IN OUT awf_inst_vars.id_check_stamp%type ,
    p_id_row         IN VARCHAR2 ,
    p_operation      IN VARCHAR2);

  PROCEDURE p_AWF_NODE(
    p_id_record       IN OUT awf_node.id_record%type ,
    p_id_process      IN OUT awf_node.id_process%type ,
    p_id_proc_rec     IN OUT awf_node.id_proc_rec%type ,
    p_node_type       IN OUT awf_node.node_type%type ,
    p_layout_column   IN OUT awf_node.layout_column%type ,
    p_layout_row      IN OUT awf_node.layout_row%type ,
    p_node_name       IN OUT awf_node.node_name%type ,
    p_description     IN OUT awf_node.description%type ,
    p_ind_disp_if_one IN OUT awf_node.ind_disp_if_one%type ,
    p_amt_for_true    IN OUT awf_node.amt_for_true%type ,
    p_interval        IN OUT awf_node.interval%type ,
    p_interval_uom    IN OUT awf_node.interval_uom%type ,
    p_ind_continue    IN OUT awf_node.ind_continue%type ,
    p_id_subprocess   IN OUT awf_node.id_subprocess%type ,
    p_id_check_stamp  IN OUT awf_node.id_check_stamp%type ,
    p_id_row          IN VARCHAR2 ,
    p_operation       IN VARCHAR2);

  PROCEDURE p_AWF_NODE_ACTION(
    p_id_record         IN OUT awf_node_action.id_record%type ,
    p_action_name       IN OUT awf_node_action.action_name%type ,
    p_id_relationship   IN OUT awf_node_action.id_relationship%type ,
    p_sequence          IN OUT awf_node_action.sequence%type ,
    p_amt_for_true      IN OUT awf_node_action.amt_for_true%type ,
    p_ind_stop_on_error IN OUT awf_node_action.ind_stop_on_error%type ,
    p_id_process        IN OUT awf_node_action.id_process%type ,
    p_id_proc_rec       IN OUT awf_node_action.id_proc_rec%type ,
    p_id_node_number    IN OUT awf_node_action.id_node_number%type ,
    p_id_check_stamp    IN OUT awf_node_action.id_check_stamp%type ,
    p_id_row            IN VARCHAR2 ,
    p_operation         IN VARCHAR2);

  PROCEDURE p_AWF_NODE_ASSIGNMENT(
    p_id_record           IN OUT awf_node_assignment.id_record%type ,
    p_description         IN OUT awf_node_assignment.description%type ,
    p_priority            IN OUT awf_node_assignment.priority%type ,
    p_ind_notify_by_email IN OUT awf_node_assignment.ind_notify_by_email%type ,
    p_node_number         IN OUT awf_node_assignment.node_number%type ,
    p_id_role             IN OUT awf_node_assignment.id_role%type ,
    p_id_escrole          IN OUT awf_node_assignment.id_escrole%type ,
    p_id_email_template   IN OUT awf_node_assignment.id_email_template%type ,
    p_id_process          IN OUT awf_node_assignment.id_process%type ,
    p_id_proc_rec         IN OUT awf_node_assignment.id_proc_rec%type ,
    p_amt_for_true        IN OUT awf_node_assignment.amt_for_true%type ,
    p_id_check_stamp      IN OUT awf_node_assignment.id_check_stamp%type ,
    p_id_row              IN VARCHAR2 ,
    p_operation           IN VARCHAR2);

  PROCEDURE p_AWF_NODE_LINK(
    p_id_record       IN OUT awf_node_link.id_record%type ,
    p_id_parent_node  IN OUT awf_node_link.id_parent_node%type ,
    p_id_child_node   IN OUT awf_node_link.id_child_node%type ,
    p_description     IN OUT awf_node_link.description%type ,
    p_ind_is_positive IN OUT awf_node_link.ind_is_positive%type ,
    p_sequence        IN OUT awf_node_link.sequence%type ,
    p_amt_for_true    IN OUT awf_node_link.amt_for_true%type ,
    p_id_process      IN OUT awf_node_link.id_process%type ,
    p_id_proc_rec     IN OUT awf_node_link.id_proc_rec%type ,
    p_id_check_stamp  IN OUT awf_node_link.id_check_stamp%type ,
    p_id_row          IN VARCHAR2 ,
    p_operation       IN VARCHAR2);

  PROCEDURE p_AWF_NODE_LINK_VERTEX(
    p_id_record      IN OUT awf_node_link_vertex.id_record%type ,
    p_id_process     IN OUT awf_node_link_vertex.id_process%type ,
    p_id_proc_rec    IN OUT awf_node_link_vertex.id_proc_rec%type ,
    p_vertex_seq     IN OUT awf_node_link_vertex.vertex_seq%type ,
    p_x_pos          IN OUT awf_node_link_vertex.x_pos%type ,
    p_y_pos          IN OUT awf_node_link_vertex.y_pos%type ,
    p_id_check_stamp IN OUT awf_node_link_vertex.id_check_stamp%type ,
    p_id_row         IN VARCHAR2 ,
    p_operation      IN VARCHAR2);

  PROCEDURE p_AWF_NODE_SUBPROCESS(
    p_id_record      IN OUT awf_node_subprocess.id_record%type ,
    p_id_check_stamp IN OUT awf_node_subprocess.id_check_stamp%type ,
    p_id_process     IN OUT awf_node_subprocess.id_process%type ,
    p_id_proc_rec    IN OUT awf_node_subprocess.id_proc_rec%type ,
    p_id_node        IN OUT awf_node_subprocess.id_node%type ,
    p_id_subprocess  IN OUT awf_node_subprocess.id_subprocess%type ,
    p_exec_action    IN OUT awf_node_subprocess.exec_action%type ,
    p_subprocess_seq IN OUT awf_node_subprocess.subprocess_seq%type ,
    p_id_row         IN VARCHAR2 ,
    p_operation      IN VARCHAR2);

  PROCEDURE p_AWF_PARAMETERS(
    p_id_record       IN OUT awf_parameters.id_record%type ,
    p_id_check_stamp  IN OUT awf_parameters.id_check_stamp%type ,
    p_parameter_name  IN OUT awf_parameters.parameter_name%type ,
    p_parameter_value IN OUT CLOB ,
    p_description     IN OUT awf_parameters.description%type ,
    p_id_row          IN VARCHAR2 ,
    p_operation       IN VARCHAR2);

  PROCEDURE p_AWF_PERSON(
    p_id_record           IN OUT awf_person.id_record%type ,
    p_person_code         IN OUT awf_person.person_code%type ,
    p_status              IN OUT awf_person.status%type ,
    p_display_name        IN OUT awf_person.display_name%type ,
    p_first_name          IN OUT awf_person.first_name%type ,
    p_last_name           IN OUT awf_person.last_name%type ,
    p_id_delegate         IN OUT awf_person.id_delegate%type ,
    p_date_delagate_start IN OUT awf_person.date_delagate_start%type ,
    p_date_delegate_end   IN OUT awf_person.date_delegate_end%type ,
    p_date_status         IN OUT awf_person.date_status%type ,
    p_email_address       IN OUT awf_person.email_address%type ,
    p_id_check_stamp      IN OUT awf_person.id_check_stamp%type ,
    p_id_row              IN VARCHAR2 ,
    p_operation           IN VARCHAR2);

  PROCEDURE p_AWF_PERSON_GROUP(
    p_id_record      IN OUT awf_person_group.id_record%type ,
    p_group_name     IN OUT awf_person_group.group_name%type ,
    p_description    IN OUT awf_person_group.description%type ,
    p_group_status   IN OUT awf_person_group.group_status%type ,
    p_id_check_stamp IN OUT awf_person_group.id_check_stamp%type ,
    p_id_row         IN VARCHAR2 ,
    p_operation      IN VARCHAR2);

  PROCEDURE p_AWF_PROCESS(
    p_id_record           IN OUT awf_process.id_record%type ,
    p_id_base_process     IN OUT awf_process.id_base_process%type ,
    p_process_name        IN OUT awf_process.process_name%type ,
    p_description         IN OUT awf_process.description%type ,
    p_proc_revision       IN OUT awf_process.proc_revision%type ,
    p_id_revised_from     IN OUT awf_process.id_revised_from%type ,
    p_id_role             IN OUT awf_process.id_role%type ,
    p_obj_owner           IN OUT awf_process.obj_owner%type ,
    p_obj_name            IN OUT awf_process.obj_name%type ,
    p_id_proc_rec         IN OUT awf_process.id_proc_rec%type ,
    p_ind_enabled         IN OUT awf_process.ind_enabled%type ,
    p_ind_active          IN OUT awf_process.ind_active%type ,
    p_ind_auto_initiate   IN OUT awf_process.ind_auto_initiate%type ,
    p_ind_allow_more_inst IN OUT awf_process.ind_allow_more_inst%type ,
    p_id_check_stamp      IN OUT awf_process.id_check_stamp%type ,
    p_id_row              IN VARCHAR2 ,
    p_operation           IN VARCHAR2);

  PROCEDURE p_AWF_PROC_JSON(
    p_id_record  IN OUT awf_proc_json.id_record%type ,
    p_id_process IN OUT awf_proc_json.id_process%type ,
    p_json       IN OUT awf_proc_json.json%type ,
    p_date_gen   IN OUT awf_proc_json.date_gen%type ,
    p_id_row     IN VARCHAR2 ,
    p_operation  IN VARCHAR2);

  PROCEDURE p_AWF_PROC_VARS(
    p_id_record         IN OUT awf_proc_vars.id_record%type ,
    p_id_process        IN OUT awf_proc_vars.id_process%type ,
    p_var_name          IN OUT awf_proc_vars.var_name%type ,
    p_var_type          IN OUT awf_proc_vars.var_type%type ,
    p_notes             IN OUT awf_proc_vars.notes%type ,
    p_ind_active        IN OUT awf_proc_vars.ind_active%type ,
    p_id_check_stamp    IN OUT awf_proc_vars.id_check_stamp%type ,
    p_default_var_value IN OUT CLOB ,
    p_dvar_value_type   IN OUT awf_proc_vars.dvar_value_type%type ,
    p_id_row            IN VARCHAR2 ,
    p_operation         IN VARCHAR2);

  PROCEDURE p_AWF_RELATIONSHIPS(
    p_id_record      IN OUT awf_relationships.id_record%type ,
    p_rel_name       IN OUT awf_relationships.rel_name%type ,
    p_description    IN OUT awf_relationships.description%type ,
    p_p_owner        IN OUT awf_relationships.p_owner%type ,
    p_p_object       IN OUT awf_relationships.p_object%type ,
    p_c_owner        IN OUT awf_relationships.c_owner%type ,
    p_c_object       IN OUT awf_relationships.c_object%type ,
    p_where_clause   IN OUT awf_relationships.where_clause%type ,
    p_ind_awf        IN OUT awf_relationships.ind_awf%type ,
    p_id_check_stamp IN OUT awf_relationships.id_check_stamp%type ,
    p_id_row         IN VARCHAR2 ,
    p_operation      IN VARCHAR2);

  PROCEDURE p_AWF_ROLES(
    p_id_record      IN OUT awf_roles.id_record%type ,
    p_role_name      IN OUT awf_roles.role_name%type ,
    p_description    IN OUT awf_roles.description%type ,
    p_role_type      IN OUT awf_roles.role_type%type ,
    p_ind_broadcast  IN OUT awf_roles.ind_broadcast%type ,
    p_value          IN OUT awf_roles.value%type ,
    p_id_check_stamp IN OUT awf_roles.id_check_stamp%type ,
    p_id_row         IN VARCHAR2 ,
    p_operation      IN VARCHAR2);

  PROCEDURE p_AWF_USERS
    (p_id_record in out awf_users.id_record%type
    ,p_id_check_stamp in out awf_users.id_check_stamp%type
    ,p_user_name in out awf_users.user_name%type
    ,p_user_pw in out awf_users.user_pw%type
    ,p_user_status in out awf_users.user_status%type
    ,p_user_email in out awf_users.user_email%type
    ,p_login_failures in out awf_users.login_failures%type
    ,p_first_name in out awf_users.first_name%type
    ,p_last_name in out awf_users.last_name%type
    ,p_ind_admin in out awf_users.ind_admin%type
    ,p_ind_owner in out awf_users.ind_owner%type
    ,p_id_row in varchar2
    ,p_operation in varchar2);

  PROCEDURE p_AWF_USER_WS
    (p_id_record in out awf_user_ws.id_record%type
    ,p_id_check_stamp in out awf_user_ws.id_check_stamp%type
    ,p_user_name in out awf_user_ws.user_name%type
    ,p_workspace_name in out awf_user_ws.workspace_name%type
    ,p_ind_is_wf_admin in out awf_user_ws.ind_is_wf_admin%type
    ,p_ind_owner in out awf_user_ws.ind_owner%type
    ,p_ind_approved in out awf_user_ws.ind_approved%type
    ,p_notes in out awf_user_ws.notes%type
    ,p_id_row in varchar2
    ,p_operation in varchar2);

  PROCEDURE p_AWF_WF_RECORD(
    p_id_record       IN OUT awf_wf_record.id_record%type ,
    p_id_process      IN OUT awf_wf_record.id_process%type ,
    p_id_owner        IN OUT awf_wf_record.id_owner%type ,
    p_id_instance     IN OUT awf_wf_record.id_instance%type ,
    p_id_workflow_run IN OUT awf_wf_record.id_workflow_run%type ,
    p_record_type     IN OUT awf_wf_record.record_type%type ,
    p_record_subtype  IN OUT awf_wf_record.record_subtype%type ,
    p_date_record     IN OUT awf_wf_record.date_record%type ,
    p_id_proc_rec     IN OUT awf_wf_record.id_proc_rec%type ,
    p_id_child_rec    IN OUT awf_wf_record.id_child_rec%type ,
    p_notes           IN OUT awf_wf_record.notes%type ,
    p_id_check_stamp  IN OUT awf_wf_record.id_check_stamp%type ,
    p_id_row          IN VARCHAR2 ,
    p_operation       IN VARCHAR2);


--------------------------------------------------------------------------------
end pkg_awf_api;

/
