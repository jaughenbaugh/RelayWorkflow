--------------------------------------------------------
--  DDL for View RLY_GRPMBR_ACCT
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "RLY_GRPMBR_ACCT" ("ID_RECORD", "ID_PERSON_GROUP", "GROUP_NAME", "ID_DELEGATE_OF", "MEMBER_SEQUENCE", "IND_GROUP_DEFAULT", "ID_GROUP_MEMBER", "ID_CHECK_STAMP", "ACCT_ID", "AUTH_ID") AS 
  SELECT
    gm."ID_RECORD",
    gm."ID_PERSON_GROUP",
    pg."GROUP_NAME",
    gm."ID_DELEGATE_OF",
    gm."MEMBER_SEQUENCE",
    gm."IND_GROUP_DEFAULT",
    gm."ID_GROUP_MEMBER",
    gm."ID_CHECK_STAMP",
    pg.acct_id,
    pg.auth_id
  FROM
    awf_group_members gm,
    relay_persgrp_acct pg
  WHERE
    pg.id_record = gm.id_person_group
;
