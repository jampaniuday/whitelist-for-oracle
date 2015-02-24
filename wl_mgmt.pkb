create or replace package body               "&1".WL_MGMT
/****************************************************************************
* NAME:     WL_MGMT
*
* PURPOSE:  This package contains the logic to configure and check white list
* connection profiles and rules. Profiles can be used as prototypes for
* white list rules or for evaluation of rule effectiveness.
*
* REVISIONS:
* Ver        Date        Author           Description
* ---------  ----------  ---------------  ----------------------------------
* 1.0        10/19/2014  Magee            1. Created this package.
****************************************************************************/

as

/****************************************************************************
* validate_profile()
*
* This function validates the current connection profile against white list
* rules. If a rule validating the profile is found, the rule id is returned.
* If no validating rule is found, 0 is returned.
*
* Inputs: None
* Output: Rule ID or 0
*
***************************************************************************/

function validate_profile
return number
as
v_profile_id number;
v_rule_id    number;
v_profile wl_profiles%rowtype;
v_alert_text varchar2(2000);
v_result     number;
begin
/*  Read the current profile from the USERENV context */
v_profile := read_profile;

/*  If profiles are not disabled then record it in wl_profiles */
if g_profile_level != 'OFF' then

/* Compare current profile to recorded profiles */
v_profile_id := find_profile ( v_profile );

/* If this is a new profile, get a PROFILE_ID from the sequence */
if v_profile_id         = 0 then
v_profile.profile_id := wl_profiles_seq.nextval;

/* If this is an existing profile, use the returned profile_id */
else
v_profile.profile_id := v_profile_id;

end if;

/* Update the wl_profiles table with the current profile information */
update_profile ( v_profile );

end if;

/*  Based on RULE_LEVEL, approve or reject current profile */
case

/* If rule enforcement is diabled, then approve the connection */
when g_rule_level = 'OFF' then
v_rule_id      := -1;

/* If enforcement is minimal, user is proxy or profile is new, then
approve the connection                                            */
when g_rule_level = 'MINIMUM' and
(
v_profile.proxy_user is not null or v_profile_id = 0
)
then
v_rule_id := -2;

/* If enforcement is medium and user is a proxy, then approve the
connection                                                      */
when g_rule_level = 'MEDIUM' and v_profile.proxy_user is not null then
v_rule_id      := -3;

/* If enforcement is maximum or other conditions are not met, find a
rule to validate the profile                                       */
else
v_rule_id := find_rule ( v_profile );

end case;

/* Based on validation results and TRACE_LEVEL, generate alert messages
or raise an application error                                        */
case

/* If no matching rule was found and tracing is enabled, write alert */
when v_rule_id = 0 and g_trace_level!='OFF' then

/* Build text message for error response and trace file */
v_alert_text := v_profile.os_user || ' is not authorized to logon as ' ||
v_profile.session_user || ' in this configuration:' || chr (13) || chr (
10) || 'Auth_Ident:[' || v_profile.authenticated_identity ||
'] Auth_Data:[' || v_profile.authentication_data || '] Auth_Method:[' ||
v_profile.authentication_method || '] BG_Job:[' || v_profile.bg_job_id ||
'] DB_Link:[' || v_profile.dblink_info || '] Ent_Ident:[' ||
v_profile.enterprise_identity || '] FG_Job:[' || v_profile.fg_job_id ||
'] Global_UID:[' || v_profile.global_uid || '] Host:[' || v_profile.host
|| '] Ident_Type:[' || v_profile.identification_type || '] IP_Addr:[' ||
v_profile.ip_address || '] SysDBA:[' || v_profile.isdba || '] Module:['
|| v_profile.module || '] Net_Protocol:[' || v_profile.network_protocol
|| '] OS_User:[' || v_profile.os_user || '] PX_Ent_Ident:[' ||
v_profile.proxy_enterprise_identity || '] PX_User:[' ||
v_profile.proxy_user || '] Service:[' || v_profile.service_name ||
'] Session_User:[' || v_profile.session_user || ']';

