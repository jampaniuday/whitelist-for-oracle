/****************************************************************************
* NAME:     WL_CONFIG_DATA.SQL
*
* PURPOSE:  This script defalt loads configuration parameters for the 
* whitelist. The script requires the schema name for the whitelist as an 
* input.
*
* INPUTS:    &1 = Schema Name
*
* REVISIONS:
* Ver        Date        Author           Description
* ---------  ----------  ---------------  ---------------------------------
* 1.0        10/19/2014  Magee            1. Created this script.
*
****************************************************************************/

Insert into "&1".WL_CONFIG (PARAMETER,VALUE,COMMENTS) values ('RULE_LEVEL','OFF','MAXIMUM - White list rule required for all connections; MEDIUM - White list rule required for all non-proxy connections; MINIMUM - White list rule not required for new profiles');
Insert into "&1".WL_CONFIG (PARAMETER,VALUE,COMMENTS) values ('PROFILE_LEVEL','MEDIUM','MAXIMUM - record detailed profiles for all incoming connections; MEDIUM - record general profiles for all incoming connections; MINIMUM - record username/os_username only in new profiles');
Insert into "&1".WL_CONFIG (PARAMETER,VALUE,COMMENTS) values ('TRACE_LEVEL','OFF','MAXIMUM - generate alert log messages for new profiles and all connections; MEDIUM - generate alert log messages for new profiles and blocked connections; MINIMUM - generate alert log messages for blocked connections; OFF - do not generate alert log messages');
Insert into "&1".WL_CONFIG (PARAMETER,VALUE,COMMENTS) values ('TABLESPACE','&2','White list tablespace name');
Insert into "&1".WL_CONFIG (PARAMETER,VALUE,COMMENTS) values ('TRACE_DEST','2','2 - Write messages to the Oracle Alert Log; 1 - Write messages to trace files.');
Insert into "&1".WL_CONFIG (PARAMETER,VALUE,COMMENTS) values ('WL_VERSION','1.0','Build 150101');
