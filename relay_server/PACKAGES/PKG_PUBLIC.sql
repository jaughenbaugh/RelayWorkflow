--------------------------------------------------------
--  DDL for Package PKG_PUBLIC
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "PKG_PUBLIC" 
as 

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
,err_log out number);

procedure stop_instance
(p_id_request in varchar2);

end pkg_public;

/