/* Write message to the alert log */
v_result := sys.write_alert_log (g_trace_dest,' ORA-20101: '|| v_alert_text);

/* Raise application error for the client */
raise_application_error(-20101,v_alert_text);

/* If a matching rule was found and tracing is maximum, write alert */
when v_rule_id != 0 and g_trace_level='MAXIMUM' then

/* Write message to the alert log */
v_alert_text := v_profile.os_user || ' is authorized to logon as profile ' ||
v_profile_id || ' per rule ' || v_rule_id;

v_result := sys.write_alert_log (g_trace_dest, 'ORA-20104: '|| v_alert_text);

else
null;

end case;

return v_rule_id;

end validate_profile;

/****************************************************************************
* read_profile()
*
* This function reads the USERENV context to build the current connection
* profile. It returns the profile as a rowtype.
*
* Inputs: None
* Output: wl_profiles%rowtype with current profile
*
****************************************************************************/
function read_profile
return wl_profiles%rowtype
as
v_profile wl_profiles%rowtype;
begin
/* Gather the 10 Basic Profile fields */
v_profile.profile_id             := 0;
v_profile.last_used_date         := sysdate;
v_profile.authenticated_identity := sys_context('USERENV',
'AUTHENTICATED_IDENTITY');
v_profile.enterprise_identity := sys_context('USERENV',
'ENTERPRISE_IDENTITY');
v_profile.global_uid                := sys_context('USERENV','GLOBAL_UID');
v_profile.os_user                   := sys_context('USERENV','OS_USER');
v_profile.proxy_enterprise_identity := sys_context('USERENV',
'PROXY_ENTERPRISE_IDENTITY');
v_profile.proxy_user     := sys_context('USERENV','PROXY_USER');
v_profile.proxy_userid   := sys_context('USERENV','PROXY_USERID');
v_profile.session_user   := sys_context('USERENV','SESSION_USER');
v_profile.session_userid := sys_context('USERENV','SESSION_USERID');

/* If PROFILE_LEVEL is greater than MINIMUM gather additional fields */
if g_profile_level              != 'MINIMUM' then
v_profile.authentication_data := sys_context('USERENV',
'AUTHENTICATION_DATA');
v_profile.authentication_method := sys_context('USERENV',
'AUTHENTICATION_METHOD');

if sys_context('USERENV','BG_JOB_ID') is not null then
v_profile.bg_job_id                 := '%';

else
v_profile.bg_job_id := null;

end if;
v_profile.client_identifier := sys_context('USERENV','CLIENT_IDENTIFIER')
;
v_profile.client_info := sys_context('USERENV','CLIENT_INFO');
v_profile.dblink_info := sys_context('USERENV','DBLINK_INFO');

if sys_context('USERENV','FG_JOB_ID') is not null then
v_profile.fg_job_id                 := '%';

else
v_profile.fg_job_id := null;

end if;
v_profile.host                := sys_context('USERENV','HOST');
v_profile.identification_type := sys_context('USERENV',
'IDENTIFICATION_TYPE');
v_profile.ip_address       := sys_context('USERENV','IP_ADDRESS');
v_profile.isdba            := sys_context('USERENV','ISDBA');
v_profile.language         := sys_context('USERENV','LANGUAGE');
v_profile.module           := sys_context('USERENV','MODULE');
v_profile.network_protocol := sys_context('USERENV','NETWORK_PROTOCOL');
v_profile.service_name     := sys_context('USERENV','SERVICE_NAME');
v_profile.terminal         := sys_context('USERENV','TERMINAL');

