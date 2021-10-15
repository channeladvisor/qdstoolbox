----------------------------------------------------------------------------------
-- Procedure Name: [dbo].[ServerTopQueries]
--
-- Desc: This script loops all the accessible user DBs (or just the selected one) and gathers the TOP XX queries based on the selected measurement and generates a report
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
--														Table available in dbo.ServerTopQueriesIndex
--
--		@ReportTable				NVARCHAR(800)	--	Table to store the results of the report, if no results returned to the user are required. 
--														[Default: NULL, results returned to user]
--														Table available in dbo.ServerTopQueriesStore
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
--		@IncludeQueryText			BIT				--	Flag to include the query text in the results.
--														[Default: 0]
--
--		@ExcludeAdhoc				BIT				--	Flag to define whether to ignore adhoc queries (not part of a DB object) from the analysis
--														[Default: 0]
--
--		@ExcludeInternal			BIT				--	Flag to define whether to ignore internal queries (backup, index rebuild, statistics update...) from the analysis
--														[Default: 0]
--
--		@AggregateAll				BIT				--	Flag to aggregate all types of executions in the results
--														[Default: 1]
--
--		@AggregateNonRegular		BIT				--	Flag to aggregate the Aborted and Exception executions in the results
--														[Default: 0]
--			Only one of @AggregateAll and @AggregateNonRegular are allowed
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
-- Date: 2020.08.06
-- Auth: Pablo Lozano (@sqlozano)
--
-- Date: 2021.02.28
-- Auth: Pablo Lozano (@sqlozano)
-- Changes:	Execution in SQL 2016 will thrown an error when the @Measurement selected does not exist
--			Execution in SQL 2016 will return NULL for the measures not included in this version (log_bytes_used & tempdb_space_used)
--
-- Date: 2021.08.19
-- Auth: Pablo Lozano (@sqlozano)
-- Changes: Added flags to aggregate executions based on the execution result (Regular, Aborted, Exception)
--			Replaced [PlanID] with [MinNumberPlans]
--
-- Date: 2021.08.25
-- Auth: Pablo Lozano (@sqlozano)
-- Changes: Removed filter based on execution result (Regular, Aborted, Exception) due to the additional load and duration it generated
--
-- Date: 2021.10.15
-- Auth: Pablo Lozano (@sqlozano)
-- Changes: Added flag @Percentages to calculate percentages instead of absolute values
----------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE [dbo].[ServerTopQueries]
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
	,@IncludeQueryText		BIT				= 0
	,@ExcludeAdhoc			BIT				= 0
	,@ExcludeInternal		BIT				= 1
	,@AggregateAll			BIT				= 1
	,@AggregateNonRegular	BIT				= 0
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
	RAISERROR(N'[dbo].[ServerTopQueries] requires SQL 2016 or higher',16,1)
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

IF (@IncludeQueryText IS NULL)
	SET @IncludeQueryText = 0
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
DROP TABLE IF EXISTS #ServerTopQueriesStore
CREATE TABLE #ServerTopQueriesStore
(
	 [DatabaseName]			SYSNAME			NOT NULL
	,[QueryID]				BIGINT			NOT NULL
	,[MinNumberPlans]		INT				NOT NULL
	,[QueryTextID]			BIGINT			NOT NULL
	,[ObjectID]				BIGINT			NOT NULL
	,[SchemaName]			SYSNAME			    NULL
	,[ObjectName]			SYSNAME			    NULL
	,[ExecutionTypeDesc]	NVARCHAR(120)	NOT NULL
	,[ExecutionCount]		BIGINT			NOT NULL
	,[duration]				BIGINT			NOT NULL
	,[cpu_time]				BIGINT			NOT NULL
	,[logical_io_reads]		BIGINT			NOT NULL
	,[logical_io_writes]	BIGINT			NOT NULL
	,[physical_io_reads]	BIGINT			NOT NULL
	,[clr_time]				BIGINT			NOT NULL
	,[query_used_memory]	BIGINT			NOT NULL
	,[log_bytes_used]		BIGINT				NULL
	,[tempdb_space_used]	BIGINT				NULL
	,[QuerySqlText]			VARBINARY(MAX)	    NULL
)
-- Definition of temp table to store the reports for each database - END

