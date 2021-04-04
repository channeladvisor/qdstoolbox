SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

----------------------------------------------------------------------------------
-- Procedure Name: [dbo].[QueryWaits]
--
-- Desc: This script queries the QDS data and generates a report based on wait statistics of a given Object, Query or Execution plan over a given period of time
--
--
-- Parameters:
--	INPUT
--		@InstanceIdentifier			SYSNAME			--	Identifier assigned to the instance.
--														[Default: @@SERVERNAME]
--
--		@DatabaseName				SYSNAME			--	Name of the database to generate this report on.
--														[Default: DB_NAME()]
--
--		@ReportIndex				NVARCHAR(800)	--	Table to store the details of the report, such as parameters used, if no results returned to the user are required
--														[Default: NULL, results returned to user]
--
--		@ReportTable				NVARCHAR(800)	--	Table to store the results of the report, if no results returned to the user are required. 
--														[Default: NULL, results returned to user]
--
--		@StartTime					DATETIME2		--	Start of the time period to be analyzed. Must be expressed in UTC.
--														[Default: DATEADD(HOUR, -1, SYSUTCDATETIME()]
--
--		@EndTime					DATETIME2		--	End of the time period to be analyzed. Must be expressed in UTC.
--														[Default: SYSUTCDATETIME()]
--
---------------------------------------------------------------------------------------------------
--			NOTE:	Only one of the three parameters (@ObjectName, @PlanID, @QueryID)		     --
---------------------------------------------------------------------------------------------------
--
--		@ObjectName					NVARCHAR(256)	--	Name of the object whose waits are to be analyzed, in format schema.name or [schema].[name]
--
--
--		@PlanID						BIGINT			--	PlanID whose waits are to be analyzed.
--
--
--		@QueryID					BIGINT			--	QueryID whose waits are to be analyzed.
--
--
--		@VerboseMode				BIT				--	Flag to determine whether the T-SQL commands that compose this report will be returned to the user.
--														[Default: 0]
--
--		@TestMode					BIT				--	Flag to determine whether the actual T-SQL commands that generate the report will be executed.
--														[Default:0]
--
--	OUTPUT
--		@ReportID					BIGINT			--	Returns the ReportID (when the report is being logged into a table)
--
-- Sample execution:
--
--	Sample 1: Return the wait details for a given object over the last hour
--		EXECUTE [dbo].[QueryWaits]
--			@DatabaseName	= 'TargetDB',
--			@ObjectName		= 'Schema.Object'
--
--
--	Sample 2: Get the wait details of a given plan ID during the last month
--		DECLARE @EndTime		DATETIME2 = SYSUTCDATETIME()
--		DECLARE @StartTime		DATETIME2 = DATEADD(MONTH, -7, @EndTime)
--		EXECUTE [dbo].[QueryWaits]
--			@DatabaseName		= 'TargetDB',
--			@PlandID			= 321321,
--			@StartTime			= @StartTime,
--			@EndTime			= @EndTime
--
--	Sample 3: Save a query's waits for the last week into a table in a linked server [LinkedSrv].[LinkedDB].[dbo].[CentralizedQueryVariationStore],
--			including the queries' text
--		DECLARE @EndTime		DATETIME2 = SYSUTCDATETIME()
--		DECLARE @StartTime		DATETIME2 = DATEADD(DAY, -7, @EndTime)
--		EXECUTE [dbo].[QueryWaits]
--			@DatabaseName		= 'TargetDB',
--			@StartTime			= @StartTime,
--			@EndTime			= @EndTime,
--			@QueryID			= 96783,
--			@ReportIndex		= '[LinkedSrv].[LinkedDB].[dbo].[CentralizedQueryWaitsIndex]',
--			@ReportTable		= '[LinkedSrv].[LinkedDB].[dbo].[CentralizedQueryWaitsStore]',
--			@IncludeQueryText	= 1
--			
--
-- Date: 2020.10.22
-- Auth: Pablo Lozano (@sqlozano)
--
-- Date: 2021.02.28
-- Auth: Pablo Lozano (@sqlozano)
-- Changes:	Execution in SQL 2016 will thrown an error (this component was enabled first in SQL 2017)
----------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[QueryWaits]
(
	 @InstanceIdentifier		SYSNAME			= NULL	
	,@DatabaseName			SYSNAME			= NULL
	,@ReportIndex			NVARCHAR(800)	= NULL
	,@ReportTable			NVARCHAR(800)	= NULL
	,@StartTime				DATETIME2		= NULL
	,@EndTime				DATETIME2		= NULL
	,@ObjectName			NVARCHAR(256)	= NULL
	,@PlanID				BIGINT			= NULL
	,@QueryID				BIGINT			= NULL
	,@IncludeQueryText		BIT				= 0
	,@VerboseMode			BIT				= 0
	,@TestMode				BIT				= 0
	,@ReportID				BIGINT			= NULL	OUTPUT
)
AS
BEGIN
SET NOCOUNT ON

-- Get the Version # to ensure it runs SQL2017 or higher
DECLARE @Version INT =  CAST(SUBSTRING(CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')),0,CHARINDEX('.',CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')),0)) AS INT)
IF (@Version <= 13)
BEGIN
	RAISERROR(N'[dbo].[QueryWaits] requires SQL 2017 or higher',16,1)
	RETURN -1
