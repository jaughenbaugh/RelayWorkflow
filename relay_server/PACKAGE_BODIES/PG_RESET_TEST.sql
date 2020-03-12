--------------------------------------------------------
--  DDL for Package Body PG_RESET_TEST
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "PG_RESET_TEST" 
as

procedure p_set_global as
begin
  g_variable := 1;
end p_set_global;

end pg_reset_test;


/
