/****************************************************************************
* NAME:     WRITE_ALERT_LOG.SQL
*
* PURPOSE:  This script creates the SYS function which allows the whitelist
* to write trace messages to the database alert log. The script requires the
* whitelist schema name as an input.
*
* INPUTS:    &1 = Schema Name
*
* REVISIONS:
* Ver        Date        Author           Description
* ---------  ----------  ---------------  ---------------------------------
* 1.0        10/19/2014  pmdba            1. Created this script.
*
****************************************************************************/

create or replace FUNCTION SYS.WRITE_ALERT_LOG (p_trace_dest IN VARCHAR2, p_alert_text IN VARCHAR2) RETURN NUMBER IS
tmpVar NUMBER;
/******************************************************************************
NAME:       write_alert_log
PURPOSE:

REVISIONS:
Ver        Date        Author           Description
---------  ----------  ---------------  ------------------------------------
1.0        12/30/2014  pmdba            1. Created this function.

******************************************************************************/
BEGIN
  tmpVar := 0;
  sys.dbms_system.ksdwrt (p_trace_dest, p_alert_text);
  RETURN tmpVar;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN OTHERS THEN
    RAISE;
END write_alert_log;

grant execute on write_alert_log to &1;
