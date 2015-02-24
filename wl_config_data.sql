--------------------------------------------------------
--  File created - Monday-February-09-2015   
--------------------------------------------------------
REM INSERTING into "&1".WL_CONFIG
--SET DEFINE OFF;
Insert into "&1".WL_CONFIG (PARAMETER,VALUE,COMMENTS) values ('RULE_LEVEL','OFF','MAXIMUM - White list rule required for all connections; MEDIUM - White list rule required for all non-proxy connections; MINIMUM - White list rule not required for new profiles');
Insert into "&1".WL_CONFIG (PARAMETER,VALUE,COMMENTS) values ('PROFILE_LEVEL','MEDIUM','MAXIMUM - record detailed profiles for all incoming connections; MEDIUM - record general profiles for all incoming connections; MINIMUM - record username/os_username only in new profiles');
Insert into "&1".WL_CONFIG (PARAMETER,VALUE,COMMENTS) values ('TRACE_LEVEL','OFF','MAXIMUM - generate alert log messages for new profiles and all connections; MEDIUM - generate alert log messages for new profiles and blocked connections; MINIMUM - generate alert log messages for blocked connections; OFF - do not generate alert log messages');
Insert into "&1".WL_CONFIG (PARAMETER,VALUE,COMMENTS) values ('TABLESPACE','&2','White list tablespace name');
Insert into "&1".WL_CONFIG (PARAMETER,VALUE,COMMENTS) values ('LOCK_DATA','FALSE','If true, the white list tablespace will be set to read-only and unlocked only when the wl_mgmt package is updating profiles or rules.');
Insert into "&1".WL_CONFIG (PARAMETER,VALUE,COMMENTS) values ('TRACE_DEST','2','2 - Write messages to the Oracle Alert Log; 1 - Write messages to trace files.');
Insert into "&1".WL_CONFIG (PARAMETER,VALUE,COMMENTS) values ('WL_VERSION','1.0','Build 150101');