/* If PROFILE_LEVEL is greater than MEDIUM gather additional fields */
if g_profile_level             != 'MEDIUM' then
v_profile.database_role      := sys_context('USERENV','DATABASE_ROLE');
v_profile.db_domain          := sys_context('USERENV','DB_DOMAIN');
v_profile.db_name            := sys_context('USERENV','DB_NAME');
v_profile.db_unique_name     := sys_context('USERENV','DB_UNIQUE_NAME');
v_profile.instance           := sys_context('USERENV','INSTANCE');
v_profile.instance_name      := sys_context('USERENV','INSTANCE_NAME');
v_profile.nls_calendar       := sys_context('USERENV','NLS_CALENDAR');
v_profile.nls_currency       := sys_context('USERENV','NLS_CURRENCY');
v_profile.nls_date_format    := sys_context('USERENV','NLS_DATE_FORMAT');
v_profile.nls_sort           := sys_context('USERENV','NLS_SORT');
v_profile.nls_territory      := sys_context('USERENV','NLS_TERRITORY');
v_profile.server_host        := sys_context('USERENV','SERVER_HOST');
v_profile.session_edition_id := sys_context('USERENV',
'SESSION_EDITION_ID');
v_profile.session_edition_name := sys_context('USERENV',
'SESSION_EDITION_NAME');

end if;

end if;

/* Return current profile rowtype */
return v_profile;

end read_profile;

/****************************************************************************
* find_profile( p_PROFILE )
*
* This function confirms that the current session profile exists in the
* wl_profiles table. If the profile is found, the profile id is returned. If
* the profile is not found, 0 is returned.
*
* Inputs: wl_profiles%rowtype of profile to be checked
* Output: Profile ID or 0
*
****************************************************************************/
function find_profile(
p_profile in wl_profiles%rowtype)
return number
as
v_profile_id number;
begin

/* Get the applicable profile_id if one exists */
select
profile_id
into
v_profile_id
from
wl_profiles
where
nvl(authenticated_identity,'NULL') = nvl(p_profile.authenticated_identity
,'NULL')
and nvl(enterprise_identity,'NULL') = nvl(p_profile.enterprise_identity,
'NULL')
and nvl(global_uid,'NULL')                = nvl(p_profile.global_uid,'NULL')
and nvl(os_user,'NULL')                   = nvl(p_profile.os_user,'NULL')
and nvl(proxy_enterprise_identity,'NULL') = nvl(
p_profile.proxy_enterprise_identity,'NULL')
and nvl(proxy_user,'NULL')          = nvl(p_profile.proxy_user,'NULL')
and nvl(proxy_userid,'NULL')        = nvl(p_profile.proxy_userid,'NULL')
and nvl(session_user,'NULL')        = nvl(p_profile.session_user,'NULL')
and nvl(session_userid,'NULL')      = nvl(p_profile.session_userid,'NULL')
and nvl(authentication_data,'NULL') = nvl(p_profile.authentication_data,
'NULL')
and nvl(authentication_method,'NULL') = nvl(p_profile.authentication_method
,'NULL')
and nvl(bg_job_id,'NULL')           = nvl(p_profile.bg_job_id,'NULL')
and nvl(client_identifier,'NULL')   = nvl(p_profile.client_identifier,'NULL')
and nvl(client_info,'NULL')         = nvl(p_profile.client_info,'NULL')
and nvl(dblink_info,'NULL')         = nvl(p_profile.dblink_info,'NULL')
and nvl(fg_job_id,'NULL')           = nvl(p_profile.fg_job_id,'NULL')
and nvl(host,'NULL')                = nvl(p_profile.host,'NULL')
and nvl(identification_type,'NULL') = nvl(p_profile.identification_type,
'NULL')
and nvl(ip_address,'NULL')         = nvl(p_profile.ip_address,'NULL')
and nvl(isdba,'NULL')              = nvl(p_profile.isdba,'NULL')
and nvl(language,'NULL')           = nvl(p_profile.language,'NULL')
and nvl(module,'NULL')             = nvl(p_profile.module,'NULL')
and nvl(network_protocol,'NULL')   = nvl(p_profile.network_protocol,'NULL')
and nvl(service_name,'NULL')       = nvl(p_profile.service_name,'NULL')
and nvl(terminal,'NULL')           = nvl(p_profile.terminal,'NULL')
and nvl(database_role,'NULL')      = nvl(p_profile.database_role,'NULL')
and nvl(db_domain,'NULL')          = nvl(p_profile.db_domain,'NULL')
and nvl(db_name,'NULL')            = nvl(p_profile.db_name,'NULL')
and nvl(db_unique_name,'NULL')     = nvl(p_profile.db_unique_name,'NULL')
and nvl(instance,'NULL')           = nvl(p_profile.instance,'NULL')
and nvl(instance_name,'NULL')      = nvl(p_profile.instance_name,'NULL')
and nvl(nls_calendar,'NULL')       = nvl(p_profile.nls_calendar,'NULL')
and nvl(nls_currency,'NULL')       = nvl(p_profile.nls_currency,'NULL')
and nvl(nls_date_format,'NULL')    = nvl(p_profile.nls_date_format,'NULL')
and nvl(nls_sort,'NULL')           = nvl(p_profile.nls_sort,'NULL')
and nvl(nls_territory,'NULL')      = nvl(p_profile.nls_territory,'NULL')
and nvl(server_host,'NULL')        = nvl(p_profile.server_host,'NULL')
and nvl(session_edition_id,'NULL') = nvl(p_profile.session_edition_id,
'NULL')
and nvl(session_edition_name,'NULL') = nvl(p_profile.session_edition_name,
'NULL')
and rownum = 1;

