--------------------------------------------------------
--  DDL for Table AWF_PROC_VARS
--------------------------------------------------------

  CREATE TABLE "AWF_PROC_VARS" 
   (	"ID_RECORD" NUMBER, 
	"ID_PROCESS" NUMBER, 
	"VAR_NAME" VARCHAR2(50 BYTE), 
	"VAR_TYPE" VARCHAR2(50 BYTE), 
	"NOTES" VARCHAR2(4000 BYTE), 
	"IND_ACTIVE" NUMBER(1,0), 
	"ID_CHECK_STAMP" NUMBER, 
	"DEFAULT_VAR_VALUE" "ANYDATA", 
	"DVAR_VALUE_TYPE" VARCHAR2(100 BYTE) DEFAULT 'VALUE', 
	"DFLT_CLOB_VALUE" CLOB, 
	"DFLT_BLOB_VALUE" BLOB
   ) ;
