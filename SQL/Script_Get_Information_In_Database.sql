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
-------	WAY : CREATE SCRIPT TO CHECK Slow SQL Queries
    -- The result of the query will look something like this below
	SELECT TOP 10 
		SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1, ((CASE qs.statement_end_offset WHEN -1 THEN DATALENGTH(qt.TEXT) ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)+1) AS Query_Script,
		qs.execution_count,
		qs.total_logical_reads, qs.last_logical_reads,
		qs.total_logical_writes, qs.last_logical_writes,
		qs.total_worker_time,
		qs.last_worker_time,
		qs.total_elapsed_time/1000000 total_elapsed_time_in_S,
		qs.last_elapsed_time/1000000 last_elapsed_time_in_S,
		qs.last_execution_time,
		qp.query_plan
	FROM sys.dm_exec_query_stats qs
	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
	CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
	ORDER BY qs.total_logical_reads DESC -- logical reads
	-- ORDER BY qs.total_logical_writes DESC -- logical writes
	-- ORDER BY qs.total_worker_time DESC -- CPU time
---- WAY : CREATE SCRIPT TO Find all index in database
	SELECT
		 t.NAME   AS TABLENAME,
		 col.NAME AS COLUMNNAME,
		 ind.NAME AS INDEXNAME
	FROM
		 SYS.INDEXES ind
	INNER JOIN
		 SYS.INDEX_COLUMNS ic ON  ind.object_id = ic.object_id and ind.index_id = ic.index_id
	INNER JOIN
		 SYS.COLUMNS col ON ic.object_id = col.object_id and ic.column_id = col.column_id
	INNER JOIN
		 SYS.TABLES t ON ind.object_id = t.object_id
	WHERE
		 (ind.is_primary_key = 0
		 AND t.is_ms_shipped = 0)
	ORDER BY
		 t.name, col.name, ind.name
---- WAY: SQL SERVER – How to Disable and Enable All Constraint for Table and Database
-----https://blog.sqlauthority.com/2014/12/02/sql-server-how-to-disable-and-enable-all-constraint-for-table-and-database/
	-- Disable all table constraints
	ALTER TABLE YourTableName NOCHECK CONSTRAINT ALL
	-- Enable all table constraints
	ALTER TABLE YourTableName CHECK CONSTRAINT ALL
	-- ----------
	-- Disable single constraint
	ALTER TABLE YourTableName NOCHECK CONSTRAINT YourConstraint
	-- Enable single constraint
	ALTER TABLE YourTableName CHECK CONSTRAINT YourConstraint
	-- ----------
	-- Disable all constraints for database
	EXEC sp_msforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all"
	-- Enable all constraints for database
	EXEC sp_msforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all"
	
	-- Creating a date dimension or calendar table in SQL Server https://www.mssqltips.com/sqlservertip/4054/creating-a-date-dimension-or-calendar-table-in-sql-server/
	DECLARE @StartDate  date = '20100101';

	DECLARE @CutoffDate date = DATEADD(DAY, -1, DATEADD(YEAR, 30, @StartDate));

	;WITH seq(n) AS 
	(
	  SELECT 0 UNION ALL SELECT n + 1 FROM seq
	  WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate)
	),
	d(d) AS 
	(
	  SELECT DATEADD(DAY, n, @StartDate) FROM seq
	),
	src AS
	(
	  SELECT
	    TheDate         = CONVERT(date, d),
	    TheDay          = DATEPART(DAY,       d),
	    TheDayName      = DATENAME(WEEKDAY,   d),
	    TheWeek         = DATEPART(WEEK,      d),
	    TheISOWeek      = DATEPART(ISO_WEEK,  d),
	    TheDayOfWeek    = DATEPART(WEEKDAY,   d),
	    TheMonth        = DATEPART(MONTH,     d),
	    TheMonthName    = DATENAME(MONTH,     d),
	    TheQuarter      = DATEPART(Quarter,   d),
	    TheYear         = DATEPART(YEAR,      d),
	    TheFirstOfMonth = DATEFROMPARTS(YEAR(d), MONTH(d), 1),
	    TheLastOfYear   = DATEFROMPARTS(YEAR(d), 12, 31),
	    TheDayOfYear    = DATEPART(DAYOFYEAR, d)
	  FROM d
	)
	SELECT * FROM src
	  ORDER BY TheDate
	  OPTION (MAXRECURSION 0);
	
	
	
	
	
