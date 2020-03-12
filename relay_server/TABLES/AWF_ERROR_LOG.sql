--------------------------------------------------------
--  DDL for Table AWF_ERROR_LOG
--------------------------------------------------------

  CREATE TABLE "AWF_ERROR_LOG" 
   (	"ID_RECORD" NUMBER, 
	"ID_INSTANCE" NUMBER, 
	"ID_WF_RUN" NUMBER, 
	"ERROR_LOG" CLOB, 
	"DATE_LOG" DATE, 
	"ID_STAMP" NUMBER
   ) ;
