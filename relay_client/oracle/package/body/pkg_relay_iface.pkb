
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "RLY_DEV02"."PKG_RELAY_IFACE" as
--------------------------------------------------------------------------

  g_coll  varchar2(50);
  g_c001	apex_application_global.vc_arr2;
  g_c002	apex_application_global.vc_arr2;
  g_c003	apex_application_global.vc_arr2;
  g_c004	apex_application_global.vc_arr2;
  g_c005	apex_application_global.vc_arr2;
  g_c006	apex_application_global.vc_arr2;
  g_c007	apex_application_global.vc_arr2;
  g_c008	apex_application_global.vc_arr2;
  g_c009	apex_application_global.vc_arr2;
  g_c010	apex_application_global.vc_arr2;
  g_c011	apex_application_global.vc_arr2;
  g_c012	apex_application_global.vc_arr2;
  g_c013	apex_application_global.vc_arr2;
  g_c014	apex_application_global.vc_arr2;
  g_c015	apex_application_global.vc_arr2;
  g_c016	apex_application_global.vc_arr2;
  g_c017	apex_application_global.vc_arr2;
  g_c018	apex_application_global.vc_arr2;
  g_c019	apex_application_global.vc_arr2;
  g_c020	apex_application_global.vc_arr2;

--  := apex_application_global.c_empty_vc_arr2


  type t_svc_param_o is record (pls_param varchar2(200)
                               ,svc_param varchar2(200)
                               ,p_value varchar2(4000));
  type t_svc_param_t is table of t_svc_param_o index by pls_integer;

--------------------------------------------------------------------------
procedure p_load_coll
as

begin

  -- init collection
  apex_collection.create_or_truncate_collection
    (p_collection_name => g_coll);

  -- add collection members
  apex_collection.add_members
    (p_collection_name => g_coll
    ,p_c001 => g_c001
    ,p_c002 => g_c002
    ,p_c003 => g_c003
    ,p_c004 => g_c004
    ,p_c005 => g_c005
    ,p_c006 => g_c006
    ,p_c007 => g_c007
    ,p_c008 => g_c008
    ,p_c009 => g_c009
    ,p_c010 => g_c010
    ,p_c011 => g_c011
    ,p_c012 => g_c012
    ,p_c013 => g_c013
    ,p_c014 => g_c014
    ,p_c015 => g_c015
    ,p_c016 => g_c016
    ,p_c017 => g_c017
    ,p_c018 => g_c018
    ,p_c019 => g_c019
    ,p_c020 => g_c020);

  -- clear global variables
  g_coll := null;
  g_c001 := apex_application_global.c_empty_vc_arr2;
  g_c002 := apex_application_global.c_empty_vc_arr2;
  g_c003 := apex_application_global.c_empty_vc_arr2;
  g_c004 := apex_application_global.c_empty_vc_arr2;
  g_c005 := apex_application_global.c_empty_vc_arr2;
  g_c006 := apex_application_global.c_empty_vc_arr2;
  g_c007 := apex_application_global.c_empty_vc_arr2;
  g_c008 := apex_application_global.c_empty_vc_arr2;
  g_c009 := apex_application_global.c_empty_vc_arr2;
  g_c010 := apex_application_global.c_empty_vc_arr2;
  g_c011 := apex_application_global.c_empty_vc_arr2;
  g_c012 := apex_application_global.c_empty_vc_arr2;
  g_c013 := apex_application_global.c_empty_vc_arr2;
  g_c014 := apex_application_global.c_empty_vc_arr2;
  g_c015 := apex_application_global.c_empty_vc_arr2;
  g_c016 := apex_application_global.c_empty_vc_arr2;
  g_c017 := apex_application_global.c_empty_vc_arr2;
  g_c018 := apex_application_global.c_empty_vc_arr2;
  g_c019 := apex_application_global.c_empty_vc_arr2;
  g_c020 := apex_application_global.c_empty_vc_arr2;