/* Return the matching PROFILE_ID */
return v_profile_id;

/* If no matching profile exists, then return a PROFILE_ID of 0 */
exception

when no_data_found then
v_profile_id := 0;

return v_profile_id;

end find_profile;

/****************************************************************************
* find_rule( p_PROFILE )
*
* This function confirms that a rule exists for the provided session profile
* in the wl_rules table. If the rule is found, the rule id is returned. If
* the rule is not found, 0 is returned.
*
* Inputs: wl_profiles%rowtype of profile to be checked
* Output: Rule ID or 0
*
****************************************************************************/
function find_rule(
p_profile in wl_profiles%rowtype)
return number
as
v_rule_id number;
begin

/* Get the applicable rule_id if one exists */
select
r.rule_id
into
v_rule_id
from
wl_rules r
where
nvl(lower(p_profile.authenticated_identity),'NULL') like nvl(lower(
r.authenticated_identity),'NULL')
and nvl(lower(p_profile.enterprise_identity),'NULL') like nvl(lower(
r.enterprise_identity),'NULL')
and nvl(lower(p_profile.global_uid),'NULL') like nvl(lower(r.global_uid),
'NULL')
and nvl(lower(p_profile.os_user),'NULL') like nvl(lower(r.os_user),'NULL')
and nvl(lower(p_profile.proxy_enterprise_identity),'NULL') like nvl(lower(
r.proxy_enterprise_identity),'NULL')
and nvl(lower(p_profile.proxy_user),'NULL') like nvl(lower(r.proxy_user),
'NULL')
and nvl(lower(p_profile.proxy_userid),'NULL') like nvl(lower(r.proxy_userid
),'NULL')
and nvl(lower(p_profile.session_user),'NULL') like nvl(lower(r.session_user
),'NULL')
and nvl(lower(p_profile.session_userid),'NULL') like nvl(lower(
r.session_userid),'NULL')
and nvl(lower(p_profile.authentication_data),'NULL') like nvl(lower(
r.authentication_data),'NULL')
and nvl(lower(p_profile.authentication_method),'NULL') like nvl(lower(
r.authentication_method),'NULL')
and nvl(lower(p_profile.bg_job_id),'NULL') like nvl(lower(r.bg_job_id),
'NULL')
and nvl(lower(p_profile.client_identifier),'NULL') like nvl(lower(
r.client_identifier),'NULL')
and nvl(lower(p_profile.client_info),'NULL') like nvl(lower(r.client_info),
'NULL')
and nvl(lower(p_profile.dblink_info),'NULL') like nvl(lower(r.dblink_info),
'NULL')
and nvl(lower(p_profile.fg_job_id),'NULL') like nvl(lower(r.fg_job_id),
'NULL')
and nvl(lower(p_profile.host),'NULL') like nvl(lower(r.host),'NULL')
and nvl(lower(p_profile.identification_type),'NULL') like nvl(lower(
r.identification_type),'NULL')
and nvl(lower(p_profile.ip_address),'NULL') like nvl(lower(r.ip_address),
'NULL')
and nvl(lower(p_profile.isdba),'NULL') like nvl(lower(r.isdba),'NULL')
and nvl(lower(p_profile.language),'NULL') like nvl(lower(r.language),'NULL'
)
and nvl(lower(p_profile.module),'NULL') like nvl(lower(r.module),'NULL')
and nvl(lower(p_profile.network_protocol),'NULL') like nvl(lower(
r.network_protocol),'NULL')
and nvl(lower(p_profile.service_name),'NULL') like nvl(lower(r.service_name
),'NULL')
and nvl(lower(p_profile.terminal),'NULL') like nvl(lower(r.terminal),'NULL'
)
and nvl(lower(p_profile.database_role),'NULL') like nvl(lower(
r.database_role),'NULL')
and nvl(lower(p_profile.db_domain),'NULL') like nvl(lower(r.db_domain),
'NULL')
and nvl(lower(p_profile.db_name),'NULL') like nvl(lower(r.db_name),'NULL')
and nvl(lower(p_profile.db_unique_name),'NULL') like nvl(lower(
r.db_unique_name),'NULL')
and nvl(lower(p_profile.instance),'NULL') like nvl(lower(r.instance),'NULL'
)
and nvl(lower(p_profile.instance_name),'NULL') like nvl(lower(
r.instance_name),'NULL')
and nvl(lower(p_profile.nls_calendar),'NULL') like nvl(lower(r.nls_calendar
),'NULL')
and nvl(lower(p_profile.nls_currency),'NULL') like nvl(lower(r.nls_currency
),'NULL')
and nvl(lower(p_profile.nls_date_format),'NULL') like nvl(lower(
r.nls_date_format),'NULL')
and nvl(lower(p_profile.nls_sort),'NULL') like nvl(lower(r.nls_sort),'NULL'
)
and nvl(lower(p_profile.nls_territory),'NULL') like nvl(lower(
r.nls_territory),'NULL')
and nvl(lower(p_profile.server_host),'NULL') like nvl(lower(r.server_host),
'NULL')
and nvl(lower(p_profile.session_edition_id),'NULL') like nvl(lower(
r.session_edition_id),'NULL')
and nvl(lower(p_profile.session_edition_name),'NULL') like nvl(lower(
r.session_edition_name),'NULL')
and rownum = 1;

