
  CREATE TABLE "RLY_DEV02"."TK_TQUE_DATA" 
   (	"ID_RECORD" NUMBER DEFAULT NULL, 
	"ID_QUEUE" NUMBER, 
	"COL_ID" NUMBER, 
	"IND_REV" NUMBER, 
	"AD_VALUE" VARCHAR2(4000) COLLATE "USING_NLS_COMP", 
	"AD_VALUE_ORIG" VARCHAR2(4000) COLLATE "USING_NLS_COMP"
   )  DEFAULT COLLATION "USING_NLS_COMP" SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "DATA" 