-- Query to extract the details for any given @DatabaseName - START
DECLARE @SqlCommand2PopulateTempTableTemplate NVARCHAR(MAX)
SET @SqlCommand2PopulateTempTableTemplate = 'USE [{@DatabaseName}]
;WITH [st1] AS
(
SELECT
 [qsp].[query_id]
,[MinNumberPlans]	= COUNT([qsrs].[plan_id])
,[qsq].[query_text_id]
,[object_id]		= ISNULL([obs].[object_id], 0)
,[SchemaName]		= ISNULL(SCHEMA_NAME([obs].[schema_id]), '''')
,[ProcedureName]	= ISNULL(OBJECT_NAME([obs].[object_id]), '''')
,CASE
	WHEN {@AggregateAll} = 1 THEN ''ALL''
	WHEN {@AggregateNonRegular} = 1 AND [qsrs].[execution_type_desc] != ''Regular'' THEN ''NonRegular''
	ELSE [qsrs].[execution_type_desc]
 END AS [ExecutionTypeDesc]
,[count_executions]	= [qsrs].[count_executions]
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
LEFT JOIN [{@DatabaseName}].[sys].[objects] [obs]
ON [qsq].[object_id] = [obs].[object_id]
WHERE
(
 (qsrs.first_execution_time >= ''{@StartTime}'' AND qsrs.last_execution_time < ''{@EndTime}'')
 OR (qsrs.first_execution_time  <= ''{@StartTime}'' AND qsrs.last_execution_time > ''{@StartTime}'')
 OR (qsrs.first_execution_time  <= ''{@EndTime}''   AND qsrs.last_execution_time > ''{@EndTime}'')
)
{@ExcludeAdhoc}
{@ExcludeInternal}
GROUP BY [qsp].[query_id], [qsq].[query_text_id], [obs].[schema_id], [obs].[object_id], [qsrs].[execution_type_desc],[qsrs].[count_executions]
),
[st2]
AS
(
SELECT
 [st1].[query_id]
,[MinNumberPlans]	= MIN([st1].[MinNumberPlans])
,[st1].[query_text_id]
,[st1].[object_id]
,[st1].[SchemaName]
,[st1].[ProcedureName]
,[st1].[ExecutionTypeDesc]
,[count_executions]	= SUM([st1].[count_executions])
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
 [st1].[query_id]
,[st1].[query_text_id]
,[st1].[object_id]
,[st1].[SchemaName]
,[st1].[ProcedureName]
,[st1].[ExecutionTypeDesc]
)
INSERT INTO #ServerTopQueriesStore
SELECT
 {@Top}
 ''{@DatabaseName}''
,[st2].[query_id]
,[st2].[MinNumberPlans]
,[st2].[query_text_id]
,[st2].[object_id]
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
,{@IncludeQueryText_Value} AS [query_sql_text] 
FROM [st2]
{@IncludeQueryText_Join}
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

	-- Based on @IncludeQueryText, include the query text in the reports or not - START
	IF (@IncludeQueryText = 0)
	BEGIN
		SET @SqlCommand2PopulateTempTableTemplate = REPLACE(@SqlCommand2PopulateTempTableTemplate, '{@IncludeQueryText_Value}',	'NULL')
		SET @SqlCommand2PopulateTempTableTemplate = REPLACE(@SqlCommand2PopulateTempTableTemplate, '{@IncludeQueryText_Join}',	'')
	END
	IF (@IncludeQueryText = 1)
	BEGIN
		SET @SqlCommand2PopulateTempTableTemplate = REPLACE(@SqlCommand2PopulateTempTableTemplate, '{@IncludeQueryText_Join}',	'INNER JOIN [{@DatabaseName}].[sys].[query_store_query_text] [qsqt] ON [st2].[query_text_id] = [qsqt].[query_text_id]')
		SET @SqlCommand2PopulateTempTableTemplate = REPLACE(@SqlCommand2PopulateTempTableTemplate, '{@IncludeQueryText_Value}',	'COMPRESS([qsqt].[query_sql_text])')
	END
	-- Based on @IncludeQueryText, include the query text in the reports or not - END

	-- Based on @ExcludeAdhoc, exclude Adhoc queries from the analysis - START
	IF (@ExcludeAdhoc = 0)
	BEGIN
		SET @SqlCommand2PopulateTempTableTemplate = REPLACE(@SqlCommand2PopulateTempTableTemplate, '{@ExcludeAdhoc}',		'')	
	END
	IF (@ExcludeAdhoc = 1)
	BEGIN
		SET @SqlCommand2PopulateTempTableTemplate = REPLACE(@SqlCommand2PopulateTempTableTemplate, '{@ExcludeAdhoc}',		'AND ([qsq].[object_id] <> 0)')
	END
	-- Based on @ExcludeAdhoc, exclude Adhoc queries from the analysis - END
	
	-- Based on @ExcludeInternal, exclude internal queries from the analysis - START
	IF (@ExcludeInternal = 0)
	BEGIN
		SET @SqlCommand2PopulateTempTableTemplate = REPLACE(@SqlCommand2PopulateTempTableTemplate, '{@ExcludeInternal}',	'')	
	END
	IF (@ExcludeInternal = 1)
	BEGIN
		SET @SqlCommand2PopulateTempTableTemplate = REPLACE(@SqlCommand2PopulateTempTableTemplate, '{@ExcludeInternal}',	'AND (qsq.is_internal_query = 0)')	
	END
	-- Based on @ExcludeInternal, exclude internal queries from the analysis - END


	-- Based on @AggregateAll, aggregate all executions in the analysis - START
	SET @SqlCommand2PopulateTempTableTemplate = REPLACE(@SqlCommand2PopulateTempTableTemplate, '{@AggregateAll}',			CAST(@AggregateAll AS NVARCHAR(1)))
	-- Based on @AggregateAll, aggregate all executions in the analysis - END

	-- Based on @AggregateNonRegular, aggregate all executions based on Regular / NonRegular in the analysis - START
	SET @SqlCommand2PopulateTempTableTemplate = REPLACE(@SqlCommand2PopulateTempTableTemplate, '{@AggregateNonRegular}',	CAST(@AggregateNonRegular AS NVARCHAR(1)))
	-- Based on @AggregateNonRegular, aggregate all executions based on Regular / NonRegular in the analysis - END

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


-- Loop through all the databases in scope to load their details into #ServerTopQueriesStore - START
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
-- Loop through all the databases in scope to load their details into #ServerTopQueriesStore - END


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
	,[QueryID]				
	,[MinNumberPlans]				
	,[QueryTextID]			
	,[ObjectID]				
	,[SchemaName]			
	,[ObjectName]			
	,[ExecutionTypeDesc]		
	,[ExecutionCount]		
	,CASE WHEN {@TotalDuration}			= 0 THEN 0 ELSE CAST( (100000*[duration]			)	/{@TotalDuration}			AS BIGINT)	END AS [Duration]
	,CASE WHEN {@TotalCPU}				= 0 THEN 0 ELSE CAST( (100000*[cpu_time]			)	/{@TotalCPU}				AS BIGINT)	END AS [CPU]
	,CASE WHEN {@TotalLogicalIOReads}	= 0 THEN 0 ELSE CAST( (100000*[logical_io_reads]	)	/{@TotalLogicalIOReads}		AS BIGINT)	END AS [LogicalIOReads]
	,CASE WHEN {@TotalLogicalIOWrites}	= 0 THEN 0 ELSE CAST( (100000*[logical_io_writes]	)	/{@TotalLogicalIOWrites}	AS BIGINT)	END AS [LogicalIOWrites]
	,CASE WHEN {@TotalPhysicalIOReads}	= 0 THEN 0 ELSE CAST( (100000*[physical_io_reads]	)	/{@TotalPhysicalIOReads}	AS BIGINT)	END AS [PhysicalIOReads]
	,CASE WHEN {@TotalCLR}				= 0 THEN 0 ELSE CAST( (100000*[clr_time]			)	/{@TotalCLR}				AS BIGINT)	END AS [CLR]
	,CASE WHEN {@TotalMemory}			= 0 THEN 0 ELSE CAST( (100000*[query_used_memory]	)	/{@TotalMemory}				AS BIGINT)	END AS [Memory]
	,CASE WHEN {@TotalLogBytesUsed}		= 0 THEN 0 ELSE CAST( (100000*[log_bytes_used]		)	/{@TotalLogBytesUsed}		AS BIGINT)	END AS [LogBytesUsed]
	,CASE WHEN {@TotalTempDB}			= 0 THEN 0 ELSE CAST( (100000*[tempdb_space_used]	)	/{@TotalTempDB}				AS BIGINT)	END AS [TempDB]
	,CAST(DECOMPRESS([QuerySqlText]) AS NVARCHAR(MAX))	AS [QuerySqlText]
	FROM #ServerTopQueriesStore
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
			''{@StartTime}''		AS [StartTime],
			''{@EndTime}''			AS [EndTime],
			{@Top}					AS [Top],
			''{@Measurement}''		AS [Measurement],
			{@Percentages}			AS [Percentages],
			{@IncludeQueryText}		AS [IncludeQueryText],
			{@ExcludeAdhoc}			AS [ExcludeAdhoc],
			{@ExcludeInternal}		AS [ExcludeInternal],
			{@AggregateAll}			AS [AggregateAll],
			{@AggregateNonRegular}	AS [AggregateNonRegular]
		FOR XML PATH(''ServerTopQueriesParameters''), ROOT(''Root'')
		)	AS [Parameters]'

	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@ReportIndex}',			@ReportIndex)
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@ServerIdentifier}',		@ServerIdentifier)
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@DatabaseName}',			ISNULL(@DatabaseName,'*'))
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@StartTime}',			CAST(@StartTime AS NVARCHAR(34)))
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@EndTime}',				CAST(@EndTime	AS NVARCHAR(34)))
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@Top}',					@Top)
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@Measurement}',			@Measurement)
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@Percentages}',			@Percentages)
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@IncludeQueryText}',		@IncludeQueryText)
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@ExcludeAdhoc}',			@ExcludeAdhoc)
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@ExcludeInternal}',		@ExcludeInternal)
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@AggregateAll}',			@AggregateAll)
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@AggregateNonRegular}',	@AggregateNonRegular)

	IF (@VerboseMode = 1)	PRINT (@SqlCmdIndex)
	IF (@TestMode = 0)		EXEC (@SqlCmdIndex)

	SET @ReportID = IDENT_CURRENT(@ReportIndex)
	-- Log report entry in [dbo].[ServerLoadIndex] - END


	DECLARE @SqlCmd2Table NVARCHAR(MAX) = 'INSERT INTO {@ReportTable}
	SELECT
		 {@ReportID}
		,[DatabaseName]
		,[QueryID]
		,[MinNumberPlans]
		,[QueryTextID]
		,[ObjectID]
		,[SchemaName]
		,[ObjectName]
		,[ExecutionTypeDesc]
		,[ExecutionCount]
		,(1000000*[duration]		 )/{@TotalDuration}
		,(1000000*[cpu_time]		 )/{@TotalCPU}
		,(1000000*[logical_io_reads] )/{@TotalLogicalIOReads}
		,(1000000*[logical_io_writes])/{@TotalLogicalIOWrites}
		,(1000000*[physical_io_reads])/{@TotalPhysicalIOReads}
		,(1000000*[clr_time]		 )/{@TotalCLR}
		,(1000000*[query_used_memory])/{@TotalMemory}
		,(1000000*[log_bytes_used]	 )/{@TotalLogBytesUsed}
		,(1000000*[tempdb_space_used])/{@TotalTempDB}
		,[QuerySqlText]	
	FROM #ServerTopQueriesStore'

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

DROP TABLE IF EXISTS #ServerTopQueriesStore
DROP TABLE IF EXISTS #TotalMetrics
RETURN
END
GO