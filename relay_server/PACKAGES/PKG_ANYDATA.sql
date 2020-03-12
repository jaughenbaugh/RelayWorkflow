--------------------------------------------------------
--  DDL for Package PKG_ANYDATA
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "PKG_ANYDATA" as
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
--PROGRAM-SPECIFICATIONS--------------------------------------------------------
function f_get_version
return varchar2;

function f_date_to_epoch
(p_input in date)
return number;

function f_epoch_to_date
(p_input in number)
return date;

function f_anydata_to_clob
(p_input sys.anydata)
return clob;

function f_run_expression
(p_expression in clob)
return anydata;

function f_get_param_vc2
(p_parameter varchar2)
return varchar2;

function f_clob_to_anydata
(p_input in clob
,p_data_type in varchar2)
return anydata;
--------------------------------------------------------------------------------
end ;

/
