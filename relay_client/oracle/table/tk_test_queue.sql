
  CREATE TABLE "RLY_DEV02"."TK_TEST_QUEUE" 
   (	"ID_RECORD" NUMBER, 
	"ID_REQUEST" VARCHAR2(50) COLLATE "USING_NLS_COMP", 
	"INTERNAL_ID" VARCHAR2(4000) COLLATE "USING_NLS_COMP", 
	"FLOW_NAME" VARCHAR2(200) COLLATE "USING_NLS_COMP", 
	"OBJ_NAME" VARCHAR2(50) COLLATE "USING_NLS_COMP", 
	"NODE_TYPE" VARCHAR2(50) COLLATE "USING_NLS_COMP", 
	"INPUT_A" VARCHAR2(50) COLLATE "USING_NLS_COMP", 
	"INPUT_C" VARCHAR2(50) COLLATE "USING_NLS_COMP", 
	"CHANGE_ID" VARCHAR2(50) COLLATE "USING_NLS_COMP", 
	"TIMELIMIT" VARCHAR2(50) COLLATE "USING_NLS_COMP", 
	"IND_CONDITION" VARCHAR2(50) COLLATE "USING_NLS_COMP", 
	"ASSIGN" CLOB COLLATE "USING_NLS_COMP", 
	"RES_REQ" CLOB COLLATE "USING_NLS_COMP", 
	"CHOICES" CLOB COLLATE "USING_NLS_COMP", 
	"ALERTS" CLOB COLLATE "USING_NLS_COMP", 
	"ERR_LOG" CLOB COLLATE "USING_NLS_COMP"
   )  DEFAULT COLLATION "USING_NLS_COMP" SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "DATA" 
 LOB ("ASSIGN") STORE AS SECUREFILE (
  TABLESPACE "DATA" ENABLE STORAGE IN ROW CHUNK 8192
  NOCACHE LOGGING  NOCOMPRESS  KEEP_DUPLICATES 
  STORAGE(INITIAL 106496 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)) 
 LOB ("RES_REQ") STORE AS SECUREFILE (
  TABLESPACE "DATA" ENABLE STORAGE IN ROW CHUNK 8192
  NOCACHE LOGGING  NOCOMPRESS  KEEP_DUPLICATES 
  STORAGE(INITIAL 106496 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)) 
 LOB ("CHOICES") STORE AS SECUREFILE (
  TABLESPACE "DATA" ENABLE STORAGE IN ROW CHUNK 8192
  NOCACHE LOGGING  NOCOMPRESS  KEEP_DUPLICATES 
  STORAGE(INITIAL 106496 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)) 
 LOB ("ALERTS") STORE AS SECUREFILE (
  TABLESPACE "DATA" ENABLE STORAGE IN ROW CHUNK 8192
  NOCACHE LOGGING  NOCOMPRESS  KEEP_DUPLICATES 
  STORAGE(INITIAL 106496 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)) 
 LOB ("ERR_LOG") STORE AS SECUREFILE (
  TABLESPACE "DATA" ENABLE STORAGE IN ROW CHUNK 8192
  NOCACHE LOGGING  NOCOMPRESS  KEEP_DUPLICATES 
  STORAGE(INITIAL 106496 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)) 