--------------------------------------------------------
--  DDL for Package Body PKG_TK_API
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "PKG_TK_API" 
AS
--------------------------------------------------------------------------------
  g_version varchar2(100) := '#VERSION#';

  type t_inst_stat is table of tk_inst_stat%rowtype index by pls_integer;
  g_inst_stat t_inst_stat := t_inst_stat();

--PROGRAMS----------------------------------------------------------------------
function f_get_version
return varchar2
as
begin
  return g_version;
end f_get_version;
--------------------------------------------------------------------------------
  PROCEDURE p_TK_OBJECT(
    p_id_record        IN OUT tk_object.id_record%type ,
    p_auth_id          IN OUT tk_object.auth_id%type ,
    p_obj_name         IN OUT tk_object.obj_name%type ,
    p_ind_active       IN OUT tk_object.ind_active%type ,
    p_description      IN OUT tk_object.description%type ,
    p_id_row           IN VARCHAR2 ,
    p_operation        IN VARCHAR2)
  AS
    invalid_operation EXCEPTION;
    oper_not_allowed  EXCEPTION;
    l_type tk_object%rowtype;
    l_id_check_stamp NUMBER;
  BEGIN
    l_type.id_record    := p_id_record;
    l_type.auth_id      := p_auth_id;
    l_type.obj_name     := p_obj_name;
    l_type.ind_active   := p_ind_active;
    l_type.description   := p_description;

    -- if operation is allowed per APP_GUID
    -- execute operation
    IF p_operation = 'SELECT' THEN
      SELECT id_record,
      auth_id ,
      obj_name,
      ind_active,
      description
      INTO p_id_record,
      p_auth_id,
      p_obj_name,
      p_ind_active,
      p_description
      FROM TK_OBJECT
      WHERE rowid     = p_id_row;
    elsif p_operation = 'INSERT' THEN
      --raise oper_not_allowed;
      INSERT
      INTO TK_OBJECT
        (
          id_record,
          auth_id ,
          obj_name,
          ind_active ,
          description
        )
        VALUES
        (
          l_type.id_record,
          l_type.auth_id ,
          l_type.obj_name,
          l_type.ind_active ,
          l_type.description
        );
      NULL;
    elsif p_operation = 'UPDATE' THEN
      --raise oper_not_allowed;
      UPDATE TK_OBJECT
      SET id_record      = l_type.id_record ,
        auth_id          = l_type.auth_id ,
        obj_name         = l_type.obj_name ,
        ind_active       = l_type.ind_active,
        description      = l_type.description
      WHERE rowid        = p_id_row;
      NULL;
    elsif p_operation = 'DELETE' THEN
      --raise oper_not_allowed;
      DELETE FROM TK_OBJECT WHERE rowid = p_id_row;
      NULL;
    ELSE
      raise invalid_operation;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    raise;
  END;
--------------------------------------------------------------------------------
function f_wsc
(p_name in varchar2)
return number
as
  pragma autonomous_transaction;
begin

  insert into tk_ws_stat
  values
  (tk_stat_seq.nextval
  ,relay_p_vars.g_wsc_src
  ,p_name
  ,to_char(systimestamp,'YYYYDDDSSSSSFF6'));

  commit;

  return 1;
end;
--------------------------------------------------------------------------------
procedure p_inst_stat
(p_rec_type number
,p_rec_subtype number
,p_rec_id number)
as
  l_is_idx number;
begin
--/*  
  l_is_idx := g_inst_stat.count + 1;

  g_inst_stat(l_is_idx).ts_stamp := to_char(systimestamp,'YYYYDDDSSSSSFF6');
  g_inst_stat(l_is_idx).id_record := tk_stat_seq.nextval();
  g_inst_stat(l_is_idx).id_acct := relay_p_rest.g_json_req.c;
  g_inst_stat(l_is_idx).id_process := relay_p_rest.g_instance.id_process;
  g_inst_stat(l_is_idx).process_name := relay_p_rest.g_process(relay_p_rest.g_proc_alt1(g_inst_stat(l_is_idx).id_process)).process_name;
  g_inst_stat(l_is_idx).id_instance := relay_p_rest.g_instance.id_record;
  g_inst_stat(l_is_idx).id_wf_index := relay_p_workflow.g_workflow_index;
  g_inst_stat(l_is_idx).id_proc_rec := p_rec_id;
  g_inst_stat(l_is_idx).rec_type := p_rec_type;
  g_inst_stat(l_is_idx).rec_subtype := p_rec_subtype;
--*/  
  null;
end;
--------------------------------------------------------------------------------
procedure p_write_istat
as

begin
--/*  
  forall idx in 1..g_inst_stat.count
  insert into tk_inst_stat
  values g_inst_stat(idx);

  g_inst_stat.delete;
--*/
  null;
end;
--------------------------------------------------------------------------------
END;

/