/* Return the matching RULE_ID */
return v_rule_id;

/* If no matching profile exists, then return a RULE_ID of 0 */
exception

when no_data_found then
v_rule_id := 0;

return v_rule_id;

end find_rule;

/****************************************************************************
* update_profile ( p_PROFILE )
*
* This procedure updates an existing entry in the wl_profiles table, based on
* the provided profile.
*
* Inputs: wl_profiles%rowtype of profile to be updated
*
****************************************************************************/
procedure update_profile(
p_profile in wl_profiles%rowtype)
as
v_alert_text varchar2(2000);
v_result     number;
begin

/* Update the exiting profile record if one exists */
update
wl_profiles
set
row = p_profile
where
profile_id = p_profile.profile_id;

/* If the update touches no rows, then insert the profile */
if (sql%rowcount) = 0 then

insert
into
wl_profiles values p_profile;

/* If TRACE_LEVEL is high enough, write new profile details to
the alert log. */
if g_trace_level in ('MEDIUM','MAXIMUM') then
v_alert_text := 'new profile created for '|| p_profile.os_user || '/' ||
p_profile.session_user || ' in this configuration:' || chr (13) || chr (
10) || 'Auth_Ident:[' || p_profile.authenticated_identity ||
'] Auth_Data:[' || p_profile.authentication_data || '] Auth_Method:[' ||
p_profile.authentication_method || '] BG_Job:[' || p_profile.bg_job_id ||
'] DB_Link:[' || p_profile.dblink_info || '] Ent_Ident:[' ||
p_profile.enterprise_identity || '] FG_Job:[' || p_profile.fg_job_id ||
'] Global_UID:[' || p_profile.global_uid || '] Host:[' || p_profile.host
|| '] Ident_Type:[' || p_profile.identification_type || '] IP_Addr:[' ||
p_profile.ip_address || '] SysDBA:[' || p_profile.isdba || '] Module:['
|| p_profile.module || '] Net_Protocol:[' || p_profile.network_protocol
|| '] OS_User:[' || p_profile.os_user || '] PX_Ent_Ident:[' ||
p_profile.proxy_enterprise_identity || '] PX_User:[' ||
p_profile.proxy_user || '] Service:[' || p_profile.service_name ||
'] Session_User:[' || p_profile.session_user || ']';

