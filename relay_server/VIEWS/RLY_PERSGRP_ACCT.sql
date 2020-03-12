--------------------------------------------------------
--  DDL for View RLY_PERSGRP_ACCT
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "RLY_PERSGRP_ACCT" ("ID_RECORD", "GROUP_NAME", "DESCRIPTION", "GROUP_STATUS", "ACCT_ID", "AUTH_ID", "ID_ROW", "MEMBERS") AS 
  SELECT
    "ID_RECORD",
    "GROUP_NAME",
    "DESCRIPTION",
    "GROUP_STATUS",
    "ACCT_ID",
    "AUTH_ID",
    "ID_ROW",
  (select count(*) from rly_grpmbr_acct where id_person_group = p.id_record) members
  FROM
    relay_persgrp_acct p
;
