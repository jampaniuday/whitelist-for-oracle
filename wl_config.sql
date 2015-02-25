/****************************************************************************
* NAME:     WL_CONFIG.SQL
*
* PURPOSE:  This script creates the table which contains configuration 
* parameters for the whitelist. The script requires the schema name and 
* tablespace name for the whitelist as an unputs.
*
* INPUTS:    &1 = Schema Name
*            &2 = Tablespace Name
*
* REVISIONS:
* Ver        Date        Author           Description
* ---------  ----------  ---------------  ---------------------------------
* 1.0        10/19/2014  Magee            1. Created this script.
*
****************************************************************************/

  CREATE TABLE "&1"."WL_CONFIG" 
   (	"PARAMETER" VARCHAR2(30 BYTE), 
	"VALUE" VARCHAR2(30 BYTE), 
	"COMMENTS" VARCHAR2(4000 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL KEEP FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE &2 ;

   COMMENT ON COLUMN "&1"."WL_CONFIG"."PARAMETER" IS 'White list configuration parameter name';
   COMMENT ON COLUMN "&1"."WL_CONFIG"."VALUE" IS 'White llist configuration parameter value';

/****************************************************************************
*  Constraints for Table WL_CONFIG
****************************************************************************/

  ALTER TABLE "&1"."WL_CONFIG" MODIFY ("VALUE" NOT NULL ENABLE);
  ALTER TABLE "&1"."WL_CONFIG" MODIFY ("PARAMETER" NOT NULL ENABLE);
