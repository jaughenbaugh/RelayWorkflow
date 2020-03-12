--------------------------------------------------------
--  DDL for Table AWF_NODE_LINK
--------------------------------------------------------

  CREATE TABLE "AWF_NODE_LINK" 
   (	"ID_RECORD" NUMBER, 
	"ID_PARENT_NODE" NUMBER, 
	"ID_CHILD_NODE" NUMBER, 
	"DESCRIPTION" VARCHAR2(500 BYTE), 
	"IND_IS_POSITIVE" NUMBER(1,0), 
	"SEQUENCE" NUMBER, 
	"AMT_FOR_TRUE" NUMBER, 
	"ID_PROCESS" NUMBER, 
	"ID_PROC_REC" NUMBER, 
	"ID_CHECK_STAMP" NUMBER
   ) ;
