--------------------------------------------------------
--  DDL for Package Body PKG_AWF_API
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "PKG_AWF_API" 
AS
--------------------------------------------------------------------------------
  g_version varchar2(100) := '#VERSION#';
--PROGRAMS----------------------------------------------------------------------
function f_get_version
return varchar2
as
begin
  return g_version;
end f_get_version;

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
      p_operation        IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_ACTION%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record        := p_id_record;
    l_type.action_name      := p_action_name;
    l_type.description      := p_description;
    l_type.obj_owner        := p_obj_owner;
    l_type.obj_name         := p_obj_name;
    l_type.code_action_type := p_code_action_type;
    l_type.id_template      := p_id_template;
    l_type.prog_owner       := p_prog_owner;
    l_type.prog_name        := p_prog_name;
    l_type.prog_type        := p_prog_type;
    l_type.func_retvar_name := p_func_retvar_name;
    l_type.func_retvar_type := p_func_retvar_type;
    l_type.id_check_stamp   := p_id_check_stamp;
    l_type.ind_save_data    := p_ind_save_data;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        action_name ,
        description ,
        obj_owner ,
        obj_name ,
        code_action_type ,
        id_template ,
        prog_owner ,
        prog_name ,
        prog_type ,
        func_retvar_name ,
        func_retvar_type ,
        id_check_stamp ,
        ind_save_data
      INTO p_id_record ,
        p_action_name ,
        p_description ,
        p_obj_owner ,
        p_obj_name ,
        p_code_action_type ,
        p_id_template ,
        p_prog_owner ,
        p_prog_name ,
        p_prog_type ,
        p_func_retvar_name ,
        p_func_retvar_type ,
        p_id_check_stamp ,
        p_ind_save_data
      FROM AWF_ACTION
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_ACTION
        (
          id_record ,
          action_name ,
          description ,
          obj_owner ,
          obj_name ,
          code_action_type ,
          id_template ,
          prog_owner ,
          prog_name ,
          prog_type ,
          func_retvar_name ,
          func_retvar_type ,
          id_check_stamp ,
          ind_save_data
        )
        VALUES
        (
          l_type.id_record ,
          l_type.action_name ,
          l_type.description ,
          l_type.obj_owner ,
          l_type.obj_name ,
          l_type.code_action_type ,
          l_type.id_template ,
          l_type.prog_owner ,
          l_type.prog_name ,
          l_type.prog_type ,
          l_type.func_retvar_name ,
          l_type.func_retvar_type ,
          l_type.id_check_stamp ,
          l_type.ind_save_data
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_ACTION
      SET id_record      = l_type.id_record ,
        action_name      = l_type.action_name ,
        description      = l_type.description ,
        obj_owner        = l_type.obj_owner ,
        obj_name         = l_type.obj_name ,
        code_action_type = l_type.code_action_type ,
        id_template      = l_type.id_template ,
        prog_owner       = l_type.prog_owner ,
        prog_name        = l_type.prog_name ,
        prog_type        = l_type.prog_type ,
        func_retvar_name = l_type.func_retvar_name ,
        func_retvar_type = l_type.func_retvar_type ,
        id_check_stamp   = l_type.id_check_stamp ,
        ind_save_data    = l_type.ind_save_data
      WHERE rowid        = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_ACTION WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_ACTION;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
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
      p_operation       IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_ACTION_PV%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record       := p_id_record;
    l_type.id_check_stamp  := p_id_check_stamp;
    l_type.id_sequence     := p_id_sequence;
    l_type.act_parameter   := p_act_parameter;
    l_type.act_param_type  := p_act_param_type;
    l_type.act_param_dir   := p_act_param_dir;
    l_type.act_value       := relay_p_anydata.f_clob_to_anydata(p_act_value,p_act_param_type);
    l_type.obj_owner       := p_obj_owner;
    l_type.obj_name        := p_obj_name;
    l_type.action_name     := p_action_name;
    l_type.act_par_target  := p_act_par_target;
    l_type.var_source_type := p_var_source_type;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        id_check_stamp ,
        id_sequence ,
        act_parameter ,
        act_param_type ,
        act_param_dir ,
        relay_p_anydata.f_anydata_to_clob(act_value) act_value ,
        obj_owner ,
        obj_name ,
        action_name ,
        act_par_target ,
        var_source_type
      INTO p_id_record ,
        p_id_check_stamp ,
        p_id_sequence ,
        p_act_parameter ,
        p_act_param_type ,
        p_act_param_dir ,
        p_act_value ,
        p_obj_owner ,
        p_obj_name ,
        p_action_name ,
        p_act_par_target ,
        p_var_source_type
      FROM AWF_ACTION_PV
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_ACTION_PV
        (
          id_record ,
          id_check_stamp ,
          id_sequence ,
          act_parameter ,
          act_param_type ,
          act_param_dir ,
          act_value ,
          obj_owner ,
          obj_name ,
          action_name ,
          act_par_target ,
          var_source_type
        )
        VALUES
        (
          l_type.id_record ,
          l_type.id_check_stamp ,
          l_type.id_sequence ,
          l_type.act_parameter ,
          l_type.act_param_type ,
          l_type.act_param_dir ,
          l_type.act_value ,
          l_type.obj_owner ,
          l_type.obj_name ,
          l_type.action_name ,
          l_type.act_par_target ,
          l_type.var_source_type
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_ACTION_PV
      SET id_record     = l_type.id_record ,
        id_check_stamp  = l_type.id_check_stamp ,
        id_sequence     = l_type.id_sequence ,
        act_parameter   = l_type.act_parameter ,
        act_param_type  = l_type.act_param_type ,
        act_param_dir   = l_type.act_param_dir ,
        act_value       = l_type.act_value ,
        obj_owner       = l_type.obj_owner ,
        obj_name        = l_type.obj_name ,
        action_name     = l_type.action_name ,
        act_par_target  = l_type.act_par_target ,
        var_source_type = l_type.var_source_type
      WHERE rowid       = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_ACTION_PV WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_ACTION_PV;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE p_AWF_AD_METHODS(
      p_id_record      IN OUT awf_ad_methods.id_record%type ,
      p_id_check_stamp IN OUT awf_ad_methods.id_check_stamp%type ,
      p_code_datatype  IN OUT awf_ad_methods.code_datatype%type ,
      p_ad_access      IN OUT awf_ad_methods.ad_access%type ,
      p_ad_convert     IN OUT awf_ad_methods.ad_convert%type ,
      p_ind_common_dt  IN OUT awf_ad_methods.ind_common_dt%type ,
      p_id_row         IN VARCHAR2 ,
      p_operation      IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_AD_METHODS%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record      := p_id_record;
    l_type.id_check_stamp := p_id_check_stamp;
    l_type.code_datatype  := p_code_datatype;
    l_type.ad_access      := p_ad_access;
    l_type.ad_convert     := p_ad_convert;
    l_type.ind_common_dt  := p_ind_common_dt;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        id_check_stamp ,
        code_datatype ,
        ad_access ,
        ad_convert ,
        ind_common_dt
      INTO p_id_record ,
        p_id_check_stamp ,
        p_code_datatype ,
        p_ad_access ,
        p_ad_convert ,
        p_ind_common_dt
      FROM AWF_AD_METHODS
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_AD_METHODS
        (
          id_record ,
          id_check_stamp ,
          code_datatype ,
          ad_access ,
          ad_convert ,
          ind_common_dt
        )
        VALUES
        (
          l_type.id_record ,
          l_type.id_check_stamp ,
          l_type.code_datatype ,
          l_type.ad_access ,
          l_type.ad_convert ,
          l_type.ind_common_dt
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_AD_METHODS
      SET id_record    = l_type.id_record ,
        id_check_stamp = l_type.id_check_stamp ,
        code_datatype  = l_type.code_datatype ,
        ad_access      = l_type.ad_access ,
        ad_convert     = l_type.ad_convert ,
        ind_common_dt  = l_type.ind_common_dt
      WHERE rowid      = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_AD_METHODS WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_AD_METHODS;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE p_AWF_COMM_SEND_TO(
      p_id_record        IN OUT awf_comm_send_to.id_record%type ,
      p_id_template      IN OUT awf_comm_send_to.id_template%type ,
      p_send_to_type     IN OUT awf_comm_send_to.send_to_type%type ,
      p_send_to_group    IN OUT awf_comm_send_to.send_to_group%type ,
      p_send_to          IN OUT awf_comm_send_to.send_to%type ,
      p_id_check_stamp   IN OUT awf_comm_send_to.id_check_stamp%type ,
      p_id_row           IN VARCHAR2 ,
      p_operation        IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_COMM_SEND_TO%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record        := p_id_record;
    l_type.id_template      := p_id_template;
    l_type.send_to_type     := p_send_to_type;
    l_type.send_to_group    := p_send_to_group;
    l_type.send_to          := p_send_to;
    l_type.id_check_stamp   := p_id_check_stamp;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        id_template ,
        send_to_type ,
        send_to_group ,
        send_to ,
        id_check_stamp
      INTO p_id_record ,
        p_id_template ,
        p_send_to_type ,
        p_send_to_group ,
        p_send_to ,
        p_id_check_stamp
      FROM AWF_COMM_SEND_TO
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_COMM_SEND_TO
        (
          id_record ,
          id_template ,
          send_to_type ,
          send_to_group ,
          send_to ,
          id_check_stamp
        )
        VALUES
        (
          l_type.id_record ,
          l_type.id_template ,
          l_type.send_to_type ,
          l_type.send_to_group ,
          l_type.send_to ,
          l_type.id_check_stamp
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_COMM_SEND_TO
      SET id_record      = l_type.id_record ,
        id_template      = l_type.id_template ,
        send_to_type     = l_type.send_to_type ,
        send_to_group    = l_type.send_to_group ,
        send_to          = l_type.send_to ,
        id_check_stamp   = l_type.id_check_stamp
      WHERE rowid        = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_COMM_SEND_TO WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_COMM_SEND_TO;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
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
      p_operation         IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_COMM_TEMPLATE%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record         := p_id_record;
    l_type.template_name     := p_template_name;
    l_type.description       := p_description;
    l_type.obj_owner         := p_obj_owner;
    l_type.object_name       := p_object_name;
    l_type.send_from_email   := p_send_from_email;
    l_type.reply_to_email    := p_reply_to_email;
    l_type.subject_line      := p_subject_line;
    l_type.message_body_pt   := p_message_body_pt;
    l_type.message_body_html := p_message_body_html;
    l_type.id_check_stamp    := p_id_check_stamp;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        template_name ,
        description ,
        obj_owner ,
        object_name ,
        send_from_email ,
        reply_to_email ,
        subject_line ,
        message_body_pt ,
        message_body_html ,
        id_check_stamp
      INTO p_id_record ,
        p_template_name ,
        p_description ,
        p_obj_owner ,
        p_object_name ,
        p_send_from_email ,
        p_reply_to_email ,
        p_subject_line ,
        p_message_body_pt ,
        p_message_body_html ,
        p_id_check_stamp
      FROM AWF_COMM_TEMPLATE
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_COMM_TEMPLATE
        (
          id_record ,
          template_name ,
          description ,
          obj_owner ,
          object_name ,
          send_from_email ,
          reply_to_email ,
          subject_line ,
          message_body_pt ,
          message_body_html ,
          id_check_stamp
        )
        VALUES
        (
          l_type.id_record ,
          l_type.template_name ,
          l_type.description ,
          l_type.obj_owner ,
          l_type.object_name ,
          l_type.send_from_email ,
          l_type.reply_to_email ,
          l_type.subject_line ,
          l_type.message_body_pt ,
          l_type.message_body_html ,
          l_type.id_check_stamp
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_COMM_TEMPLATE
      SET id_record       = l_type.id_record ,
        template_name     = l_type.template_name ,
        description       = l_type.description ,
        obj_owner         = l_type.obj_owner ,
        object_name       = l_type.object_name ,
        send_from_email   = l_type.send_from_email ,
        reply_to_email    = l_type.reply_to_email ,
        subject_line      = l_type.subject_line ,
        message_body_pt   = l_type.message_body_pt ,
        message_body_html = l_type.message_body_html ,
        id_check_stamp    = l_type.id_check_stamp
      WHERE rowid         = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE
      FROM AWF_COMM_TEMPLATE
      WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_COMM_TEMPLATE;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
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
      p_operation       IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_CONDITIONS%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record       := p_id_record;
    l_type.condition       := p_condition;
    l_type.id_relationship := p_id_relationship;
    l_type.obj_owner       := p_obj_owner;
    l_type.object          := p_object;
    l_type.ind_must_be     := p_ind_must_be;
    l_type.id_process      := p_id_process;
    l_type.id_proc_rec     := p_id_proc_rec;
    l_type.id_check_stamp  := p_id_check_stamp;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        condition ,
        id_relationship ,
        obj_owner ,
        object ,
        ind_must_be ,
        id_process ,
        id_proc_rec ,
        id_check_stamp
      INTO p_id_record ,
        p_condition ,
        p_id_relationship ,
        p_obj_owner ,
        p_object ,
        p_ind_must_be ,
        p_id_process ,
        p_id_proc_rec ,
        p_id_check_stamp
      FROM AWF_CONDITIONS
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_CONDITIONS
        (
          id_record ,
          condition ,
          id_relationship ,
          obj_owner ,
          object ,
          ind_must_be ,
          id_process ,
          id_proc_rec ,
          id_check_stamp
        )
        VALUES
        (
          l_type.id_record ,
          l_type.condition ,
          l_type.id_relationship ,
          l_type.obj_owner ,
          l_type.object ,
          l_type.ind_must_be ,
          l_type.id_process ,
          l_type.id_proc_rec ,
          l_type.id_check_stamp
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_CONDITIONS
      SET id_record     = l_type.id_record ,
        condition       = l_type.condition ,
        id_relationship = l_type.id_relationship ,
        obj_owner       = l_type.obj_owner ,
        object          = l_type.object ,
        ind_must_be     = l_type.ind_must_be ,
        id_process      = l_type.id_process ,
        id_proc_rec     = l_type.id_proc_rec ,
        id_check_stamp  = l_type.id_check_stamp
      WHERE rowid       = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_CONDITIONS WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_CONDITIONS;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
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
      p_operation       IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_D2D_DATA%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record       := p_id_record;
    l_type.id_check_stamp  := p_id_check_stamp;
    l_type.type_record     := p_type_record;
    l_type.id_shape        := p_id_shape;
    l_type.id_port         := p_id_port;
    l_type.port_seq        := p_port_seq;
    l_type.link_type       := p_link_type;
    l_type.type            := p_type;
    l_type.id              := p_id;
    l_type.x               := p_x;
    l_type.y               := p_y;
    l_type.width           := p_width;
    l_type.height          := p_height;
    l_type.alpha           := p_alpha;
    l_type.angle           := p_angle;
    l_type.userdata        := p_userdata;
    l_type.cssclass        := p_cssclass;
    l_type.bgcolor         := p_bgcolor;
    l_type.color           := p_color;
    l_type.stroke          := p_stroke;
    l_type.dasharray       := p_dasharray;
    l_type.maxfanout       := p_maxfanout;
    l_type.name            := p_name;
    l_type.port            := p_port;
    l_type.locator         := p_locator;
    l_type.radius          := p_radius;
    l_type.ind_is_positive := p_ind_is_positive;
    l_type.path            := p_path;
    l_type.shape_type      := p_shape_type;
    l_type.router          := p_router;
    l_type.policy          := p_policy;
    l_type.outlinecolor    := p_outlinecolor;
    l_type.outlinestroke   := p_outlinestroke;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        id_check_stamp ,
        type_record ,
        id_shape ,
        id_port ,
        port_seq ,
        link_type ,
        type ,
        id ,
        x ,
        y ,
        width ,
        height ,
        alpha ,
        angle ,
        userdata ,
        cssclass ,
        bgcolor ,
        color ,
        stroke ,
        dasharray ,
        maxfanout ,
        name ,
        port ,
        locator ,
        radius ,
        ind_is_positive ,
        path ,
        shape_type ,
        router ,
        policy ,
        outlinecolor ,
        outlinestroke
      INTO p_id_record ,
        p_id_check_stamp ,
        p_type_record ,
        p_id_shape ,
        p_id_port ,
        p_port_seq ,
        p_link_type ,
        p_type ,
        p_id ,
        p_x ,
        p_y ,
        p_width ,
        p_height ,
        p_alpha ,
        p_angle ,
        p_userdata ,
        p_cssclass ,
        p_bgcolor ,
        p_color ,
        p_stroke ,
        p_dasharray ,
        p_maxfanout ,
        p_name ,
        p_port ,
        p_locator ,
        p_radius ,
        p_ind_is_positive ,
        p_path ,
        p_shape_type ,
        p_router ,
        p_policy ,
        p_outlinecolor ,
        p_outlinestroke
      FROM AWF_D2D_DATA
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_D2D_DATA
        (
          id_record ,
          id_check_stamp ,
          type_record ,
          id_shape ,
          id_port ,
          port_seq ,
          link_type ,
          type ,
          id ,
          x ,
          y ,
          width ,
          height ,
          alpha ,
          angle ,
          userdata ,
          cssclass ,
          bgcolor ,
          color ,
          stroke ,
          dasharray ,
          maxfanout ,
          name ,
          port ,
          locator ,
          radius ,
          ind_is_positive ,
          path ,
          shape_type ,
          router ,
          policy ,
          outlinecolor ,
          outlinestroke
        )
        VALUES
        (
          l_type.id_record ,
          l_type.id_check_stamp ,
          l_type.type_record ,
          l_type.id_shape ,
          l_type.id_port ,
          l_type.port_seq ,
          l_type.link_type ,
          l_type.type ,
          l_type.id ,
          l_type.x ,
          l_type.y ,
          l_type.width ,
          l_type.height ,
          l_type.alpha ,
          l_type.angle ,
          l_type.userdata ,
          l_type.cssclass ,
          l_type.bgcolor ,
          l_type.color ,
          l_type.stroke ,
          l_type.dasharray ,
          l_type.maxfanout ,
          l_type.name ,
          l_type.port ,
          l_type.locator ,
          l_type.radius ,
          l_type.ind_is_positive ,
          l_type.path ,
          l_type.shape_type ,
          l_type.router ,
          l_type.policy ,
          l_type.outlinecolor ,
          l_type.outlinestroke
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_D2D_DATA
      SET id_record     = l_type.id_record ,
        id_check_stamp  = l_type.id_check_stamp ,
        type_record     = l_type.type_record ,
        id_shape        = l_type.id_shape ,
        id_port         = l_type.id_port ,
        port_seq        = l_type.port_seq ,
        link_type       = l_type.link_type ,
        type            = l_type.type ,
        id              = l_type.id ,
        x               = l_type.x ,
        y               = l_type.y ,
        width           = l_type.width ,
        height          = l_type.height ,
        alpha           = l_type.alpha ,
        angle           = l_type.angle ,
        userdata        = l_type.userdata ,
        cssclass        = l_type.cssclass ,
        bgcolor         = l_type.bgcolor ,
        color           = l_type.color ,
        stroke          = l_type.stroke ,
        dasharray       = l_type.dasharray ,
        maxfanout       = l_type.maxfanout ,
        name            = l_type.name ,
        port            = l_type.port ,
        locator         = l_type.locator ,
        radius          = l_type.radius ,
        ind_is_positive = l_type.ind_is_positive ,
        path            = l_type.path ,
        shape_type      = l_type.shape_type ,
        router          = l_type.router ,
        policy          = l_type.policy ,
        outlinecolor    = l_type.outlinecolor ,
        outlinestroke   = l_type.outlinestroke
      WHERE rowid       = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_D2D_DATA WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_D2D_DATA;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE p_AWF_DATATYPES(
      p_id_record      IN OUT awf_datatypes.id_record%type ,
      p_data_type      IN OUT awf_datatypes.data_type%type ,
      p_id_check_stamp IN OUT awf_datatypes.id_check_stamp%type ,
      p_id_row         IN VARCHAR2 ,
      p_operation      IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_DATATYPES%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record      := p_id_record;
    l_type.data_type      := p_data_type;
    l_type.id_check_stamp := p_id_check_stamp;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        data_type ,
        id_check_stamp
      INTO p_id_record ,
        p_data_type ,
        p_id_check_stamp
      FROM AWF_DATATYPES
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_DATATYPES
        (
          id_record ,
          data_type ,
          id_check_stamp
        )
        VALUES
        (
          l_type.id_record ,
          l_type.data_type ,
          l_type.id_check_stamp
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_DATATYPES
      SET id_record    = l_type.id_record ,
        data_type      = l_type.data_type ,
        id_check_stamp = l_type.id_check_stamp
      WHERE rowid      = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_DATATYPES WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_DATATYPES;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE p_AWF_DT_FUNC(
      p_id_record      IN OUT awf_dt_func.id_record%type ,
      p_id_datatype    IN OUT awf_dt_func.id_datatype%type ,
      p_id_function    IN OUT awf_dt_func.id_function%type ,
      p_id_check_stamp IN OUT awf_dt_func.id_check_stamp%type ,
      p_id_row         IN VARCHAR2 ,
      p_operation      IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_DT_FUNC%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record      := p_id_record;
    l_type.id_datatype    := p_id_datatype;
    l_type.id_function    := p_id_function;
    l_type.id_check_stamp := p_id_check_stamp;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        id_datatype ,
        id_function ,
        id_check_stamp
      INTO p_id_record ,
        p_id_datatype ,
        p_id_function ,
        p_id_check_stamp
      FROM AWF_DT_FUNC
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_DT_FUNC
        (
          id_record ,
          id_datatype ,
          id_function ,
          id_check_stamp
        )
        VALUES
        (
          l_type.id_record ,
          l_type.id_datatype ,
          l_type.id_function ,
          l_type.id_check_stamp
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_DT_FUNC
      SET id_record    = l_type.id_record ,
        id_datatype    = l_type.id_datatype ,
        id_function    = l_type.id_function ,
        id_check_stamp = l_type.id_check_stamp
      WHERE rowid      = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_DT_FUNC WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_DT_FUNC;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE p_AWF_ERROR_LOG(
      p_id_record   IN OUT awf_error_log.id_record%type ,
      p_id_instance IN OUT awf_error_log.id_instance%type ,
      p_id_wf_run   IN OUT awf_error_log.id_wf_run%type ,
      p_error_log   IN OUT awf_error_log.error_log%type ,
      p_date_log    IN OUT awf_error_log.date_log%type ,
      p_id_stamp    IN OUT awf_error_log.id_stamp%type ,
      p_id_row      IN VARCHAR2 ,
      p_operation   IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_ERROR_LOG%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record   := p_id_record;
    l_type.id_instance := p_id_instance;
    l_type.id_wf_run   := p_id_wf_run;
    l_type.error_log   := p_error_log;
    l_type.date_log    := p_date_log;
    l_type.id_stamp    := p_id_stamp;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        id_instance ,
        id_wf_run ,
        error_log ,
        date_log ,
        id_stamp
      INTO p_id_record ,
        p_id_instance ,
        p_id_wf_run ,
        p_error_log ,
        p_date_log ,
        p_id_stamp
      FROM AWF_ERROR_LOG
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_ERROR_LOG
        (
          id_record ,
          id_instance ,
          id_wf_run ,
          error_log ,
          date_log ,
          id_stamp
        )
        VALUES
        (
          l_type.id_record ,
          l_type.id_instance ,
          l_type.id_wf_run ,
          l_type.error_log ,
          l_type.date_log ,
          l_type.id_stamp
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_ERROR_LOG
      SET id_record = l_type.id_record ,
        id_instance = l_type.id_instance ,
        id_wf_run   = l_type.id_wf_run ,
        error_log   = l_type.error_log ,
        date_log    = l_type.date_log ,
        id_stamp    = l_type.id_stamp
      WHERE rowid   = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_ERROR_LOG WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_ERROR_LOG;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE p_AWF_FUNCTION(
      p_id_record      IN OUT awf_function.id_record%type ,
      p_function       IN OUT awf_function.function%type ,
      p_description    IN OUT awf_function.description%type ,
      p_id_check_stamp IN OUT awf_function.id_check_stamp%type ,
      p_ind_dateformat IN OUT awf_function.ind_dateformat%type ,
      p_id_row         IN VARCHAR2 ,
      p_operation      IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_FUNCTION%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record      := p_id_record;
    l_type.function       := p_function;
    l_type.description    := p_description;
    l_type.id_check_stamp := p_id_check_stamp;
    l_type.ind_dateformat := p_ind_dateformat;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        FUNCTION ,
        description ,
        id_check_stamp ,
        ind_dateformat
      INTO p_id_record ,
        p_function ,
        p_description ,
        p_id_check_stamp ,
        p_ind_dateformat
      FROM AWF_FUNCTION
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_FUNCTION
        (
          id_record ,
          FUNCTION ,
          description ,
          id_check_stamp ,
          ind_dateformat
        )
        VALUES
        (
          l_type.id_record ,
          l_type.function ,
          l_type.description ,
          l_type.id_check_stamp ,
          l_type.ind_dateformat
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_FUNCTION
      SET id_record    = l_type.id_record ,
        FUNCTION       = l_type.function ,
        description    = l_type.description ,
        id_check_stamp = l_type.id_check_stamp ,
        ind_dateformat = l_type.ind_dateformat
      WHERE rowid      = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_FUNCTION WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_FUNCTION;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE p_AWF_GROUP_MEMBERS(
      p_id_record         IN OUT awf_group_members.id_record%type ,
      p_id_person_group   IN OUT awf_group_members.id_person_group%type ,
      p_id_delegate_of    IN OUT awf_group_members.id_delegate_of%type ,
      p_member_sequence   IN OUT awf_group_members.member_sequence%type ,
      p_ind_group_default IN OUT awf_group_members.ind_group_default%type ,
      p_id_group_member   IN OUT awf_group_members.id_group_member%type ,
      p_id_check_stamp    IN OUT awf_group_members.id_check_stamp%type ,
      p_id_row            IN VARCHAR2 ,
      p_operation         IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_GROUP_MEMBERS%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record         := p_id_record;
    l_type.id_person_group   := p_id_person_group;
    l_type.id_delegate_of    := p_id_delegate_of;
    l_type.member_sequence   := p_member_sequence;
    l_type.ind_group_default := p_ind_group_default;
    l_type.id_group_member   := p_id_group_member;
    l_type.id_check_stamp    := p_id_check_stamp;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        id_person_group ,
        id_delegate_of ,
        member_sequence ,
        ind_group_default ,
        id_group_member ,
        id_check_stamp
      INTO p_id_record ,
        p_id_person_group ,
        p_id_delegate_of ,
        p_member_sequence ,
        p_ind_group_default ,
        p_id_group_member ,
        p_id_check_stamp
      FROM AWF_GROUP_MEMBERS
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_GROUP_MEMBERS
        (
          id_record ,
          id_person_group ,
          id_delegate_of ,
          member_sequence ,
          ind_group_default ,
          id_group_member ,
          id_check_stamp
        )
        VALUES
        (
          l_type.id_record ,
          l_type.id_person_group ,
          l_type.id_delegate_of ,
          l_type.member_sequence ,
          l_type.ind_group_default ,
          l_type.id_group_member ,
          l_type.id_check_stamp
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_GROUP_MEMBERS
      SET id_record       = l_type.id_record ,
        id_person_group   = l_type.id_person_group ,
        id_delegate_of    = l_type.id_delegate_of ,
        member_sequence   = l_type.member_sequence ,
        ind_group_default = l_type.ind_group_default ,
        id_group_member   = l_type.id_group_member ,
        id_check_stamp    = l_type.id_check_stamp
      WHERE rowid         = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE
      FROM AWF_GROUP_MEMBERS
      WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_GROUP_MEMBERS;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
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
      p_operation      IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_INSTANCE%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record      := p_id_record;
    l_type.id_parent      := p_id_parent;
    l_type.ind_active     := p_ind_active;
    l_type.instance_orig  := p_instance_orig;
    l_type.date_start     := p_date_start;
    l_type.id_process     := p_id_process;
    l_type.id_owner       := p_id_owner;
    l_type.id_check_stamp := p_id_check_stamp;
    l_type.instance_log   := p_instance_log;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        id_parent ,
        ind_active ,
        instance_orig ,
        date_start ,
        id_process ,
        id_owner ,
        id_check_stamp ,
        instance_log
      INTO p_id_record ,
        p_id_parent ,
        p_ind_active ,
        p_instance_orig ,
        p_date_start ,
        p_id_process ,
        p_id_owner ,
        p_id_check_stamp ,
        p_instance_log
      FROM AWF_INSTANCE
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_INSTANCE
        (
          id_record ,
          id_parent ,
          ind_active ,
          instance_orig ,
          date_start ,
          id_process ,
          id_owner ,
          id_check_stamp ,
          instance_log
        )
        VALUES
        (
          l_type.id_record ,
          l_type.id_parent ,
          l_type.ind_active ,
          l_type.instance_orig ,
          l_type.date_start ,
          l_type.id_process ,
          l_type.id_owner ,
          l_type.id_check_stamp ,
          l_type.instance_log
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_INSTANCE
      SET id_record    = l_type.id_record ,
        id_parent      = l_type.id_parent ,
        ind_active     = l_type.ind_active ,
        instance_orig  = l_type.instance_orig ,
        date_start     = l_type.date_start ,
        id_process     = l_type.id_process ,
        id_owner       = l_type.id_owner ,
        id_check_stamp = l_type.id_check_stamp ,
        instance_log   = l_type.instance_log
      WHERE rowid      = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_INSTANCE WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_INSTANCE;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
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
      p_operation      IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_INSTANCE_STATE%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record      := p_id_record;
    l_type.id_instance    := p_id_instance;
    l_type.node_number    := p_node_number;
    l_type.node_status    := p_node_status;
    l_type.ind_active     := p_ind_active;
    l_type.id_process     := p_id_process;
    l_type.date_set       := p_date_set;
    l_type.ind_ui_reqd    := p_ind_ui_reqd;
    l_type.id_link_fwd    := p_id_link_fwd;
    l_type.id_check_stamp := p_id_check_stamp;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        id_instance ,
        node_number ,
        node_status ,
        ind_active ,
        id_process ,
        date_set ,
        ind_ui_reqd ,
        id_link_fwd ,
        id_check_stamp
      INTO p_id_record ,
        p_id_instance ,
        p_node_number ,
        p_node_status ,
        p_ind_active ,
        p_id_process ,
        p_date_set ,
        p_ind_ui_reqd ,
        p_id_link_fwd ,
        p_id_check_stamp
      FROM AWF_INSTANCE_STATE
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_INSTANCE_STATE
        (
          id_record ,
          id_instance ,
          node_number ,
          node_status ,
          ind_active ,
          id_process ,
          date_set ,
          ind_ui_reqd ,
          id_link_fwd ,
          id_check_stamp
        )
        VALUES
        (
          l_type.id_record ,
          l_type.id_instance ,
          l_type.node_number ,
          l_type.node_status ,
          l_type.ind_active ,
          l_type.id_process ,
          l_type.date_set ,
          l_type.ind_ui_reqd ,
          l_type.id_link_fwd ,
          l_type.id_check_stamp
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_INSTANCE_STATE
      SET id_record    = l_type.id_record ,
        id_instance    = l_type.id_instance ,
        node_number    = l_type.node_number ,
        node_status    = l_type.node_status ,
        ind_active     = l_type.ind_active ,
        id_process     = l_type.id_process ,
        date_set       = l_type.date_set ,
        ind_ui_reqd    = l_type.ind_ui_reqd ,
        id_link_fwd    = l_type.id_link_fwd ,
        id_check_stamp = l_type.id_check_stamp
      WHERE rowid      = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE
      FROM AWF_INSTANCE_STATE
      WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_INSTANCE_STATE;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
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
      p_ind_decision   IN OUT awf_inst_assign.ind_decision%type ,
      p_id_check_stamp in out awf_inst_assign.id_check_stamp%type ,
      p_person_code    in out awf_inst_assign.person_code%type ,
      p_id_row         IN VARCHAR2 ,
      p_operation      IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_INST_ASSIGN%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record      := p_id_record;
    l_type.priority       := p_priority;
    l_type.id_assignee    := p_id_assignee;
    l_type.date_start     := p_date_start;
    l_type.date_due       := p_date_due;
    l_type.code_status    := p_code_status;
    l_type.id_instance    := p_id_instance;
    l_type.id_process     := p_id_process;
    l_type.id_proc_rec    := p_id_proc_rec;
    l_type.ind_decision   := p_ind_decision;
    l_type.id_check_stamp := p_id_check_stamp;
    l_type.person_code    := p_person_code;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        priority ,
        id_assignee ,
        date_start ,
        date_due ,
        code_status ,
        id_instance ,
        id_process ,
        id_proc_rec ,
        ind_decision ,
        id_check_stamp,
        person_code
      INTO p_id_record ,
        p_priority ,
        p_id_assignee ,
        p_date_start ,
        p_date_due ,
        p_code_status ,
        p_id_instance ,
        p_id_process ,
        p_id_proc_rec ,
        p_ind_decision ,
        p_id_check_stamp,
        p_person_code
      FROM AWF_INST_ASSIGN
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_INST_ASSIGN
        (
          id_record ,
          priority ,
          id_assignee ,
          date_start ,
          date_due ,
          code_status ,
          id_instance ,
          id_process ,
          id_proc_rec ,
          ind_decision ,
          id_check_stamp,
          person_code
        )
        VALUES
        (
          l_type.id_record ,
          l_type.priority ,
          l_type.id_assignee ,
          l_type.date_start ,
          l_type.date_due ,
          l_type.code_status ,
          l_type.id_instance ,
          l_type.id_process ,
          l_type.id_proc_rec ,
          l_type.ind_decision ,
          l_type.id_check_stamp,
          l_type.person_code
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_INST_ASSIGN
      SET id_record    = l_type.id_record ,
        priority       = l_type.priority ,
        id_assignee    = l_type.id_assignee ,
        date_start     = l_type.date_start ,
        date_due       = l_type.date_due ,
        code_status    = l_type.code_status ,
        id_instance    = l_type.id_instance ,
        id_process     = l_type.id_process ,
        id_proc_rec    = l_type.id_proc_rec ,
        ind_decision   = l_type.ind_decision ,
        id_check_stamp = l_type.id_check_stamp,
        person_code    = l_type.person_code
      WHERE rowid      = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_INST_ASSIGN WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_INST_ASSIGN;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE p_AWF_INST_ASSIGN_STATUS(
      p_id_record      IN OUT awf_inst_assign_status.id_record%type ,
      p_id_assignment  IN OUT awf_inst_assign_status.id_assignment%type ,
      p_date_status    IN OUT awf_inst_assign_status.date_status%type ,
      p_code_status    IN OUT awf_inst_assign_status.code_status%type ,
      p_id_check_stamp IN OUT awf_inst_assign_status.id_check_stamp%type ,
      p_id_row         IN VARCHAR2 ,
      p_operation      IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_INST_ASSIGN_STATUS%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record      := p_id_record;
    l_type.id_assignment  := p_id_assignment;
    l_type.date_status    := p_date_status;
    l_type.code_status    := p_code_status;
    l_type.id_check_stamp := p_id_check_stamp;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        id_assignment ,
        date_status ,
        code_status ,
        id_check_stamp
      INTO p_id_record ,
        p_id_assignment ,
        p_date_status ,
        p_code_status ,
        p_id_check_stamp
      FROM AWF_INST_ASSIGN_STATUS
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_INST_ASSIGN_STATUS
        (
          id_record ,
          id_assignment ,
          date_status ,
          code_status ,
          id_check_stamp
        )
        VALUES
        (
          l_type.id_record ,
          l_type.id_assignment ,
          l_type.date_status ,
          l_type.code_status ,
          l_type.id_check_stamp
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_INST_ASSIGN_STATUS
      SET id_record    = l_type.id_record ,
        id_assignment  = l_type.id_assignment ,
        date_status    = l_type.date_status ,
        code_status    = l_type.code_status ,
        id_check_stamp = l_type.id_check_stamp
      WHERE rowid      = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE
      FROM AWF_INST_ASSIGN_STATUS
      WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_INST_ASSIGN_STATUS;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
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
      p_operation         IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_INST_LOG%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_instance       := p_id_instance;
    l_type.id_workflow_index := p_id_workflow_index;
    l_type.id_seq            := p_id_seq;
    l_type.runtime_id        := p_runtime_id;
    l_type.program_unit      := p_program_unit;
    l_type.position          := p_position;
    l_type.program           := p_program;
    l_type.log_type          := p_log_type;
    l_type.log_entry         := p_log_entry;
    l_type.log_time          := p_log_time;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_instance ,
        id_workflow_index ,
        id_seq ,
        runtime_id ,
        program_unit ,
        position ,
        program ,
        log_type ,
        log_entry ,
        log_time
      INTO p_id_instance ,
        p_id_workflow_index ,
        p_id_seq ,
        p_runtime_id ,
        p_program_unit ,
        p_position ,
        p_program ,
        p_log_type ,
        p_log_entry ,
        p_log_time
      FROM AWF_INST_LOG
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_INST_LOG
        (
          id_instance ,
          id_workflow_index ,
          id_seq ,
          runtime_id ,
          program_unit ,
          position ,
          program ,
          log_type ,
          log_entry ,
          log_time
        )
        VALUES
        (
          l_type.id_instance ,
          l_type.id_workflow_index ,
          l_type.id_seq ,
          l_type.runtime_id ,
          l_type.program_unit ,
          l_type.position ,
          l_type.program ,
          l_type.log_type ,
          l_type.log_entry ,
          l_type.log_time
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_INST_LOG
      SET id_instance     = l_type.id_instance ,
        id_workflow_index = l_type.id_workflow_index ,
        id_seq            = l_type.id_seq ,
        runtime_id        = l_type.runtime_id ,
        program_unit      = l_type.program_unit ,
        position          = l_type.position ,
        program           = l_type.program ,
        log_type          = l_type.log_type ,
        log_entry         = l_type.log_entry ,
        log_time          = l_type.log_time
      WHERE rowid         = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_INST_LOG WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_INST_LOG;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE p_AWF_INST_NODE_LINKS(
      p_id_record      IN OUT awf_inst_node_links.id_record%type ,
      p_id_check_stamp IN OUT awf_inst_node_links.id_check_stamp%type ,
      p_id_instance    IN OUT awf_inst_node_links.id_instance%type ,
      p_id_node        IN OUT awf_inst_node_links.id_node%type ,
      p_id_link        IN OUT awf_inst_node_links.id_link%type ,
      p_link_sequence  IN OUT awf_inst_node_links.link_sequence%type ,
      p_id_row         IN VARCHAR2 ,
      p_operation      IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_INST_NODE_LINKS%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record      := p_id_record;
    l_type.id_check_stamp := p_id_check_stamp;
    l_type.id_instance    := p_id_instance;
    l_type.id_node        := p_id_node;
    l_type.id_link        := p_id_link;
    l_type.link_sequence  := p_link_sequence;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        id_check_stamp ,
        id_instance ,
        id_node ,
        id_link ,
        link_sequence
      INTO p_id_record ,
        p_id_check_stamp ,
        p_id_instance ,
        p_id_node ,
        p_id_link ,
        p_link_sequence
      FROM AWF_INST_NODE_LINKS
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_INST_NODE_LINKS
        (
          id_record ,
          id_check_stamp ,
          id_instance ,
          id_node ,
          id_link ,
          link_sequence
        )
        VALUES
        (
          l_type.id_record ,
          l_type.id_check_stamp ,
          l_type.id_instance ,
          l_type.id_node ,
          l_type.id_link ,
          l_type.link_sequence
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_INST_NODE_LINKS
      SET id_record    = l_type.id_record ,
        id_check_stamp = l_type.id_check_stamp ,
        id_instance    = l_type.id_instance ,
        id_node        = l_type.id_node ,
        id_link        = l_type.id_link ,
        link_sequence  = l_type.link_sequence
      WHERE rowid      = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE
      FROM AWF_INST_NODE_LINKS
      WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_INST_NODE_LINKS;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
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
      p_operation      IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_INST_VARS%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record      := p_id_record;
    l_type.id_instance    := p_id_instance;
    l_type.var_type       := p_var_type;
    l_type.var_name       := p_var_name;
    l_type.var_value      := relay_p_anydata.f_clob_to_anydata(p_var_value,p_var_type);
    l_type.var_source     := p_var_source;
    l_type.var_sequence   := p_var_sequence;
    l_type.id_check_stamp := p_id_check_stamp;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        id_instance ,
        var_type ,
        var_name ,
        relay_p_anydata.f_anydata_to_clob(var_value) var_value ,
        var_source ,
        var_sequence ,
        id_check_stamp
      INTO p_id_record ,
        p_id_instance ,
        p_var_type ,
        p_var_name ,
        p_var_value ,
        p_var_source ,
        p_var_sequence ,
        p_id_check_stamp
      FROM AWF_INST_VARS
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_INST_VARS
        (
          id_record ,
          id_instance ,
          var_type ,
          var_name ,
          var_value ,
          var_source ,
          var_sequence ,
          id_check_stamp
        )
        VALUES
        (
          l_type.id_record ,
          l_type.id_instance ,
          l_type.var_type ,
          l_type.var_name ,
          l_type.var_value ,
          l_type.var_source ,
          l_type.var_sequence ,
          l_type.id_check_stamp
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_INST_VARS
      SET id_record    = l_type.id_record ,
        id_instance    = l_type.id_instance ,
        var_type       = l_type.var_type ,
        var_name       = l_type.var_name ,
        var_value      = l_type.var_value ,
        var_source     = l_type.var_source ,
        var_sequence   = l_type.var_sequence ,
        id_check_stamp = l_type.id_check_stamp
      WHERE rowid      = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_INST_VARS WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_INST_VARS;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
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
      p_operation       IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_NODE%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record       := p_id_record;
    l_type.id_process      := p_id_process;
    l_type.id_proc_rec     := p_id_proc_rec;
    l_type.node_type       := p_node_type;
    l_type.layout_column   := p_layout_column;
    l_type.layout_row      := p_layout_row;
    l_type.node_name       := p_node_name;
    l_type.description     := p_description;
    l_type.ind_disp_if_one := p_ind_disp_if_one;
    l_type.amt_for_true    := p_amt_for_true;
    l_type.interval        := p_interval;
    l_type.interval_uom    := p_interval_uom;
    l_type.ind_continue    := p_ind_continue;
    l_type.id_subprocess   := p_id_subprocess;
    l_type.id_check_stamp  := p_id_check_stamp;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        id_process ,
        id_proc_rec ,
        node_type ,
        layout_column ,
        layout_row ,
        node_name ,
        description ,
        ind_disp_if_one ,
        amt_for_true ,
        interval ,
        interval_uom ,
        ind_continue ,
        id_subprocess ,
        id_check_stamp
      INTO p_id_record ,
        p_id_process ,
        p_id_proc_rec ,
        p_node_type ,
        p_layout_column ,
        p_layout_row ,
        p_node_name ,
        p_description ,
        p_ind_disp_if_one ,
        p_amt_for_true ,
        p_interval ,
        p_interval_uom ,
        p_ind_continue ,
        p_id_subprocess ,
        p_id_check_stamp
      FROM AWF_NODE
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_NODE
        (
          id_record ,
          id_process ,
          id_proc_rec ,
          node_type ,
          layout_column ,
          layout_row ,
          node_name ,
          description ,
          ind_disp_if_one ,
          amt_for_true ,
          interval ,
          interval_uom ,
          ind_continue ,
          id_subprocess ,
          id_check_stamp
        )
        VALUES
        (
          l_type.id_record ,
          l_type.id_process ,
          l_type.id_proc_rec ,
          l_type.node_type ,
          l_type.layout_column ,
          l_type.layout_row ,
          l_type.node_name ,
          l_type.description ,
          l_type.ind_disp_if_one ,
          l_type.amt_for_true ,
          l_type.interval ,
          l_type.interval_uom ,
          l_type.ind_continue ,
          l_type.id_subprocess ,
          l_type.id_check_stamp
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_NODE
      SET id_record     = l_type.id_record ,
        id_process      = l_type.id_process ,
        id_proc_rec     = l_type.id_proc_rec ,
        node_type       = l_type.node_type ,
        layout_column   = l_type.layout_column ,
        layout_row      = l_type.layout_row ,
        node_name       = l_type.node_name ,
        description     = l_type.description ,
        ind_disp_if_one = l_type.ind_disp_if_one ,
        amt_for_true    = l_type.amt_for_true ,
        interval        = l_type.interval ,
        interval_uom    = l_type.interval_uom ,
        ind_continue    = l_type.ind_continue ,
        id_subprocess   = l_type.id_subprocess ,
        id_check_stamp  = l_type.id_check_stamp
      WHERE rowid       = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_NODE WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_NODE;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
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
      p_operation         IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_NODE_ACTION%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record         := p_id_record;
    l_type.action_name       := p_action_name;
    l_type.id_relationship   := p_id_relationship;
    l_type.sequence          := p_sequence;
    l_type.amt_for_true      := p_amt_for_true;
    l_type.ind_stop_on_error := p_ind_stop_on_error;
    l_type.id_process        := p_id_process;
    l_type.id_proc_rec       := p_id_proc_rec;
    l_type.id_node_number    := p_id_node_number;
    l_type.id_check_stamp    := p_id_check_stamp;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        action_name ,
        id_relationship ,
        sequence ,
        amt_for_true ,
        ind_stop_on_error ,
        id_process ,
        id_proc_rec ,
        id_node_number ,
        id_check_stamp
      INTO p_id_record ,
        p_action_name ,
        p_id_relationship ,
        p_sequence ,
        p_amt_for_true ,
        p_ind_stop_on_error ,
        p_id_process ,
        p_id_proc_rec ,
        p_id_node_number ,
        p_id_check_stamp
      FROM AWF_NODE_ACTION
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_NODE_ACTION
        (
          id_record ,
          action_name ,
          id_relationship ,
          sequence ,
          amt_for_true ,
          ind_stop_on_error ,
          id_process ,
          id_proc_rec ,
          id_node_number ,
          id_check_stamp
        )
        VALUES
        (
          l_type.id_record ,
          l_type.action_name ,
          l_type.id_relationship ,
          l_type.sequence ,
          l_type.amt_for_true ,
          l_type.ind_stop_on_error ,
          l_type.id_process ,
          l_type.id_proc_rec ,
          l_type.id_node_number ,
          l_type.id_check_stamp
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_NODE_ACTION
      SET id_record       = l_type.id_record ,
        action_name       = l_type.action_name ,
        id_relationship   = l_type.id_relationship ,
        sequence          = l_type.sequence ,
        amt_for_true      = l_type.amt_for_true ,
        ind_stop_on_error = l_type.ind_stop_on_error ,
        id_process        = l_type.id_process ,
        id_proc_rec       = l_type.id_proc_rec ,
        id_node_number    = l_type.id_node_number ,
        id_check_stamp    = l_type.id_check_stamp
      WHERE rowid         = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_NODE_ACTION WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_NODE_ACTION;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
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
      p_operation           IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_NODE_ASSIGNMENT%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record           := p_id_record;
    l_type.description         := p_description;
    l_type.priority            := p_priority;
    l_type.ind_notify_by_email := p_ind_notify_by_email;
    l_type.node_number         := p_node_number;
    l_type.id_role             := p_id_role;
    l_type.id_escrole          := p_id_escrole;
    l_type.id_email_template   := p_id_email_template;
    l_type.id_process          := p_id_process;
    l_type.id_proc_rec         := p_id_proc_rec;
    l_type.amt_for_true        := p_amt_for_true;
    l_type.id_check_stamp      := p_id_check_stamp;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        description ,
        priority ,
        ind_notify_by_email ,
        node_number ,
        id_role ,
        id_escrole ,
        id_email_template ,
        id_process ,
        id_proc_rec ,
        amt_for_true ,
        id_check_stamp
      INTO p_id_record ,
        p_description ,
        p_priority ,
        p_ind_notify_by_email ,
        p_node_number ,
        p_id_role ,
        p_id_escrole ,
        p_id_email_template ,
        p_id_process ,
        p_id_proc_rec ,
        p_amt_for_true ,
        p_id_check_stamp
      FROM AWF_NODE_ASSIGNMENT
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_NODE_ASSIGNMENT
        (
          id_record ,
          description ,
          priority ,
          ind_notify_by_email ,
          node_number ,
          id_role ,
          id_escrole ,
          id_email_template ,
          id_process ,
          id_proc_rec ,
          amt_for_true ,
          id_check_stamp
        )
        VALUES
        (
          l_type.id_record ,
          l_type.description ,
          l_type.priority ,
          l_type.ind_notify_by_email ,
          l_type.node_number ,
          l_type.id_role ,
          l_type.id_escrole ,
          l_type.id_email_template ,
          l_type.id_process ,
          l_type.id_proc_rec ,
          l_type.amt_for_true ,
          l_type.id_check_stamp
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_NODE_ASSIGNMENT
      SET id_record         = l_type.id_record ,
        description         = l_type.description ,
        priority            = l_type.priority ,
        ind_notify_by_email = l_type.ind_notify_by_email ,
        node_number         = l_type.node_number ,
        id_role             = l_type.id_role ,
        id_escrole          = l_type.id_escrole ,
        id_email_template   = l_type.id_email_template ,
        id_process          = l_type.id_process ,
        id_proc_rec         = l_type.id_proc_rec ,
        amt_for_true        = l_type.amt_for_true ,
        id_check_stamp      = l_type.id_check_stamp
      WHERE rowid           = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE
      FROM AWF_NODE_ASSIGNMENT
      WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_NODE_ASSIGNMENT;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
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
      p_operation       IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_NODE_LINK%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record       := p_id_record;
    l_type.id_parent_node  := p_id_parent_node;
    l_type.id_child_node   := p_id_child_node;
    l_type.description     := p_description;
    l_type.ind_is_positive := p_ind_is_positive;
    l_type.sequence        := p_sequence;
    l_type.amt_for_true    := p_amt_for_true;
    l_type.id_process      := p_id_process;
    l_type.id_proc_rec     := p_id_proc_rec;
    l_type.id_check_stamp  := p_id_check_stamp;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        id_parent_node ,
        id_child_node ,
        description ,
        ind_is_positive ,
        sequence ,
        amt_for_true ,
        id_process ,
        id_proc_rec ,
        id_check_stamp
      INTO p_id_record ,
        p_id_parent_node ,
        p_id_child_node ,
        p_description ,
        p_ind_is_positive ,
        p_sequence ,
        p_amt_for_true ,
        p_id_process ,
        p_id_proc_rec ,
        p_id_check_stamp
      FROM AWF_NODE_LINK
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_NODE_LINK
        (
          id_record ,
          id_parent_node ,
          id_child_node ,
          description ,
          ind_is_positive ,
          sequence ,
          amt_for_true ,
          id_process ,
          id_proc_rec ,
          id_check_stamp
        )
        VALUES
        (
          l_type.id_record ,
          l_type.id_parent_node ,
          l_type.id_child_node ,
          l_type.description ,
          l_type.ind_is_positive ,
          l_type.sequence ,
          l_type.amt_for_true ,
          l_type.id_process ,
          l_type.id_proc_rec ,
          l_type.id_check_stamp
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_NODE_LINK
      SET id_record     = l_type.id_record ,
        id_parent_node  = l_type.id_parent_node ,
        id_child_node   = l_type.id_child_node ,
        description     = l_type.description ,
        ind_is_positive = l_type.ind_is_positive ,
        sequence        = l_type.sequence ,
        amt_for_true    = l_type.amt_for_true ,
        id_process      = l_type.id_process ,
        id_proc_rec     = l_type.id_proc_rec ,
        id_check_stamp  = l_type.id_check_stamp
      WHERE rowid       = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_NODE_LINK WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_NODE_LINK;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE p_AWF_NODE_LINK_VERTEX(
      p_id_record      IN OUT awf_node_link_vertex.id_record%type ,
      p_id_process     IN OUT awf_node_link_vertex.id_process%type ,
      p_id_proc_rec    IN OUT awf_node_link_vertex.id_proc_rec%type ,
      p_vertex_seq     IN OUT awf_node_link_vertex.vertex_seq%type ,
      p_x_pos          IN OUT awf_node_link_vertex.x_pos%type ,
      p_y_pos          IN OUT awf_node_link_vertex.y_pos%type ,
      p_id_check_stamp IN OUT awf_node_link_vertex.id_check_stamp%type ,
      p_id_row         IN VARCHAR2 ,
      p_operation      IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_NODE_LINK_VERTEX%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record      := p_id_record;
    l_type.id_process     := p_id_process;
    l_type.id_proc_rec    := p_id_proc_rec;
    l_type.vertex_seq     := p_vertex_seq;
    l_type.x_pos          := p_x_pos;
    l_type.y_pos          := p_y_pos;
    l_type.id_check_stamp := p_id_check_stamp;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        id_process ,
        id_proc_rec ,
        vertex_seq ,
        x_pos ,
        y_pos ,
        id_check_stamp
      INTO p_id_record ,
        p_id_process ,
        p_id_proc_rec ,
        p_vertex_seq ,
        p_x_pos ,
        p_y_pos ,
        p_id_check_stamp
      FROM AWF_NODE_LINK_VERTEX
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_NODE_LINK_VERTEX
        (
          id_record ,
          id_process ,
          id_proc_rec ,
          vertex_seq ,
          x_pos ,
          y_pos ,
          id_check_stamp
        )
        VALUES
        (
          l_type.id_record ,
          l_type.id_process ,
          l_type.id_proc_rec ,
          l_type.vertex_seq ,
          l_type.x_pos ,
          l_type.y_pos ,
          l_type.id_check_stamp
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_NODE_LINK_VERTEX
      SET id_record    = l_type.id_record ,
        id_process     = l_type.id_process ,
        id_proc_rec    = l_type.id_proc_rec ,
        vertex_seq     = l_type.vertex_seq ,
        x_pos          = l_type.x_pos ,
        y_pos          = l_type.y_pos ,
        id_check_stamp = l_type.id_check_stamp
      WHERE rowid      = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE
      FROM AWF_NODE_LINK_VERTEX
      WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_NODE_LINK_VERTEX;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
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
      p_operation      IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_NODE_SUBPROCESS%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record      := p_id_record;
    l_type.id_check_stamp := p_id_check_stamp;
    l_type.id_process     := p_id_process;
    l_type.id_proc_rec    := p_id_proc_rec;
    l_type.id_node        := p_id_node;
    l_type.id_subprocess  := p_id_subprocess;
    l_type.exec_action    := p_exec_action;
    l_type.subprocess_seq := p_subprocess_seq;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        id_check_stamp ,
        id_process ,
        id_proc_rec ,
        id_node ,
        id_subprocess ,
        exec_action ,
        subprocess_seq
      INTO p_id_record ,
        p_id_check_stamp ,
        p_id_process ,
        p_id_proc_rec ,
        p_id_node ,
        p_id_subprocess ,
        p_exec_action ,
        p_subprocess_seq
      FROM AWF_NODE_SUBPROCESS
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_NODE_SUBPROCESS
        (
          id_record ,
          id_check_stamp ,
          id_process ,
          id_proc_rec ,
          id_node ,
          id_subprocess ,
          exec_action ,
          subprocess_seq
        )
        VALUES
        (
          l_type.id_record ,
          l_type.id_check_stamp ,
          l_type.id_process ,
          l_type.id_proc_rec ,
          l_type.id_node ,
          l_type.id_subprocess ,
          l_type.exec_action ,
          l_type.subprocess_seq
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_NODE_SUBPROCESS
      SET id_record    = l_type.id_record ,
        id_check_stamp = l_type.id_check_stamp ,
        id_process     = l_type.id_process ,
        id_proc_rec    = l_type.id_proc_rec ,
        id_node        = l_type.id_node ,
        id_subprocess  = l_type.id_subprocess ,
        exec_action    = l_type.exec_action ,
        subprocess_seq = l_type.subprocess_seq
      WHERE rowid      = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE
      FROM AWF_NODE_SUBPROCESS
      WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_NODE_SUBPROCESS;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE p_AWF_PARAMETERS(
      p_id_record       IN OUT awf_parameters.id_record%type ,
      p_id_check_stamp  IN OUT awf_parameters.id_check_stamp%type ,
      p_parameter_name  IN OUT awf_parameters.parameter_name%type ,
      p_parameter_value IN OUT CLOB ,
      p_description     IN OUT awf_parameters.description%type ,
      p_id_row          IN VARCHAR2 ,
      p_operation       IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_PARAMETERS%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record       := p_id_record;
    l_type.id_check_stamp  := p_id_check_stamp;
    l_type.parameter_name  := p_parameter_name;
    l_type.parameter_value := relay_p_anydata.f_clob_to_anydata(p_parameter_value,'VARCHAR2');
    l_type.description     := p_description;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        id_check_stamp ,
        parameter_name ,
        relay_p_anydata.f_anydata_to_clob(parameter_value) parameter_value ,
        description
      INTO p_id_record ,
        p_id_check_stamp ,
        p_parameter_name ,
        p_parameter_value ,
        p_description
      FROM AWF_PARAMETERS
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_PARAMETERS
        (
          id_record ,
          id_check_stamp ,
          parameter_name ,
          parameter_value ,
          description
        )
        VALUES
        (
          l_type.id_record ,
          l_type.id_check_stamp ,
          l_type.parameter_name ,
          l_type.parameter_value ,
          l_type.description
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_PARAMETERS
      SET id_record     = l_type.id_record ,
        id_check_stamp  = l_type.id_check_stamp ,
        parameter_name  = l_type.parameter_name ,
        parameter_value = l_type.parameter_value ,
        description     = l_type.description
      WHERE rowid       = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_PARAMETERS WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_PARAMETERS;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
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
      p_operation           IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_PERSON%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record           := p_id_record;
    l_type.person_code         := p_person_code;
    l_type.status              := p_status;
    l_type.display_name        := p_display_name;
    l_type.first_name          := p_first_name;
    l_type.last_name           := p_last_name;
    l_type.id_delegate         := p_id_delegate;
    l_type.date_delagate_start := p_date_delagate_start;
    l_type.date_delegate_end   := p_date_delegate_end;
    l_type.date_status         := p_date_status;
    l_type.email_address       := p_email_address;
    l_type.id_check_stamp      := p_id_check_stamp;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        person_code ,
        status ,
        display_name ,
        first_name ,
        last_name ,
        id_delegate ,
        date_delagate_start ,
        date_delegate_end ,
        date_status ,
        email_address ,
        id_check_stamp
      INTO p_id_record ,
        p_person_code ,
        p_status ,
        p_display_name ,
        p_first_name ,
        p_last_name ,
        p_id_delegate ,
        p_date_delagate_start ,
        p_date_delegate_end ,
        p_date_status ,
        p_email_address ,
        p_id_check_stamp
      FROM AWF_PERSON
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_PERSON
        (
          id_record ,
          person_code ,
          status ,
          display_name ,
          first_name ,
          last_name ,
          id_delegate ,
          date_delagate_start ,
          date_delegate_end ,
          date_status ,
          email_address ,
          id_check_stamp
        )
        VALUES
        (
          l_type.id_record ,
          l_type.person_code ,
          l_type.status ,
          l_type.display_name ,
          l_type.first_name ,
          l_type.last_name ,
          l_type.id_delegate ,
          l_type.date_delagate_start ,
          l_type.date_delegate_end ,
          l_type.date_status ,
          l_type.email_address ,
          l_type.id_check_stamp
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_PERSON
      SET id_record         = l_type.id_record ,
        person_code         = l_type.person_code ,
        status              = l_type.status ,
        display_name        = l_type.display_name ,
        first_name          = l_type.first_name ,
        last_name           = l_type.last_name ,
        id_delegate         = l_type.id_delegate ,
        date_delagate_start = l_type.date_delagate_start ,
        date_delegate_end   = l_type.date_delegate_end ,
        date_status         = l_type.date_status ,
        email_address       = l_type.email_address ,
        id_check_stamp      = l_type.id_check_stamp
      WHERE rowid           = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_PERSON WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_PERSON;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE p_AWF_PERSON_GROUP(
      p_id_record      IN OUT awf_person_group.id_record%type ,
      p_group_name     IN OUT awf_person_group.group_name%type ,
      p_description    IN OUT awf_person_group.description%type ,
      p_group_status   IN OUT awf_person_group.group_status%type ,
      p_id_check_stamp IN OUT awf_person_group.id_check_stamp%type ,
      p_id_row         IN VARCHAR2 ,
      p_operation      IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_PERSON_GROUP%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record      := p_id_record;
    l_type.group_name     := p_group_name;
    l_type.description    := p_description;
    l_type.group_status   := p_group_status;
    l_type.id_check_stamp := p_id_check_stamp;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        group_name ,
        description ,
        group_status ,
        id_check_stamp
      INTO p_id_record ,
        p_group_name ,
        p_description ,
        p_group_status ,
        p_id_check_stamp
      FROM AWF_PERSON_GROUP
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_PERSON_GROUP
        (
          id_record ,
          group_name ,
          description ,
          group_status ,
          id_check_stamp
        )
        VALUES
        (
          l_type.id_record ,
          l_type.group_name ,
          l_type.description ,
          l_type.group_status ,
          l_type.id_check_stamp
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_PERSON_GROUP
      SET id_record    = l_type.id_record ,
        group_name     = l_type.group_name ,
        description    = l_type.description ,
        group_status   = l_type.group_status ,
        id_check_stamp = l_type.id_check_stamp
      WHERE rowid      = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_PERSON_GROUP WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_PERSON_GROUP;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
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
      p_operation           IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_PROCESS%rowtype;
    l_id_check_stamp NUMBER;
    l_id_record number;
  BEGIN
    l_type.id_record           := p_id_record;
    l_type.id_base_process     := p_id_base_process;
    l_type.process_name        := p_process_name;
    l_type.description         := p_description;
    l_type.proc_revision       := p_proc_revision;
    l_type.id_revised_from     := p_id_revised_from;
    l_type.id_role             := p_id_role;
    l_type.obj_owner           := p_obj_owner;
    l_type.obj_name            := p_obj_name;
    l_type.id_proc_rec         := p_id_proc_rec;
    l_type.ind_enabled         := p_ind_enabled;
    l_type.ind_active          := p_ind_active;
    l_type.ind_auto_initiate   := p_ind_auto_initiate;
    l_type.ind_allow_more_inst := p_ind_allow_more_inst;
    l_type.id_check_stamp      := p_id_check_stamp;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        id_base_process ,
        process_name ,
        description ,
        proc_revision ,
        id_revised_from ,
        id_role ,
        obj_owner ,
        obj_name ,
        id_proc_rec ,
        ind_enabled ,
        ind_active ,
        ind_auto_initiate ,
        ind_allow_more_inst ,
        id_check_stamp
      INTO p_id_record ,
        p_id_base_process ,
        p_process_name ,
        p_description ,
        p_proc_revision ,
        p_id_revised_from ,
        p_id_role ,
        p_obj_owner ,
        p_obj_name ,
        p_id_proc_rec ,
        p_ind_enabled ,
        p_ind_active ,
        p_ind_auto_initiate ,
        p_ind_allow_more_inst ,
        p_id_check_stamp
      FROM AWF_PROCESS
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;

      l_id_record := relay_p_workflow.f_an_main();

      INSERT
      INTO AWF_PROCESS
        (
          id_record ,
          id_base_process ,
          process_name ,
          description ,
          proc_revision ,
          id_revised_from ,
          id_role ,
          obj_owner ,
          obj_name ,
          id_proc_rec ,
          ind_enabled ,
          ind_active ,
          ind_auto_initiate ,
          ind_allow_more_inst ,
          id_check_stamp
        )
        VALUES
        (
          nvl(l_type.id_record,l_id_record) ,
          nvl(l_type.id_base_process,l_id_record) ,
          l_type.process_name ,
          l_type.description ,
          l_type.proc_revision ,
          l_type.id_revised_from ,
          l_type.id_role ,
          l_type.obj_owner ,
          l_type.obj_name ,
          l_type.id_proc_rec ,
          l_type.ind_enabled ,
          l_type.ind_active ,
          l_type.ind_auto_initiate ,
          l_type.ind_allow_more_inst ,
          l_type.id_check_stamp
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_PROCESS
      SET id_record         = l_type.id_record ,
        id_base_process     = l_type.id_base_process ,
        process_name        = l_type.process_name ,
        description         = l_type.description ,
        proc_revision       = l_type.proc_revision ,
        id_revised_from     = l_type.id_revised_from ,
        id_role             = l_type.id_role ,
        obj_owner           = l_type.obj_owner ,
        obj_name            = l_type.obj_name ,
        id_proc_rec         = l_type.id_proc_rec ,
        ind_enabled         = l_type.ind_enabled ,
        ind_active          = l_type.ind_active ,
        ind_auto_initiate   = l_type.ind_auto_initiate ,
        ind_allow_more_inst = l_type.ind_allow_more_inst ,
        id_check_stamp      = l_type.id_check_stamp
      WHERE rowid           = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_PROCESS WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_PROCESS;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE p_AWF_PROC_JSON(
      p_id_record  IN OUT awf_proc_json.id_record%type ,
      p_id_process IN OUT awf_proc_json.id_process%type ,
      p_json       IN OUT awf_proc_json.json%type ,
      p_date_gen   IN OUT awf_proc_json.date_gen%type ,
      p_id_row     IN VARCHAR2 ,
      p_operation  IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_PROC_JSON%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record  := p_id_record;
    l_type.id_process := p_id_process;
    l_type.json       := p_json;
    l_type.date_gen   := p_date_gen;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        id_process ,
        json ,
        date_gen
      INTO p_id_record ,
        p_id_process ,
        p_json ,
        p_date_gen
      FROM AWF_PROC_JSON
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_PROC_JSON
        (
          id_record ,
          id_process ,
          json ,
          date_gen
        )
        VALUES
        (
          l_type.id_record ,
          l_type.id_process ,
          l_type.json ,
          l_type.date_gen
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_PROC_JSON
      SET id_record = l_type.id_record ,
        id_process  = l_type.id_process ,
        json        = l_type.json ,
        date_gen    = l_type.date_gen
      WHERE rowid   = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_PROC_JSON WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_PROC_JSON;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
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
      p_operation         IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_PROC_VARS%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record         := p_id_record;
    l_type.id_process        := p_id_process;
    l_type.var_name          := p_var_name;
    l_type.var_type          := p_var_type;
    l_type.notes             := p_notes;
    l_type.ind_active        := p_ind_active;
    l_type.id_check_stamp    := p_id_check_stamp;
    l_type.default_var_value := relay_p_anydata.f_clob_to_anydata(p_default_var_value,p_var_type);
    l_type.dvar_value_type   := p_dvar_value_type;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        id_process ,
        var_name ,
        var_type ,
        notes ,
        ind_active ,
        id_check_stamp ,
        relay_p_anydata.f_anydata_to_clob(default_var_value) default_var_value ,
        dvar_value_type
      INTO p_id_record ,
        p_id_process ,
        p_var_name ,
        p_var_type ,
        p_notes ,
        p_ind_active ,
        p_id_check_stamp ,
        p_default_var_value ,
        p_dvar_value_type
      FROM AWF_PROC_VARS
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_PROC_VARS
        (
          id_record ,
          id_process ,
          var_name ,
          var_type ,
          notes ,
          ind_active ,
          id_check_stamp ,
          default_var_value ,
          dvar_value_type
        )
        VALUES
        (
          l_type.id_record ,
          l_type.id_process ,
          l_type.var_name ,
          l_type.var_type ,
          l_type.notes ,
          l_type.ind_active ,
          l_type.id_check_stamp ,
          l_type.default_var_value ,
          l_type.dvar_value_type
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_PROC_VARS
      SET id_record       = l_type.id_record ,
        id_process        = l_type.id_process ,
        var_name          = l_type.var_name ,
        var_type          = l_type.var_type ,
        notes             = l_type.notes ,
        ind_active        = l_type.ind_active ,
        id_check_stamp    = l_type.id_check_stamp ,
        default_var_value = l_type.default_var_value ,
        dvar_value_type   = l_type.dvar_value_type
      WHERE rowid         = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_PROC_VARS WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_PROC_VARS;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
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
      p_operation      IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_RELATIONSHIPS%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record      := p_id_record;
    l_type.rel_name       := p_rel_name;
    l_type.description    := p_description;
    l_type.p_owner        := p_p_owner;
    l_type.p_object       := p_p_object;
    l_type.c_owner        := p_c_owner;
    l_type.c_object       := p_c_object;
    l_type.where_clause   := p_where_clause;
    l_type.ind_awf        := p_ind_awf;
    l_type.id_check_stamp := p_id_check_stamp;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        rel_name ,
        description ,
        p_owner ,
        p_object ,
        c_owner ,
        c_object ,
        where_clause ,
        ind_awf ,
        id_check_stamp
      INTO p_id_record ,
        p_rel_name ,
        p_description ,
        p_p_owner ,
        p_p_object ,
        p_c_owner ,
        p_c_object ,
        p_where_clause ,
        p_ind_awf ,
        p_id_check_stamp
      FROM AWF_RELATIONSHIPS
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_RELATIONSHIPS
        (
          id_record ,
          rel_name ,
          description ,
          p_owner ,
          p_object ,
          c_owner ,
          c_object ,
          where_clause ,
          ind_awf ,
          id_check_stamp
        )
        VALUES
        (
          l_type.id_record ,
          l_type.rel_name ,
          l_type.description ,
          l_type.p_owner ,
          l_type.p_object ,
          l_type.c_owner ,
          l_type.c_object ,
          l_type.where_clause ,
          l_type.ind_awf ,
          l_type.id_check_stamp
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_RELATIONSHIPS
      SET id_record    = l_type.id_record ,
        rel_name       = l_type.rel_name ,
        description    = l_type.description ,
        p_owner        = l_type.p_owner ,
        p_object       = l_type.p_object ,
        c_owner        = l_type.c_owner ,
        c_object       = l_type.c_object ,
        where_clause   = l_type.where_clause ,
        ind_awf        = l_type.ind_awf ,
        id_check_stamp = l_type.id_check_stamp
      WHERE rowid      = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE
      FROM AWF_RELATIONSHIPS
      WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_RELATIONSHIPS;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE p_AWF_ROLES(
      p_id_record      IN OUT awf_roles.id_record%type ,
      p_role_name      IN OUT awf_roles.role_name%type ,
      p_description    IN OUT awf_roles.description%type ,
      p_role_type      IN OUT awf_roles.role_type%type ,
      p_ind_broadcast  IN OUT awf_roles.ind_broadcast%type ,
      p_value          IN OUT awf_roles.value%type ,
      p_id_check_stamp IN OUT awf_roles.id_check_stamp%type ,
      p_id_row         IN VARCHAR2 ,
      p_operation      IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_ROLES%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record      := p_id_record;
    l_type.role_name      := p_role_name;
    l_type.description    := p_description;
    l_type.role_type      := p_role_type;
    l_type.ind_broadcast  := p_ind_broadcast;
    l_type.value          := p_value;
    l_type.id_check_stamp := p_id_check_stamp;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        role_name ,
        description ,
        role_type ,
        ind_broadcast ,
        value ,
        id_check_stamp
      INTO p_id_record ,
        p_role_name ,
        p_description ,
        p_role_type ,
        p_ind_broadcast ,
        p_value ,
        p_id_check_stamp
      FROM AWF_ROLES
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_ROLES
        (
          id_record ,
          role_name ,
          description ,
          role_type ,
          ind_broadcast ,
          value ,
          id_check_stamp
        )
        VALUES
        (
          l_type.id_record ,
          l_type.role_name ,
          l_type.description ,
          l_type.role_type ,
          l_type.ind_broadcast ,
          l_type.value ,
          l_type.id_check_stamp
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_ROLES
      SET id_record    = l_type.id_record ,
        role_name      = l_type.role_name ,
        description    = l_type.description ,
        role_type      = l_type.role_type ,
        ind_broadcast  = l_type.ind_broadcast ,
        value          = l_type.value ,
        id_check_stamp = l_type.id_check_stamp
      WHERE rowid      = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_ROLES WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_ROLES;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE p_AWF_USERS(
      p_id_record      IN OUT awf_users.id_record%type ,
      p_id_check_stamp IN OUT awf_users.id_check_stamp%type ,
      p_user_name      IN OUT awf_users.user_name%type ,
      p_user_pw        IN OUT awf_users.user_pw%type ,
      p_user_status    IN OUT awf_users.user_status%type ,
      p_user_email     IN OUT awf_users.user_email%type ,
      p_login_failures IN OUT awf_users.login_failures%type ,
      p_first_name     IN OUT awf_users.first_name%type ,
      p_last_name      IN OUT awf_users.last_name%type ,
      p_ind_admin      IN OUT awf_users.ind_admin%type,
      p_ind_owner      IN OUT awf_users.ind_owner%type,
      p_id_row         IN VARCHAR2 ,
      p_operation      IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_USERS%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record      := p_id_record;
    l_type.id_check_stamp := p_id_check_stamp;
    l_type.user_name      := p_user_name;
    l_type.user_pw        := p_user_pw;
    l_type.user_status    := p_user_status;
    l_type.user_email     := p_user_email;
    l_type.login_failures := p_login_failures;
    l_type.first_name     := p_first_name;
    l_type.last_name      := p_last_name;
    l_type.ind_admin      := p_ind_admin;
    l_type.ind_owner      := p_ind_owner;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        id_check_stamp ,
        user_name ,
        user_pw ,
        user_status ,
        user_email ,
        login_failures ,
        first_name ,
        last_name,
        ind_admin,
        ind_owner
      INTO p_id_record ,
        p_id_check_stamp ,
        p_user_name ,
        p_user_pw ,
        p_user_status ,
        p_user_email ,
        p_login_failures ,
        p_first_name ,
        p_last_name,
        p_ind_admin,
        p_ind_owner
      FROM AWF_USERS
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_USERS
        (
          id_record ,
          id_check_stamp ,
          user_name ,
          user_pw ,
          user_status ,
          user_email ,
          login_failures ,
          first_name ,
          last_name,
          ind_admin,
          ind_owner
        )
        VALUES
        (
          l_type.id_record ,
          l_type.id_check_stamp ,
          l_type.user_name ,
          l_type.user_pw ,
          l_type.user_status ,
          l_type.user_email ,
          l_type.login_failures ,
          l_type.first_name ,
          l_type.last_name,
          l_type.ind_admin,
          l_type.ind_owner
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_USERS
      SET id_record    = l_type.id_record ,
        id_check_stamp = l_type.id_check_stamp ,
        user_name      = l_type.user_name ,
        user_pw        = l_type.user_pw ,
        user_status    = l_type.user_status ,
        user_email     = l_type.user_email ,
        login_failures = l_type.login_failures ,
        first_name     = l_type.first_name ,
        last_name      = l_type.last_name,
        ind_admin      = l_type.ind_admin,
        ind_owner      = l_type.ind_owner
      WHERE rowid      = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_USERS WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_USERS;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE p_AWF_USER_WS(
      p_id_record       IN OUT awf_user_ws.id_record%type ,
      p_id_check_stamp  IN OUT awf_user_ws.id_check_stamp%type ,
      p_user_name       IN OUT awf_user_ws.user_name%type ,
      p_workspace_name  IN OUT awf_user_ws.workspace_name%type ,
      p_ind_is_wf_admin IN OUT awf_user_ws.ind_is_wf_admin%type ,
      p_ind_owner       IN OUT awf_user_ws.ind_owner%type ,
      p_ind_approved    IN OUT awf_user_ws.ind_approved%type ,
      p_notes in out awf_user_ws.notes%type,
      p_id_row          IN VARCHAR2 ,
      p_operation       IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_USER_WS%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record       := p_id_record;
    l_type.id_check_stamp  := p_id_check_stamp;
    l_type.user_name       := p_user_name;
    l_type.workspace_name  := p_workspace_name;
    l_type.ind_is_wf_admin := p_ind_is_wf_admin;
    l_type.ind_owner       := p_ind_owner;
    l_type.ind_approved    := p_ind_approved;
    l_type.notes           := p_notes;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        id_check_stamp ,
        user_name ,
        workspace_name ,
        ind_is_wf_admin ,
        ind_owner ,
        ind_approved,
        notes
      INTO p_id_record ,
        p_id_check_stamp ,
        p_user_name ,
        p_workspace_name ,
        p_ind_is_wf_admin ,
        p_ind_owner ,
        p_ind_approved,
        p_notes
      FROM AWF_USER_WS
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_USER_WS
        (
          id_record ,
          id_check_stamp ,
          user_name ,
          workspace_name ,
          ind_is_wf_admin ,
          ind_owner ,
          ind_approved ,
          notes
        )
        VALUES
        (
          l_type.id_record ,
          l_type.id_check_stamp ,
          l_type.user_name ,
          l_type.workspace_name ,
          l_type.ind_is_wf_admin ,
          l_type.ind_owner ,
          l_type.ind_approved,
          l_type.notes
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_USER_WS
      SET id_record     = l_type.id_record ,
        id_check_stamp  = l_type.id_check_stamp ,
        user_name       = l_type.user_name ,
        workspace_name  = l_type.workspace_name ,
        ind_is_wf_admin = l_type.ind_is_wf_admin ,
        ind_owner       = l_type.ind_owner ,
        ind_approved    = l_type.ind_approved ,
        notes           = l_type.notes
      WHERE rowid       = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_USER_WS WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_USER_WS;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
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
      p_operation       IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type AWF_WF_RECORD%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record       := p_id_record;
    l_type.id_process      := p_id_process;
    l_type.id_owner        := p_id_owner;
    l_type.id_instance     := p_id_instance;
    l_type.id_workflow_run := p_id_workflow_run;
    l_type.record_type     := p_record_type;
    l_type.record_subtype  := p_record_subtype;
    l_type.date_record     := p_date_record;
    l_type.id_proc_rec     := p_id_proc_rec;
    l_type.id_child_rec    := p_id_child_rec;
    l_type.notes           := p_notes;
    l_type.id_check_stamp  := p_id_check_stamp;
    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record ,
        id_process ,
        id_owner ,
        id_instance ,
        id_workflow_run ,
        record_type ,
        record_subtype ,
        date_record ,
        id_proc_rec ,
        id_child_rec ,
        notes ,
        id_check_stamp
      INTO p_id_record ,
        p_id_process ,
        p_id_owner ,
        p_id_instance ,
        p_id_workflow_run ,
        p_record_type ,
        p_record_subtype ,
        p_date_record ,
        p_id_proc_rec ,
        p_id_child_rec ,
        p_notes ,
        p_id_check_stamp
      FROM AWF_WF_RECORD
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO AWF_WF_RECORD
        (
          id_record ,
          id_process ,
          id_owner ,
          id_instance ,
          id_workflow_run ,
          record_type ,
          record_subtype ,
          date_record ,
          id_proc_rec ,
          id_child_rec ,
          notes ,
          id_check_stamp
        )
        VALUES
        (
          l_type.id_record ,
          l_type.id_process ,
          l_type.id_owner ,
          l_type.id_instance ,
          l_type.id_workflow_run ,
          l_type.record_type ,
          l_type.record_subtype ,
          l_type.date_record ,
          l_type.id_proc_rec ,
          l_type.id_child_rec ,
          l_type.notes ,
          l_type.id_check_stamp
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE AWF_WF_RECORD
      SET id_record     = l_type.id_record ,
        id_process      = l_type.id_process ,
        id_owner        = l_type.id_owner ,
        id_instance     = l_type.id_instance ,
        id_workflow_run = l_type.id_workflow_run ,
        record_type     = l_type.record_type ,
        record_subtype  = l_type.record_subtype ,
        date_record     = l_type.date_record ,
        id_proc_rec     = l_type.id_proc_rec ,
        id_child_rec    = l_type.id_child_rec ,
        notes           = l_type.notes ,
        id_check_stamp  = l_type.id_check_stamp
      WHERE rowid       = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM AWF_WF_RECORD WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END p_AWF_WF_RECORD;
--------------------------------------------------------------------------------
END pkg_awf_api;

/
