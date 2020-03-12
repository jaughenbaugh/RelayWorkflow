--------------------------------------------------------
--  DDL for Package Body PKG_ANYDATA
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "PKG_ANYDATA" 
is
/*******************************************************************************
-- PACKAGE: pkg_anydata
--
-- PURPOSE: 
--
-- SVN: $Id: $
-- $HeadURL: $
--
--------------------------------------------------------------------------------
-- REVISION HISTORY:
--
--   DATE        VERSION NAME               DESCRIPTION
--   ----------- ------- ------------------ ------------------------------------
--   23-MAR-2016 0.1.0   Jason Aughenbaugh  Initial revision
*******************************************************************************/
--GLOBALS-----------------------------------------------------------------------
  g_version varchar2(100) := '#VERSION#';
--PROGRAMS----------------------------------------------------------------------
function f_get_version
return varchar2
as
begin
  return g_version;
end ;
--------------------------------------------------------------------------------
function f_date_to_epoch
(p_input in date)
return number
as
  l_retvar number;
begin

  l_retvar := round((sysdate - to_date('19700101000000','YYYYMMDDHH24MISS'))*24*60*60);

  return l_retvar;
end;
--------------------------------------------------------------------------------
function f_epoch_to_date
(p_input in number)
return date
as
  l_retvar date;
begin

  l_retvar := to_date('19700101000000','YYYYMMDDHH24MISS') + (p_input/60/60/24);

  return l_retvar;
end;
--------------------------------------------------------------------------------
function f_anydata_to_clob
(p_input sys.anydata)
return clob
as
  l_retvar clob;
  l_var_type varchar2(100);
begin
  if p_input is not null then

    -- get the variable source type
    l_var_type := ltrim(p_input.gettypename,'SYS.');

    case l_var_type
      when 'BINARY_DOUBLE' then l_retvar := to_clob(anydata.AccessBDouble(p_input));
--      when 'BFILE' then l_retvar := to_clob(anydata.AccessBfile(p_input));
      when 'BINARY_FLOAT' then l_retvar := to_clob(anydata.AccessBFloat(p_input));
--      when 'BLOB' then l_retvar := to_clob(anydata.AccessBlob(p_input));
      when 'CHAR' then l_retvar := to_clob(anydata.AccessChar(p_input));
      when 'CLOB' then l_retvar := to_clob(anydata.AccessClob(p_input));
--      when 'DATE' then l_retvar := to_clob(to_char(anydata.AccessDate(p_input),'YYYY.MM.DD.SSSSS'));
      when 'DATE' then l_retvar := to_clob(to_char(f_date_to_epoch(anydata.AccessDate(p_input))));
      when 'INTERVAL DAY TO SECOND' then l_retvar := to_clob(anydata.AccessIntervalDS(p_input));
      when 'INTERVAL YEAR TO MONTH' then l_retvar := to_clob(anydata.AccessIntervalYM(p_input));
      when 'NCHAR' then l_retvar := to_clob(anydata.AccessNchar(p_input));
      when 'NCLOB' then l_retvar := to_clob(anydata.AccessNClob(p_input));
      when 'NUMBER' then l_retvar := to_clob(anydata.AccessNumber(p_input));
      when 'NVARCHAR2' then l_retvar := to_clob(anydata.AccessNVarchar2(p_input));
      when 'RAW' then l_retvar := to_clob(anydata.AccessRaw(p_input));
      when 'TIMESTAMP' then l_retvar := to_clob(anydata.AccessTimestamp(p_input));
      when 'TIMESTAMP WITH TIMEZONE' then l_retvar := to_clob(anydata.AccessTimestampTZ(p_input));
      when 'TIMESTAMP WITH LOCAL TIMEZONE' then l_retvar := to_clob(anydata.AccessTimestampLTZ(p_input));
      when 'UROWID' then l_retvar := to_clob(anydata.AccessURowid(p_input));
      when 'VARCHAR' then l_retvar := to_clob(anydata.AccessVarchar(p_input));
      when 'VARCHAR2' then l_retvar := to_clob(anydata.AccessVarchar2(p_input));
      else null; 
    end case;

  end if; 

  return l_retvar;
exception
  when others then
    raise;
end ;
--------------------------------------------------------------------------------
-- TODO: merge PKG_SUBSTR_VAR here
--------------------------------------------------------------------------------
function f_run_expression
(p_expression in clob)
return anydata
as
  g_hash varchar2(100) := '#HASH#';

  l_retvar anydata;
  l_anydata sys.anydata;
  l_code_dt_base clob;
  l_code_val_base clob;
  l_code clob;  
  l_result varchar2(4000);

  l_expression clob;

begin

  l_code_dt_base := relay_p_vars.g_ei_set('PAD01').text;
  l_code_val_base := relay_p_vars.g_ei_set('PAD02').text;

  -- load the code base to get the datatype of the expression, replace values
  l_code := l_code_dt_base;
  l_code := replace(l_code,'{EXPR}',l_expression);

  -- execute code to get the datatype
  execute immediate l_code into l_result;

  -- load the base code to execute the expression into an anydata type, replace values
  l_code := l_code_val_base;
  l_code := replace(l_code,'{EXPR}',l_expression);
  l_code := replace(l_code,'{FUNCTION}',l_result);

  -- execute expression into an anydata type, update local variable, return
  execute immediate l_code into l_anydata;

  return l_retvar;
exception
  when others then
    raise;
end ;
--------------------------------------------------------------------------------
function f_get_param_vc2
(p_parameter varchar2)
return varchar2
as

  l_retvar varchar2(4000);
begin

  select anydata.accessvarchar2(parameter_value)
  into   l_retvar
  from   awf_parameters
  where  parameter_name = p_parameter;

  return l_retvar;
exception
  when others then
    raise;
end ;
--------------------------------------------------------------------------------
function f_clob_to_anydata
(p_input in clob
,p_data_type in varchar2)
return anydata
as

  l_input clob := p_input;
  l_retvar anydata;
  l_stmt varchar2(4000);

begin

  if l_input like '%~%' then
    l_input := replace(l_input,'~',chr(10));
  end if;

  if p_data_type = 'DATE' then 
    l_retvar := sys.anydata.convertdate(f_epoch_to_date(to_number(p_input)));
  elsif p_data_type = 'NUMBER' then 
    l_retvar := sys.anydata.convertnumber(to_number(p_input));
  elsif p_data_type = 'VARCHAR2' then 
    l_retvar := sys.anydata.convertvarchar2(dbms_lob.substr(p_input,3999,1));
  else
    l_stmt := 'select sys.anydata.convert'||p_data_type||'(:a) val1 from dual';  

    begin 
      execute immediate (l_stmt) into l_retvar using p_input;
    exception
      when others then
        l_retvar := null;
    end;

  end if;

  return l_retvar;
exception
  when others then
    raise;
end ;
--------------------------------------------------------------------------------
end ;

/
