--------------------------------------------------------
--  DDL for Table AWF_INST_VARS
--------------------------------------------------------

  CREATE TABLE "AWF_INST_VARS" 
   (	"ID_RECORD" NUMBER, 
	"ID_INSTANCE" NUMBER, 
	"VAR_TYPE" VARCHAR2(50 BYTE), 
	"VAR_NAME" VARCHAR2(4000 BYTE), 
	"VAR_VALUE" "ANYDATA", 
	"VAR_SOURCE" VARCHAR2(20 BYTE), 
	"VAR_SEQUENCE" NUMBER, 
	"ID_CHECK_STAMP" NUMBER, 
	"CLOB_VALUE" CLOB, 
	"BLOB_VALUE" BLOB, 
	"IND_CHANGED" NUMBER
   ) ;