END

-- Check variables and set defaults - START
IF (@InstanceIdentifier IS NULL)
	SET @InstanceIdentifier = @@SERVERNAME

-- If no @DatabaseName is provided, set it to DB_NAME() - START
IF (@DatabaseName IS NULL) OR (@DatabaseName = '')
	SET @DatabaseName = DB_NAME()
-- If no @DatabaseName is provided, set it to DB_NAME() - END

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

IF (@StartTime IS NULL) OR (@EndTime IS NULL)
BEGIN
	SET @StartTime	= DATEADD(HOUR,-1, GETUTCDATE())
	SET	@EndTime	= GETUTCDATE()
END

IF (@StartTime > @EndTime)
BEGIN
	DECLARE @Start NVARCHAR(34) = CAST(@StartTime AS NVARCHAR(34))
	DECLARE @End   NVARCHAR(34) = CAST(@EndTime   AS NVARCHAR(34))
	RAISERROR('@StartTime [%s] must be earlier than @EndTime [%s].', 16, 0, @Start , @End )
	RETURN
END

IF	
(
	( (@ObjectName IS NOT NULL)	AND		((@PlanID IS NOT NULL) OR (@QueryID IS NOT NULL)) )
	OR
	( (@PlanID IS NOT NULL)		AND		((@ObjectName IS NOT NULL) OR (@QueryID IS NOT NULL)) )
	OR
	( (@QueryID IS NOT NULL)	AND		((@ObjectName IS NOT NULL) OR (@PlanID IS NOT NULL)) )
)
BEGIN
	RAISERROR('Only one of the parameters [@ObjectName, @PlanID, @QueryID] can be provider at a time to this procedure.', 16, 0)
	RETURN
END

IF	( (@ObjectName IS NULL)	AND	(@PlanID IS NULL) AND (@QueryID IS NULL) )
BEGIN
	RAISERROR('None of the necessary parameters [@ObjectName, @PlanID, @QueryID] has been provided.', 16, 0)
	RETURN
END
-- Check variables and set defaults - END


