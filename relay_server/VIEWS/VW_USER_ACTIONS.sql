--------------------------------------------------------
--  DDL for View VW_USER_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_USER_ACTIONS" ("ID_RECORD", "ACTION_NAME", "DESCRIPTION", "OBJ_OWNER", "OBJ_NAME", "CODE_ACTION_TYPE", "ID_TEMPLATE", "PROG_OWNER", "PROG_NAME", "PROG_TYPE", "FUNC_RETVAR_NAME", "FUNC_RETVAR_TYPE", "ID_CHECK_STAMP", "IND_SAVE_DATA", "ID_ROW") AS 
  SELECT  ID_RECORD,
        ACTION_NAME,
        DESCRIPTION,
        OBJ_OWNER,
        OBJ_NAME,
        CODE_ACTION_TYPE,
        ID_TEMPLATE,
        PROG_OWNER,
        PROG_NAME,
        PROG_TYPE,
        FUNC_RETVAR_NAME,
        FUNC_RETVAR_TYPE,
        ID_CHECK_STAMP,
        IND_SAVE_DATA,
        rowid id_row
FROM    AWF_ACTION a
where   obj_name in  (select obj_name 
                      from   relay_obj_acct o
                      where  acct_id = case 
                                         when length(v('G_USR_AUTH')) > 0 then v('G_USR_AUTH')
                                         else to_char(o.acct_id) 
                                       end)
/*******************************************************************************
-- NAME: VW_USER_ACTIONS
--
-- PURPOSE: Purpose
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
;
