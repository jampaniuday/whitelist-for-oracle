accept log_file PROMPT 'Enter log file>'

accept wl_user_in CHAR PROMPT 'Enter White List User>'

accept wl_tablespace_in CHAR PROMPT 'Enter White List Tablespace>'

--define log_file = 'proto-install.log';
--define wl_user_in = 'WLSYS';
--define wl_tablespace_in = 'WL_DATA';

--set serveroutput on;
--set serveroutput on format wrap;
--set termout off;
set verify off;
--set feedback off;

execute dbms_application_info.set_action('install white list');

spool &log_file;

/* Create WL Tablespace */
@wl_tablespace.sql &wl_tablespace_in

/* Create WL User */
@wl_user.sql &wl_user_in &wl_tablespace_in

/* Create write_alert_log function */
@write_alert_log.sql &wl_user_in

/* Create and Load Configuration Table */
@wl_config.sql &wl_user_in &wl_tablespace_in
@wl_config_data.sql &wl_user_in &wl_tablespace_in

/* Create Profiles and Rules Tables */
@wl_profiles_seq.sql &wl_user_in
@wl_profiles.sql &wl_user_in &wl_tablespace_in
@wl_rules_seq.sql &wl_user_in
@wl_rules.sql &wl_user_in &wl_tablespace_in

/* Create Approved and Blocked Views */
@wl_approved_profiles.sql &wl_user_in
@wl_blocked_profiles.sql &wl_user_in

/* Create WL Management Package */
@wl_mgmt.pks &wl_user_in
@wl_mgmt.pkb &wl_user_in

/* Create WL Logon Trigger */
@wl_filter.sql &wl_user_in

spool off;
--set termout on;
--set verify on;
--set feedback on;