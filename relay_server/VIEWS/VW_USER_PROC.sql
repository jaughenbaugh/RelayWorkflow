--------------------------------------------------------
--  DDL for View VW_USER_PROC
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_USER_PROC" ("ID_RECORD", "ID_BASE_PROCESS", "PROCESS_NAME", "DESCRIPTION", "PROC_REVISION", "ID_REVISED_FROM", "ID_ROLE", "OBJ_OWNER", "OBJ_NAME", "ID_PROC_REC", "IND_ENABLED", "IND_ACTIVE", "IND_AUTO_INITIATE", "IND_ALLOW_MORE_INST", "ID_CHECK_STAMP", "ID_ROW") AS 
  SELECT  p."ID_RECORD",
        p."ID_BASE_PROCESS",
        p."PROCESS_NAME",
        p."DESCRIPTION",
        p."PROC_REVISION",
        p."ID_REVISED_FROM",
        p."ID_ROLE",
        p."OBJ_OWNER",
        p."OBJ_NAME",
        p."ID_PROC_REC",
        p."IND_ENABLED",
        p."IND_ACTIVE",
        p."IND_AUTO_INITIATE",
        p."IND_ALLOW_MORE_INST",
        p."ID_CHECK_STAMP",
        id_row
FROM    relay_proc_acct p
where   acct_id = case 
                    when length(v('G_USR_AUTH')) > 0 then v('G_USR_AUTH')
                    else to_char(p.acct_id)
                  end
/*******************************************************************************
-- PACKAGE: VW_USER_PROC
--
-- PURPOSE: Package Purpose
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
