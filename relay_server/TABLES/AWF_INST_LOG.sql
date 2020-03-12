--------------------------------------------------------
--  DDL for Table AWF_INST_LOG
--------------------------------------------------------

  CREATE TABLE "AWF_INST_LOG" 
   (	"ID_INSTANCE" NUMBER, 
	"ID_WORKFLOW_INDEX" NUMBER, 
	"ID_SEQ" NUMBER, 
	"RUNTIME_ID" NUMBER, 
	"PROGRAM_UNIT" VARCHAR2(1000 BYTE), 
	"POSITION" NUMBER, 
	"PROGRAM" VARCHAR2(1000 BYTE), 
	"LOG_TYPE" VARCHAR2(1000 BYTE), 
	"LOG_ENTRY" VARCHAR2(4000 BYTE), 
	"LOG_TIME" DATE
   ) ;
