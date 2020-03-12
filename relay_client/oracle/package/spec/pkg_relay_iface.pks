
  CREATE OR REPLACE EDITIONABLE PACKAGE "RLY_DEV02"."PKG_RELAY_IFACE" as 
--------------------------------------------------------------------------
type t_apx_coll is table of apex_collections%rowtype index by pls_integer;
g_apx_coll t_apx_coll;

g_response clob;

--------------------------------------------------------------------------
procedure p_object_list
(p_object_name in varchar2 default null
,p_ind_active in number default null
,p_ind_abstract in number default 0);

procedure p_abs_object_attr
(p_object_name in varchar2);

procedure p_object_detail
(p_object_name in varchar2
,p_show_all in number default 0
,p_show_attr in number default 0
,p_show_proc in number default 0);

procedure p_process_list
(p_process_name in varchar2 default null
,p_object_name in number default null
,p_ind_enabled in number default 0
,p_ind_active in number default 0
,p_ind_abstract in number default 0);

procedure p_queue_list
(p_request_id in varchar2 default null
,p_flow_name in number default null
,p_internal_id in number default null
,p_node_type in number default null
,p_object_name in number default null
,p_change_id in number default null
,p_ind_abstract in number default 0);

procedure p_abs_queue_data
(p_request_id in varchar2);

procedure p_abs_queue_vars
(p_request_id in varchar2);

procedure p_abs_queue_hist
(p_request_id in varchar2);

procedure p_queue_detail
(p_request_id in varchar2
,p_show_all in number default 1
,p_show_attr in number default 0
,p_show_data in number default 0
,p_show_hist in number default 0
,p_show_obj in number default 0
,p_show_proc in number default 0
,p_show_vars in number default 0);

procedure p_resource_group_detail
(p_group_name in varchar2
,p_show_all in number default 1
,p_show_mbr in number default 0);

procedure p_resource_group
(p_description in varchar2 default null
,p_group_name in varchar2 default null
,p_group_status in varchar2 default null
,p_ind_abstract in number default 0);

procedure p_resource_person_detail
(p_person_code in varchar2
,p_show_all in number default 1
,p_show_grp in number default 0);

procedure p_resource_person_list
(p_email in varchar2 default null
,p_first_name in varchar2 default null
,p_last_name in varchar2 default null
,p_person_code in varchar2 default null
,p_status in varchar2 default null
,p_ind_abstract in number default 0);

--------------------------------------------------------------------------
end;

