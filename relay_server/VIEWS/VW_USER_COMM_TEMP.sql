--------------------------------------------------------
--  DDL for View VW_USER_COMM_TEMP
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "VW_USER_COMM_TEMP" ("ID_RECORD", "TEMPLATE_NAME", "DESCRIPTION", "OBJ_OWNER", "OBJECT_NAME", "SEND_FROM_EMAIL", "REPLY_TO_EMAIL", "SUBJECT_LINE", "MESSAGE_BODY_PT", "MESSAGE_BODY_HTML", "ID_CHECK_STAMP", "ID_ROW") AS 
  SELECT  c."ID_RECORD",
        c."TEMPLATE_NAME",
        c."DESCRIPTION",
        c."OBJ_OWNER",
        c."OBJECT_NAME",
        c."SEND_FROM_EMAIL",
        c."REPLY_TO_EMAIL",
        c."SUBJECT_LINE",
        c."MESSAGE_BODY_PT",
        c."MESSAGE_BODY_HTML",
        c."ID_CHECK_STAMP",
        c.id_row
FROM    relay_comm_template_acct c 
where   acct_id = case 
                    when length(v('G_USR_AUTH')) > 0 then v('G_USR_AUTH')
                    else to_char(c.acct_id)
                  end
/*******************************************************************************
-- PACKAGE: VW_USER_COMM_TEMP
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
