--------------------------------------------------------
--  DDL for Type TK_JSON_REQ
--------------------------------------------------------

  CREATE OR REPLACE TYPE "TK_JSON_REQ" as object 
(a varchar2(4000)
,b varchar2(4000)
,c varchar2(4000)
,d varchar2(4000)
,e varchar2(4000)
,f varchar2(4000)
,g varchar2(4000)
,h varchar2(4000)
,owner_data tk_json_obj
,assignments tk_json_obj
,res_req tk_json_obj
,res_reply tk_json_obj
,choices tk_json_obj
,err_log tk_json_obj);

/