v_result := sys.write_alert_log (g_trace_dest, 'ORA-20105: '|| v_alert_text);
end if;

end if;

/* Commit the changes to the wl_profiles table */
commit;

end update_profile;

/****************************************************************************
* drop_profile ( p_PROFILE_ID )
*
* This procedure deletes an existing entry in the wl_profiles table, based on
* the provided Profile ID.
*
* Inputs: Profile ID
*
****************************************************************************/
procedure drop_profile
(
p_profile_id in number
)
as
begin

/* Delete the specified profile record from wl_profiles */
delete
from
wl_profiles
where
profile_id=p_profile_id;
commit;

end drop_profile;

/****************************************************************************
* update_rule ( p_RULE )
*
* This procedure updates an existing entry in the wl_rules table, based on
* the provided profile.
*
* Inputs: wl_rules%rowtype of rule to be created
*
****************************************************************************/
procedure update_rule
(
p_rule in wl_rules%rowtype
)
as
begin

/* Update rule record */
update
wl_rules
set
row = p_rule
where
rule_id = p_rule.rule_id;

/* If the update touches no rows, then insert the profile */
if sql%rowcount = 0 then

insert
into
wl_rules values p_rule;

end if;

/* Commit the changes to the wl_profiles table */
commit;

end update_rule;

/****************************************************************************
* drop_rule ( p_RULE_ID )
*
* This procedure deletes an existing entry in the wl_rules table, based on
* the provided Rule ID.
*
* Inputs: Rule ID
*
****************************************************************************/
procedure drop_rule
(
p_rule_id in number
)
as
begin

/* Delete the specified rule record */
delete
from
wl_rules
where
rule_id=p_rule_id;
commit;

end drop_rule;

/****************************************************************************
* profile2rule ( p_PROFILE_ID )
*
* This procedure creates a custom rule in the wl_rules table, based on the
* provided Profile ID.
*
* Inputs: Profile ID
*
****************************************************************************/
procedure profile2rule(
p_profile_id in number)
as
v_profile wl_profiles%rowtype;
v_rule wl_rules%rowtype;
v_rule_id number;
begin

/* Get details of source profile */
select
*
into
v_profile
from
wl_profiles
where
profile_id = p_profile_id;

/* If source profile is not found, raise an error */
if sql%rowcount = 0 then
raise_application_error(-20102,'Profile '|| p_profile_id ||
' does not exist.');

