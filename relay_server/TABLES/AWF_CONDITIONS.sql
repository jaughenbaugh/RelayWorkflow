--------------------------------------------------------
--  DDL for Table AWF_CONDITIONS
--------------------------------------------------------

  CREATE TABLE "AWF_CONDITIONS" 
   (	"ID_RECORD" NUMBER, 
	"CONDITION" CLOB, 
	"ID_RELATIONSHIP" NUMBER, 
	"OBJ_OWNER" VARCHAR2(50 BYTE), 
	"OBJECT" VARCHAR2(50 BYTE), 
	"IND_MUST_BE" NUMBER(1,0), 
	"ID_PROCESS" NUMBER, 
	"ID_PROC_REC" NUMBER, 
	"ID_CHECK_STAMP" NUMBER
   ) ;
