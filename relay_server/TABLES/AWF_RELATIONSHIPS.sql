--------------------------------------------------------
--  DDL for Table AWF_RELATIONSHIPS
--------------------------------------------------------

  CREATE TABLE "AWF_RELATIONSHIPS" 
   (	"ID_RECORD" NUMBER, 
	"REL_NAME" VARCHAR2(50 BYTE), 
	"DESCRIPTION" VARCHAR2(500 BYTE), 
	"P_OWNER" VARCHAR2(50 BYTE), 
	"P_OBJECT" VARCHAR2(50 BYTE), 
	"C_OWNER" VARCHAR2(50 BYTE), 
	"C_OBJECT" VARCHAR2(50 BYTE), 
	"WHERE_CLAUSE" CLOB, 
	"IND_AWF" NUMBER(*,0) DEFAULT 0, 
	"ID_CHECK_STAMP" NUMBER
   ) ;
