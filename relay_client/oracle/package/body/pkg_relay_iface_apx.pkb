
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "RLY_DEV02"."PKG_RELAY_IFACE_APX" as
--------------------------------------------------------------------------

  type t_svc_param_o is record (pls_param varchar2(200)
                               ,svc_param varchar2(200)
                               ,p_value varchar2(4000));
  type t_svc_param_t is table of t_svc_param_o index by pls_integer;

--------------------------------------------------------------------------
procedure p_load_token
as
begin

  if (nvl(v('G_SVC_TOKEN'),'daisy') != 'daisy'
    and sysdate < to_date(v('G_SVC_TOKEN_EXP'),'YYYY.MM.DD.HH24.MI.SS'))
  then
    apex_web_service.g_oauth_token.token := v('G_SVC_TOKEN');
    apex_web_service.g_oauth_token.expires := to_date(v('G_SVC_TOKEN_EXP'),'YYYY.MM.DD.HH24.MI.SS');
  end if;

end;
--------------------------------------------------------------------------
procedure p_set_token_apx
as
  l_apx_token varchar2(50);
  l_pls_token varchar2(50);
begin

  l_apx_token := nvl(v('G_SVC_TOKEN'),'-abc123');
  l_pls_token := nvl(v('G_SVC_TOKEN'),'-123abc');

  if l_apx_token != l_pls_token then
    apex_util.set_session_state 
    (p_name => 'G_SVC_TOKEN'
    ,p_value => nvl(apex_web_service.g_oauth_token.token,'-a1b2c3'));

    apex_util.set_session_state
    (p_name => 'G_SVC_TOKEN_EXP'
    ,p_value => to_char(apex_web_service.g_oauth_token.expires,'YYYY.MM.DD.HH24.MI.SS'));
  end if;

end;
--------------------------------------------------------------------------
procedure p_load_coll
(p_input in number)
as

begin

  -- if this is the first page then
  if p_input = 1 then

    -- init collection
    apex_collection.create_or_truncate_collection
      (p_collection_name => g_coll);

  end if;

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
    ,p_c020 => g_c020
    ,p_c021 => g_c021);

  -- clear global variables
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
  g_c021 := apex_application_global.c_empty_vc_arr2;

end;
--------------------------------------------------------------------------
procedure p_process_response
as
  l_hasmore number := 1;
  l_next varchar2(4000);
  l_loop1 number := 1;
begin

  g_coll_page := 0;

  loop

    l_next := json_value(replace(pkg_relay_api.g_response,'$ref','ref'),'$.next.ref');

    if nvl(l_next,'null') = 'null' then
      l_hasmore := 0;
    end if;

    select a,b,c,d,e
          ,f,g,h,i,j
          ,k,l,m,n,o
          ,p,q,r,s,t
          ,l_loop1
    bulk collect into g_c001,g_c002,g_c003,g_c004,g_c005
                     ,g_c006,g_c007,g_c008,g_c009,g_c010
                     ,g_c011,g_c012,g_c013,g_c014,g_c015
                     ,g_c016,g_c017,g_c018,g_c019,g_c020
                     ,g_c021
    from json_table(pkg_relay_api.g_response,'$.items[*]'
         columns (a varchar2(4000) path '$.a'
                 ,b varchar2(4000) path '$.b'
                 ,c varchar2(4000) path '$.c'
                 ,d varchar2(4000) path '$.d'
                 ,e varchar2(4000) path '$.e'
                 ,f varchar2(4000) path '$.f'
                 ,g varchar2(4000) path '$.g'
                 ,h varchar2(4000) path '$.h'
                 ,i varchar2(4000) path '$.i'
                 ,j varchar2(4000) path '$.j'
                 ,k varchar2(4000) path '$.k'
                 ,l varchar2(4000) path '$.l'
                 ,m varchar2(4000) path '$.m'
                 ,n varchar2(4000) path '$.n'
                 ,o varchar2(4000) path '$.o'
                 ,p varchar2(4000) path '$.p'
                 ,q varchar2(4000) path '$.q'
                 ,r varchar2(4000) path '$.r'
                 ,s varchar2(4000) path '$.s'
                 ,t varchar2(4000) path '$.t'
                 ));

    if g_test = 1 then
      g_coll := g_c001(1); 
    end if;

    if g_c001.count != 0 and g_test = 0 then
      g_coll := g_c001(1); 
      p_load_coll(l_loop1);
      g_coll_page := l_loop1;
    end if;

    if length(l_next) > 0 then

      pkg_relay_api.p_data_service(l_next);

    end if;

    l_loop1 := l_loop1 + 1;
    exit when l_hasmore = 0 or l_loop1 >= 10;
  end loop;

end;
--------------------------------------------------------------------------
function f_process_params
(p_params t_svc_param_t)
return varchar2
as
  l_param varchar2(4000);
  l_loop1 number := 0;
