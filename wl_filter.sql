/****************************************************************************
* NAME:     WL_FILTER.SQL
*
* PURPOSE:  This script creates the database logon trigger at the heard of
* the whitelist. The script requires the schema name for the whitelist as an
* input. The trigger is disabled by default to ensure that no connections
* are blocked before appropriate rules are created.
*
* INPUTS:    &1 = Schema Name
*
* REVISIONS:
* Ver        Date        Author           Description
* ---------  ----------  ---------------  ---------------------------------
* 1.0        10/19/2014  Magee            1. Created this script.
*
****************************************************************************/

  CREATE OR REPLACE TRIGGER "&1"."WL_FILTER" 
AFTER LOGON
ON DATABASE
/******************************************************************************
   NAME:       WL_FILTER
   PURPOSE:    To record profiles of incoming connection requests and evaluate
               them against a set of rules to determine if they should be 
               allowed.

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        11/6/2014   pmdba            1. Created this trigger.

   NOTES:
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
