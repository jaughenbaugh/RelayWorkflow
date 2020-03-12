--------------------------------------------------------
--  DDL for Package Body PKG_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "PKG_SECURITY" Is
--------------------------------------------------------------------------------
g_version varchar2(100) := '#VERSION#';
--PROGRAMS----------------------------------------------------------------------
function f_get_version
return varchar2
as
begin
  return g_version;
end ;

Function Authenticate_User
(p_User_Name Varchar2
,p_Password  Varchar2) 
Return Boolean 
As

   l_user relay_users%rowtype;

Begin
   If p_User_Name Is Null Or p_Password Is Null Then

      -- Write to Session, Notification must enter a username and password
      Apex_Util.Set_Session_State('LOGIN_MESSAGE'
                                 ,'Please enter Username and password.');
      Return False;
   End If;

   Begin
      Select *
      Into   l_user
      From   relay_users u
      Where  u.User_Name = p_User_Name;
   Exception
      When No_Data_Found Then

         -- Write to Session, User not found.
         Apex_Util.Set_Session_State('LOGIN_MESSAGE'
                                    ,'User not found');
         Return False;
   End;
   If l_user.user_pw <> relay_p_hutil.sha1_vc((p_password)) then

      -- Write to Session, Password incorrect.
      Apex_Util.Set_Session_State('LOGIN_MESSAGE'
                                 ,'Password incorrect');

      if l_user.login_failures + 1 > 5 then
        update relay_users set login_failures = login_failures + 1, user_status = 'BLOCKED' where user_name = l_user.user_name;
      else
        update relay_users set login_failures = login_failures + 1 where user_name = l_user.user_name;
      end if;

      Return False;
   End If;
   If l_user.user_status = 'BLOCKED' Then
      Apex_Util.Set_Session_State('LOGIN_MESSAGE'
                                 ,'User locked, please contact admin');
      Return False;
   End If;

   update relay_users set login_failures = 0 where user_name = l_user.user_name;

   -- Write user information to Session.
   Apex_Util.Set_Session_State('SESSION_USER_NAME'
                              ,p_User_Name);
   Apex_Util.Set_Session_State('SESSION_EMAIL'
                              ,l_user.user_email);

   Return True;
End;
--------------------------------------------------------------------------------
Procedure Process_Login
(p_User_Name Varchar2
,p_Password  Varchar2
,p_App_Id    Number) 
As
   v_Result Boolean := False;
   g_hash varchar2(100) := '#HASH#';
Begin
   v_Result := Authenticate_User(p_User_Name
                                ,p_Password);
   If v_Result = True Then
      -- Redirect to Page 1 (Home Page).
      Wwv_Flow_Custom_Auth_Std.Post_Login(p_User_Name -- p_User_Name
                                         ,p_Password -- p_Password
                                         ,v('APP_SESSION') -- p_Session_Id
                                         ,p_App_Id || ':1' -- p_Flow_page
                                          );
   Else
      -- Login Failure, redirect to page 101 (Login Page).
      Owa_Util.Redirect_Url('f?p=&APP_ID.:101:&SESSION.');
   End If;
End;
--------------------------------------------------------------------------------
function f_unique_user
(p_user_name in varchar2)
return number
as

  l_retvar number := 0;

begin

  select count(*) 
  into l_retvar
  from relay_users 
  where user_name = p_user_name;

  return l_retvar;
end ;
--------------------------------------------------------------------------------
function f_unique_email
(p_user_email in varchar2)
return number
as

  l_retvar number := 0;

begin

  select count(*) 
  into l_retvar
  from relay_users 
  where user_email = p_user_email;

  return l_retvar;
end ;
--------------------------------------------------------------------------------
End ;

/
