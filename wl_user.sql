/****************************************************************************
* NAME:     WL_USER.SQL
*
* PURPOSE:  This script creates the schema which contains whitelist database
* objects. It requires the schema name and tablespace name for the whitelist
* as inputs.
*
* INPUTS:    &1 = Schema Name
*            &2 = Tablespace Name
*
* REVISIONS:
* Ver        Date        Author           Description
* ---------  ----------  ---------------  ---------------------------------
* 1.0        10/19/2014  pmdba            1. Created this script.
*
****************************************************************************/

/* Create the user/schema for the whitelist */

CREATE USER &1
IDENTIFIED BY VALUES 'no_login_allowed'
DEFAULT TABLESPACE &2
QUOTA UNLIMITED ON &2
PROFILE DEFAULT
ACCOUNT UNLOCK;

/* Grant appropriate system privileges to the whitelist user */

GRANT CREATE INDEXTYPE,
      CREATE VIEW,
      CREATE CLUSTER,
      CREATE SESSION,
      CREATE JOB,
      CREATE MATERIALIZED VIEW,
      CREATE TRIGGER,
      CREATE SYNONYM,
      CREATE ANY CONTEXT,
      CREATE OPERATOR,
      CREATE SEQUENCE,
      CREATE TABLE,
      CREATE DIMENSION,
      CREATE TYPE,
      CREATE PROCEDURE
   TO &1;
