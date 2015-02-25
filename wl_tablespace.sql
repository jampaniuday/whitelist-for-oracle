/****************************************************************************
* NAME:     WL_TABLESPACE.SQL
*
* PURPOSE:  This script creates the tablespace which contains whitelist 
* database objects. It requires the tablespace name for the whitelist
* as input.
*
* INPUTS:    &1 = Tablespace Name
*
* REVISIONS:
* Ver        Date        Author           Description
* ---------  ----------  ---------------  ---------------------------------
* 1.0        10/19/2014  pmdba            1. Created this script.
*
****************************************************************************/

CREATE SMALLFILE TABLESPACE &1     
DATAFILE SIZE 102400 K AUTOEXTEND ON NEXT 102400 K MAXSIZE UNLIMITED     
LOGGING     
ONLINE     
PERMANENT     
DEFAULT NOCOMPRESS     
EXTENT MANAGEMENT LOCAL AUTOALLOCATE     
FLASHBACK ON;
