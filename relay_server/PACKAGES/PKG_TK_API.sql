--------------------------------------------------------
--  DDL for Package PKG_TK_API
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "PKG_TK_API" as


-- IS THIS USED???

--------------------------------------------------------------------------------
function f_get_version
return varchar2;

PROCEDURE p_TK_OBJECT(
p_id_record        IN OUT tk_object.id_record%type ,
p_auth_id          IN OUT tk_object.auth_id%type ,
p_obj_name         IN OUT tk_object.obj_name%type ,
p_ind_active       IN OUT tk_object.ind_active%type ,
p_description      IN OUT tk_object.description%type ,
p_id_row           IN VARCHAR2 ,
p_operation        IN VARCHAR2);

function f_wsc
(p_name in varchar2)
return number;

procedure p_inst_stat
(p_rec_type number
,p_rec_subtype number
,p_rec_id number);

procedure p_write_istat;

--------------------------------------------------------------------------------
end;

/
