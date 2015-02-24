--------------------------------------------------------
--  File created - Monday-February-09-2015   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Trigger WL_FILTER
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "&1"."WL_FILTER" 
AFTER LOGON
ON DATABASE
/******************************************************************************
   NAME:       WL_FILTER
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        11/6/2014      1280210206E       1. Created this trigger.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     WL_FILTER
      Sysdate:         11/6/2014
      Date and Time:   11/6/2014, 11:56:23 PM, and 11/6/2014 11:56:23 PM
      Username:        1280210206E (set in TOAD Options, Proc Templates)
      Table Name:       (set in the "New PL/SQL Object" dialog)
      Trigger Options:  (set in the "New PL/SQL Object" dialog)
******************************************************************************/
DECLARE
   v_RULE_ID NUMBER;
BEGIN
   
   v_RULE_ID := WL_MGMT.VALIDATE_PROFILE;
   
   EXCEPTION
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END WL_FILTER;

/
ALTER TRIGGER "&1"."WL_FILTER" DISABLE;