end;
--------------------------------------------------------------------------
-- new procedure to read the response and create apex_collections
--------------------------------------------------------------------------
function f_process_params
(p_params t_svc_param_t)
return varchar2
as
  l_param varchar2(4000);
begin

  if p_params.count > 1 then

    -- cycle parameters
    for idx in 1..p_params.count loop

      -- if the param value is given then 
      if p_params(idx).p_value is not null then
        -- add either a ? or & as appropriate, and add the param to the set
        l_param := case when l_param is null then '?' else '&' end
                  ||p_params(idx).svc_param||'='||p_params(idx).p_value;

      end if;

    end loop;

  else
    if p_params(1).p_value is not null then
      l_param := '?'||p_params(1).svc_param||'='||p_params(1).p_value;
    end if;
  end if;

end;
--------------------------------------------------------------------------
procedure p_object_list
(p_object_name in varchar2 default null
,p_ind_active in number default null
,p_ind_abstract in number default 0)
as
  l_url varchar2(4000) := '/object/list';
  l_url_abs varchar2(4000) := '/abstract/object';
  l_param varchar2(4000);
  l_params t_svc_param_t;
begin
  -- load parameter collection
  l_params(1) := t_svc_param_o('p_object_name','object_name',p_object_name);
  l_params(2) := t_svc_param_o('p_ind_active','ind_active',p_ind_active);

  -- process parameters
  l_param := f_process_params(l_params);

  -- run the web service
  pkg_relay_api.p_data_service(p_service => case when nvl(p_ind_abstract,0) = 1 then l_url
                                                 else l_url_abs end||l_param);
end;
--------------------------------------------------------------------------
procedure p_abs_object_attr
(p_object_name in varchar2)
as
  l_url varchar2(4000) := '/abstract/object.attribute';
  l_param varchar2(4000);
  l_params t_svc_param_t;
begin
  -- load parameter collection
  l_params(1) := t_svc_param_o('p_object_name','object_name',p_object_name);

  -- process parameters
  l_param := f_process_params(l_params);

  -- run the web service
  pkg_relay_api.p_data_service(p_service => l_url||l_param);
end;
--------------------------------------------------------------------------
procedure p_object_detail
(p_object_name in varchar2
,p_show_all in number default 0
,p_show_attr in number default 0
,p_show_proc in number default 0)
as
  l_url varchar2(4000) := '/object/detail';
  l_param varchar2(4000);
  l_params t_svc_param_t;
begin
  -- load parameter collection
  l_params(1) := t_svc_param_o('p_object_name','object_name',p_object_name);
  l_params(2) := t_svc_param_o('p_show_all','show_all',p_show_all);
  l_params(3) := t_svc_param_o('p_show_attr','show_attr',p_show_attr);
  l_params(4) := t_svc_param_o('p_show_proc','show_proc',p_show_proc);

  -- process parameters
  l_param := f_process_params(l_params);

  -- run the web service
  pkg_relay_api.p_data_service(p_service => l_url||l_param);
end;
--------------------------------------------------------------------------
procedure p_process_list
(p_process_name in varchar2 default null
,p_object_name in number default null
,p_ind_enabled in number default 0
,p_ind_active in number default 0
,p_ind_abstract in number default 0)
as
  l_url varchar2(4000) := '/process/list';
  l_url_abs varchar2(4000) := '/abstract/process';
  l_param varchar2(4000);
  l_params t_svc_param_t;
begin
  -- load parameter collection
  l_params(1) := t_svc_param_o('p_process_name','process_name',p_process_name);
  l_params(2) := t_svc_param_o('p_object_name','object_name',p_object_name);
  l_params(3) := t_svc_param_o('p_ind_enabled','ind_enabled',p_ind_enabled);
  l_params(4) := t_svc_param_o('p_ind_active','ind_active',p_ind_active);

  -- process parameters
  l_param := f_process_params(l_params);

  -- run the web service
  pkg_relay_api.p_data_service(p_service => case when nvl(p_ind_abstract,0) = 1 then l_url
                                                 else l_url_abs end||l_param);
