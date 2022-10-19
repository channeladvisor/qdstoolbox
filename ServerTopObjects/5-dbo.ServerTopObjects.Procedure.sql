----------------------------------------------------------------------------------
-- Procedure Name: [dbo].[ServerTopObjects]
--
-- Desc: This script loops all the accessible user DBs (or just the selected one) and gathers the TOP XX objects based on the selected measurement and generates a report
--
--
-- Parameters:
--	INPUT
--		@ServerIdentifier			SYSNAME			--	Identifier assigned to the server.
--														[Default: @@SERVERNAME]
--
--		@DatabaseName				SYSNAME			--	Name of the database to generate this report on.
--														[Default: NULL, all databases on the server are processed]
--
--		@ReportIndex				NVARCHAR(800)	--	Table to store the details of the report, such as parameters used, if no results returned to the user are required
--														[Default: NULL, results returned to user]
--														Table available in dbo.ServerTopObjectsIndex
--
--		@ReportTable				NVARCHAR(800)	--	Table to store the results of the report, if no results returned to the user are required. 
--														[Default: NULL, results returned to user]
--														Table available in dbo.ServerTopObjectsStore
--
--		@StartTime					DATETIME		--	Start time of the period to analyze, in UTC format.
--														[Default: DATEADD(HOUR,-1,GETUTCDATE()]
--
--		@EndTime					DATETIME2		--	End time of the period to analyze, in UTC format.
--														[Default: GETUTCDATE()]
--
--		@Top						INT				--	Number of queries to extract from each database.
--														[Default: 25]
--
--		@Measurement				NVARCHAR(32)	--	Measurement to order the results by, to select from:
--															duration
--															cpu_time
--															logical_io_reads
--															logical_io_writes
--															physical_io_reads
--															clr_time
--															query_used_memory
--															log_bytes_used
--															tempdb_space_used
--														[Default: cpu_time]
--
--		@Percentages				BIT				--	Flag to use percentages rather than total values for @Measurement.
--														When enabled, @Measurement will go from 0 to 100000 (equivalent to 0% to 100%)
--														[Default: 0]
--
--		@AggregateAll				BIT				--	Flag to aggregate all types of executions in the results
--														[Default: 1]
--
--		@AggregateNonRegular		BIT				--	Flag to aggregate the Aborted and Exception executions in the results
--														[Default: 0]
--			Only one of @AggregateAll and @AggregateNonRegular are allowed
--
--		@IncludeAdhocQueries		BIT				--	Flag to include all Adhoc queries aggregated under a single "virtual" object
--														[Default: 0]
--
--		@IncludeObjectQueryIDs		BIT				--	Flag to include the QueryID of the subqueries of the object in the report
--														[Default: 1]
--
--		@VerboseMode				BIT				--	Flag to determine whether the T-SQL commands that compose this report will be returned to the user.
--														[Default: 0]
--
--		@TestMode					BIT				--	Flag to determine whether the actual T-SQL commands that generate the report will be executed.
--														[Default: 0]
--
--	OUTPUT
--		@ReportID					BIGINT			--	Returns the ReportID (when the report is being logged into a table)
--
-- Date: 2022.10.18
-- Auth: Pablo Lozano (@sqlozano)
-- Desc: Based on [dbo].[ServerTopQueries]
--
-- Date: 2022.10.19
-- Auth: Pablo Lozano (@sqlozano)
-- Changes: Added new parameters: @IncludeAdhocQueries, @IncludeObjectQueryIDs to include QueryIDs to be returned
----------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE [dbo].[ServerTopObjects]
(
	 @ServerIdentifier		SYSNAME			= NULL
	,@DatabaseName			SYSNAME			= NULL
	,@ReportIndex			NVARCHAR(800)	= NULL
	,@ReportTable			NVARCHAR(800)	= NULL
	,@StartTime				DATETIME2		= NULL
	,@EndTime				DATETIME2		= NULL
	,@Top					INT				= 25
	,@Measurement			NVARCHAR(32)	= 'cpu_time'
	,@Percentages			BIT				= 0
	,@AggregateAll			BIT				= 1
	,@AggregateNonRegular	BIT				= 0
	,@IncludeAdhocQueries	BIT				= 0
	,@IncludeObjectQueryIDs	BIT				= 0
	,@VerboseMode			BIT				= 0
	,@TestMode				BIT				= 0
	,@ReportID				BIGINT			= NULL	OUTPUT
)
AS
BEGIN
SET NOCOUNT ON

-- Get the Version # to ensure it runs SQL2016 or higher
DECLARE @Version INT =  CAST(SUBSTRING(CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')),0,CHARINDEX('.',CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')),0)) AS INT)
IF (@Version < 13)
BEGIN
	RAISERROR(N'[dbo].[ServerTopObjects] requires SQL 2016 or higher',16,1)
	RETURN -1
END
-- Raise an error if the @Measurement selected is not available in SQL 2016
IF (@Version = 13 AND @Measurement IN ('log_bytes_used', 'tempdb_space_used'))
BEGIN
	RAISERROR(N'The selected @Measurement [%s] is not available in the current SQL version (2016)',16,1, @Measurement)
	RETURN -1
END