/* If source profile is found, copy details into a rule */
else
v_rule_id := 0;

/* Determine if requested rule already exists */
v_rule_id := find_rule ( v_profile );

/* If no equivalent rule exists, then create a new rule */
if v_rule_id                        = 0 then
v_rule.rule_id                   := wl_rules_seq.nextval;
v_rule.expire_date               := to_date('01-01-4000','MM-DD-YYYY');
v_rule.authenticated_identity    := v_profile.authenticated_identity;
v_rule.enterprise_identity       := v_profile.enterprise_identity;
v_rule.global_uid                := v_profile.global_uid;
v_rule.os_user                   := v_profile.os_user;
v_rule.proxy_enterprise_identity := v_profile.proxy_enterprise_identity
;
v_rule.proxy_user            := v_profile.proxy_user;
v_rule.proxy_userid          := v_profile.proxy_userid;
v_rule.session_user          := v_profile.session_user;
v_rule.session_userid        := v_profile.session_userid;
v_rule.authentication_data   := v_profile.authentication_data;
v_rule.authentication_method := v_profile.authentication_method;
v_rule.bg_job_id             := v_profile.bg_job_id;
v_rule.client_identifier     := v_profile.client_identifier;
v_rule.client_info           := v_profile.client_info;
v_rule.dblink_info           := v_profile.dblink_info;
v_rule.fg_job_id             := v_profile.fg_job_id;
v_rule.host                  := v_profile.host;
v_rule.identification_type   := v_profile.identification_type;
v_rule.ip_address            := v_profile.ip_address;
v_rule.isdba                 := v_profile.isdba;
v_rule.language              := v_profile.language;
v_rule.module                := v_profile.module;
v_rule.network_protocol      := v_profile.network_protocol;
v_rule.service_name          := v_profile.service_name;
v_rule.terminal              := v_profile.terminal;
v_rule.database_role         := v_profile.database_role;
v_rule.db_domain             := v_profile.db_domain;
v_rule.db_name               := v_profile.db_name;
v_rule.db_unique_name        := v_profile.db_unique_name;
v_rule.instance              := v_profile.instance;
v_rule.instance_name         := v_profile.instance_name;
v_rule.nls_calendar          := v_profile.nls_calendar;
v_rule.nls_currency          := v_profile.nls_currency;
v_rule.nls_date_format       := v_profile.nls_date_format;
v_rule.nls_sort              := v_profile.nls_sort;
v_rule.nls_territory         := v_profile.nls_territory;
v_rule.server_host           := v_profile.server_host;
v_rule.session_edition_id    := v_profile.session_edition_id;
v_rule.session_edition_name  := v_profile.session_edition_name;

insert
into
wl_rules values v_rule;
commit;

/* If an equivalent rule exists, raise an error */
else
raise_application_error(-20103,'Validation rule '|| v_rule_id ||
' for profile '|| p_profile_id ||' already exists.');

end if;

end if;

end profile2rule;

/****************************************************************************
* get_parameter ( p_PARAMETER )
*
* This function retrieves the value of the designated white list parameter
* from the wl_config table.
*
* Inputs: Parameter Name
* Output: Parameter Value
*
****************************************************************************/
function get_parameter
(
p_parameter in varchar2
)
return wl_config.value%type
as
v_value wl_config.value%type;
begin

/* Get the parameter value from the wl_config table */
select
value
into
v_value
from
wl_config
where
parameter = p_parameter;

return v_value;

/* If no value is found, then return a null value for the parameter */
exception

when no_data_found then
v_value := null;

return v_value;

end get_parameter;

begin

/* Load configuration variables */
g_trace_level   := get_parameter('TRACE_LEVEL');
g_trace_dest    := to_number(get_parameter('TRACE_DEST'));
g_profile_level := get_parameter('PROFILE_LEVEL');
g_rule_level    := get_parameter('RULE_LEVEL');

end wl_mgmt;
