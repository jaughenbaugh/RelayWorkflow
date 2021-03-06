--------------------------------------------------------
--  DDL for Table AWF_ACTION
--------------------------------------------------------

  CREATE TABLE "AWF_ACTION" 
   (	"ID_RECORD" NUMBER, 
	"ACTION_NAME" VARCHAR2(50 BYTE), 
	"DESCRIPTION" VARCHAR2(500 BYTE), 
	"OBJ_OWNER" VARCHAR2(50 BYTE), 
	"OBJ_NAME" VARCHAR2(50 BYTE), 
	"CODE_ACTION_TYPE" VARCHAR2(26 BYTE), 
	"ID_TEMPLATE" NUMBER, 
	"PROG_OWNER" VARCHAR2(50 BYTE), 
	"PROG_NAME" VARCHAR2(4000 BYTE), 
	"PROG_TYPE" VARCHAR2(100 BYTE), 
	"FUNC_RETVAR_NAME" VARCHAR2(50 BYTE), 
	"FUNC_RETVAR_TYPE" VARCHAR2(50 BYTE), 
	"ID_CHECK_STAMP" NUMBER, 
	"IND_SAVE_DATA" NUMBER
   ) ;
