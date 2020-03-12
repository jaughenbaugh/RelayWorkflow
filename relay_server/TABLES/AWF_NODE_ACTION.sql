--------------------------------------------------------
--  DDL for Table AWF_NODE_ACTION
--------------------------------------------------------

  CREATE TABLE "AWF_NODE_ACTION" 
   (	"ID_RECORD" NUMBER, 
	"ACTION_NAME" VARCHAR2(50 BYTE), 
	"ID_RELATIONSHIP" NUMBER, 
	"SEQUENCE" NUMBER, 
	"AMT_FOR_TRUE" NUMBER, 
	"IND_STOP_ON_ERROR" NUMBER(1,0), 
	"ID_PROCESS" NUMBER, 
	"ID_PROC_REC" NUMBER, 
	"ID_NODE_NUMBER" NUMBER, 
	"ID_CHECK_STAMP" NUMBER
   ) ;
