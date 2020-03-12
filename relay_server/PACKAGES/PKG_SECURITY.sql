--------------------------------------------------------
--  DDL for Package PKG_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "PKG_SECURITY" Is

function f_get_version
return varchar2;

Function Authenticate_User
(p_User_Name Varchar2
,p_Password  Varchar2) 
Return Boolean;


Procedure Process_Login
(p_User_Name Varchar2
,p_Password  Varchar2
,p_App_Id    Number);

function f_unique_user
(p_user_name in varchar2)
return number;

function f_unique_email
(p_user_email in varchar2)
return number;

End ;


/
