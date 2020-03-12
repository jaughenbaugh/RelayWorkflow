--------------------------------------------------------
--  DDL for Package Body PKG_PUBLIC
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "PKG_PUBLIC" 
as
-------------------------------------------------------------------------
-------------------------------------------------------------------------
procedure relay_interface
(p_req_in in tk_json_request
,a out varchar2
,b out varchar2
,d out varchar2
,e out varchar2
,h out varchar2
,i out varchar2
,j out varchar2
,k out varchar2
,owner_data out tk_json_obj
,assignments out number
,res_req out number
,choices out number
,alerts out number
,err_log out number) 
as
  
  l_owner_data tk_json_obj;
  l_assignments tk_json_obj;
  l_res_req tk_json_obj;
  l_choices tk_json_obj;
  l_alerts tk_json_obj;
  l_err_log tk_json_obj;

  l_dummy number;

begin
  l_dummy := tk_p_api.f_wsc('27');

  relay_p_rest.relay_interface
  (p_req_in
  ,a
  ,b
  ,d
  ,e
  ,h
  ,i
  ,j
  ,k
  ,l_owner_data 
  ,l_assignments
  ,l_res_req 
  ,l_choices 
  ,l_alerts 
  ,l_err_log);

  owner_data := l_owner_data;
  assignments := l_assignments.count;
  res_req := l_res_req.count;
  choices := l_choices.count;
  alerts := l_alerts.count;
  err_log := l_err_log.count;

end;
-------------------------------------------------------------------------
procedure stop_instance
(p_id_request in varchar2) 
as

  l_dummy number;

begin
  l_dummy := tk_p_api.f_wsc('29');

  relay_p_rest.p_kill_instance(p_id_request);

end;

end pkg_public;

/
