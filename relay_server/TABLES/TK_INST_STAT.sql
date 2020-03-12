--------------------------------------------------------
--  DDL for Table TK_INST_STAT
--------------------------------------------------------

  CREATE TABLE "TK_INST_STAT" 
   (	"ID_RECORD" NUMBER, 
	"ID_ACCT" VARCHAR2(50 BYTE), 
	"ID_PROCESS" NUMBER, 
	"PROCESS_NAME" VARCHAR2(100 BYTE), 
	"ID_INSTANCE" NUMBER, 
	"ID_WF_INDEX" NUMBER, 
	"ID_PROC_REC" NUMBER, 
	"REC_TYPE" NUMBER, 
	"REC_SUBTYPE" NUMBER, 
	"TS_STAMP" NUMBER
   ) ;
