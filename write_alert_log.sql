create or replace FUNCTION     WRITE_ALERT_LOG (p_trace_dest IN VARCHAR2, p_alert_text IN VARCHAR2) RETURN NUMBER IS
tmpVar NUMBER;
/******************************************************************************
NAME:       write_alert_log
PURPOSE:

REVISIONS:
Ver        Date        Author           Description
---------  ----------  ---------------  ------------------------------------
1.0        12/30/2014   Pete            1. Created this function.

NOTES:

Automatically available Auto Replace Keywords:
Object Name:     write_alert_log
Sysdate:         12/30/2014
Date and Time:   12/30/2014, 11:47:03 PM, and 12/30/2014 11:47:03 PM

******************************************************************************/
BEGIN
tmpVar := 0;

sys.dbms_system.ksdwrt (p_trace_dest, p_alert_text);

RETURN tmpVar;
EXCEPTION
WHEN NO_DATA_FOUND THEN
NULL;
WHEN OTHERS THEN
-- Consider logging the error and then re-raise
RAISE;
END write_alert_log;

grant execute on write_alert_log to &1;