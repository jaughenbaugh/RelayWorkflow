--------------------------------------------------------
--  DDL for Type TO_ALL_TAB_COLS
--------------------------------------------------------

  CREATE OR REPLACE TYPE "TO_ALL_TAB_COLS" as object 
(OWNER	VARCHAR2(30)
,TABLE_NAME	VARCHAR2(30)
,COLUMN_NAME	VARCHAR2(30)
,DATA_TYPE	VARCHAR2(106)
,DATA_LENGTH	NUMBER
,DATA_PRECISION	NUMBER
,DATA_SCALE	NUMBER
,NULLABLE	VARCHAR2(1)
,COLUMN_ID	NUMBER)


/
