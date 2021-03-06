--------------------------------------------------------
--  DDL for Table AWF_ACTION_PV
--------------------------------------------------------

  CREATE TABLE "AWF_ACTION_PV" 
   (	"ID_RECORD" NUMBER, 
	"ID_CHECK_STAMP" NUMBER, 
	"ID_SEQUENCE" NUMBER, 
	"ACT_PARAMETER" VARCHAR2(50 BYTE), 
	"ACT_PARAM_TYPE" VARCHAR2(50 BYTE), 
	"ACT_PARAM_DIR" VARCHAR2(50 BYTE), 
	"ACT_VALUE" "ANYDATA", 
	"OBJ_OWNER" VARCHAR2(50 BYTE), 
	"OBJ_NAME" VARCHAR2(50 BYTE), 
	"ACTION_NAME" VARCHAR2(50 BYTE), 
	"ACT_PAR_TARGET" VARCHAR2(50 BYTE), 
	"VAR_SOURCE_TYPE" VARCHAR2(20 BYTE), 
	"ID_ACTION" NUMBER
   ) ;