begin

  if p_params.count > 1 then

    l_param := '?';

    -- cycle parameters
    for idx in 1..p_params.count loop

      -- if the param value is given then 
      if nvl(p_params(idx).p_value,'null') != 'null' then
        -- add either a ? or & as appropriate, and add the param to the set
        l_param := l_param||case when idx = 1 then '' else '&' end
                   ||p_params(idx).svc_param||'='||p_params(idx).p_value;

      end if; 

    end loop;

  else
    if p_params(1).p_value is not null then
      l_param := '?'||p_params(1).svc_param||'='||p_params(1).p_value;
    end if;
  end if;

  return l_param;
end;
--------------------------------------------------------------------------
procedure p_assignment_list
(p_person_code in varchar2 default null)
as
  l_url varchar2(4000) := pkg_relay_api.g_relay_url||'/v1/abstract/assignment';
  l_param varchar2(4000);
  l_params t_svc_param_t;
begin
  -- load parameter collection
  l_params(1) := t_svc_param_o('p_person_code','person_code',p_person_code);

  -- process parameters
  l_param := f_process_params(l_params);

  -- load session token if it exists
  p_load_token;

  -- run the web service
  pkg_relay_api.p_data_service(p_service => l_url||l_param);

  -- process the response and any additional pages
  p_process_response;

  -- update the session token if needed
  p_set_token_apx;

end;
--------------------------------------------------------------------------
procedure p_object_list
(p_object_name in varchar2 default null
,p_ind_active in number default null)
as
  l_url varchar2(4000) := pkg_relay_api.g_relay_url||'/v1/abstract/object';
  l_param varchar2(4000);
  l_params t_svc_param_t;
begin
  -- load parameter collection
  l_params(1) := t_svc_param_o('p_object_name','object_name',p_object_name);
  l_params(2) := t_svc_param_o('p_ind_active','ind_active',p_ind_active);

  -- process parameters
  l_param := f_process_params(l_params);

  -- load session token if it exists
  p_load_token;

  -- run the web service
  pkg_relay_api.p_data_service(p_service => l_url||l_param);

  -- process the response and any additional pages
  p_process_response;

  -- update the session token if needed
  p_set_token_apx;

end;
--------------------------------------------------------------------------
procedure p_object_attr
(p_object_name in varchar2)
as
  l_url varchar2(4000) := pkg_relay_api.g_relay_url||'/v1/abstract/object.attribute';
  l_param varchar2(4000);
  l_params t_svc_param_t;
begin
  -- load parameter collection
  l_params(1) := t_svc_param_o('p_object_name','object_name',p_object_name);

  -- process parameters
  l_param := f_process_params(l_params);

  -- load session token if it exists
  p_load_token;

  -- run the web service
  pkg_relay_api.p_data_service(p_service => l_url||l_param);

  -- process the response and any additional pages
  p_process_response;

  -- update the session token if needed
  p_set_token_apx;

end;
--------------------------------------------------------------------------
procedure p_process_list
(p_process_name in varchar2 default null
,p_object_name in varchar2 default null
,p_ind_enabled in varchar2 default null
,p_ind_active in varchar2 default null
,p_internal_id in varchar2 default null)
as
  l_url varchar2(4000) := pkg_relay_api.g_relay_url||'/v1/abstract/process';
  l_param varchar2(4000);
  l_params t_svc_param_t;
begin
  -- load parameter collection
  l_params(1) := t_svc_param_o('p_process_name','process_name',p_process_name);
  l_params(2) := t_svc_param_o('p_object_name','object_name',p_object_name);
  l_params(3) := t_svc_param_o('p_ind_enabled','ind_enabled',p_ind_enabled);
  l_params(4) := t_svc_param_o('p_ind_active','ind_active',p_ind_active);
  l_params(5) := t_svc_param_o('p_internal_id','internal_id',p_internal_id);

  -- process parameters
  l_param := f_process_params(l_params);

  -- load session token if it exists
  p_load_token;

  -- run the web service
  pkg_relay_api.p_data_service(p_service => l_url||l_param);

  -- process the response and any additional pages
  p_process_response;

  -- update the session token if needed
  p_set_token_apx;

end;
--------------------------------------------------------------------------
procedure p_queue_list
(p_request_id in varchar2 default null
,p_flow_name in varchar2 default null
,p_internal_id in varchar2 default null
,p_node_type in varchar2 default null
,p_object_name in varchar2 default null
,p_change_id in varchar2 default null
,p_ind_closed in varchar2 default null)
as
  l_url varchar2(4000) := pkg_relay_api.g_relay_url||'/v1/abstract/queue';
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
  l_params(7) := t_svc_param_o('p_ind_closed','ind_closed',p_ind_closed);

  -- process parameters
  l_param := f_process_params(l_params);

  -- load session token if it exists
  p_load_token;

  -- run the web service
  pkg_relay_api.p_data_service(p_service => l_url||l_param);

  -- process the response and any additional pages
  p_process_response;

  -- update the session token if needed
  p_set_token_apx;

end;
--------------------------------------------------------------------------
procedure p_queue_data
(p_request_id in varchar2) 
as
  l_url varchar2(4000) := pkg_relay_api.g_relay_url||'/v1/abstract/queue.data';
  l_param varchar2(4000);
  l_params t_svc_param_t;
