--------------------------------------------------------
--  DDL for Function F_INT_TO_SEC
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "F_INT_TO_SEC" 
(p_begin timestamp
,p_end timestamp)
return number
as
  l_retvar number;
  l_interval interval day to second;
begin

  l_interval := p_end - p_begin;

  l_retvar := abs(extract( second from l_interval ) 
                + extract( minute from l_interval ) * 60 
                + extract( hour from l_interval ) * 60 * 60 
                + extract( day from l_interval ) * 60 * 60 * 24);

  return l_retvar;  
end;

/
