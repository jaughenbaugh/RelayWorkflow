--------------------------------------------------------
--  DDL for Table AWF_COMM_TEMPLATE
--------------------------------------------------------

  CREATE TABLE "AWF_COMM_TEMPLATE" 
   (	"ID_RECORD" NUMBER, 
	"TEMPLATE_NAME" VARCHAR2(50 BYTE), 
	"DESCRIPTION" VARCHAR2(500 BYTE), 
	"OBJ_OWNER" VARCHAR2(50 BYTE), 
	"OBJECT_NAME" VARCHAR2(50 BYTE), 
	"SEND_FROM_EMAIL" VARCHAR2(250 BYTE), 
	"REPLY_TO_EMAIL" VARCHAR2(250 BYTE), 
	"SUBJECT_LINE" VARCHAR2(250 BYTE), 
	"MESSAGE_BODY_PT" CLOB, 
	"MESSAGE_BODY_HTML" CLOB, 
	"ID_CHECK_STAMP" NUMBER
   ) ;
