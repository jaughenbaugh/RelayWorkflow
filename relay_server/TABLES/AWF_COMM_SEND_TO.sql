--------------------------------------------------------
--  DDL for Table AWF_COMM_SEND_TO
--------------------------------------------------------

  CREATE TABLE "AWF_COMM_SEND_TO" 
   (	"ID_RECORD" NUMBER, 
	"ID_TEMPLATE" NUMBER, 
	"SEND_TO_TYPE" VARCHAR2(20 BYTE), 
	"SEND_TO_GROUP" VARCHAR2(5 BYTE) DEFAULT NULL, 
	"SEND_TO" VARCHAR2(500 BYTE), 
	"ID_CHECK_STAMP" NUMBER
   ) ;
