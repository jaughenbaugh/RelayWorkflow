--------------------------------------------------------
--  DDL for Table AWF_INSTANCE
--------------------------------------------------------

  CREATE TABLE "AWF_INSTANCE" 
   (	"ID_RECORD" NUMBER, 
	"ID_PARENT" NUMBER, 
	"IND_ACTIVE" NUMBER(1,0), 
	"INSTANCE_ORIG" VARCHAR2(50 BYTE), 
	"DATE_START" DATE, 
	"ID_PROCESS" NUMBER, 
	"ID_OWNER" VARCHAR2(4000 BYTE), 
	"ID_CHECK_STAMP" NUMBER, 
	"INSTANCE_LOG" CLOB
   ) ;
