--------------------------------------------------------
--  DDL for Table AWF_WF_RECORD
--------------------------------------------------------

  CREATE TABLE "AWF_WF_RECORD" 
   (	"ID_RECORD" NUMBER, 
	"ID_PROCESS" NUMBER, 
	"ID_OWNER" NUMBER, 
	"ID_INSTANCE" NUMBER, 
	"ID_WORKFLOW_RUN" NUMBER, 
	"RECORD_TYPE" VARCHAR2(50 BYTE), 
	"RECORD_SUBTYPE" VARCHAR2(50 BYTE), 
	"DATE_RECORD" TIMESTAMP (6), 
	"ID_PROC_REC" NUMBER, 
	"ID_CHILD_REC" NUMBER, 
	"NOTES" VARCHAR2(4000 BYTE), 
	"ID_CHECK_STAMP" NUMBER
   ) ;
