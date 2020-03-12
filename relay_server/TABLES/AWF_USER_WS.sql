--------------------------------------------------------
--  DDL for Table AWF_USER_WS
--------------------------------------------------------

  CREATE TABLE "AWF_USER_WS" 
   (	"ID_RECORD" NUMBER, 
	"ID_CHECK_STAMP" NUMBER, 
	"USER_NAME" VARCHAR2(100 BYTE), 
	"WORKSPACE_NAME" VARCHAR2(100 BYTE), 
	"IND_IS_WF_ADMIN" NUMBER, 
	"IND_OWNER" NUMBER, 
	"IND_APPROVED" NUMBER, 
	"NOTES" VARCHAR2(4000 BYTE)
   ) ;