-- Raise an error if both @AggregateAll and @AggregateNonRegular are enabled, or none is - START
IF ( (@AggregateAll = 1) AND (@AggregateNonRegular = 1) )
BEGIN
	RAISERROR(N'The flags @AggregateAll and @AggregateNonRegular cannot be simulatenously enabled',16,1)
	RETURN -1
END
-- Raise an error if both @AggregateAll and @AggregateNonRegular are enabled, or none is - END

-- Check variables and set defaults - START
IF (@ServerIdentifier IS NULL)
	SET @ServerIdentifier = @@SERVERNAME

IF (@StartTime IS NULL) OR (@EndTime IS NULL)
BEGIN
	SET @StartTime	= DATEADD(HOUR,-1, GETUTCDATE())
	SET	@EndTime	= GETUTCDATE()
END
	
IF (@Top < 0) OR (@Top IS NULL)
	SET @Top = 0

IF	(@Measurement NOT IN 
		(
		'duration',
		'cpu_time',
		'logical_io_reads',
		'logical_io_writes',
		'physical_io_reads',
		'clr_time',
		'query_used_memory',
		'log_bytes_used',
		'tempdb_space_used'
		)
	)
BEGIN
	RAISERROR('The measurement [%s] is not valid. Valid values are:
		[duration]
		[cpu_time]
		[logical_io_reads]
		[logical_io_writes]
		[physical_io_reads]
		[clr_time]
		[query_used_memory]
		[log_bytes_used]
		[tempdb_space_used]', 16, 0, @Measurement)
	RETURN
END

IF (@Percentages IS NULL)
	SET @Percentages = 0


IF (@AggregateAll IS NULL)
	SET @AggregateAll = 1

IF (@AggregateNonRegular IS NULL)
	SET @AggregateNonRegular = 0

IF (@IncludeAdhocQueries IS NULL)
	SET @IncludeAdhocQueries = 0

IF (@IncludeObjectQueryIDs IS NULL)
	SET @IncludeObjectQueryIDs = 0
-- Check variables and set defaults - END


-- Define databases in scope for the report - START
DECLARE @dbs TABLE
(
    DatabaseName sysname
)
	--Specific @DatabaseName provided - START
	IF (@DatabaseName IS NOT NULL) AND (@DatabaseName <> '')
	BEGIN
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
		INSERT INTO @dbs ([DatabaseName]) VALUES (@DatabaseName)
	END
	--Specific @DatabaseName provided - END

	-- No @DatabaseName provided: all databases in scope - START
	IF (@DatabaseName IS NULL) OR (@DatabaseName = '')
	BEGIN
		INSERT INTO @dbs ([DatabaseName])
		SELECT [name] FROM [sys].[databases] WHERE [state_desc] = 'ONLINE'
	END
	-- No @DatabaseName provided: all databases in scope - END
-- Define databases in scope for the report - END

-- Definition of temp table to store the reports for each database - START
DROP TABLE IF EXISTS #ServerTopObjectsStore
CREATE TABLE #ServerTopObjectsStore
(
	 [DatabaseName]				SYSNAME			NOT NULL
	,[ObjectID]					BIGINT			NOT NULL
	,[ObjectQueries]			XML					NULL
	,[SchemaName]				SYSNAME			    NULL
	,[ObjectName]				SYSNAME			    NULL
	,[ExecutionTypeDesc]		NVARCHAR(120)	NOT NULL
	,[EstimatedExecutionCount]	BIGINT			NOT NULL
	,[duration]					BIGINT			NOT NULL
	,[cpu_time]					BIGINT			NOT NULL
	,[logical_io_reads]			BIGINT			NOT NULL
	,[logical_io_writes]		BIGINT			NOT NULL
	,[physical_io_reads]		BIGINT			NOT NULL
	,[clr_time]					BIGINT			NOT NULL
	,[query_used_memory]		BIGINT			NOT NULL
	,[log_bytes_used]			BIGINT				NULL
	,[tempdb_space_used]		BIGINT				NULL
)
-- Definition of temp table to store the reports for each database - END

-- Query to extract the details for any given @DatabaseName - START
DECLARE @SqlCommand2PopulateTempTableTemplate NVARCHAR(MAX)
SET @SqlCommand2PopulateTempTableTemplate = 'USE [{@DatabaseName}]
;WITH [st1] AS
(
SELECT
 [qsq].[query_id]
,[object_id]		= ISNULL([obs].[object_id], 0)
,[SchemaName]		= ISNULL(SCHEMA_NAME([obs].[schema_id]), ''ADHOC'')
,[ProcedureName]	= ISNULL(OBJECT_NAME([obs].[object_id]), ''ADHOC'')
,CASE
	WHEN {@AggregateAll} = 1 THEN ''ALL''
	WHEN {@AggregateNonRegular} = 1 AND [qsrs].[execution_type_desc] != ''Regular'' THEN ''NonRegular''
	ELSE [qsrs].[execution_type_desc]
 END AS [ExecutionTypeDesc]
,[count_executions]		= SUM([qsrs].[count_executions])
,[duration]				=					CAST(SUM([qsrs].[avg_duration]				* [qsrs].[count_executions]) AS BIGINT)
,[cpu_time]				=					CAST(SUM([qsrs].[avg_cpu_time]				* [qsrs].[count_executions]) AS BIGINT)
,[logical_io_reads]		=					CAST(SUM([qsrs].[avg_logical_io_reads]		* [qsrs].[count_executions]) AS BIGINT)
,[logical_io_writes]	=					CAST(SUM([qsrs].[avg_logical_io_writes]		* [qsrs].[count_executions]) AS BIGINT)
,[physical_io_reads]	=					CAST(SUM([qsrs].[avg_physical_io_reads]		* [qsrs].[count_executions]) AS BIGINT)
,[clr_time]				=					CAST(SUM([qsrs].[avg_clr_time]				* [qsrs].[count_executions]) AS BIGINT)
,[query_used_memory]	=					CAST(SUM([qsrs].[avg_query_max_used_memory]	* [qsrs].[count_executions]) AS BIGINT)
,[log_bytes_used]		= {@SQL2016columns} CAST(SUM([qsrs].[avg_log_bytes_used]		* [qsrs].[count_executions]) AS BIGINT)
,[tempdb_space_used]	= {@SQL2016columns} CAST(SUM([qsrs].[avg_tempdb_space_used]		* [qsrs].[count_executions]) AS BIGINT)
FROM
[{@DatabaseName}].[sys].[query_store_runtime_stats] [qsrs]
INNER JOIN [{@DatabaseName}].[sys].[query_store_plan] [qsp]
ON [qsrs].[plan_id] = [qsp].[plan_id]
INNER JOIN [{@DatabaseName}].[sys].[query_store_query] [qsq]
ON [qsp].[query_id] = [qsq].[query_id]
{@IncludeAdhocQueries} JOIN [{@DatabaseName}].[sys].[objects] [obs]
ON [qsq].[object_id] = [obs].[object_id]
WHERE
(
 (qsrs.first_execution_time >= ''{@StartTime}'' AND qsrs.last_execution_time < ''{@EndTime}'')
 OR (qsrs.first_execution_time  <= ''{@StartTime}'' AND qsrs.last_execution_time > ''{@StartTime}'')
 OR (qsrs.first_execution_time  <= ''{@EndTime}''   AND qsrs.last_execution_time > ''{@EndTime}'')
)
GROUP BY [qsq].[query_id], [obs].[schema_id], [obs].[object_id], [qsrs].[execution_type_desc]
),
[st2]
AS
(
SELECT
 [st1].[object_id]
,[st1].[SchemaName]
,[st1].[ProcedureName]
,[st1].[ExecutionTypeDesc]
,[count_executions]	= MAX([st1].[count_executions])
,[duration]			= SUM([st1].[duration])
,[cpu_time]			= SUM([st1].[cpu_time])
,[logical_io_reads]	= SUM([st1].[logical_io_reads])
,[logical_io_writes]= SUM([st1].[logical_io_writes])
,[physical_io_reads]= SUM([st1].[physical_io_reads])
,[clr_time]			= SUM([st1].[clr_time])
,[query_used_memory]= SUM([st1].[query_used_memory])
,[log_bytes_used]	= SUM([st1].[log_bytes_used])
,[tempdb_space_used]= SUM([st1].[tempdb_space_used])
FROM [st1]
GROUP BY
 [st1].[object_id]
,[st1].[SchemaName]
,[st1].[ProcedureName]
,[st1].[ExecutionTypeDesc]
)
INSERT INTO #ServerTopObjectsStore
SELECT
 {@Top}
 ''{@DatabaseName}''
,[st2].[object_id]
,{@IncludeObjectQueryIDs}(SELECT [st1].[query_id] FROM [st1] WHERE [st1].[object_id] = [st2].[object_id] {@Order} FOR XML PATH(''ObjectQueryIDs'')) AS XML
,[st2].[SchemaName]
,[st2].[ProcedureName]
,[st2].[ExecutionTypeDesc]
,[st2].[count_executions]
,[st2].[duration]
,[st2].[cpu_time]
,[st2].[logical_io_reads]
,[st2].[logical_io_writes]
,[st2].[physical_io_reads]
,[st2].[clr_time]
,[st2].[query_used_memory]
,[st2].[log_bytes_used]
,[st2].[tempdb_space_used]
FROM [st2]
{@Order}'

	SET @SqlCommand2PopulateTempTableTemplate = REPLACE(@SqlCommand2PopulateTempTableTemplate, '{@StartTime}',				CAST(@StartTime AS NVARCHAR(34)))
	SET @SqlCommand2PopulateTempTableTemplate = REPLACE(@SqlCommand2PopulateTempTableTemplate, '{@EndTime}',				CAST(@EndTime AS NVARCHAR(34)))

	-- If the SQL version is 2016, exclude components not available on that version - START
	IF (@Version = 13)
	BEGIN
		SET @SqlCommand2PopulateTempTableTemplate = REPLACE(@SqlCommand2PopulateTempTableTemplate, '{@SQL2016columns}',		'NULL --')
	END
	ELSE
	BEGIN
		SET @SqlCommand2PopulateTempTableTemplate = REPLACE(@SqlCommand2PopulateTempTableTemplate, '{@SQL2016columns}',		'')
	END
	-- If the SQL version is 2016, exclude components not available on that version - END

	-- Based on @AggregateAll, aggregate all executions in the analysis - START
	SET @SqlCommand2PopulateTempTableTemplate = REPLACE(@SqlCommand2PopulateTempTableTemplate, '{@AggregateAll}',			CAST(@AggregateAll AS NVARCHAR(1)))
	-- Based on @AggregateAll, aggregate all executions in the analysis - END

	-- Based on @AggregateNonRegular, aggregate all executions based on Regular / NonRegular in the analysis - START
	SET @SqlCommand2PopulateTempTableTemplate = REPLACE(@SqlCommand2PopulateTempTableTemplate, '{@AggregateNonRegular}',	CAST(@AggregateNonRegular AS NVARCHAR(1)))
	-- Based on @AggregateNonRegular, aggregate all executions based on Regular / NonRegular in the analysis - END

	-- Based on @IncludeAdhocQueries, return adhoc query IDs under a "virtual" Object - START
	IF (@IncludeAdhocQueries = 0)
		SET @SqlCommand2PopulateTempTableTemplate = REPLACE(@SqlCommand2PopulateTempTableTemplate, '{@IncludeAdhocQueries}',	'INNER')
	IF (@IncludeAdhocQueries = 1)
		SET @SqlCommand2PopulateTempTableTemplate = REPLACE(@SqlCommand2PopulateTempTableTemplate, '{@IncludeAdhocQueries}',	'LEFT')
	-- Based on @IncludeAdhocQueries, return adhoc query IDs under a "virtual" Object - END

	-- Based on @IncludeObjectQueryIDs, return the query IDs part of the Object captured - START
	IF (@IncludeObjectQueryIDs = 0)
		SET @SqlCommand2PopulateTempTableTemplate = REPLACE(@SqlCommand2PopulateTempTableTemplate, '{@IncludeObjectQueryIDs}',	'NULL --')
	IF (@IncludeObjectQueryIDs = 1)
		SET @SqlCommand2PopulateTempTableTemplate = REPLACE(@SqlCommand2PopulateTempTableTemplate, '{@IncludeObjectQueryIDs}',	'')
	-- Based on @IncludeObjectQueryIDs, return the query IDs part of the Object captured - END

	-- Based on @Top, return only the @Top queries or all - START
	IF (@Top > 0)
	BEGIN
		SET @SqlCommand2PopulateTempTableTemplate = REPLACE(@SqlCommand2PopulateTempTableTemplate, '{@Top}',				'TOP('+CAST(@Top AS NVARCHAR(8))+')')
		SET @SqlCommand2PopulateTempTableTemplate = REPLACE(@SqlCommand2PopulateTempTableTemplate, '{@Order}',				'ORDER BY {@Measurement} DESC')
		SET @SqlCommand2PopulateTempTableTemplate = REPLACE(@SqlCommand2PopulateTempTableTemplate, '{@Measurement}',		QUOTENAME(@Measurement))
	END
	IF (@Top = 0)
	BEGIN
		SET @SqlCommand2PopulateTempTableTemplate = REPLACE(@SqlCommand2PopulateTempTableTemplate, '{@Top}',				'')
		SET @SqlCommand2PopulateTempTableTemplate = REPLACE(@SqlCommand2PopulateTempTableTemplate, '{@Order}',				'')
	END
	-- Based on @Top, return only the @Top queries or all - END

-- Query to extract the details for any given @DatabaseName - END 

 
-- Create and initialize temp table to store Total Metrics for @Percentages = 1 - START
DROP TABLE IF EXISTS #TotalMetrics
CREATE TABLE #TotalMetrics
(
	 [duration]				BIGINT
	,[cpu_time]				BIGINT
	,[logical_io_reads]		BIGINT
	,[logical_io_writes]	BIGINT
	,[physical_io_reads]	BIGINT
	,[clr_time]				BIGINT
	,[query_used_memory]	BIGINT
	,[log_bytes_used]		BIGINT
	,[tempdb_space_used]	BIGINT
)
INSERT INTO #TotalMetrics VALUES (0,0,0,0,0,0,0,0,0)
-- Create and initialize temp table to store Total Metrics for @Percentages = 1 - END

-- Define query to capture total values for all metrics - START
DECLARE @SqlCommand2GetTotalMetricsTemplate NVARCHAR(MAX)
SET @SqlCommand2GetTotalMetricsTemplate = 'USE [{@DatabaseName}]
DECLARE @Database_duration			BIGINT
DECLARE @Database_cpu_time			BIGINT
DECLARE @Database_logical_io_reads	BIGINT
DECLARE @Database_logical_io_writes	BIGINT
DECLARE @Database_physical_io_reads	BIGINT
DECLARE @Database_clr_time			BIGINT
DECLARE @Database_query_used_memory	BIGINT
DECLARE @Database_log_bytes_used	BIGINT
DECLARE @Database_tempdb_space_used	BIGINT

SELECT
 @Database_duration				=					CAST(SUM([qsrs].[avg_duration]				* [qsrs].[count_executions]) AS BIGINT)
,@Database_cpu_time				=					CAST(SUM([qsrs].[avg_cpu_time]				* [qsrs].[count_executions]) AS BIGINT)
,@Database_logical_io_reads		=					CAST(SUM([qsrs].[avg_logical_io_reads]		* [qsrs].[count_executions]) AS BIGINT)
,@Database_logical_io_writes	=					CAST(SUM([qsrs].[avg_logical_io_writes]		* [qsrs].[count_executions]) AS BIGINT)
,@Database_physical_io_reads	=					CAST(SUM([qsrs].[avg_physical_io_reads]		* [qsrs].[count_executions]) AS BIGINT)
,@Database_clr_time				=					CAST(SUM([qsrs].[avg_clr_time]				* [qsrs].[count_executions]) AS BIGINT)
,@Database_query_used_memory	=					CAST(SUM([qsrs].[avg_query_max_used_memory]	* [qsrs].[count_executions]) AS BIGINT)
,@Database_log_bytes_used		= {@SQL2016columns} CAST(SUM([qsrs].[avg_log_bytes_used]		* [qsrs].[count_executions]) AS BIGINT)
,@Database_tempdb_space_used	= {@SQL2016columns} CAST(SUM([qsrs].[avg_tempdb_space_used]		* [qsrs].[count_executions]) AS BIGINT)
FROM [{@DatabaseName}].[sys].[query_store_runtime_stats] [qsrs]
WHERE
	(
	 (qsrs.first_execution_time >= ''{@StartTime}'' AND qsrs.last_execution_time < ''{@EndTime}'')
	 OR (qsrs.first_execution_time  <= ''{@StartTime}'' AND qsrs.last_execution_time > ''{@StartTime}'')
	 OR (qsrs.first_execution_time  <= ''{@EndTime}''   AND qsrs.last_execution_time > ''{@EndTime}'')
	)

SET @Database_duration			= COALESCE(@Database_duration,0)
SET @Database_cpu_time			= COALESCE(@Database_cpu_time,0)
SET @Database_logical_io_reads	= COALESCE(@Database_logical_io_reads,0)
SET @Database_logical_io_writes	= COALESCE(@Database_logical_io_writes,0)
SET @Database_physical_io_reads	= COALESCE(@Database_physical_io_reads,0)
SET @Database_clr_time			= COALESCE(@Database_clr_time,0)
SET @Database_query_used_memory	= COALESCE(@Database_query_used_memory,0)
SET @Database_log_bytes_used	= COALESCE(@Database_log_bytes_used,0)
SET @Database_tempdb_space_used	= COALESCE(@Database_tempdb_space_used,0)

DECLARE @Total_duration				BIGINT
DECLARE @Total_cpu_time				BIGINT
DECLARE @Total_logical_io_reads		BIGINT
DECLARE @Total_logical_io_writes	BIGINT
DECLARE @Total_physical_io_reads	BIGINT
DECLARE @Total_clr_time				BIGINT
DECLARE @Total_query_used_memory	BIGINT
DECLARE @Total_log_bytes_used		BIGINT
DECLARE @Total_tempdb_space_used	BIGINT
SELECT
 @Total_duration			=	[duration]
,@Total_cpu_time			=	[cpu_time]
,@Total_logical_io_reads	=	[logical_io_reads]
,@Total_logical_io_writes	=	[logical_io_writes]
,@Total_physical_io_reads	=	[physical_io_reads]
,@Total_clr_time			=	[clr_time]
,@Total_query_used_memory	=	[query_used_memory]
,@Total_log_bytes_used		=	[log_bytes_used]
,@Total_tempdb_space_used	=	[tempdb_space_used]
FROM #TotalMetrics

UPDATE #TotalMetrics
SET
 [duration]				= @Total_duration			+	@Database_duration
,[cpu_time]				= @Total_cpu_time			+	@Database_cpu_time
,[logical_io_reads]		= @Total_logical_io_reads	+	@Database_logical_io_reads
,[logical_io_writes]	= @Total_logical_io_writes	+	@Database_logical_io_writes
,[physical_io_reads]	= @Total_physical_io_reads	+	@Database_physical_io_reads
,[clr_time]				= @Total_clr_time			+	@Database_clr_time
,[query_used_memory]	= @Total_query_used_memory	+	@Database_query_used_memory
,[log_bytes_used]		= @Total_log_bytes_used		+	@Database_log_bytes_used
,[tempdb_space_used]	= @Total_tempdb_space_used	+	@Database_tempdb_space_used'
	SET @SqlCommand2GetTotalMetricsTemplate = REPLACE(@SqlCommand2GetTotalMetricsTemplate, '{@StartTime}',			CAST(@StartTime AS NVARCHAR(34)))
	SET @SqlCommand2GetTotalMetricsTemplate = REPLACE(@SqlCommand2GetTotalMetricsTemplate, '{@EndTime}',				CAST(@EndTime AS NVARCHAR(34)))

	-- If the SQL version is 2016, exclude components not available on that version - START
	IF (@Version = 13)
	BEGIN
		SET @SqlCommand2GetTotalMetricsTemplate = REPLACE(@SqlCommand2GetTotalMetricsTemplate, '{@SQL2016columns}',	'0 --')
	END
	ELSE
	BEGIN
		SET @SqlCommand2GetTotalMetricsTemplate = REPLACE(@SqlCommand2GetTotalMetricsTemplate, '{@SQL2016columns}',	'')
	END
	-- If the SQL version is 2016, exclude components not available on that version - END
-- Define query to capture total values for all metrics - END


-- Loop through all the databases in scope to load their details into #ServerTopObjectsStore - START
DECLARE @CurrentDBTable TABLE(
    DatabaseName  SYSNAME
)
DECLARE @CurrentDB SYSNAME

DECLARE @SqlCommand2GetTotalMetrics NVARCHAR(MAX)
DECLARE @SqlCommand2PopulateTempTable NVARCHAR(MAX)
WHILE EXISTS (SELECT 1 FROM @dbs)
BEGIN
    DELETE TOP(1) FROM @dbs
    OUTPUT deleted.DatabaseName INTO @CurrentDBTable
    SELECT @CurrentDB = DatabaseName FROM @CurrentDBTable

	-- When @Percentages = 1, calculate the total amount of all metrics - START
	IF (@Percentages = 1)
	BEGIN
		SET @SqlCommand2GetTotalMetrics	=	REPLACE(@SqlCommand2GetTotalMetricsTemplate,	'{@DatabaseName}',		@CurrentDB)
		IF (@VerboseMode = 1)	PRINT	(@SqlCommand2GetTotalMetrics)
		IF (@TestMode = 0)		EXECUTE	(@SqlCommand2GetTotalMetrics)
	END
	-- When @Percentages = 1, calculate the total amount of all metrics - END

    SET @SqlCommand2PopulateTempTable	=	REPLACE(@SqlCommand2PopulateTempTableTemplate,	'{@DatabaseName}',		@CurrentDB)
    IF (@VerboseMode = 1)	PRINT	(@SqlCommand2PopulateTempTable)
	IF (@TestMode = 0)		EXECUTE	(@SqlCommand2PopulateTempTable)
END
-- Loop through all the databases in scope to load their details into #ServerTopObjectsStore - END


-- Store the Total Metrics for calculations required for @Percentages = 1 - START
DECLARE @TotalDuration			BIGINT
DECLARE @TotalCPU				BIGINT
DECLARE @TotalLogicalIOReads	BIGINT
DECLARE @TotalLogicalIOWrites	BIGINT
DECLARE @TotalPhysicalIOReads	BIGINT
DECLARE @TotalCLR				BIGINT
DECLARE @TotalMemory			BIGINT
DECLARE @TotalLogBytesUsed		BIGINT
DECLARE @TotalTempDB			BIGINT
SELECT
	 @TotalDuration			=	[tm].[duration]
	,@TotalCPU				=	[tm].[cpu_time]
	,@TotalLogicalIOReads	=	[tm].[logical_io_reads]
	,@TotalLogicalIOWrites	=	[tm].[logical_io_writes]
	,@TotalPhysicalIOReads	=	[tm].[physical_io_reads]
	,@TotalCLR				=	[tm].[clr_time]
	,@TotalMemory			=	[tm].[query_used_memory]
	,@TotalLogBytesUsed		=	[tm].[log_bytes_used]
	,@TotalTempDB			=	[tm].[tempdb_space_used]
FROM #TotalMetrics [tm]
	-- If no total metrics have been calculated, reset this value to xxxxx - START
	IF (@TotalDuration + @TotalCPU + @TotalLogicalIOReads + @TotalLogicalIOWrites + @TotalPhysicalIOReads + @TotalCLR + @TotalMemory + @TotalLogBytesUsed + @TotalTempDB = 0)
	BEGIN
		SET @TotalDuration			=	100000
		SET @TotalCPU				=	100000
		SET @TotalLogicalIOReads	=	100000
		SET @TotalLogicalIOWrites	=	100000
		SET @TotalPhysicalIOReads	=	100000
		SET @TotalCLR				=	100000
		SET @TotalMemory			=	100000
		SET @TotalLogBytesUsed		=	100000
		SET @TotalTempDB			=	100000
	END
	-- If no total metrics have been calculated, reset this value to xxxxx - END
-- Store the Total Metrics for calculations required for @Percentages = 1 - END


-- Output to user - START
IF (@ReportTable IS NULL) OR (@ReportTable = '') OR (@ReportIndex IS NULL) OR (@ReportIndex = '')
BEGIN
	DECLARE @SqlCmd2User NVARCHAR(MAX)
	SET @SqlCmd2User = 'SELECT
	 [DatabaseName]			
	,[ObjectID]
	,[ObjectQueries]
	,[SchemaName]			
	,[ObjectName]			
	,[ExecutionTypeDesc]		
	,[EstimatedExecutionCount]		
	,CASE WHEN {@TotalDuration}			= 0 THEN 0 ELSE CAST( (100000*[duration]			)	/{@TotalDuration}			AS BIGINT)	END AS [Duration]
	,CASE WHEN {@TotalCPU}				= 0 THEN 0 ELSE CAST( (100000*[cpu_time]			)	/{@TotalCPU}				AS BIGINT)	END AS [CPU]
	,CASE WHEN {@TotalLogicalIOReads}	= 0 THEN 0 ELSE CAST( (100000*[logical_io_reads]	)	/{@TotalLogicalIOReads}		AS BIGINT)	END AS [LogicalIOReads]
	,CASE WHEN {@TotalLogicalIOWrites}	= 0 THEN 0 ELSE CAST( (100000*[logical_io_writes]	)	/{@TotalLogicalIOWrites}	AS BIGINT)	END AS [LogicalIOWrites]
	,CASE WHEN {@TotalPhysicalIOReads}	= 0 THEN 0 ELSE CAST( (100000*[physical_io_reads]	)	/{@TotalPhysicalIOReads}	AS BIGINT)	END AS [PhysicalIOReads]
	,CASE WHEN {@TotalCLR}				= 0 THEN 0 ELSE CAST( (100000*[clr_time]			)	/{@TotalCLR}				AS BIGINT)	END AS [CLR]
	,CASE WHEN {@TotalMemory}			= 0 THEN 0 ELSE CAST( (100000*[query_used_memory]	)	/{@TotalMemory}				AS BIGINT)	END AS [Memory]
	,CASE WHEN {@TotalLogBytesUsed}		= 0 THEN 0 ELSE CAST( (100000*[log_bytes_used]		)	/{@TotalLogBytesUsed}		AS BIGINT)	END AS [LogBytesUsed]
	,CASE WHEN {@TotalTempDB}			= 0 THEN 0 ELSE CAST( (100000*[tempdb_space_used]	)	/{@TotalTempDB}				AS BIGINT)	END AS [TempDB]
	FROM #ServerTopObjectsStore
	ORDER BY {@Measurement} DESC'
	
	-- Replace @TotalXXXXX values - START
	SET @SqlCmd2User = REPLACE(@SqlCmd2User,	'{@TotalDuration}',			CAST(@TotalDuration			AS NVARCHAR(22)))
	SET @SqlCmd2User = REPLACE(@SqlCmd2User,	'{@TotalCPU}',				CAST(@TotalCPU				AS NVARCHAR(22)))
	SET @SqlCmd2User = REPLACE(@SqlCmd2User,	'{@TotalLogicalIOReads}',	CAST(@TotalLogicalIOReads	AS NVARCHAR(22)))
	SET @SqlCmd2User = REPLACE(@SqlCmd2User,	'{@TotalLogicalIOWrites}',	CAST(@TotalLogicalIOWrites	AS NVARCHAR(22)))
	SET @SqlCmd2User = REPLACE(@SqlCmd2User,	'{@TotalPhysicalIOReads}',	CAST(@TotalPhysicalIOReads	AS NVARCHAR(22)))
	SET @SqlCmd2User = REPLACE(@SqlCmd2User,	'{@TotalCLR}',				CAST(@TotalCLR				AS NVARCHAR(22)))
	SET @SqlCmd2User = REPLACE(@SqlCmd2User,	'{@TotalMemory}',			CAST(@TotalMemory			AS NVARCHAR(22)))
	SET @SqlCmd2User = REPLACE(@SqlCmd2User,	'{@TotalLogBytesUsed}',		CAST(@TotalLogBytesUsed		AS NVARCHAR(22)))
	SET @SqlCmd2User = REPLACE(@SqlCmd2User,	'{@TotalTempDB}',			CAST(@TotalTempDB			AS NVARCHAR(22)))
	-- Replace @TotalXXXXX values - END

	SET @SqlCmd2User = REPLACE(@SqlCmd2User,	'{@Measurement}', QUOTENAME(@Measurement))
	IF (@VerboseMode = 1)	PRINT (@SqlCmd2User)
	IF (@TestMode = 0)		EXEC (@SqlCmd2User)
END
-- Output to user - END

-- Output to table - START
IF (@ReportTable IS NOT NULL) AND (@ReportTable <> '') AND (@ReportIndex IS NOT NULL) AND (@ReportIndex <> '')
BEGIN
	-- Log report entry in [dbo].[ServerLoadIndex] - START
	DECLARE @SqlCmdIndex NVARCHAR(MAX) =
	'INSERT INTO {@ReportIndex}
	(
		[CaptureDate],
		[ServerIdentifier],
		[DatabaseName],
		[Parameters]
	)
	SELECT
		SYSUTCDATETIME(),
		''{@ServerIdentifier}'',
		''{@DatabaseName}'',
		(
		SELECT
			''{@StartTime}''			AS [StartTime],
			''{@EndTime}''				AS [EndTime],
			{@Top}						AS [Top],
			''{@Measurement}''			AS [Measurement],
			{@Percentages}				AS [Percentages],
			{@AggregateAll}				AS [AggregateAll],
			{@AggregateNonRegular}		AS [AggregateNonRegular],
			{@IncludeAdhocQueries}		AS [IncludeAdhocQueries],
			{@IncludeObjectQueryIDs}	AS [IncludeObjectQueryIDs]
		FOR XML PATH(''ServerTopObjectsParameters''), ROOT(''Root'')
		)	AS [Parameters]'

	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@ReportIndex}',				@ReportIndex)
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@ServerIdentifier}',			@ServerIdentifier)
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@DatabaseName}',				ISNULL(@DatabaseName,'*'))
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@StartTime}',				CAST(@StartTime AS NVARCHAR(34)))
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@EndTime}',					CAST(@EndTime	AS NVARCHAR(34)))
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@Top}',						@Top)
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@Measurement}',				@Measurement)
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@Percentages}',				@Percentages)
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@AggregateAll}',				@AggregateAll)
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@AggregateNonRegular}',		@AggregateNonRegular)
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@IncludeAdhocQueries}',		@IncludeAdhocQueries)
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@IncludeObjectQueryIDs}',	@IncludeObjectQueryIDs)

	IF (@VerboseMode = 1)	PRINT (@SqlCmdIndex)
	IF (@TestMode = 0)		EXEC (@SqlCmdIndex)

	SET @ReportID = IDENT_CURRENT(@ReportIndex)
	-- Log report entry in [dbo].[ServerLoadIndex] - END


	DECLARE @SqlCmd2Table NVARCHAR(MAX) = 'INSERT INTO {@ReportTable}
	SELECT
		 {@ReportID}
		,[DatabaseName]
		,[ObjectID]
		,[ObjectQueries]
		,[SchemaName]
		,[ObjectName]
		,[ExecutionTypeDesc]
		,[EstimatedExecutionCount]
		,CASE 
			WHEN {@TotalDuration} != 0 THEN (1000000*[duration]		 )/{@TotalDuration}
			ELSE 0
		 END
		,CASE 
			WHEN {@TotalCPU} != 0 THEN (1000000*[cpu_time]		 )/{@TotalCPU}
			ELSE 0
		 END
		,CASE 
			WHEN {@TotalLogicalIOReads} != 0 THEN (1000000*[logical_io_reads] )/{@TotalLogicalIOReads}
			ELSE 0
		 END
		,CASE 
			WHEN {@TotalLogicalIOWrites} != 0 THEN (1000000*[logical_io_writes])/{@TotalLogicalIOWrites}
			ELSE 0
		 END
		,CASE 
			WHEN {@TotalPhysicalIOReads} != 0 THEN (1000000*[physical_io_reads])/{@TotalPhysicalIOReads}
			ELSE 0
		 END
		,CASE 
			WHEN {@TotalCLR} != 0 THEN (1000000*[clr_time]		 )/{@TotalCLR}
			ELSE 0
		 END
		,CASE 
			WHEN {@TotalMemory} != 0 THEN (1000000*[query_used_memory])/{@TotalMemory}
			ELSE 0
		 END
		,CASE 
			WHEN {@TotalLogBytesUsed} != 0 THEN (1000000*[log_bytes_used]	 )/{@TotalLogBytesUsed}
			ELSE 0
		 END
		,CASE 
			WHEN {@TotalTempDB} != 0 THEN (1000000*[tempdb_space_used])/{@TotalTempDB}
			ELSE 0
		 END
	FROM #ServerTopObjectsStore'

	SET @SqlCmd2Table = REPLACE(@SqlCmd2Table, '{@ReportTable}',		@ReportTable) 
	SET @SqlCmd2Table = REPLACE(@SqlCmd2Table, '{@ReportID}',			@ReportID) 

	-- Replace @TotalXXXXX values - START
	SET @SqlCmd2Table = REPLACE(@SqlCmd2Table,	'{@TotalDuration}',			CAST(@TotalDuration			AS NVARCHAR(22)))
	SET @SqlCmd2Table = REPLACE(@SqlCmd2Table,	'{@TotalCPU}',				CAST(@TotalCPU				AS NVARCHAR(22)))
	SET @SqlCmd2Table = REPLACE(@SqlCmd2Table,	'{@TotalLogicalIOReads}',	CAST(@TotalLogicalIOReads	AS NVARCHAR(22)))
	SET @SqlCmd2Table = REPLACE(@SqlCmd2Table,	'{@TotalLogicalIOWrites}',	CAST(@TotalLogicalIOWrites	AS NVARCHAR(22)))
	SET @SqlCmd2Table = REPLACE(@SqlCmd2Table,	'{@TotalPhysicalIOReads}',	CAST(@TotalPhysicalIOReads	AS NVARCHAR(22)))
	SET @SqlCmd2Table = REPLACE(@SqlCmd2Table,	'{@TotalCLR}',				CAST(@TotalCLR				AS NVARCHAR(22)))
	SET @SqlCmd2Table = REPLACE(@SqlCmd2Table,	'{@TotalMemory}',			CAST(@TotalMemory			AS NVARCHAR(22)))
	SET @SqlCmd2Table = REPLACE(@SqlCmd2Table,	'{@TotalLogBytesUsed}',		CAST(@TotalLogBytesUsed		AS NVARCHAR(22)))
	SET @SqlCmd2Table = REPLACE(@SqlCmd2Table,	'{@TotalTempDB}',			CAST(@TotalTempDB			AS NVARCHAR(22)))
	-- Replace @TotalXXXXX values - END

	IF (@VerboseMode = 1)	PRINT (@SqlCmd2Table)
	IF (@TestMode = 0)		EXEC (@SqlCmd2Table)
END
-- Output to table - END

DROP TABLE IF EXISTS #ServerTopObjectsStore
DROP TABLE IF EXISTS #TotalMetrics
RETURN
END
GO