-- Temporary table to hold the Wait details - START
DROP TABLE IF EXISTS #WaitDetails
CREATE TABLE #WaitDetails
(
	 [ObjectID]				BIGINT			NOT NULL
	,[SchemaName]			NVARCHAR(128)	NOT NULL
	,[ObjectName]			NVARCHAR(128)	NOT NULL
	,[PlanID]				BIGINT			NOT NULL
	,[QueryID]				BIGINT			NOT NULL
	,[QueryTextID]			BIGINT			NOT NULL
	,[StartTime]			DATETIME2		NOT NULL
	,[EndTime]				DATETIME2		NOT NULL
	,[DifferentPlansUsed]	INT				NOT NULL
	,[DifferentQueriesUsed]	INT				NOT NULL
	,[Total_Duration]		BIGINT			NOT NULL
	,[Total_CPUTime]		BIGINT			NOT NULL
	,[Total_CLRTime]		BIGINT			NOT NULL
	,[Total_Wait]			BIGINT			NOT NULL
	,[Wait_CPU]				BIGINT			NOT NULL
	,[Wait_WorkerThread]	BIGINT			NOT NULL
	,[Wait_Lock]			BIGINT			NOT NULL
	,[Wait_Latch]			BIGINT			NOT NULL
	,[Wait_BufferLatch]		BIGINT			NOT NULL
	,[Wait_BufferIO]		BIGINT			NOT NULL
	,[Wait_Compilation]		BIGINT			NOT NULL
	,[Wait_SQLCLR]			BIGINT			NOT NULL
	,[Wait_Mirroring]		BIGINT			NOT NULL
	,[Wait_Transaction]		BIGINT			NOT NULL
	,[Wait_Idle]			BIGINT			NOT NULL
	,[Wait_Preemptive]		BIGINT			NOT NULL
	,[Wait_ServiceBroker]	BIGINT			NOT NULL
	,[Wait_TranLogIO]		BIGINT			NOT NULL
	,[Wait_NetworkIO]		BIGINT			NOT NULL
	,[Wait_Parallelism]		BIGINT			NOT NULL
	,[Wait_Memory]			BIGINT			NOT NULL
	,[Wait_UserWait]		BIGINT			NOT NULL
	,[Wait_Tracing]			BIGINT			NOT NULL
	,[Wait_FullTextSearch]	BIGINT			NOT NULL
	,[Wait_OtherDiskIO]		BIGINT			NOT NULL
	,[Wait_Replication]		BIGINT			NOT NULL
	,[Wait_LogRateGovernor]	BIGINT			NOT NULL
)
-- Temporary table to hold the Wait details - END