begin
  -- load parameter collection
  l_params(1) := t_svc_param_o('p_request_id','request_id',p_request_id);

  -- process parameters
  l_param := f_process_params(l_params);

  -- load session token if it exists
  p_load_token;

  -- run the web service
  pkg_relay_api.p_data_service(p_service => l_url||l_param);

  -- process the response and any additional pages
  p_process_response;

  -- update the session token if needed
  p_set_token_apx;

end;
--------------------------------------------------------------------------
procedure p_queue_vars
(p_request_id in varchar2) 
as
  l_url varchar2(4000) := pkg_relay_api.g_relay_url||'/v1/abstract/queue.variables';
  l_param varchar2(4000);
  l_params t_svc_param_t;
begin
  -- load parameter collection
  l_params(1) := t_svc_param_o('p_request_id','request_id',p_request_id);

  -- process parameters
  l_param := f_process_params(l_params);

  -- load session token if it exists
  p_load_token;

  -- run the web service
  pkg_relay_api.p_data_service(p_service => l_url||l_param);

  -- process the response and any additional pages
  p_process_response;

  -- update the session token if needed
  p_set_token_apx;

end;
--------------------------------------------------------------------------
procedure p_queue_hist
(p_request_id in varchar2) 
as
  l_url varchar2(4000) := pkg_relay_api.g_relay_url||'/v1/abstract/queue.history';
  l_param varchar2(4000);
  l_params t_svc_param_t;
begin
  -- load parameter collection
  l_params(1) := t_svc_param_o('p_request_id','request_id',p_request_id);

  -- process parameters
  l_param := f_process_params(l_params);

  -- load session token if it exists
  p_load_token;

  -- run the web service
  pkg_relay_api.p_data_service(p_service => l_url||l_param);

  -- process the response and any additional pages
  p_process_response;

  -- update the session token if needed
  p_set_token_apx;

end;
--------------------------------------------------------------------------
procedure p_queue_assign
(p_request_id in varchar2
,p_person_code in varchar2 default null) 
as
  l_url varchar2(4000) := pkg_relay_api.g_relay_url||'/v1/abstract/queue.assignment';
  l_param varchar2(4000);
  l_params t_svc_param_t;
begin
  -- load parameter collection
  l_params(1) := t_svc_param_o('p_request_id','request_id',p_request_id);
  l_params(2) := t_svc_param_o('p_person_code','person_code',p_person_code);

  -- process parameters
  l_param := f_process_params(l_params);

  -- load session token if it exists
  p_load_token;

  -- run the web service
  pkg_relay_api.p_data_service(p_service => l_url||l_param);

  -- process the response and any additional pages
  p_process_response;

  -- update the session token if needed
  p_set_token_apx;

end;
--------------------------------------------------------------------------
procedure p_queue_opts
(p_request_id in varchar2) 
as
  l_url varchar2(4000) := pkg_relay_api.g_relay_url||'/v1/abstract/queue.choices';
  l_param varchar2(4000);
  l_params t_svc_param_t;
begin
  -- load parameter collection
  l_params(1) := t_svc_param_o('p_request_id','request_id',p_request_id);

  -- process parameters
  l_param := f_process_params(l_params);

  -- load session token if it exists
  p_load_token;

  -- run the web service
  pkg_relay_api.p_data_service(p_service => l_url||l_param);

  -- process the response and any additional pages
  p_process_response;

  -- update the session token if needed
  p_set_token_apx;

end;
--------------------------------------------------------------------------
procedure p_resource_group
(p_description in varchar2 default null
,p_group_name in varchar2 default null
,p_group_status in varchar2 default null) 
as
  l_url varchar2(4000) := pkg_relay_api.g_relay_url||'/v1/abstract/resource.group';
  l_param varchar2(4000);
  l_params t_svc_param_t;
begin
  -- load parameter collection
  l_params(1) := t_svc_param_o('p_description','description',p_description);
  l_params(2) := t_svc_param_o('p_group_name','group_name',p_group_name);
  l_params(3) := t_svc_param_o('p_group_status','group_status',p_group_status);

  -- process parameters
  l_param := f_process_params(l_params);

  -- load session token if it exists
  p_load_token;

  -- run the web service
  pkg_relay_api.p_data_service(p_service => l_url||l_param);

  -- process the response and any additional pages
  p_process_response;

  -- update the session token if needed
  p_set_token_apx;

end;
--------------------------------------------------------------------------
procedure p_resource_person_list
(p_email in varchar2 default null
,p_first_name in varchar2 default null
,p_last_name in varchar2 default null
,p_person_code in varchar2 default null
,p_status in varchar2 default null)
as
  l_url varchar2(4000) := pkg_relay_api.g_relay_url||'/v1/abstract/resource.person';
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

  -- load session token if it exists
  p_load_token;

  -- run the web service
  pkg_relay_api.p_data_service(p_service => l_url||l_param);

  -- process the response and any additional pages
  p_process_response;

  -- update the session token if needed
  p_set_token_apx;

end;
--------------------------------------------------------------------------
end;
