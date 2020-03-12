--------------------------------------------------------
--  DDL for Table AWF_INST_ASSIGN
--------------------------------------------------------

  CREATE TABLE "AWF_INST_ASSIGN" 
   (	"ID_RECORD" NUMBER, 
	"PRIORITY" NUMBER, 
	"ID_ASSIGNEE" VARCHAR2(100 BYTE), 
	"DATE_START" DATE, 
	"DATE_DUE" DATE, 
	"CODE_STATUS" VARCHAR2(50 BYTE), 
	"ID_INSTANCE" NUMBER, 
	"ID_PROCESS" NUMBER, 
	"ID_PROC_REC" NUMBER, 
	"IND_DECISION" NUMBER(1,0), 
	"ID_CHECK_STAMP" NUMBER, 
	"PERSON_CODE" VARCHAR2(200 BYTE)
   ) ;
