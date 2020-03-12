--------------------------------------------------------
--  DDL for Package Body PKG_VARIABLES
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "PKG_VARIABLES" as  
  type t_ei_text is table of awf_ei_text%rowtype index by pls_integer;  
  g_ei_text t_ei_text;  
-----------------------------------------------------------------------
function f_get_rel_role
(p_input in varchar2)
return varchar2
as
  l_retvar varchar2(4000);
  l_active_instance number := 0;
  l_role_value varchar2(4000);
  l_var_value clob;
begin
  l_retvar := '-1a';

  begin
    l_active_instance := g_active_instance;
  exception
    when others then 
      l_retvar := '-1b';
  end;

  if nvl(l_active_instance,0) > 0 then
    begin 
      l_var_value := relay_p_anydata.f_anydata_to_clob(g_inst_own_values(l_active_instance)(p_input).var_value);
      l_role_value := substr(l_var_value,1,4000);
    exception
      when others then
        l_retvar := '-1c';
    end;
  end if;

  return l_retvar;
end;
------------------------------------------------------------------------
-- function to convert current date to UTC
function f_conv_to_ue
(p_input date)
return number
as
  l_retvar number;
  l_uepoch date := to_date('01-JAN-1970');
begin

  l_retvar := round((p_input - l_uepoch) * (24*60*60));

  return l_retvar;
end;
------------------------------------------------------------------------
-- function to convert number string to hex code
function f_conv_hex
(p_input number)
return varchar2
as
  l_retvar varchar2(50);
  l_hex_var varchar2(50) := 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
begin
  l_retvar := trim(to_char(p_input,l_hex_var));
  return l_retvar;
end;
--INIT-----------------------------------------------------------------
begin  

  select *   
  bulk collect into g_ei_text  
  from awf_ei_text;  

  for idx in 1..g_ei_text.count loop  

    g_ei_set(g_ei_text(idx).code_text) := g_ei_text(idx);  

  end loop;      
end ;

/