-- Load the Wait details into #WaitDetails - START
DECLARE @SqlCmd NVARCHAR(MAX) =
'INSERT INTO #WaitDetails
SELECT
	 [ObjectID]		=	[qsq].[object_id]
	,[SchemaName]	=	ISNULL([s].[name],'''')
	,[ObjectName]	=	ISNULL([o].[name],'''')
	,[PlanID] = 
	{@LookingForObjectName}{@LookingForQueryID}	[qsrs].[plan_id]
	{@LookingForPlanID} 0
	,[QueryID] =
	{@LookingForObjectName} [qsp].[query_id]
	{@LookingForQueryID}{@LookingForPlanID} 0
	,[QueryTextID] =
	{@LookingForObjectName} [qsq].[query_text_id]
	{@LookingForQueryID}{@LookingForPlanID} 0
	,[qsrsi].[start_time]	AS [StartTime]
	,[qsrsi].[end_time]		AS [EndTime]
	,[DifferentPlansUsed]		= COUNT(DISTINCT [qsp].[plan_id])
	,[DifferentQueriesUsed]		= COUNT(DISTINCT [qsp].[query_id])
	,[Total_Duration]			=	SUM([qsrs].[count_executions]*[qsrs].[avg_duration])
	,[Total_CpuTime]			=	SUM([qsrs].[count_executions]*[qsrs].[avg_cpu_time])
	,[Total_ClrTime]			=	SUM([qsrs].[count_executions]*[qsrs].[avg_clr_time])
	,[Total_Wait]				=	1000*
		(
		 SUM(ISNULL([Total_CPU],0))
		+SUM(ISNULL([Total_WorkerThread],0))
		+SUM(ISNULL([Total_Lock],0))
		+SUM(ISNULL([Total_Latch],0))
		+SUM(ISNULL([Total_BufferLatch],0))
		+SUM(ISNULL([Total_BufferIO],0))
		+SUM(ISNULL([Total_Compilation],0))
		+SUM(ISNULL([Total_SQLCLR],0))
		+SUM(ISNULL([Total_Mirroring],0))
		+SUM(ISNULL([Total_Transaction],0))
		+SUM(ISNULL([Total_Idle],0))
		+SUM(ISNULL([Total_Preemptive],0))
		+SUM(ISNULL([Total_ServiceBroker],0))
		+SUM(ISNULL([Total_TranLogIO],0))
		+SUM(ISNULL([Total_NetworkIO],0))
		+SUM(ISNULL([Total_Parallelism],0))
		+SUM(ISNULL([Total_Memory],0))
		+SUM(ISNULL([Total_UserWait],0))
		+SUM(ISNULL([Total_Tracing],0))
		+SUM(ISNULL([Total_FullTextSearch],0))
		+SUM(ISNULL([Total_OtherDiskIO],0))
		+SUM(ISNULL([Total_Replication],0))
		+SUM(ISNULL([Total_LogRateGovernor],0))
		)
	,[Wait_CPU]					=	SUM(ISNULL(1000*[Total_CPU],0))
	,[Wait_WorkerThread]		=	SUM(ISNULL(1000*[Total_WorkerThread],0))
	,[Wait_Lock]				=	SUM(ISNULL(1000*[Total_Lock],0))
	,[Wait_Latch]				=	SUM(ISNULL(1000*[Total_Latch],0))
	,[Wait_BufferLatch]			=	SUM(ISNULL(1000*[Total_BufferLatch],0))
	,[Wait_BufferIO]			=	SUM(ISNULL(1000*[Total_BufferIO],0))
	,[Wait_Compilation]			=	SUM(ISNULL(1000*[Total_Compilation],0))
	,[Wait_SQLCLR]				=	SUM(ISNULL(1000*[Total_SQLCLR],0))
	,[Wait_Mirroring]			=	SUM(ISNULL(1000*[Total_Mirroring],0))
	,[Wait_Transaction]			=	SUM(ISNULL(1000*[Total_Transaction],0))
	,[Wait_Idle]				=	SUM(ISNULL(1000*[Total_Idle],0))
	,[Wait_Preemptive]			=	SUM(ISNULL(1000*[Total_Preemptive],0))
	,[Wait_ServiceBroker]		=	SUM(ISNULL(1000*[Total_ServiceBroker],0))
	,[Wait_TranLogIO]			=	SUM(ISNULL(1000*[Total_TranLogIO],0))
	,[Wait_NetworkIO]			=	SUM(ISNULL(1000*[Total_NetworkIO],0))
	,[Wait_Parallelism]			=	SUM(ISNULL(1000*[Total_Parallelism],0))
	,[Wait_Memory]				=	SUM(ISNULL(1000*[Total_Memory],0))
	,[Wait_UserWait]			=	SUM(ISNULL(1000*[Total_UserWait],0))
	,[Wait_Tracing]				=	SUM(ISNULL(1000*[Total_Tracing],0))
	,[Wait_FullTextSearch]		=	SUM(ISNULL(1000*[Total_FullTextSearch],0))
	,[Wait_OtherDiskIO]			=	SUM(ISNULL(1000*[Total_OtherDiskIO],0))
	,[Wait_Replication]			=	SUM(ISNULL(1000*[Total_Replication],0))
	,[Wait_LogRateGovernor]		=	SUM(ISNULL(1000*[Total_LogRateGovernor],0))
FROM [{@DatabaseName}].[sys].[query_store_runtime_stats] [qsrs]
LEFT JOIN (
SELECT 
	 [runtime_stats_interval_id]
	,[plan_id]
	,[Unknown]				AS [Total_Unknown]
	,[CPU]					AS [Total_CPU]
	,[Worker Thread]		AS [Total_WorkerThread]
	,[Lock]					AS [Total_Lock]
	,[Latch]				AS [Total_Latch]
	,[Buffer Latch]			AS [Total_BufferLatch]
	,[Buffer IO]			AS [Total_BufferIO]
	,[Compilation]			AS [Total_Compilation]
	,[SQL CLR]				AS [Total_SQLCLR]
	,[Mirroring]			AS [Total_Mirroring]
	,[Transaction]			AS [Total_Transaction]
	,[Idle]					AS [Total_Idle]
	,[Preemptive]			AS [Total_Preemptive]
	,[Service Broker]		AS [Total_ServiceBroker]
	,[Tran Log IO]			AS [Total_TranLogIO]
	,[Network IO]			AS [Total_NetworkIO]
	,[Parallelism]			AS [Total_Parallelism]
	,[Memory]				AS [Total_Memory]
	,[User Wait]			AS [Total_UserWait]
	,[Tracing]				AS [Total_Tracing]
	,[Full Text Search]		AS [Total_FullTextSearch]
	,[Other Disk IO]		AS [Total_OtherDiskIO]
	,[Replication]			AS [Total_Replication]
	,[Log Rate Governor]	AS [Total_LogRateGovernor]
FROM
(
	SELECT
		 [qsws].[runtime_stats_interval_id]
		,[qsws].[plan_id]
		,[qsws].[wait_category_desc]
		,[qsws].[total_query_wait_time_ms]
	FROM [{@DatabaseName}].[sys].[query_store_wait_stats] [qsws]
	INNER JOIN [{@DatabaseName}].[sys].[query_store_runtime_stats] [qsrs]
	ON [qsws].[runtime_stats_interval_id] = [qsrs].[runtime_stats_interval_id]
	AND [qsws].[plan_id] = [qsrs].[plan_id]
) as [SourceTable]
PIVOT (
	SUM([total_query_wait_time_ms])
	FOR [wait_category_desc] IN 
	(
		 [Unknown]
		,[CPU]
		,[Worker Thread]
		,[Lock]
		,[Latch]
		,[Buffer Latch]
		,[Buffer IO]
		,[Compilation]
		,[SQL CLR]
		,[Mirroring]
		,[Transaction]
		,[Idle]
		,[Preemptive]
		,[Service Broker]
		,[Tran Log IO]
		,[Network IO]
		,[Parallelism]
		,[Memory]
		,[User Wait]
		,[Tracing]
		,[Full Text Search]
		,[Other Disk IO]
		,[Replication]
		,[Log Rate Governor]
	)
	)
	AS [PivotTable]
) as [qsws]
ON [qsrs].[runtime_stats_interval_id] = [qsws].[runtime_stats_interval_id]
AND [qsrs].[plan_id] = [qsws].[plan_id]
INNER JOIN [{@DatabaseName}].[sys].[query_store_runtime_stats_interval] [qsrsi]
ON [qsrs].[runtime_stats_interval_id] = [qsrsi].[runtime_stats_interval_id]
INNER JOIN [{@DatabaseName}].[sys].[query_store_plan] [qsp]
ON [qsrs].[plan_id] = [qsp].[plan_id]
INNER JOIN [{@DatabaseName}].[sys].[query_store_query] [qsq]
ON [qsp].[query_id] = [qsq].[query_id]
INNER JOIN [{@DatabaseName}].[sys].[objects] [o]
ON [qsq].[object_id] = [o].[object_id]
INNER JOIN [{@DatabaseName}].[sys].[schemas] [s]
ON [o].[schema_id] = [s].[schema_id]
INNER JOIN [{@DatabaseName}].[sys].[query_store_query_text] [qsqt]
ON [qsq].[query_text_id] = [qsqt].[query_text_id]
WHERE 
	(
		([qsrs].[first_execution_time] >= ''{@StartTime}'' AND [qsrs].[last_execution_time] < ''{@EndTime}'')
	OR	([qsrs].[first_execution_time] <= ''{@StartTime}'' AND [qsrs].[last_execution_time] > ''{@StartTime}'')
	OR	([qsrs].[first_execution_time] <= ''{@EndTime}''   AND [qsrs].[last_execution_time] > ''{@EndTime}'')
	)
	{@LookingForObjectName}{@LookingForQueryID}	AND [qsrs].[plan_id] = {@PlanID}
	{@LookingForObjectName}{@LookingForPlanID}	AND [qsp].[query_id] = {@QueryID}
	{@LookingForPlanID}{@LookingForQueryID}	AND [s].[name]+''.''+[o].[name] = ''{@ObjectName}''
GROUP BY
	 [qsrsi].[start_time]
	,[qsrsi].[end_time]
	{@LookingForObjectName}{@LookingForQueryID}	,[qsrs].[plan_id]
	{@LookingForObjectName}						,[qsp].[query_id]
	,[s].[name]
	,[o].[name]
	,[qsq].[object_id]
	{@LookingForObjectName}						,[qsq].[query_text_id]'

SET @SqlCmd = REPLACE(@SqlCmd,	'{@DatabaseName}',	@DatabaseName)
SET @SqlCmd = REPLACE(@SqlCmd,	'{@StartTime}',		CAST(@StartTime AS NVARCHAR(34)))
SET @SqlCmd = REPLACE(@SqlCmd,	'{@EndTime}',		CAST(@EndTime AS NVARCHAR(34)))

-- @ObjectName provided - START
IF(@ObjectName IS NOT NULL)
BEGIN
	SET @SqlCmd = REPLACE(@SqlCmd,	'{@ObjectName}',			@ObjectName)
	SET @SqlCmd = REPLACE(@SqlCmd,	'{@LookingForObjectName}',	'--')
	SET @SqlCmd = REPLACE(@SqlCmd,	'{@LookingForPlanID}',		'')
	SET @SqlCmd = REPLACE(@SqlCmd,	'{@LookingForQueryID}',		'')
END
-- @ObjectName provided - END

-- @PlanID provided - START
IF(@PlanID IS NOT NULL)
BEGIN
	SET @SqlCmd = REPLACE(@SqlCmd,	'{@PlanID}',				CAST(@PlanID AS NVARCHAR(20)))
	SET @SqlCmd = REPLACE(@SqlCmd,	'{@LookingForObjectName}',	'')
	SET @SqlCmd = REPLACE(@SqlCmd,	'{@LookingForPlanID}',		'--')
	SET @SqlCmd = REPLACE(@SqlCmd,	'{@LookingForQueryID}',		'')
END
-- @PlanID provided - END

-- @QueryID provided - START
IF(@QueryID IS NOT NULL)
BEGIN
	SET @SqlCmd = REPLACE(@SqlCmd,	'{@QueryID}',				CAST(@QueryID AS NVARCHAR(20)))
	SET @SqlCmd = REPLACE(@SqlCmd,	'{@LookingForObjectName}',	'')
	SET @SqlCmd = REPLACE(@SqlCmd,	'{@LookingForPlanID}',		'')
	SET @SqlCmd = REPLACE(@SqlCmd,	'{@LookingForQueryID}',		'--')
END
-- @QueryID provided - END


IF (@VerboseMode = 1)	PRINT (@SqlCmd)
IF (@TestMode = 0)		EXEC (@SqlCmd)
-- Load the Wait details into #WaitDetails - START

-- Output to user - START
IF (@ReportTable IS NULL) OR (@ReportTable = '') OR (@ReportIndex IS NULL) OR (@ReportIndex = '')
BEGIN
	DECLARE @SqlCmd2User NVARCHAR(MAX) = 'SELECT * FROM #WaitDetails ORDER BY [StartTime], [PlanID], [QueryID] ASC'
	IF (@VerboseMode = 1)	PRINT (@SqlCmd2User)
	IF (@TestMode = 0)		EXEC (@SqlCmd2User)
END
-- Output to user - END


-- Output to table - START
IF (@ReportTable IS NOT NULL) AND (@ReportTable <> '') AND (@ReportIndex IS NOT NULL) AND (@ReportIndex <> '')
BEGIN
	-- Log report entry - START
	DECLARE @SqlCmdIndex NVARCHAR(MAX) =
	'INSERT INTO {@ReportIndex}
	(
		[CaptureDate],
		[InstanceIdentifier],
		[DatabaseName],
		[ObjectID],
		[SchemaName],
		[ObjectName],
		[QueryTextID],
		[QueryText],
		[Parameters]
	)
	SELECT TOP(1)
		SYSUTCDATETIME(),
		''{@InstanceIdentifier}'',
		''{@DatabaseName}'',
		COALESCE([wd].[ObjectID],0),
		COALESCE([wd].[SchemaName],''''),
		COALESCE([wd].[ObjectName],''''),
		{@QueryTextID},
		{@QueryText},
		(
		SELECT
			''{@ObjectName}''		AS [ObjectName],
			{@PlanID}				AS [PlanID],
			{@QueryID}				AS [QueryID],
			''{@StartTime}''		AS [StartTime],
			''{@EndTime}''			AS [EndTime],
			{@IncludeQueryText}		AS [IncludeQueryText]
		FOR XML PATH(''WaitDetailsParameters''), ROOT(''Root'')
		)	AS [Parameters]
		FROM [{@DatabaseName}].[sys].[query_store_query_text] [qsqt]
		LEFT JOIN #WaitDetails [wd]
		ON [wd].[ObjectID] = [wd].[ObjectID]
		{@QueryTextIDClause}'

	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@ReportIndex}',			@ReportIndex)
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@InstanceIdentifier}',	@InstanceIdentifier)
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@DatabaseName}',			@DatabaseName)
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@ObjectName}',			ISNULL(@ObjectName, ''))
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@PlanID}',				ISNULL(@PlanID, 0))
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@QueryID}',				ISNULL(@QueryID, 0))
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@StartTime}',			CAST(@StartTime AS NVARCHAR(34)))
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@EndTime}',				CAST(@EndTime AS NVARCHAR(34)))
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@IncludeQueryText}',		CAST(@IncludeQueryText AS NVARCHAR(1)))

	DECLARE @QueryTextID	BIGINT
	CREATE TABLE #QueryTextID
	(
		QueryTextID	BIGINT
	)
	DECLARE @SqlCmdQueryTextID NVARCHAR(MAX) =
	'INSERT INTO #QueryTextID ([QueryTextID])
	SELECT
		[query_text_id]
	FROM [{@DatabaseName}].[sys].[query_store_plan] [qsp]
	INNER JOIN [{@DatabaseName}].[sys].[query_store_query] [qsq]
	ON [qsp].[query_id] = [qsq].[query_id]
	WHERE {@SearchClause}'
	SET @SqlCmdQueryTextID = REPLACE(@SqlCmdQueryTextID, '{@DatabaseName}',	@DatabaseName)
	
	-- @PlanID provided - START
	IF (@PlanID IS NOT NULL)
	BEGIN
		SET @SqlCmdQueryTextID = REPLACE(@SqlCmdQueryTextID, '{@SearchClause}',	'[qsp].[plan_id] = ' + CAST(@PlanID AS NVARCHAR(20)) )
		IF (@VerboseMode = 1)	PRINT	(@SqlCmdQueryTextID)
		IF (@TestMode = 0)		EXEC	(@SqlCmdQueryTextID)
	END
	-- @PlanID provided - END
	
	-- @QueryID provided - START
	IF (@QueryID IS NOT NULL)
	BEGIN
		SET @SqlCmdQueryTextID = REPLACE(@SqlCmdQueryTextID, '{@SearchClause}',	'[qsq].[query_id] = ' + CAST(@QueryID AS NVARCHAR(20)) )
		IF (@VerboseMode = 1)	PRINT	(@SqlCmdQueryTextID)
		IF (@TestMode = 0)		EXEC	(@SqlCmdQueryTextID)
	END
	-- @QueryID provided - END



	-- Check whether different queries are involved in this analysis (when using @ObjectName) - START
	DECLARE @DifferentQueries INT
	SELECT @DifferentQueries = COUNT(1) FROM #QueryTextID
		-- If there is more than 1 query, don't log the QueryText details - START
	IF (@DifferentQueries <> 1)
	BEGIN
		SET @SqlCmdIndex = REPLACE(@SqlCmdIndex,	'{@QueryTextID}',				0)
		SET @SqlCmdIndex = REPLACE(@SqlCmdIndex,	'{@QueryText}',					'NULL')
		SET @SqlCmdIndex = REPLACE(@SqlCmdIndex,	'{@QueryTextIDClause}',			'')
	END
		-- If there is more than 1 query, don't log the QueryText details - END
	
		-- If there is only 1 query, include the QueryText details in the report summary - START
	IF (@DifferentQueries = 1)
	BEGIN
		SELECT @QueryTextID = [QueryTextID] FROM #QueryTextID
		SET @SqlCmdIndex = REPLACE(@SqlCmdIndex,	'{@QueryTextID}',							CAST(@QueryTextID AS NVARCHAR(20)) )
		IF (@IncludeQueryText = 0) SET @SqlCmdIndex = REPLACE(@SqlCmdIndex,	'{@QueryText}',		'NULL')
		IF (@IncludeQueryText = 1) SET @SqlCmdIndex = REPLACE(@SqlCmdIndex,	'{@QueryText}',		'COMPRESS(query_sql_text)')
		SET @SqlCmdIndex = REPLACE(@SqlCmdIndex,	'{@QueryTextIDClause}',						'WHERE [qsqt].[query_text_id] = ' + CAST(@QueryTextID AS NVARCHAR(20)) )
	END
		-- If there is only 1 query, include the QueryText details in the report summary - END

	-- Check whether different queries are involved in this analysis (when using @ObjectName) - END
	
	IF (@VerboseMode = 1)	PRINT (@SqlCmdIndex)
	IF (@TestMode = 0)		EXEC  (@SqlCmdIndex)
	

	SET @ReportID = IDENT_CURRENT(@ReportIndex)
	-- Log report entry - END

	DECLARE @SqlCmd2Table NVARCHAR(MAX) = 'INSERT INTO {@ReportTable}
	SELECT
	{@ReportID}
	,[PlanID]			
	,[QueryID]
	,[QueryTextID]			
	,[StartTime]			
	,[EndTime]				
	,[DifferentPlansUsed]	
	,[DifferentQueriesUsed]	
	,[Total_Duration]		
	,[Total_CPUTime]		
	,[Total_CLRTime]		
	,[Total_Wait]			
	,[Wait_CPU]				
	,[Wait_WorkerThread]	
	,[Wait_Lock]			
	,[Wait_Latch]			
	,[Wait_BufferLatch]		
	,[Wait_BufferIO]		
	,[Wait_Compilation]		
	,[Wait_SQLCLR]			
	,[Wait_Mirroring]		
	,[Wait_Transaction]		
	,[Wait_Idle]			
	,[Wait_Preemptive]		
	,[Wait_ServiceBroker]	
	,[Wait_TranLogIO]		
	,[Wait_NetworkIO]		
	,[Wait_Parallelism]		
	,[Wait_Memory]			
	,[Wait_UserWait]		
	,[Wait_Tracing]			
	,[Wait_FullTextSearch]	
	,[Wait_OtherDiskIO]		
	,[Wait_Replication]		
	,[Wait_LogRateGovernor]	
	FROM #WaitDetails
	ORDER BY
		 [StartTime]	ASC
		,[PlanID]		ASC
		,[QueryID]		ASC
		,[ObjectName]	ASC'

	SET @SqlCmd2Table = REPLACE(@SqlCmd2Table, '{@ReportTable}',		@ReportTable) 
	SET @SqlCmd2Table = REPLACE(@SqlCmd2Table, '{@ReportID}',			@ReportID) 

	IF (@VerboseMode = 1)	PRINT (@SqlCmd2Table)
	IF (@TestMode = 0)		EXEC  (@SqlCmd2Table)
END
-- Output to table - END

DROP TABLE IF EXISTS #WaitDetails



END