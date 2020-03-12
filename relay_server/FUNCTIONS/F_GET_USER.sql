--------------------------------------------------------
--  DDL for Function F_GET_USER
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "F_GET_USER" 
return varchar2 
authid current_user
as 
begin  
  return user;
end f_get_user;


/
