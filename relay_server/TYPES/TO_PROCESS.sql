--------------------------------------------------------
--  DDL for Type TO_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE TYPE "TO_PROCESS" as object 
("ID_RECORD" NUMBER, 
	"ID_BASE_PROCESS" NUMBER, 
	"PROCESS_NAME" VARCHAR2(50 BYTE), 
	"DESCRIPTION" VARCHAR2(500 BYTE), 
	"PROC_REVISION" NUMBER, 
	"ID_REVISED_FROM" NUMBER, 
	"ID_ROLE" NUMBER, 
	"OBJ_OWNER" VARCHAR2(50 BYTE), 
	"OBJ_NAME" VARCHAR2(50 BYTE), 
	"ID_PROC_REC" NUMBER, 
	"IND_ENABLED" NUMBER(1,0), 
	"IND_ACTIVE" NUMBER(1,0), 
	"IND_AUTO_INITIATE" NUMBER(1,0), 
	"IND_ALLOW_MORE_INST" NUMBER(1,0), 
	"ID_CHECK_STAMP" NUMBER)


/
