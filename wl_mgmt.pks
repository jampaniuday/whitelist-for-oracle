/****************************************************************************
* NAME:     WL_MGMT.PKS
*
* PURPOSE:  This script creates the package specification for wl_mgmt, which 
* performs all whitelist operations. The script requires the schema name for 
* the whitelist as an input.
*
* INPUTS:    &1 = Schema Name
*
* REVISIONS:
* Ver        Date        Author           Description
* ---------  ----------  ---------------  ---------------------------------
* 1.0        10/19/2014  pmdba            1. Created this script.
*
****************************************************************************/

create or replace PACKAGE               "&1".WL_MGMT
/****************************************************************************
* NAME:     WL_MGMT
*
* PURPOSE:  This package contains the logic to configure and check white
* list connection profiles and rules. Profiles can be used as prototypes
* for white list rules or for evaluation of rule effectiveness.
*
* REVISIONS:
* Ver        Date        Author           Description
* ---------  ----------  ---------------  ---------------------------------
* 1.0        10/19/2014  pmdba            1. Created this package.
*
* OVERVIEW:
* The primary purpose of this package is to evaluate incoming connections
* against a list of white list rules. A logon trigger should call the
* top-level validate_profile function to determine of the session should be
* permitted.
*
* The validate_profile function will perform the following steps:
* 1. Read configuration parameters from wl_config.
* 2. Read the current profile from the USERENV context.
* 3. Compare the current profile to existing profiles.
* 4. If current profile is new, add it to the wl_profiles table.
* 5. If the current profile is known, update the last_used_date in the
*    wl_profiles table.
* 6. Compare the current profile to rules in the wl_rules table
* 7. If the current profile matches a rule allow the connection,
*    otherwise raise an error and reject the connection.
*
* ERRORS:
* ORA-20101: %s is not authorized to logon as %s in this configuration
* ORA-20102: profile %s does not exist
* ORA-20103: validation rule %s for profile %s already exists
* ORA-20104: %s is authorized to logon as profile %s per rule %s
* ORA-20105: new profile created for %s/%s in this configuration
***************************************************************************/
IS

/****************************************************************************
*  Define global variables
***************************************************************************/
g_TRACE_LEVEL wl_config.value%type;
g_TRACE_DEST NUMBER;
g_PROFILE_LEVEL wl_config.value%type;
g_RULE_LEVEL wl_config.value%type;

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
FUNCTION validate_profile
RETURN NUMBER;

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
FUNCTION read_profile
RETURN WL_PROFILES%ROWTYPE;

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
FUNCTION find_profile(
p_PROFILE IN WL_PROFILES%ROWTYPE)
RETURN NUMBER;

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
FUNCTION find_rule(
p_PROFILE IN WL_PROFILES%ROWTYPE)
RETURN NUMBER;

/****************************************************************************
* update_profile ( p_PROFILE )
*
* This procedure updates an existing entry in the wl_profiles table, based on
* the provided profile.
*
* Inputs: wl_profiles%rowtype of profile to be updated
*
****************************************************************************/
PROCEDURE update_profile(
p_PROFILE IN WL_PROFILES%ROWTYPE );

/****************************************************************************
* drop_profile ( p_PROFILE_ID )
*
* This procedure deletes an existing entry in the wl_profiles table, based on
* the provided Profile ID.
*
* Inputs: Profile ID
*
****************************************************************************/
PROCEDURE drop_profile(
p_PROFILE_ID IN NUMBER );

/****************************************************************************
* update_rule ( p_RULE )
*
* This procedure updates an existing entry in the wl_rules table, based on
* the provided profile.
*
* Inputs: wl_rules%rowtype of rule to be created
*
****************************************************************************/
PROCEDURE update_rule(
p_RULE IN WL_RULES%ROWTYPE );

/****************************************************************************
* drop_rule ( p_RULE_ID )
*
* This procedure deletes an existing entry in the wl_rules table, based on
* the provided Rule ID.
*
* Inputs: Rule ID
*
****************************************************************************/
PROCEDURE drop_rule(
p_RULE_ID IN NUMBER);

/****************************************************************************
* profile2rule ( p_PROFILE_ID )
*
* This procedure creates a custom rule in the wl_rules table, based on the
* provided Profile ID.
*
* Inputs: Profile ID
*
****************************************************************************/
PROCEDURE profile2rule(
p_PROFILE_ID IN NUMBER );

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
FUNCTION get_parameter(
p_PARAMETER IN VARCHAR2)
RETURN wl_config.value%type;
END WL_MGMT;
