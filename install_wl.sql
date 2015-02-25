/****************************************************************************
* NAME:     INSTALL_WL.SQL
*
* PURPOSE:  This script installs the whitelist database objects and prepares
* them for first use. The script is interactive and requires no inputs.
*
* REVISIONS:
* Ver        Date        Author           Description
* ---------  ----------  ---------------  ---------------------------------
* 1.0        10/19/2014  pmdba            1. Created this script.
*
* NOTES:     This script must be run as a user with SYSDBA privileges.
*
****************************************************************************/

/****************************************************************************
* If running the script in batch mode, comment out the following "accept" 
* lines.
****************************************************************************/
accept log_file PROMPT 'Enter log file>'
accept wl_user_in CHAR PROMPT 'Enter White List User>'
accept wl_tablespace_in CHAR PROMPT 'Enter White List Tablespace>'

/****************************************************************************
* If running the script in batch mode, un-comment out the following "define" 
* lines and enter your desired parameters before running.
****************************************************************************/
--define log_file = 'install.log';
--define wl_user_in = 'WLSYS';
--define wl_tablespace_in = 'WL_DATA';

/* Set environment and start spooling to the log file */
set verify off;
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
@wl_profiles.sql &wl_user_in &wl_tablespace_in
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
