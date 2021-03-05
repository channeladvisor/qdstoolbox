SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

----------------------------------------------------------------------------------
-- Procedure Name: [dbo].[QDSCacheCleanup]
--
-- Desc: This script clears entries from the QDS data release space and avoid the automated space-based cleanup
--
--
-- Parameters:
--	INPUT
--		@ServerIdentifier			SYSNAME			--	Identifier assigned the server.
--														[Default: @@SERVERNAME]
--
--		@DatabaseName				SYSNAME			--	Name of the database apply the QDS cleanup process on
--
--		@CleanAdhocStale			BIT				--	Flag to clean queries that:
--															Are ad-hoc queries (don't belong any object)
--															Haven't been executed at least @MinExecutionCount times
--															Haven't been executed in the last @Retention hours
--														[Default: 0; is it included in the @CleanStale flag]
--
--		@CleanStale					BIT				--	Flag to clean queries that:
--															Queries belonging an object and ad-hoc ones (don't belong any object)
--															Haven't been executed at least @MinExecutionCount times
--															Haven't been executed in the last @Retention hours
--														[Default: 1]
--
--		@Retention					INT				--	Hours since the last execution of the query 
--														[Default: 168 (24*7), one week]
--														IF @Retention = 0, ALL queries will be flagged for deletion
--
--		@MinExecutionCount			INT				--	Minimum number of executions NOT to delete the query
--														[Default :2; deletes queries executed only once]
--														If @MinExecutionCount = 0, ALL queries will be flagged for deletion
--
--		@CleanOrphan				BIT				--	Flag to clean queries associated with deleted objects
--														[Default: 1]
--
--		@CleanInternal				BIT				--	Flag to clean queries identified as internal ones by QDS (UPDATE STATISTICS, INDEX REBUILD....)
--														[Default: 1]
--
--		@CleanStatsOnly				BIT				--	Changes the behavior of the clean process so only the stats will be cleaned, but not the plans, queries and queries' texts.
--														[Default: 0]
--
--		@ReportAsText				BIT				--	Flag print out a report on the space released after the removal of the queries' information (in a text format). 
--														[Default: 0]
--
--		@ReportAsTable				BIT				--	Flag print out a report on the space released after the removal of the queries' information (in a table format).
--														[Default: 0]
--
--		@ReportIndexOutputTable			NVARCHAR(800)	--	Table store the summary of the report, such as parameters used.
--														[Default: NULL, results returned user]
--														Table definition available in the dbo.QDSCacheCleanupIndex script
--
--		@ReportDetailsAsTable		BIT				--	Flag print out a report with the details of each query targeted for deletion,
--														including the query text and the parameters used select the query
--														[Default: 0]
--
--		@ReportDetailsOutputTable	NVARCHAR(800)	--	Table store the summary's details
--														[Default: NULL, results returned user]
--														Table definition available in the dbo.QDSCleanSummary script
--														In order decompress the content og the [QueryText] column, use the command 
--														CAST(DECOMPRESS([QueryText] AS NVARCHAR(MAX))
--
--		@TestMode					BIT				--	Flag execute the SP in test mode. 
--														[Default: 0: queries are deleted]
--
--		@VerboseMode				BIT				--	Flag include verbose messages. 
--														[Default: 0; no output messages]
--
--	OUTPUT
--		@ReportID					BIGINT			--	Returns the ReportID (when the report is being logged into a table)
--
-- Sample execution:
--
--		*** Report-Only: this execution is recommended before applying any change into a live environment in order review the impact of the different parameters would have
--
--		EXECUTE [dbo].[QDSCacheCleanup]
--			 @DatabaseName = 'Database01'
--			,@CleanAdhocStale = 0
--			,@CleanStale = 1
--			,@Retention = 24
--			,@MinExecutionCount = 2
--			,@CleanOrphan = 1
--			,@CleanInternal = 1
--			,@ReportAsTable = 1
--			,@ReportDetailsAsTable = 1
--			,@TestMode = 1
--
--		This execution will generate 2 separate reports:
--			Estimated space used by the queries be deleted (including query text, execution plans, and both runtime and wait statistics
--			Complete list of the queries selected be deleted, along with details on their execution analyze why they have been selected be deleted and the text of the query itself
--		Using the following parameters:
--			Queries that haven't been executed at (@MinExecutionCount) 2 times in the past (@Retention) 24 hours
--			Queries associated objects that no longer exist (@Orphan = 1)
--			Internal queries such as index / statistics maintenance
--		But won't perform any actual cleanup
--
--
--
--		*** Basic-logged cleanup: this execution is recommended when a cleanup is required but logging is necessary for further analysis afterwards
--
--		EXECUTE [dbo].[QDSCacheCleanup]
--			 @DatabaseName				= 'Database01'
--			,@ReportIndexOutputTable	= '[LinkedSQL].[CentralMaintenanceDB].[dbo].[QDSCacheCleanupIndex]'
--			,@ReportDetailsOutputTable	= '[LinkedSQL].[CentralMaintenanceDB].[dbo].[QDSCacheCleanupDetails]'
--
--		This execution will generate 2 separate reports:
--			Stored in the table [dbo].[QDSCleanSummary] on the database [CentralMaintenanceDB] on the linked server [LinkedSQL] : Estimated space used by the queries be deleted (including query text, execution plans, and both runtime and wait statistics
--			Stored in the table [dbo].[QDSCleanQueryDetails] on the database [CentralMaintenanceDB] on the linked server [LinkedSQL] : Complete list of the queries selected be deleted, along with details on their execution analyze why they have been selected be deleted and the text of the query itself
--		using the default parameters
--		Will also perform the actual cleanup using the default parameters
--
--
-- Date: 2020.10.22
-- Auth: Pablo Lozano (@sqlozano)
--
-- Date: 2021.02.28
-- Auth: Pablo Lozano (@sqlozano)
-- Changes:	Fixed an error in the dynamic SQL command not properly joining the QDS tables from the target @DatabaseName
--		 	Added support for SQL 2016
----------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[QDSCacheCleanup]
(
	 @ServerIdentifier			SYSNAME			=	NULL
	,@DatabaseName				SYSNAME			=	NULL
	,@CleanAdhocStale			BIT				=	0
	,@CleanStale				BIT				=	1
	,@Retention					INT				=	168
	,@MinExecutionCount			INT				=	2
	,@CleanOrphan				BIT				=	1
	,@CleanInternal				BIT				=	1
	,@CleanStatsOnly			BIT				=	1
	,@ReportAsText				BIT				=	0
	,@ReportAsTable				BIT				=	0
	,@ReportIndexOutputTable	NVARCHAR(800)	=	NULL
	,@ReportDetailsAsTable		BIT				=	0
	,@ReportDetailsOutputTable	NVARCHAR(800)	=	NULL
	,@TestMode					BIT				=	0
	,@VerboseMode				BIT				=	0
	,@ReportID					BIGINT			=	NULL	OUTPUT
)
AS
BEGIN
SET NOCOUNT ON
-- Get the Version # to ensure it runs SQL2016 or higher
DECLARE @Version INT =  CAST(SUBSTRING(CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')),0,CHARINDEX('.',CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')),0)) AS INT)
IF (@Version < 13)
BEGIN
	RAISERROR('[dbo].[QDSCacheCleanup] requires SQL 2016 or higher',16,1)
	RETURN -1
END

-- If no @ServerIdentifier is provided, use @@SERVERNAME - START
IF (@ServerIdentifier IS NULL) OR (@ServerIdentifier = '')
	SET @ServerIdentifier = @@SERVERNAME
-- If no @ServerIdentifier is provided, use @@SERVERNAME - END

-- If no @DatabaseName is provided, use current one - START
IF (@DatabaseName IS NULL) OR (@DatabaseName = '')
	SET @DatabaseName = DB_NAME()
-- If no @DatabaseName is provided, use current one - END

-- Check whether @DatabaseName actually exists - START
IF NOT EXISTS (SELECT 1 FROM [sys].[databases] WHERE [name] = @DatabaseName)
BEGIN
	RAISERROR('The database [%s] does not exist', 16, 0, @DatabaseName)
	RETURN
END
-- Check whether @DatabaseName actually exists - END

-- Check whether @DatabaseName is ONLINE - START
IF EXISTS (SELECT 1 FROM [sys].[databases] WHERE [name] = @DatabaseName AND [state_desc] <> 'ONLINE')
BEGIN
	RAISERROR('The database [%s] is not online', 16, 0, @DatabaseName)
	RETURN
END
-- Check whether @DatabaseName is ONLINE - END

DECLARE @SqlCmd NVARCHAR(MAX) = ''
DECLARE @ExecutionTime DATETIMEOFFSET(7) = GETUTCDATE()

-- Declare variable & create table extract @@ROWCOUNT values from dynamic T-SQL - START
DECLARE @Rows BIGINT 
CREATE TABLE #Rows ( r BIGINT )
-- Declare variable & create table extract @@ROWCOUNT values from dynamic T-SQL - END

-- Count total # of queries in @DatabaseName's QDS - START
IF (@VerboseMode = 1)
BEGIN
	DECLARE @TotalQueriesCount BIGINT
	SET @SqlCmd = 'INSERT INTO #Rows SELECT COUNT(1) FROM ' + QUOTENAME(@DatabaseName) + '.[sys].[query_store_query]'
	IF (@VerboseMode = 1) PRINT (@SqlCmd)
	EXECUTE (@SqlCmd)
	SELECT TOP(1) @TotalQueriesCount = r FROM #Rows

	TRUNCATE TABLE #Rows

	PRINT 'Total queries: ' + CAST(@TotalQueriesCount AS VARCHAR(20))
END
-- Count total # of queries in @DatabaseName's QDS - END

-- Create table #DeleteableQueryTable store the list of queries and plans (when forced on a query) be deleted - START
DROP TABLE IF EXISTS #DeleteableQueryTable
CREATE TABLE #DeleteableQueryTable
(
	 [QueryType] NVARCHAR(16)
	,[QueryID] BIGINT
	,[PlanID] BIGINT
	,[ForcedPlan] BIT
)
-- Create table #DeleteableQueryTable store the list of queries and plans (when forced on a query) be deleted - END


-- Load ad-hoc stale queries into #DeleteableQueryTable - START
IF (@CleanAdhocStale = 1)
BEGIN
	SET @SqlCmd = 'INSERT INTO #DeleteableQueryTable
	SELECT ''AdhocStale'', [qsq].[query_id], [qsp].[plan_id], [qsp].[is_forced_plan] 
	FROM {@DatabaseName}.[sys].[query_store_query] AS [qsq]
	JOIN {@DatabaseName}.[sys].[query_store_plan] AS [qsp]
		ON [qsp].[query_id] = [qsq].[query_id]
	JOIN {@DatabaseName}.[sys].[query_store_runtime_stats] AS [qsrs]
		ON [qsrs].[plan_id] = [qsp].[plan_id]
	WHERE [qsq].[object_id] = 0
	GROUP BY [qsq].[query_id], [qsp].[plan_id], [qsp].[is_forced_plan] 
	{@QueryClause}

	INSERT INTO #Rows (r) VALUES (@@ROWCOUNT)'
	
	-- If @MinExecutionCount = 0 or @Retention = 0, all adhoc queries will be deleted - START
	IF ( (@MinExecutionCount * @Retention) <> 0)
	BEGIN
		SET @SqlCmd = REPLACE(@SqlCmd, '{@QueryClause}',			'HAVING SUM([qsrs].[count_executions]) < {@MinExecutionCount}
	AND MAX([qsq].[last_execution_time]) < DATEADD (HOUR, -{@Retention}, GETUTCDATE())')
	END
	ELSE
	BEGIN
		SET @SqlCmd = REPLACE(@SqlCmd, '{@QueryClause}',			'')
	END
	-- If @MinExecutionCount = 0 or @Retention = 0, all adhoc queries will be deleted - END

	SET @SqlCmd = REPLACE(@SqlCmd, '{@DatabaseName}',			QUOTENAME(@DatabaseName))
	SET @SqlCmd = REPLACE(@SqlCmd, '{@MinExecutionCount}',		CAST(@MinExecutionCount AS NVARCHAR(16)))
	SET @SqlCmd = REPLACE(@SqlCmd, '{@Retention}',				CAST(@Retention AS NVARCHAR(16)))

	IF (@VerboseMode = 1) PRINT (@SqlCmd)
	EXECUTE (@SqlCmd)
	
	SELECT TOP(1) @Rows = r FROM #Rows
	TRUNCATE TABLE #Rows

	IF (@VerboseMode = 1)
	BEGIN
		IF ( (@MinExecutionCount * @Retention) > 0)
			PRINT 'Adhoc stale queries criteria: executed less than ' + CAST(@MinExecutionCount AS VARCHAR(8)) + ' times, and not executed for the last '+ CAST (@Retention AS VARCHAR(8)) +' hours'
		IF ( (@MinExecutionCount * @Retention) = 0)
			PRINT 'Adhoc stale queries criteria: all adhoc queries'
		PRINT 'Adhoc stale queries found: ' + CAST(@Rows AS VARCHAR(20))
	END
END
-- Load ad-hoc stale queries into #DeleteableQueryTable - END

-- Load stale queries into #StaleQueryTable - START
IF (@CleanStale = 1)
BEGIN
	SET @SqlCmd = 'INSERT INTO #DeleteableQueryTable
	SELECT 
		''Stale''
		,[qsq].[query_id]
		,[qsp].[plan_id]
		,[qsp].[is_forced_plan]
	FROM {@DatabaseName}.[sys].[query_store_query] AS [qsq]
	JOIN {@DatabaseName}.[sys].[query_store_plan] AS [qsp]   
		ON [qsp].[query_id] = [qsq].[query_id]
	JOIN {@DatabaseName}.[sys].[query_store_runtime_stats] AS [qsrs]
		ON [qsrs].[plan_id] = [qsp].[plan_id]
	WHERE [qsq].[object_id] <> 0
	GROUP BY [qsq].[query_id], [qsp].[plan_id], [qsp].[is_forced_plan] 
	{@QueryClause}

	INSERT INTO #Rows (r) VALUES (@@ROWCOUNT)'

	-- If @MinExecutionCount = 0 or @Retention = 0, all queries will be deleted - START
	IF ( (@MinExecutionCount * @Retention) <> 0)
	BEGIN
		SET @SqlCmd = REPLACE(@SqlCmd, '{@QueryClause}',			'HAVING SUM([qsrs].[count_executions]) < {@MinExecutionCount}
	AND MAX([qsq].[last_execution_time]) < DATEADD (HOUR, -{@Retention}, GETUTCDATE())')
	END
	ELSE
	BEGIN
		SET @SqlCmd = REPLACE(@SqlCmd, '{@QueryClause}',			'')
	END
	-- If @MinExecutionCount = 0 or @Retention = 0, all  queries will be deleted - END

	SET @SqlCmd = REPLACE(@SqlCmd, '{@DatabaseName}',			QUOTENAME(@DatabaseName))
	SET @SqlCmd = REPLACE(@SqlCmd, '{@MinExecutionCount}',		CAST(@MinExecutionCount AS NVARCHAR(16)))
	SET @SqlCmd = REPLACE(@SqlCmd, '{@Retention}',				CAST(@Retention AS NVARCHAR(16)))

	IF (@VerboseMode = 1) PRINT (@SqlCmd)
	EXECUTE (@SqlCmd)

	SELECT TOP(1) @Rows = r FROM #Rows
	TRUNCATE TABLE #Rows
	
	IF (@VerboseMode = 1)
	BEGIN
		PRINT 'Stale queries: ' + CAST(@Rows AS VARCHAR(19)) + ' (executed less than ' + CAST(@MinExecutionCount AS VARCHAR(8)) + ' times, and not executed for the last '+ CAST (@Retention AS VARCHAR(8)) +' hours)'
		PRINT 'Stale queries found: ' + CAST(@Rows as VARCHAR(20))
	END
END
-- Load stale queries into #StaleQueryTable - END

-- Load internal queries into #InternalQueryTable - START 
IF (@CleanInternal = 1)
BEGIN
	SET @SqlCmd = 'INSERT INTO #DeleteableQueryTable
	SELECT 
		''Internal''
		,[qsq].[query_id]
		,[qsp].[plan_id]
		,[qsp].[is_forced_plan]
	FROM {@DatabaseName}.[sys].[query_store_query] AS [qsq]
	JOIN {@DatabaseName}.[sys].[query_store_plan] AS [qsp]
	ON [qsq].[query_id] = [qsp].[query_id]
	WHERE [qsq].[is_internal_query] = 1

	INSERT INTO #Rows (r) VALUES (@@ROWCOUNT)'

	SET @SqlCmd = REPLACE(@SqlCmd, '{@DatabaseName}',			QUOTENAME(@DatabaseName))

	IF (@VerboseMode = 1) PRINT (@SqlCmd)
	EXECUTE (@SqlCmd)

	SELECT TOP(1) @Rows = r FROM #Rows
	TRUNCATE TABLE #Rows

	IF (@VerboseMode = 1)
	BEGIN
		PRINT 'Internal queries found: ' + CAST(@Rows AS VARCHAR(19))
	END
END
-- Load internal queries into #InternalQueryTable - END


-- Load orphan queries into #DeleteableQueryTable - START
IF (@CleanOrphan = 1)
BEGIN
	SET @SqlCmd = 'INSERT INTO #DeleteableQueryTable
	SELECT 
		''Orphan''
		,[qsq].[query_id]
		,[qsp].[plan_id]
		,[qsp].[is_forced_plan]
	FROM {@DatabaseName}.[sys].[query_store_query] AS [qsq]
	JOIN {@DatabaseName}.[sys].[query_store_plan] AS [qsp]
		ON [qsp].[query_id] = [qsq].[query_id]
	WHERE [qsq].[object_id] <> 0 
		AND [qsq].[object_id] NOT IN (SELECT [object_id] FROM ' + QUOTENAME(@DatabaseName) + '.[sys].[objects])

	INSERT INTO #Rows (r) VALUES (@@ROWCOUNT)'

	SET @SqlCmd = REPLACE(@SqlCmd, '{@DatabaseName}',			QUOTENAME(@DatabaseName))

	IF (@VerboseMode = 1) PRINT (@SqlCmd)
	EXECUTE (@SqlCmd)

	SELECT TOP(1) @Rows = r FROM #Rows
	TRUNCATE TABLE #Rows

	IF (@VerboseMode = 1)
	BEGIN
		PRINT 'Orphan queries found: ' + CAST(@Rows AS VARCHAR(19))
	END
END
-- Load orphan queries into #DeleteableQueryTable - END

-- Create indexes order the queries and plans be deleted reduce the effort when querying #DeleteableQueryTable - START
CREATE CLUSTERED INDEX [CIX_DeleteableQueryTable_QueryID] ON #DeleteableQueryTable ([QueryID])
CREATE NONCLUSTERED INDEX [NCIX_DeleteableQueryTable_PlanID] ON #DeleteableQueryTable ([PlanID])
-- Create indexes order the queries and plans be deleted reduce the effort when querying #DeleteableQueryTable - END

-- Summary Report: Prepare user-friendly output (as table or text) - START
IF ( (@ReportAsTable = 1) OR (@ReportAsText = 1)  OR (@ReportIndexOutputTable IS NOT NULL) )
BEGIN

	-- Summary Report: Create table #Report store metrics before outputing them - START
	DROP TABLE IF EXISTS #Report
	CREATE TABLE #Report
	(
		 [QueryType]	NVARCHAR(16)	
		,[QueryCount]	BIGINT		NULL
		,[PlanCount]	BIGINT		NULL
		,[QueryTextKBs]	BIGINT		NULL
		,[PlanXMLKBs]	BIGINT		NULL
		,[RunStatsKBs]	BIGINT		NULL
		,[WaitStatsKBs]	BIGINT		NULL 
	)
	-- Summary Report: Create table #Report store metrics before outputing them - END
	
	-- Summary Report: Use @SqlCmd load details into #Report - START
	--SET @SqlCmd = 'INSERT INTO #Report
	SET @SqlCmd = 'WITH 
{@SQL2016tables} [qsws]
{@SQL2016tables} AS
{@SQL2016tables} (
{@SQL2016tables} SELECT
{@SQL2016tables} 	 [QueryType]	= [dqt].[QueryType]
{@SQL2016tables} 	,[WaitStatsKBs]	=	( COUNT_BIG([qsws].[wait_stats_id]) * 315 ) / 1024
{@SQL2016tables} FROM #DeleteableQueryTable [dqt]
{@SQL2016tables} LEFT JOIN {@DatabaseName}.[sys].[query_store_wait_stats] [qsws]
{@SQL2016tables} 	ON [dqt].[PlanID] = [qsws].[plan_id]
{@SQL2016tables} GROUP BY [dqt].[QueryType]
{@SQL2016tables} ), 
[qsrs]
AS
(
SELECT
	[QueryType]		= [dqt].[QueryType]
	,[RunStatsKBs]	=	( COUNT_BIG([qsrs].[runtime_stats_id]) * 653 ) / 1024
FROM #DeleteableQueryTable [dqt]
LEFT JOIN {@DatabaseName}.[sys].[query_store_runtime_stats] [qsrs]
	ON [dqt].[PlanID] = [qsrs].[plan_id]
GROUP BY [dqt].[QueryType]
), [q]
AS
(
SELECT
	 [QueryType]		=	[dqt].[QueryType]
	,[QueryCount]		=	COUNT_BIG(DISTINCT [dqt].[QueryID])
	,[PlanCount]		=	COUNT_BIG(DISTINCT [dqt].[PlanID])
	,[QueryTextKBs]		=	SUM(DATALENGTH([qsqt].[query_sql_text])) / 1024
	,[PlanXMLKBs]		=	SUM(DATALENGTH([qsp].[query_plan])) / 1024
FROM #DeleteableQueryTable [dqt]
	INNER JOIN {@DatabaseName}.[sys].[query_store_query] [qsq]
		ON [dqt].[QueryID] = [qsq].[query_id]
	INNER JOIN {@DatabaseName}.[sys].[query_store_plan] [qsp]
		ON [dqt].[PlanID] = [qsp].[plan_id]
	LEFT JOIN {@DatabaseName}.[sys].[query_store_query_text] [qsqt]
		ON [qsq].[query_text_id] = [qsqt].[query_text_id]
GROUP BY [dqt].[QueryType]
)
INSERT INTO #Report
SELECT
	 [q].[QueryType]
	,[q].[QueryCount]
	,[q].[PlanCount]
	,[q].[QueryTextKBs]
	,[q].[PlanXMLKBs]
	,[qsrs].[RunStatsKBs]
	,{@SQL2016columns} [qsws].[WaitStatsKBs]
FROM [q]
	LEFT JOIN [qsrs]
		ON [q].[QueryType] = [qsrs].[QueryType]
{@SQL2016tables}	LEFT JOIN [qsws]
{@SQL2016tables}		ON [q].[QueryType] = [qsws].[QueryType]'
	
	SET @SqlCmd = REPLACE(@SqlCmd, '{@DatabaseName}',			QUOTENAME(@DatabaseName))
	
	-- If the SQL version is 2016, exclude components not available on that version - START
	IF (@Version = 13)
	BEGIN
		SET @SqlCmd = REPLACE(@SqlCmd, '{@SQL2016columns}',		'NULL --')
		SET @SqlCmd = REPLACE(@SqlCmd, '{@SQL2016tables}',		'--')
	END
	ELSE
		BEGIN
		SET @SqlCmd = REPLACE(@SqlCmd, '{@SQL2016columns}',		'')
		SET @SqlCmd = REPLACE(@SqlCmd, '{@SQL2016tables}',		'')
	END
	-- If the SQL version is 2016, exclude components not available on that version - END

	IF (@VerboseMode = 1) PRINT (@SqlCmd)
	EXECUTE (@SqlCmd)

	-- If no queries that satisfy the parameters are found, generate an empty report - START
	IF NOT EXISTS(SELECT 1 FROM #Report)
		INSERT INTO #Report ([QueryType], [QueryCount], [PlanCount], [QueryTextKBs], [PlanXMLKBs], [RunStatsKBs], [WaitStatsKBs])
		VALUES ('NONE', 0, 0, 0, 0, 0, 0)
	-- If no queries that satisfy the parameters are found, generate an empty report - END

	-- Summary Report: Use @SqlCmd load details into #Report - END
END
-- Summary Report: Prepare user-friendly output (as table or text) - END


-- Summary Report: Generate report as a Table - START
IF (@ReportAsTable = 1)
BEGIN
	SELECT 
		 @ExecutionTime AS [ExecutionTime]
		,@ServerIdentifier AS [ServerIdentifier]
		,@DatabaseName AS [DatabaseName]
		,[QueryType]		
		,[QueryCount]	
		,[PlanCount]		
		,[QueryTextKBs]
		,[PlanXMLKBs]
		,[RunStatsKBs]
		,[WaitStatsKBs]
	FROM #Report
END
-- Summary Report: Generate report as a Table - END

-- Summary Report: Generate report as text - START
IF (@ReportAsText = 1)
BEGIN

	DECLARE @QueryCount		BIGINT
	DECLARE @PlanCount		BIGINT
	DECLARE @QueryTextKBs	BIGINT
	DECLARE @PlanXMLKBs		BIGINT
	DECLARE @RunStatsKBs	BIGINT
	DECLARE @WaitStatsKBs	BIGINT

	-- Summary Report: Adhoc Stale query details - START
	IF EXISTS (SELECT 1 FROM #Report WHERE [QueryType] = 'AdhocStale')
	BEGIN
		SELECT
			 @QueryCount	=	[QueryCount]
			,@PlanCount		=	[PlanCount]
			,@QueryTextKBs	=	[QueryTextKBs]
			,@PlanXMLKBs	=	[PlanXMLKBs]
			,@RunStatsKBs	=	[RunStatsKBs]
			,@WaitStatsKBs	=	[WaitStatsKBs]
		FROM #Report 
		WHERE [QueryType] = 'AdhocStale'

		PRINT ''
		PRINT '**********************************'
		PRINT '*   Adhoc Stale queries found    *'
		PRINT '**********************************'
		PRINT '# of Queries : '				+ CAST(@QueryCount		AS VARCHAR(20))
		PRINT '# of Plans : '				+ CAST(@PlanCount		AS VARCHAR(20))
		PRINT 'KBs of query texts : '		+ CAST(@QueryTextKBs	AS VARCHAR(20))
		PRINT 'KBs of execution plans : '	+ CAST(@PlanXMLKBs		AS VARCHAR(20))
		PRINT 'KBs of runtime stats : '		+ CAST(@RunStatsKBs		AS VARCHAR(20))
		PRINT 'KBs of wait stats : '		+ CAST(@WaitStatsKBs	AS VARCHAR(20))
		PRINT ''
	END
	-- Summary Report: Adhoc Stale query details - END

	-- Summary Report: Stale query details - START
	IF EXISTS (SELECT 1 FROM #Report WHERE [QueryType] = 'Stale')
	BEGIN
		SELECT
			 @QueryCount	=	[QueryCount]
			,@PlanCount		=	[PlanCount]
			,@QueryTextKBs	=	[QueryTextKBs]
			,@PlanXMLKBs	=	[PlanXMLKBs]
			,@RunStatsKBs	=	[RunStatsKBs]
			,@WaitStatsKBs	=	[WaitStatsKBs]
		FROM #Report 
		WHERE [QueryType] = 'Stale'

		PRINT ''
		PRINT '**********************************'
		PRINT '*       Stale queries found      *'
		PRINT '**********************************'
		PRINT '# of Queries : '				+ CAST(@QueryCount		AS VARCHAR(20))
		PRINT '# of Plans : '				+ CAST(@PlanCount		AS VARCHAR(20))
		PRINT 'KBs of query texts : '		+ CAST(@QueryTextKBs	AS VARCHAR(20))
		PRINT 'KBs of execution plans : '	+ CAST(@PlanXMLKBs		AS VARCHAR(20))
		PRINT 'KBs of runtime stats : '		+ CAST(@RunStatsKBs		AS VARCHAR(20))
		PRINT 'KBs of wait stats : '		+ CAST(@WaitStatsKBs	AS VARCHAR(20))
		PRINT ''
	END
	-- Summary Report: Stale query details - END

	-- Summary Report: Internal query details - START
	IF EXISTS (SELECT 1 FROM #Report WHERE [QueryType] = 'Internal')
	BEGIN
		SELECT
			 @QueryCount	=	[QueryCount]
			,@PlanCount		=	[PlanCount]
			,@QueryTextKBs	=	[QueryTextKBs]
			,@PlanXMLKBs	=	[PlanXMLKBs]
			,@RunStatsKBs	=	[RunStatsKBs]
			,@WaitStatsKBs	=	[WaitStatsKBs]
		FROM #Report 
		WHERE [QueryType] = 'Internal'

		PRINT ''
		PRINT '**********************************'
		PRINT '*     Internal queries found     *'
		PRINT '**********************************'
		PRINT '# of Queries : '				+ CAST(@QueryCount		AS VARCHAR(20))
		PRINT '# of Plans : '				+ CAST(@PlanCount		AS VARCHAR(20))
		PRINT 'KBs of query texts : '		+ CAST(@QueryTextKBs	AS VARCHAR(20))
		PRINT 'KBs of execution plans : '	+ CAST(@PlanXMLKBs		AS VARCHAR(20))
		PRINT 'KBs of runtime stats : '		+ CAST(@RunStatsKBs		AS VARCHAR(20))
		PRINT 'KBs of wait stats : '		+ CAST(@WaitStatsKBs	AS VARCHAR(20))
		PRINT ''
	END
	-- Summary Report: Internal query details - END

	-- Summary Report: Orphan query details - START
	IF EXISTS (SELECT 1 FROM #Report WHERE [QueryType] = 'Orphan')
	BEGIN
		SELECT
			 @QueryCount	=	[QueryCount]
			,@PlanCount		=	[PlanCount]
			,@QueryTextKBs	=	[QueryTextKBs]
			,@PlanXMLKBs	=	[PlanXMLKBs]
			,@RunStatsKBs	=	[RunStatsKBs]
			,@WaitStatsKBs	=	[WaitStatsKBs]
		FROM #Report 
		WHERE [QueryType] = 'Orphan'

		PRINT ''
		PRINT '**********************************'
		PRINT '*      Orphan queries found      *'
		PRINT '**********************************'
		PRINT '# of Queries : '				+ CAST(@QueryCount		AS VARCHAR(20))
		PRINT '# of Plans : '				+ CAST(@PlanCount		AS VARCHAR(20))
		PRINT 'KBs of query texts : '		+ CAST(@QueryTextKBs	AS VARCHAR(20))
		PRINT 'KBs of execution plans : '	+ CAST(@PlanXMLKBs		AS VARCHAR(20))
		PRINT 'KBs of runtime stats : '		+ CAST(@RunStatsKBs		AS VARCHAR(20))
		PRINT 'KBs of wait stats : '		+ CAST(@WaitStatsKBs	AS VARCHAR(20))
		PRINT ''
	END
	-- Summary Report: Orphan query details - END
END
-- Summary Report: Generate report as text - END


-- Summary Report: Persisted-table output (index) - START
	-- Declare @ReportID be used in following steps (if logging table is required) - START
	DROP TABLE IF EXISTS #ReportIDTable
	CREATE TABLE #ReportIDTable ( [ReportID] BIGINT )
	SET @SqlCmd = 'INSERT INTO #ReportIDTable ([ReportID])
	SELECT TOP(1) [ReportID] FROM {@ReportIndexTable} ORDER BY [ReportID] DESC'
	SET @SqlCmd = REPLACE(@SqlCmd, '{@ReportIndexTable}', @ReportIndexOutputTable)

	IF (@VerboseMode = 1) PRINT (@SqlCmd)
	EXECUTE (@SqlCmd)

	SELECT TOP(1) @ReportID = [ReportID] FROM #ReportIDTable
	SET @ReportID = COALESCE(@ReportID +1, 1)

	DROP TABLE IF EXISTS #ReportIDTable
	-- Declare @ReportID be used in following steps (if logging table is required) - END

IF (@ReportIndexOutputTable IS NOT NULL)
BEGIN
	DECLARE @ReportOutputInsert NVARCHAR(MAX)
	SET @ReportOutputInsert = '
	INSERT INTO {@ReportIndexOutputTable} (
		 [ReportID]
		,[ReportDate] 
		,[ServerIdentifier]	
		,[DatabaseName]	
		,[QueryType]		
		,[QueryCount]	
		,[PlanCount]		
		,[QueryTextKBs]	
		,[PlanXMLKBs]	
		,[RunStatsKBs]	
		,[WaitStatsKBs]
		,[CleanupParameters]
		,[TestMode]
	)
	SELECT 
		 {@ReportID}
		,''{@ReportDate}''
		,''{@ServerIdentifier}''
		,''{@DatabaseName}''
		,[QueryType]		
		,[QueryCount]	
		,[PlanCount]		
		,[QueryTextKBs]
		,[PlanXMLKBs]
		,[RunStatsKBs]
		,[WaitStatsKBs]
		,(	SELECT 
				 {@CleanAdhocStale}		AS [CleanAdhocStale]
				,{@CleanStale}			AS [CleanStale]
				,{@Retention}			AS [Retention]
				,{@MinExecutionCount}	AS [MinExecutionCount]
				,{@CleanOrphan}			AS [CleanOrphan]
				,{@CleanInternal}		AS [CleanInternal]
				,{@CleanStatsOnly}		AS [CleanStatsOnly]
			FOR XML PATH (''CleanupParameters''), ROOT(''Root'')
		) as [CleanupParameters]
		, {@TestMode}
	FROM #Report
	ORDER BY [QueryType] ASC'

	SET @ReportOutputInsert = REPLACE(@ReportOutputInsert, '{@ReportIndexOutputTable}',				@ReportIndexOutputTable)
	SET @ReportOutputInsert = REPLACE(@ReportOutputInsert, '{@ReportID}',				CAST(@ReportID AS NVARCHAR(20)))
	SET @ReportOutputInsert = REPLACE(@ReportOutputInsert, '{@ReportDate}',				CAST(@ExecutionTime AS NVARCHAR(34)))
	SET @ReportOutputInsert = REPLACE(@ReportOutputInsert, '{@ServerIdentifier}',		@ServerIdentifier)
	SET @ReportOutputInsert = REPLACE(@ReportOutputInsert, '{@DatabaseName}',			@DatabaseName)
	SET @ReportOutputInsert = REPLACE(@ReportOutputInsert, '{@CleanAdhocStale}',		CAST(@CleanAdhocStale AS NVARCHAR(1)))
	SET @ReportOutputInsert = REPLACE(@ReportOutputInsert, '{@CleanStale}',				CAST(@CleanStale AS NVARCHAR(1)))
	SET @ReportOutputInsert = REPLACE(@ReportOutputInsert, '{@Retention}',				CAST(@Retention AS NVARCHAR(8)))
	SET @ReportOutputInsert = REPLACE(@ReportOutputInsert, '{@MinExecutionCount}',		CAST(@MinExecutionCount AS NVARCHAR(8)))
	SET @ReportOutputInsert = REPLACE(@ReportOutputInsert, '{@CleanOrphan}',			CAST(@CleanOrphan AS NVARCHAR(1)))
	SET @ReportOutputInsert = REPLACE(@ReportOutputInsert, '{@CleanInternal}',			CAST(@CleanInternal AS NVARCHAR(1)))
	SET @ReportOutputInsert = REPLACE(@ReportOutputInsert, '{@CleanStatsOnly}',			CAST(@CleanStatsOnly AS NVARCHAR(1)))
	SET @ReportOutputInsert = REPLACE(@ReportOutputInsert, '{@TestMode}',				CAST(@TestMode AS NVARCHAR(1)))

	IF (@VerboseMode = 1) PRINT (@ReportOutputInsert)
	IF (@VerboseMode = 1) PRINT (@ReportOutputInsert)
	EXECUTE (@ReportOutputInsert)

END
-- Summary Report: Persisted-table output (index) - END


-- Detailed Report: Prepare user-friendly output (as table or text) - START
IF ( ( @ReportDetailsAsTable = 1 ) OR ( @ReportDetailsOutputTable IS NOT NULL) )
BEGIN
	-- Detailed Report: Create table #Report store metrics before outputing them - START
	DROP TABLE IF EXISTS #QueryDetailsStagingTable
	CREATE TABLE #QueryDetailsStagingTable
	(
			 [QueryType] NVARCHAR(16) NOT NULL
			,[QueryID] BIGINT NOT NULL
			,[ObjectID] INT NOT NULL
			,[LastExecutionTime] DATETIMEOFFSET(7) NULL
			,[ExecutionCount] BIGINT NULL
			,[QueryText] VARBINARY(MAX) NULL
	)
	-- Detailed Report: Create table #Report store metrics before outputing them - END

	-- Detailed Report: Use @SqlCmd load details into #QueryDetailsStagingTable - START
	SET @SqlCmd = 'INSERT INTO #QueryDetailsStagingTable
	SELECT
		 [dqt].[QueryType]
		,[dqt].[QueryID]
		,[qsq].[object_id]
		,[qsq].[last_execution_time]
		,SUM([qsrs].[count_executions])
		,COMPRESS([qsqt].[query_sql_text])
	FROM #DeleteableQueryTable [dqt]
		INNER JOIN {@DatabaseName}.[sys].[query_store_query] [qsq]
			ON [dqt].[QueryID] = [qsq].[query_id]
		INNER JOIN {@DatabaseName}.[sys].[query_store_query_text] [qsqt]
			ON [qsq].[query_text_id] = [qsqt].[query_text_id]
		INNER JOIN {@DatabaseName}.[sys].[query_store_runtime_stats] [qsrs]
			ON [dqt].[PlanID] = [qsrs].[plan_id]
	GROUP BY [dqt].[QueryType], [dqt].[QueryID], [qsq].[object_id], [qsq].[last_execution_time], [qsqt].[query_sql_text]'

	SET @SqlCmd = REPLACE(@SqlCmd, '{@DatabaseName}',			QUOTENAME(@DatabaseName))

	IF (@VerboseMode = 1) PRINT (@SqlCmd)
	EXECUTE (@SqlCmd)
	-- Detailed Report: Use @SqlCmd load details into #QueryDetailsStagingTable - END


	-- Detailed Report: Create an index on #QueryDetailsStagingTable prevent scans - START
	CREATE CLUSTERED INDEX [CIX_QueryDetailsStagingTable_QueryID] ON #QueryDetailsStagingTable (QueryID)
	-- Detailed Report: Create an index on #QueryDetailsStagingTable prevent scans - END


	-- Detailed Report: Create table #QueryDetailsTable store query details before processing them - START
	DROP TABLE IF EXISTS #QueryDetailsTable
	CREATE TABLE #QueryDetailsTable
	(
			 [QueryType] NVARCHAR(16) NOT NULL
			,[ObjectName] NVARCHAR(270) NOT NULL
			,[QueryID] BIGINT NOT NULL
			,[LastExecutionTime] DATETIMEOFFSET(7) NULL
			,[ExecutionCount] BIGINT NULL
			,[QueryText] VARBINARY(MAX) NULL
	)
	-- Detailed Report: Create table #QueryDetailsTable store query details before processing them - END

	-- Detailed Report: Load details of queries including adhoc and orphan queries - START
	SET @SqlCmd = 'INSERT INTO #QueryDetailsTable
			SELECT
			 [qdst].[QueryType]
			,QUOTENAME([s].[name]) + ''.'' + QUOTENAME([o].[name])
			,[qdst].[QueryID]
			,[qdst].[LastExecutionTime]
			,[qdst].[ExecutionCount]
			,[qdst].[QueryText]
		FROM #QueryDetailsStagingTable [qdst]
		INNER JOIN {@DatabaseName}.[sys].[objects] [o]
			ON [qdst].[ObjectID] = [o].[object_id]
		INNER JOIN {@DatabaseName}.[sys].[schemas] [s]
			ON [o].[schema_id] = [s].[schema_id]

		UNION ALL

		SELECT
			 [qdst].[QueryType]
			,''ADHOC''
			,[qdst].[QueryID]
			,[qdst].[LastExecutionTime]
			,[qdst].[ExecutionCount]
			,[qdst].[QueryText]
		FROM #QueryDetailsStagingTable [qdst]
		WHERE [qdst].[ObjectID] = 0

		UNION ALL

		SELECT
			 [qdst].[QueryType]
			,''DELETED''
			,[qdst].[QueryID]
			,[qdst].[LastExecutionTime]
			,[qdst].[ExecutionCount]
			,[qdst].[QueryText]
		FROM #QueryDetailsStagingTable [qdst]
		WHERE [qdst].[ObjectID]  <> 0 
			AND [qdst].[ObjectID] NOT IN (SELECT [object_id] FROM {@DatabaseName}.[sys].[objects])'

	SET @SqlCmd = REPLACE(@SqlCmd, '{@DatabaseName}',			QUOTENAME(@DatabaseName))

	IF (@VerboseMode = 1) PRINT (@SqlCmd)
	EXECUTE (@SqlCmd)
	-- Detailed Report: Load details of queries including adhoc and orphan queries - END


	-- Detailed Report: Generate user-friendly output as table - START
	IF ( @ReportDetailsAsTable = 1 )
	BEGIN
		SELECT 
			 @ExecutionTime AS [ExecutionTime]
			,@ServerIdentifier AS [ServerIdentifier]
			,@DatabaseName AS [DatabaseName]
			,[qdt].[QueryType]
			,[qdt].[ObjectName]
			,[qdt].[QueryID]
			,[qdt].[LastExecutionTime]
			,[qdt].[ExecutionCount]
			,CAST(DECOMPRESS([qdt].[QueryText]) AS NVARCHAR(MAX)) AS [QueryText]
		FROM #QueryDetailsTable [qdt]
		ORDER BY [qdt].[QueryType], [qdt].[ObjectName], [qdt].[QueryID]
	END
	-- Detailed Report: Generate user-friendly output as table - END


	-- Detailed Report: Persisted-table output - START
	IF (@ReportDetailsOutputTable IS NOT NULL)
	BEGIN
		DECLARE @ReportDetailsOutputInsert NVARCHAR(MAX)
		SET @ReportDetailsOutputInsert = '
		INSERT INTO {@ReportDetailsOutputTable} (
			 [ReportID]
			,[QueryType]
			,[ObjectName]
			,[QueryID]
			,[LastExecutionTime]
			,[ExecutionCount]
			,[QueryText]
		)
		SELECT
			 {@ReportID}
			,[qdt].[QueryType]
			,[qdt].[ObjectName]
			,[qdt].[QueryID]
			,[qdt].[LastExecutionTime]
			,[qdt].[ExecutionCount]
			,[qdt].[QueryText]
		FROM #QueryDetailsTable [qdt]
		ORDER BY
			[qdt].[QueryType] ASC,
			[qdt].[QueryID] ASC'

		SET @ReportDetailsOutputInsert = REPLACE(@ReportDetailsOutputInsert, '{@ReportDetailsOutputTable}',			@ReportDetailsOutputTable)
		SET @ReportDetailsOutputInsert = REPLACE(@ReportDetailsOutputInsert, '{@ReportID}',							CAST(@ReportID AS NVARCHAR(20)))

		IF (@VerboseMode = 1) PRINT (@ReportDetailsOutputInsert)
		EXECUTE (@ReportDetailsOutputInsert)

	END
	-- Detailed Report: Persisted-table output - END
END

-- Perform actual cleanup operations - START
DECLARE @DeleteableQueryID BIGINT
DECLARE @DeleteablePlanID BIGINT

-- Deletion of query & plans, when @CleanStatsOnly = 0 - START
IF (@CleanStatsOnly = 0)
BEGIN
	DECLARE @DeleteableQueryDeletedTable TABLE (QueryID BIGINT, PlanID BIGINT, PRIMARY KEY (QueryID ASC, PlanID ASC))
	DECLARE @UnforcePlanCmdTemplate	VARCHAR(MAX) = QUOTENAME(@DatabaseName)+'..sp_query_store_unforce_plan @query_id = {@QueryID}, @plan_id = {@PlanID};'
	DECLARE @UnforcePlanCmd			VARCHAR(MAX)
	DECLARE @RemoveQueryCmdTemplate	VARCHAR(MAX) = QUOTENAME(@DatabaseName)+'..sp_query_store_remove_query @query_id = {@QueryID};'
	DECLARE @RemoveQueryCmd			VARCHAR(MAX)
	WHILE (SELECT COUNT(1) FROM #DeleteableQueryTable) > 0
	-- Loop through each query in the list, starting with the ones having a forced plan on then ([ForcedPlan] = 1) - START
	BEGIN
		;WITH dqt AS ( SELECT TOP(1) * FROM #DeleteableQueryTable ORDER BY [ForcedPlan] DESC)
		DELETE FROM dqt
		OUTPUT DELETED.QueryID, DELETED.PlanID INTO @DeleteableQueryDeletedTable
		SELECT TOP(1) @DeleteableQueryID = QueryID, @DeleteablePlanID = PlanID FROM @DeleteableQueryDeletedTable
		DELETE FROM @DeleteableQueryDeletedTable

		-- If there is a forced plan for the query, unforce it before removing the query (queries with forced plans can't be removed) - START
		IF (@DeleteablePlanID <> 0)
		BEGIN
			-- Unforce the plan (if any) - START
			IF (@VerboseMode = 1) PRINT 'Unforce plan : ' + CAST(@DeleteablePlanID AS VARCHAR(19)) + ' for query :' + CAST(@DeleteableQueryID AS VARCHAR(19))
			SET @UnforcePlanCmd = REPLACE(@UnforcePlanCmdTemplate,	'{@QueryID}',	CAST(@DeleteableQueryID AS NVARCHAR(20)))
			SET @UnforcePlanCmd = REPLACE(@UnforcePlanCmd,			'{@PlanID}',	CAST(@DeleteablePlanID AS NVARCHAR(20)))
			IF (@VerboseMode = 1) PRINT (@UnforcePlanCmd)
			IF (@TestMode = 0) EXECUTE (@UnforcePlanCmd)
			-- Unforce the plan (if any) - END
		END
		-- If there is a forced plan for the query, unforce it before removing the query (queries with forced plans can't be removed) - END

		-- Delete the query from Query Store - START
		IF (@VerboseMode = 1) PRINT 'Remove query : ' + CAST(@DeleteableQueryID AS VARCHAR(19))
		SET @UnforcePlanCmd = REPLACE(@RemoveQueryCmdTemplate,	'{@QueryID}',	CAST(@DeleteableQueryID AS NVARCHAR(20)))
		IF (@VerboseMode = 1) PRINT (@RemoveQueryCmd)
		IF (@TestMode = 0) EXECUTE (@RemoveQueryCmd) 
		-- Delete the query from Query Store - END

		-- Delete the query from #DeleteableQueryTable prevent the loop from trying remove the same query multiple times - START
		DELETE FROM #DeleteableQueryTable WHERE QueryID = @DeleteableQueryID
		-- Delete the query from #DeleteableQueryTable prevent the loop from trying remove the same query multiple times - END
	END
	-- Loop through each query in the list, starting with the ones having a forced plan on then (plan_id <> 0) - END
END
-- Deletion of query & plans, when @CleanStatsOnly = 0 - END

-- Deletion of plan execution stats only, when @CleanStatsOnly = 1 - START
IF (@CleanStatsOnly = 1)
BEGIN
	DECLARE @DeleteablePlanStatsDeletedTable TABLE ([PlanID] BIGINT, PRIMARY KEY ([PlanID] ASC))
	DECLARE @ResetPlanStatsCmdTemplate	VARCHAR(MAX) = QUOTENAME(@DatabaseName)+'..sp_query_store_reset_exec_stats @plan_id = {@PlanID};'
	DECLARE @ResetPlanStatsCmd			VARCHAR(MAX)
	WHILE (SELECT COUNT(1) FROM #DeleteableQueryTable) > 0
	-- Loop through each plan in the list - START
	BEGIN
		;WITH dqt AS ( SELECT TOP(1) * FROM #DeleteableQueryTable ORDER BY [PlanID] ASC)
		DELETE FROM dqt
		OUTPUT DELETED.PlanID INTO @DeleteablePlanStatsDeletedTable
		SELECT TOP(1) @DeleteablePlanID = PlanID FROM @DeleteablePlanStatsDeletedTable
		DELETE FROM @DeleteablePlanStatsDeletedTable

		-- Delete the stats for the current plan - START
		IF (@VerboseMode = 1) PRINT 'Reset stats for plan : ' + CAST(@DeleteablePlanID AS VARCHAR(19))
		SET @ResetPlanStatsCmd = REPLACE(@ResetPlanStatsCmdTemplate,	'{@PlanID}',	CAST(@DeleteablePlanID AS NVARCHAR(20)))
		IF (@VerboseMode = 1) PRINT (@ResetPlanStatsCmd)
		IF (@TestMode = 0) EXECUTE (@ResetPlanStatsCmd) 
		-- Delete the stats for the current plan - END

		DELETE FROM #DeleteableQueryTable WHERE PlanID = @DeleteablePlanID
	END
	-- Loop through each plan in the list - END
END
-- Deletion of plan execution stats only, when @CleanStatsOnly = 1 - END

DROP TABLE IF EXISTS #DeleteableQueryTable
-- Perform actual cleanup operations - END

END