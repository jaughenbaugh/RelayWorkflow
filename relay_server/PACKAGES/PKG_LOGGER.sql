--------------------------------------------------------
--  DDL for Package PKG_LOGGER
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "PKG_LOGGER" as 
 
procedure p_build_log
(p_program in varchar2
,p_position in number
,p_runtime_id in number
,p_log_type in varchar2
,p_log_entry in clob default '');

procedure p_write_err_log;

procedure p_build_wf_rec
(p_record_type in varchar2
,p_record_subtype in varchar2
,p_id_proc_rec number default null
,p_id_child_rec number default null
,p_notes varchar2 default null);

procedure p_write_wf_rec;


function f_get_log_id
return number;

end;


/
