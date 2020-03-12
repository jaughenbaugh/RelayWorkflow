--------------------------------------------------------
--  DDL for Function F_GET_OWNER
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "F_GET_OWNER" 
return varchar2 
authid DEFINER
as 
begin  
  return sys_context( 'userenv', 'current_schema' );
end f_get_owner;


/