end;
--------------------------------------------------------------------------
procedure p_queue_list
(p_request_id in varchar2 default null
,p_flow_name in number default null
,p_internal_id in number default null
,p_node_type in number default null
,p_object_name in number default null
,p_change_id in number default null
,p_ind_abstract in number default 0)
as
  l_url varchar2(4000) := '/queue/list';
  l_url_abs varchar2(4000) := '/abstract/queue';
  l_param varchar2(4000);
  l_params t_svc_param_t;
begin
  -- load parameter collection
  l_params(1) := t_svc_param_o('p_request_id','request_id',p_request_id);
  l_params(2) := t_svc_param_o('p_flow_name','flow_name',p_flow_name);
  l_params(3) := t_svc_param_o('p_internal_id','internal_id',p_internal_id);
  l_params(4) := t_svc_param_o('p_node_type','node_type',p_node_type);
  l_params(5) := t_svc_param_o('p_object_name','object_name',p_object_name);
  l_params(6) := t_svc_param_o('p_change_id','change_id',p_change_id);

  -- process parameters
  l_param := f_process_params(l_params);

  -- run the web service
  pkg_relay_api.p_data_service(p_service => case when nvl(p_ind_abstract,0) = 1 then l_url
                                                 else l_url_abs end||l_param);
end;
--------------------------------------------------------------------------
procedure p_abs_queue_data
(p_request_id in varchar2) 
as
  l_url varchar2(4000) := '/abstract/queue.data';
  l_param varchar2(4000);
  l_params t_svc_param_t;
begin
  -- load parameter collection
  l_params(1) := t_svc_param_o('p_request_id','request_id',p_request_id);

  -- process parameters
  l_param := f_process_params(l_params);

  -- run the web service
  pkg_relay_api.p_data_service(p_service => l_url||l_param);
end;
--------------------------------------------------------------------------
procedure p_abs_queue_vars
(p_request_id in varchar2) 
as
  l_url varchar2(4000) := '/abstract/queue.variables';
  l_param varchar2(4000);
  l_params t_svc_param_t;
begin
  -- load parameter collection
  l_params(1) := t_svc_param_o('p_request_id','request_id',p_request_id);

  -- process parameters
  l_param := f_process_params(l_params);

  -- run the web service
  pkg_relay_api.p_data_service(p_service => l_url||l_param);
end;
--------------------------------------------------------------------------
procedure p_abs_queue_hist
(p_request_id in varchar2) 
as
  l_url varchar2(4000) := '/abstract/queue.history';
  l_param varchar2(4000);
  l_params t_svc_param_t;
begin
  -- load parameter collection
  l_params(1) := t_svc_param_o('p_request_id','request_id',p_request_id);

  -- process parameters
  l_param := f_process_params(l_params);

  -- run the web service
  pkg_relay_api.p_data_service(p_service => l_url||l_param);
end;
--------------------------------------------------------------------------
procedure p_queue_detail
(p_request_id in varchar2
,p_show_all in number default 1
,p_show_attr in number default 0
,p_show_data in number default 0
,p_show_hist in number default 0
,p_show_obj in number default 0
,p_show_proc in number default 0
,p_show_vars in number default 0) 
as
  l_url varchar2(4000) := '/queue/detail';
  l_param varchar2(4000);
  l_params t_svc_param_t;
begin
  -- load parameter collection
  l_params(1) := t_svc_param_o('p_request_id','request_id',p_request_id);
  l_params(2) := t_svc_param_o('p_show_all','show_all',p_show_all);
  l_params(3) := t_svc_param_o('p_show_attr','show_attr',p_show_attr);
  l_params(4) := t_svc_param_o('p_show_data','show_data',p_show_data);
  l_params(5) := t_svc_param_o('p_show_hist','show_hist',p_show_hist);
  l_params(6) := t_svc_param_o('p_show_obj','show_obj',p_show_obj);
  l_params(7) := t_svc_param_o('p_show_proc','show_proc',p_show_proc);
  l_params(8) := t_svc_param_o('p_show_vars','show_vars',p_show_vars);

  -- process parameters
  l_param := f_process_params(l_params);

  -- run the web service
  pkg_relay_api.p_data_service(p_service => l_url||l_param);
