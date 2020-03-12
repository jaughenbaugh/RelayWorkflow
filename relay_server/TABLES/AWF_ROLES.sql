--------------------------------------------------------
--  DDL for Table AWF_ROLES
--------------------------------------------------------

  CREATE TABLE "AWF_ROLES" 
   (	"ID_RECORD" NUMBER, 
	"ROLE_NAME" VARCHAR2(50 BYTE), 
	"DESCRIPTION" VARCHAR2(500 BYTE), 
	"ROLE_TYPE" VARCHAR2(50 BYTE), 
	"IND_BROADCAST" NUMBER(1,0), 
	"VALUE" VARCHAR2(250 BYTE), 
	"ID_CHECK_STAMP" NUMBER, 
	"IND_REL_DATA" NUMBER, 
	"OBJ_COL" VARCHAR2(20 BYTE)
   ) ;
