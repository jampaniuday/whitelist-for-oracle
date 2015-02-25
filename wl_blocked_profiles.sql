/****************************************************************************
* NAME:     WL_BLOCKED_PROFILES
*
* PURPOSE:  This view illustrates which connection profiles would be 
* denied access to the database, based on the current whitelist rules. 
*
* REVISIONS:
* Ver        Date        Author           Description
* ---------  ----------  ---------------  ---------------------------------
* 1.0        10/19/2014  Magee            1. Created this view.
*
****************************************************************************/

CREATE OR REPLACE FORCE VIEW "&1"."WL_BLOCKED_PROFILES" ("PROFILE_ID") AS 
  select profile_id from wl_profiles where profile_id not in (select distinct profile_id from wl_approved_profiles);

/****************************************************************************
* NAME:     WL_APPROVED_PROFILES_DETAIL
*
* PURPOSE:  This view illustrates which connection profiles would be 
* approved to connect to the database, including the profile details, based
* on the current whitelist rules.
*
* REVISIONS:
* Ver        Date        Author           Description
* ---------  ----------  ---------------  ---------------------------------
* 1.0        10/19/2014  Magee            1. Created this view.
*
****************************************************************************/

CREATE OR REPLACE FORCE VIEW "&1".WL_BLOCKED_PROFILES_DETAIL
(
   PROFILE_ID,
   LAST_USED_DATE,
   AUTHENTICATED_IDENTITY,
   ENTERPRISE_IDENTITY,
   GLOBAL_UID,
   OS_USER,
   PROXY_ENTERPRISE_IDENTITY,
   PROXY_USER,
   PROXY_USERID,
   SESSION_USER,
   SESSION_USERID,
   AUTHENTICATION_DATA,
   AUTHENTICATION_METHOD,
   BG_JOB_ID,
   CLIENT_IDENTIFIER,
   CLIENT_INFO,
   DBLINK_INFO,
   FG_JOB_ID,
   HOST,
   IDENTIFICATION_TYPE,
   IP_ADDRESS,
   ISDBA,
   LANGUAGE,
   MODULE,
   NETWORK_PROTOCOL,
   SERVICE_NAME,
   TERMINAL,
   DATABASE_ROLE,
   DB_DOMAIN,
   DB_NAME,
   DB_UNIQUE_NAME,
   INSTANCE,
   INSTANCE_NAME,
   NLS_CALENDAR,
   NLS_CURRENCY,
   NLS_DATE_FORMAT,
   NLS_SORT,
   NLS_TERRITORY,
   SERVER_HOST,
   SESSION_EDITION_ID,
   SESSION_EDITION_NAME
)
AS
   SELECT "PROFILE_ID",
          "LAST_USED_DATE",
          "AUTHENTICATED_IDENTITY",
          "ENTERPRISE_IDENTITY",
          "GLOBAL_UID",
          "OS_USER",
          "PROXY_ENTERPRISE_IDENTITY",
          "PROXY_USER",
          "PROXY_USERID",
          "SESSION_USER",
          "SESSION_USERID",
          "AUTHENTICATION_DATA",
          "AUTHENTICATION_METHOD",
          "BG_JOB_ID",
          "CLIENT_IDENTIFIER",
          "CLIENT_INFO",
          "DBLINK_INFO",
          "FG_JOB_ID",
          "HOST",
          "IDENTIFICATION_TYPE",
          "IP_ADDRESS",
          "ISDBA",
          "LANGUAGE",
          "MODULE",
          "NETWORK_PROTOCOL",
          "SERVICE_NAME",
          "TERMINAL",
          "DATABASE_ROLE",
          "DB_DOMAIN",
          "DB_NAME",
          "DB_UNIQUE_NAME",
          "INSTANCE",
          "INSTANCE_NAME",
          "NLS_CALENDAR",
          "NLS_CURRENCY",
          "NLS_DATE_FORMAT",
          "NLS_SORT",
          "NLS_TERRITORY",
          "SERVER_HOST",
          "SESSION_EDITION_ID",
          "SESSION_EDITION_NAME"
     FROM wl_profiles
    WHERE profile_id IN (SELECT profile_id FROM wl_blocked_profiles);
