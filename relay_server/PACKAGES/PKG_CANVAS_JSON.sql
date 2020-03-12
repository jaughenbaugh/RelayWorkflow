--------------------------------------------------------
--  DDL for Package PKG_CANVAS_JSON
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "PKG_CANVAS_JSON" as 
function f_get_version
return varchar2;

procedure p_clob_to_table
(p_clob in clob);

procedure p_process_wf_json
(p_id_process number
,p_proc_json clob);

function f_get_d2d_node
(p_node_type in awf_node.node_type%type
,p_node_id in awf_node.id_proc_rec%type
,p_image_path in varchar2)
return clob;

function f_get_d2d_process
(p_id_process in awf_process.id_record%type
,p_image_path in varchar2)
return clob;

end ;

/
