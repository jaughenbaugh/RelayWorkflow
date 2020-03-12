--------------------------------------------------------
--  DDL for Table AWF_INSTANCE_STATE
--------------------------------------------------------

  CREATE TABLE "AWF_INSTANCE_STATE" 
   (	"ID_RECORD" NUMBER, 
	"ID_INSTANCE" NUMBER, 
	"NODE_NUMBER" NUMBER, 
	"NODE_STATUS" VARCHAR2(30 BYTE), 
	"IND_ACTIVE" NUMBER(1,0), 
	"ID_PROCESS" NUMBER, 
	"DATE_SET" DATE, 
	"IND_UI_REQD" NUMBER(1,0), 
	"ID_LINK_FWD" NUMBER, 
	"ID_CHECK_STAMP" NUMBER
   ) ;
