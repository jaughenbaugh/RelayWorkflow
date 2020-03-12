
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "RLY_DEV02"."PKG_RELAY_API" 
as
  
  g_body clob;

  type t_svc_param_o is record (pls_param varchar2(200)
                               ,svc_param varchar2(200)
                               ,p_value varchar2(4000));
  type t_svc_param_t is table of t_svc_param_o index by pls_integer;

--------------------------------------------------------------------------
procedure p_authenticate
as
  l_auth_req number := 0;
begin

  if (apex_web_service.g_oauth_token.token is not null
      and sysdate < apex_web_service.g_oauth_token.expires)
  then
    l_auth_req := 0;
  else 
    l_auth_req := 1;
  end if;

  if l_auth_req = 1 then

    apex_web_service.oauth_authenticate
    (p_token_url     => g_oauth_url
    ,p_client_id     => g_auth_id
    ,p_client_secret => g_auth_pw);

  end if;

end;
--------------------------------------------------------------------------
procedure p_prep_body
as
  l_json clob;
begin

  apex_json.initialize_clob_output;
  apex_json.open_object();  -- main
    apex_json.open_object('p_req_in');
      apex_json.write('a',g_a);
      apex_json.write('b',g_b);
      apex_json.write('c',g_c);
      apex_json.write('d',g_d);
      apex_json.write('e',g_e);
      apex_json.write('f',g_f);
      apex_json.write('g',g_g);
      apex_json.write('i',g_i);
      apex_json.write('k',g_k);

      apex_json.open_array('owner_data');
      for idx in 1..g_owner_data.count loop
        apex_json.open_object(); -- owner_data item
          apex_json.write('a',g_owner_data(idx).a);
          apex_json.write('b',g_owner_data(idx).b);
        apex_json.close_object(); -- owner_data item
      end loop;
      apex_json.close_array(); -- owner_data

      apex_json.open_array('res_reply');
      for idx in 1..g_res_reply.count loop
        apex_json.open_object(); -- owner_data item
          apex_json.write('a',g_owner_data(idx).a);
          apex_json.write('b',g_owner_data(idx).b);
        apex_json.close_object(); -- owner_data item
      end loop;
      apex_json.close_array(); -- res_reply

    apex_json.close_object(); -- p_req_in
  apex_json.close_object(); -- main

  l_json := apex_json.get_clob_output;
  l_json := replace(l_json,chr(10),'');

--  dbms_output.put_line('REQUEST : '||chr(10)||l_json);

  g_body := l_json;

  null;
end;
--------------------------------------------------------------------------
procedure p_queue_response
as

  l_response clob;

begin

  l_response := g_response;

  g_a := json_value(l_response,'$.a');
  g_b := json_value(l_response,'$.b');
  g_c := json_value(l_response,'$.c');
  g_d := json_value(l_response,'$.d');
  g_e := json_value(l_response,'$.e');
  g_f := json_value(l_response,'$.f');
  g_g := json_value(l_response,'$.g');
  g_h := json_value(l_response,'$.h');
  g_i := json_value(l_response,'$.i');
  g_j := json_value(l_response,'$.j');
  g_k := json_value(l_response,'$.k');
  g_assignments := json_value(l_response,'$.assignments');
  g_alert_log := json_value(l_response,'$.alerts');
  g_choices := json_value(l_response,'$.choices');
  g_res_req := json_value(l_response,'$.res_req');
  g_err_log := json_value(l_response,'$.err_log');

  select a, b
  bulk collect into g_owner_data
  from json_table(l_response, '$.owner_data[*]' 
          columns(a varchar2(4000) path '$.a'
                 ,b varchar2(4000) path '$.b'));

exception 
  when others then
    raise;
end;
--------------------------------------------------------------------------
procedure p_add_headers
as

begin

  -- clear headers
  apex_web_service.g_request_headers.delete();

  -- set headers
  apex_web_service.g_request_headers(1).name := 'Authorization';
  apex_web_service.g_request_headers(1).value := 'Bearer '||apex_web_service.g_oauth_token.token;
  apex_web_service.g_request_headers(2).name := 'Content-Type';   
  apex_web_service.g_request_headers(2).value := 'application/json';

end;
--------------------------------------------------------------------------
procedure p_run_ws
(p_service in varchar2
,p_type in varchar2
,p_param in varchar2 default null)
as
  l_response clob;
  error500 exception;
  error404 exception;

  l_url varchar2(4000);

begin
  -- prep the url
  l_url := p_service;
--  dbms_output.put_line('url: '||l_url);

  -- execute the webservice
  l_response := apex_web_service.make_rest_request
                  (p_url => l_url
                  ,p_http_method => p_type
                  ,p_body => g_body
                  );

  -- handle ws errors
  if l_response like '%Internal Server Error%' then
    raise ERROR500;
  elsif l_response like '%Not Found%' then
    raise ERROR404;
  else 
    null;
  end if;

  g_response := l_response;

exception 
  when error500 then
    g_response := 'RESPONSE : '||chr(10)||'Internal Server Error (500)';
  when error404 then
    g_response := 'RESPONSE : '||chr(10)||'Not Found (404)';
--    raise;
end;
--------------------------------------------------------------------------
procedure p_interface
as

begin
  -- clear response 
  g_response := null;

  -- prep json body
  p_prep_body;

  -- authenticate
  p_authenticate;

  --clear and set headers
  p_add_headers;

  -- run the web service
  p_run_ws(g_relay_interface, 'POST');

  -- process the response
  p_queue_response;

end;
--------------------------------------------------------------------------
procedure p_refresh
(p_request_id in varchar2)
as

begin
  -- clear response 
  g_response := null;

  -- prep json body
  g_body := '{"p_id_request" : "'||p_request_id||'"}';

  -- authenticate
  p_authenticate;

  --clear and set headers
  p_add_headers;

  -- run the web service
  p_run_ws(g_refresh_instance, 'POST');

  -- process the response
  p_queue_response;

end;
--------------------------------------------------------------------------
procedure p_stop
(p_request_id in varchar2)
as

begin
  -- clear response 
  g_response := null;

  -- prep json body
  g_body := '{"p_id_request" : "'||p_request_id||'"}';

  -- authenticate
  p_authenticate;

  --clear and set headers
  p_add_headers;

  -- run the web service
  p_run_ws(g_stop_instance, 'POST');

  -- process the response
  p_queue_response;

end;
--------------------------------------------------------------------------
procedure p_data_service
(p_service in varchar2)
as

begin

  -- clear body
  g_body := null;

  -- clear response 
  g_response := null;

  -- authenticate
  p_authenticate;

  --clear and set headers
  p_add_headers;

  -- run the web service
  p_run_ws(p_service,'GET');

end;
--------------------------------------------------------------------------
end;