end;
--------------------------------------------------------------------------
procedure p_resource_group_detail
(p_group_name in varchar2
,p_show_all in number default 1
,p_show_mbr in number default 0) 
as
  l_url varchar2(4000) := '/resource/group/detail';
  l_param varchar2(4000);
  l_params t_svc_param_t;
begin
  -- load parameter collection
  l_params(1) := t_svc_param_o('p_group_name','group_name',p_group_name);
  l_params(2) := t_svc_param_o('p_show_all','show_all',p_show_all);
  l_params(3) := t_svc_param_o('p_show_mbr','show_mbr',p_show_mbr);

  -- process parameters
  l_param := f_process_params(l_params);

  -- run the web service
  pkg_relay_api.p_data_service(p_service => l_url||l_param);
end;
--------------------------------------------------------------------------
procedure p_resource_group
(p_description in varchar2 default null
,p_group_name in varchar2 default null
,p_group_status in varchar2 default null
,p_ind_abstract in number default 0) 
as
  l_url varchar2(4000) := '/resource/group/list';
  l_url_abs varchar2(4000) := '/abstract/resource.group';
  l_param varchar2(4000);
  l_params t_svc_param_t;
begin
  -- load parameter collection
  l_params(1) := t_svc_param_o('p_description','description',p_description);
  l_params(2) := t_svc_param_o('p_group_name','group_name',p_group_name);
  l_params(3) := t_svc_param_o('p_group_status','group_status',p_group_status);

  -- process parameters
  l_param := f_process_params(l_params);

  -- run the web service
  pkg_relay_api.p_data_service(p_service => case when nvl(p_ind_abstract,0) = 1 then l_url
                                                 else l_url_abs end||l_param);
end;
--------------------------------------------------------------------------
procedure p_resource_person_detail
(p_person_code in varchar2
,p_show_all in number default 1
,p_show_grp in number default 0)
as
  l_url varchar2(4000) := '/resource/person/detail';
  l_param varchar2(4000);
  l_params t_svc_param_t;
begin
  -- load parameter collection
  l_params(1) := t_svc_param_o('p_person_code','person_code',p_person_code);
  l_params(2) := t_svc_param_o('p_show_all','show_all',p_show_all);
  l_params(3) := t_svc_param_o('p_show_grp','show_grp',p_show_grp);

  -- process parameters
  l_param := f_process_params(l_params);

  -- run the web service
  pkg_relay_api.p_data_service(p_service => l_url||l_param);
end;
--------------------------------------------------------------------------
procedure p_resource_person_list
(p_email in varchar2 default null
,p_first_name in varchar2 default null
,p_last_name in varchar2 default null
,p_person_code in varchar2 default null
,p_status in varchar2 default null
,p_ind_abstract in number default 0)
as
  l_url varchar2(4000) := '/resource/person/list';
  l_url_abs varchar2(4000) := '/abstract/resource.person';
  l_param varchar2(4000);
  l_params t_svc_param_t;
begin
  -- load parameter collection
  l_params(1) := t_svc_param_o('p_email','email',p_email);
  l_params(2) := t_svc_param_o('p_first_name','first_name',p_first_name);
  l_params(3) := t_svc_param_o('p_last_name','last_name',p_last_name);
  l_params(4) := t_svc_param_o('p_person_code','person_code',p_person_code);
  l_params(5) := t_svc_param_o('p_status','status',p_status);

  -- process parameters
  l_param := f_process_params(l_params);

  -- run the web service
  pkg_relay_api.p_data_service(p_service => case when nvl(p_ind_abstract,0) = 1 then l_url
                                                 else l_url_abs end||l_param);
end;
--------------------------------------------------------------------------
end;
