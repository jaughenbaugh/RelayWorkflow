--------------------------------------------------------
--  DDL for Table TK_REC_ACCT
--------------------------------------------------------

  CREATE TABLE "TK_REC_ACCT" 
   (	"ID_RECORD" NUMBER DEFAULT NULL, 
	"REC_TYPE" NUMBER, 
	"REC_ID" NUMBER, 
	"ACCT_ID" VARCHAR2(50 BYTE)
   ) ;

   COMMENT ON COLUMN "TK_REC_ACCT"."REC_TYPE" IS '1:USER,2:OBJECT,3:PROCESS,4:PERSON,5:GROUP,6:ROLE';
   COMMENT ON TABLE "TK_REC_ACCT"  IS 'WFaaS table';
