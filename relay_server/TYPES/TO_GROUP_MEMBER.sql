--------------------------------------------------------
--  DDL for Type TO_GROUP_MEMBER
--------------------------------------------------------

  CREATE OR REPLACE TYPE "TO_GROUP_MEMBER" as object 
(ID_RECORD	NUMBER
,ID_PERSON_GROUP	NUMBER
,ID_DELEGATE_OF	NUMBER
,MEMBER_SEQUENCE	NUMBER
,IND_GROUP_DEFAULT	NUMBER(1,0)
,ID_GROUP_MEMBER	NUMBER)


/
