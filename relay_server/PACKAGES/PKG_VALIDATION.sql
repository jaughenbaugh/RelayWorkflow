--------------------------------------------------------
--  DDL for Package PKG_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "PKG_VALIDATION" as
  /*******************************************************************************
  -- PACKAGE: pkg_validation
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

procedure p_validate
(p_id_process in number
,p_val_desc out number
,p_val_text out clob);

function f_enable
(p_id_process in number)
return number;

function f_disable
(p_id_process in number)
return number;

function f_activate
(p_id_process in number)
return number;

function f_deactivate
(p_id_process in number)
return number;

--------------------------------------------------------------------------------
end ;

/
