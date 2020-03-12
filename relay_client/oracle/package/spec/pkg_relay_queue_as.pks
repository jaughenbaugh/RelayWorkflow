
  CREATE OR REPLACE EDITIONABLE PACKAGE "RLY_DEV02"."PKG_RELAY_QUEUE_AS" as 

function f_load_queue
(p_internal_id in varchar2
,p_flow_name in varchar2
,p_obj_name in varchar2)
return number;

procedure p_load_queue
(p_internal_id in varchar2
,p_flow_name in varchar2
,p_obj_name in varchar2);

end pkg_relay_queue_as;
