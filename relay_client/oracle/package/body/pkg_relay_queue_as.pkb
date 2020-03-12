
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "RLY_DEV02"."PKG_RELAY_QUEUE_AS" as
--------------------------------------------------------------------------------
procedure p_load_qdata
(p_id_queue in number)
as
begin
  null;
end;
--------------------------------------------------------------------------------
function f_load_queue
(p_internal_id in varchar2
,p_flow_name in varchar2
,p_obj_name in varchar2)
return number
as
  l_id_queue number;
  l_retvar number;
begin

  l_id_queue := tk_iface_main.nextval();

  insert into tk_test_queue
  (id_record, internal_id, flow_name, obj_name)
  values
  (l_id_queue, p_internal_id, p_flow_name, p_obj_name);

  p_load_qdata(l_id_queue);

  l_retvar := l_id_queue;

  return l_retvar;
end;
--------------------------------------------------------------------------------
procedure p_load_queue
(p_internal_id in varchar2
,p_flow_name in varchar2
,p_obj_name in varchar2)
as
  l_var varchar2(50);
begin

  l_var := f_load_queue(p_internal_id,p_flow_name,p_obj_name);

end;
-------------------------------------------------------------------------------- 
end;
