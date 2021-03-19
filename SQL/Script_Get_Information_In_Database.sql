------- CREATE SCRIPT TO DELETE ALL TABLE IN DATABASE --------
	SELECT 'DELETE FROM ' + TABLE_SCHEMA + '.' + TABLE_NAME  
	FROM INFORMATION_SCHEMA.TABLES 
	WHERE TABLE_TYPE = 'BASE TABLE'
		 AND TABLE_SCHEMA = 'staging' -- raw, staging
	 --AND TABLE_NAME LIKE '%cam_%'

------- CREATE SCRIPT TO GET INFORMATION ALL TABLE IN DATABASE --------
	SELECT TABLE_CATALOG
		   ,TABLE_SCHEMA
		   ,TABLE_NAME
		   ,COLUMN_NAME
		   ,ORDINAL_POSITION
		   ,IS_NULLABLE
		   ,DATA_TYPE
	FROM INFORMATION_SCHEMA.COLUMNS 
	WHERE TABLE_SCHEMA = 'staging' -- 'raw' -- 'dbo'
	ORDER BY TABLE_SCHEMA,TABLE_NAME,ORDINAL_POSITION
------- 3 WAY :  CREATE SCRIPT TO GET INFORMATION ALL PROCEDURE IN DATABASE --------
--  WAY 1
	SELECT 
		inf.SPECIFIC_CATALOG	AS [DATABASE_NAME],
		inf.SPECIFIC_SCHEMA		AS SCHEMA_PROCEDURE,
		inf.SPECIFIC_NAME		AS NANE_PROCEDURE,
		inf.ROUTINE_TYPE		AS TYPE_PROCEDURE,
		inf.ROUTINE_BODY		AS ROUTINE_BODY,
		inf.ROUTINE_DEFINITION  AS SCRIPT_PROCEDURE,
		inf.IS_DETERMINISTIC,
		inf.SQL_DATA_ACCESS,
		inf.SCHEMA_LEVEL_ROUTINE,
		inf.MAX_DYNAMIC_RESULT_SETS,
		inf.IS_USER_DEFINED_CAST,
		inf.IS_IMPLICITLY_INVOCABLE,
		inf.CREATED,
		inf.LAST_ALTERED
	FROM INFORMATION_SCHEMA.ROUTINES AS inf
	WHERE ROUTINE_TYPE = 'PROCEDURE'
--  WAY 2
	SELECT 
		  SCHEMA_NAME(SCHEMA_ID) AS [SCHEMA],
		  NAME AS NANE_PROCEDURE,
		  OBJECT_ID,
		  SCHEMA_ID,
		  TYPE,
		  TYPE_DESC,
		  CREATE_DATE,
		  MODIFY_DATE,
		  IS_MS_SHIPPED,
		  IS_PUBLISHED,
		  IS_SCHEMA_PUBLISHED
	FROM SYS.OBJECTS
	WHERE TYPE  = 'P' OR TYPE_DESC = 'SQL_STORED_PROCEDURE';
--  WAY 3
	SELECT 
		  SCHEMA_NAME(SCHEMA_ID) AS [SCHEMA],
		  NAME AS NANE_PROCEDURE,
		  OBJECT_ID,
		  SCHEMA_ID,
		  TYPE,
		  TYPE_DESC,
		  CREATE_DATE,
		  MODIFY_DATE,
		  IS_MS_SHIPPED,
		  IS_PUBLISHED,
		  IS_SCHEMA_PUBLISHED
	FROM SYS.PROCEDURES;
------- 3 WAY :  CREATE SCRIPT TO GET INFORMATION ALL VEIW IN DATABASE --------
--  WAY 1
	SELECT 
		  TABLE_CATALOG AS DATABASE_NAME,
		  TABLE_SCHEMA  AS SCHEMA_VIEW,
		  TABLE_NAME    AS NAME_VIEW,
		  VIEW_DEFINITION AS SCRIPT_VIEW,
		  CHECK_OPTION,
		  IS_UPDATABLE
	FROM INFORMATION_SCHEMA.VIEWS;
--  WAY 2
	SELECT 
		  SCHEMA_NAME(v.SCHEMA_ID) AS [SCHEMA],
		  v.NAME AS NANE_VIEW,
		  m.DEFINITION AS SCRIPT_VIEW,
		  v.OBJECT_ID,
		  v.SCHEMA_ID,
		  v.TYPE,
		  v.TYPE_DESC,
		  v.CREATE_DATE,
		  v.MODIFY_DATE,
		  v.IS_MS_SHIPPED,
		  v.IS_PUBLISHED,
		  v.IS_SCHEMA_PUBLISHED
	FROM SYS.VIEWS AS v
	INNER JOIN SYS.SQL_MODULES m 
	ON v.OBJECT_ID = m.OBJECT_ID;
--  WAY 3
	SELECT 
		  SCHEMA_NAME(v.SCHEMA_ID) AS [SCHEMA],
		  v.NAME AS NANE_VIEW,
		  m.DEFINITION AS SCRIPT_VIEW,
		  v.OBJECT_ID,
		  v.SCHEMA_ID,
		  v.TYPE,
		  v.TYPE_DESC,
		  v.CREATE_DATE,
		  v.MODIFY_DATE,
		  v.IS_MS_SHIPPED,
		  v.IS_PUBLISHED,
		  v.IS_SCHEMA_PUBLISHED
	FROM SYS.OBJECTS as v
	INNER JOIN SYS.SQL_MODULES m 
	ON v.OBJECT_ID = m.OBJECT_ID
	WHERE v.type = 'V' OR v.TYPE_DESC = 'VIEW';

------- WAY :  CREATE SCRIPT TO GET INFORMATION ALL FUNCTION IN DATABASE --------
	SELECT 
		o.NAME AS NAME_VIEW,
		m.DEFINITION AS SCRIPT_VIEW,
		o.TYPE_DESC,
		o.OBJECT_ID,
		o.CREATE_DATE,
		o.MODIFY_DATE,
		o.IS_MS_SHIPPED,
		o.IS_PUBLISHED,
		o.IS_SCHEMA_PUBLISHED
	FROM SYS.SQL_MODULES AS m 
	INNER JOIN SYS.OBJECTS o 
		ON m.object_id=o.object_id
	WHERE TYPE_DESC LIKE '%FUNCTION%' OR o.TYPE IN ('IF','TF','FN')