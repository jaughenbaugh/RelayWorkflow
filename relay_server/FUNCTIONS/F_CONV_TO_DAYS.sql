--------------------------------------------------------
--  DDL for Function F_CONV_TO_DAYS
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "F_CONV_TO_DAYS" 
(p_unit varchar2
,p_int number)
return number
as

  l_retvar number;

begin

  l_retvar := case p_unit
                when 'SECONDS' then p_int/60/60/24
                when 'MINUTES' then p_int/60/24
                when 'HOURS' then p_int/24
                when 'DAYS' then p_int
                else p_int
              end;

  return l_retvar;  
end;

/
