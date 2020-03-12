--------------------------------------------------------
--  DDL for Table AWF_NODE_ASSIGNMENT
--------------------------------------------------------

  CREATE TABLE "AWF_NODE_ASSIGNMENT" 
   (	"ID_RECORD" NUMBER, 
	"DESCRIPTION" VARCHAR2(500 BYTE), 
	"PRIORITY" NUMBER, 
	"IND_NOTIFY_BY_EMAIL" NUMBER(1,0), 
	"NODE_NUMBER" NUMBER, 
	"ID_ROLE" NUMBER, 
	"ID_ESCROLE" NUMBER, 
	"ID_EMAIL_TEMPLATE" NUMBER, 
	"ID_PROCESS" NUMBER, 
	"ID_PROC_REC" NUMBER, 
	"AMT_FOR_TRUE" NUMBER, 
	"ID_CHECK_STAMP" NUMBER
   ) ;
