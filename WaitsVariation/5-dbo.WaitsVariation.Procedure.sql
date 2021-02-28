----------------------------------------------------------------------------------
-- Procedure Name: [dbo].[WaitsVariation]
--
-- Desc: This script queries the QDS data and generates a report based on those queries whose wait statistics has changed when comparing two periods of time
--
--
-- Parameters:
--	INPUT
--		@ServerIdentifier			SYSNAME			--	Identifier assigned to the server.
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
--		@WaitType					NVARCHAR(16)	--	Wait Type to analyze, to select from
--															Total
--															Unknown
--															CPU
--															WorkerThread
--															Lock
--															Latch
--															BufferLatch
--															BufferIO
--															Compilation
--															SQLCLR
--															Mirroring
--															Transaction
--															Idle
--															Preemptive
--															ServiceBroker
--															TranLogIO
--															NetworkIO
--															Parallelism
--															Memory
--															UserWait
--															Tracing
--															FullTextSearch
--															OtherDiskIO
--															Replication
--															LogRateGovernor
--															CLR
--															CPU
--															DOP
--															Duration
--															Log
--															LogicalIOReads
--															LogicalIOWrites
--															MaxMemory
--															PhysicalIOReads
--															Rowcount
--															TempDB
--														[Default: Total]
--													https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-query-store-wait-stats-transact-sql?view=sql-server-ver15#wait-categories-mapping-table
--
--		@Metric						NVARCHAR(8)		--	Metric on which to analyze the @WaitType values on, to select from
--															Avg
--															Total
--														[Default: Avg]
--
--		@VariationType				NVARCHAR(1)		--	Defines whether queries whose wait metrics indicates an improvement (I) or a regression (R).
--														[Default: R]
--
--		@ResultsRowCount			INT				--	Number of rows to return.
--														[Default: 25]
--
--		@RecentStartTime			DATETIME2		--	Start of the time period considered as "recent" to be compared with the "history" time period. Must be expressed in UTC.
--														[Default: DATEADD(HOUR, -1, SYSUTCDATETIME()]
--
--		@RecentEndTime				DATETIME2		--	End of the time period considered as "recent" to be compared with the "history" time period. Must be expressed in UTC.
--														[Default: SYSUTCDATETIME()]
--
--		@HistoryStartTime			DATETIME2		--	Start of the time period considered as "history" to be compared with the "recent" time period. Must be expressed in UTC.
--														[Default: DATEADD(DAY, -30, SYSUTCDATETIME())]
--
--		@HistoryEndTime				DATETIME2		--	End of the time period considered as "history" to be compared with the "recent" time period. Must be expressed in UTC.
--														[Default: DATEADD(HOUR, -1, SYSUTCDATETIME()]
--
--		@IncludeQueryText			BIT				--	Flag to define whether the text of the query will be returned.
--														[Default: 0]
--
--		@ExcludeAdhoc				BIT				--	Flag to define whether to ignore adhoc queries (not part of a DB object) from the analysis
--														[Default: 0]
--
--		@ExcludeInternal			BIT				--	Flag to define whether to ignore internal queries (backup, index rebuild, statistics update...) from the analysis
--														[Default: 0]
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
--	Sample 1: Return a list of the 25 queries whose average CPU waits have increased the most comparing 2020-08-01->2020-08-02 with 2020-08-02->2020-08-03
--			EXECUTE [dbo].[WaitsVariation]
--				@DatabaseName = 'Database00001',
--				@HistoryStartTime = '2020-08-01',
--				@HistoryEndTime = '2020-08-02',
--				@RecentStartTime = '2020-08-02',
--				@RecentEndTime = '2020-08-03',
--				@WaitType = 'CPU',
--				@Metric = 'Avg'
--
--
--	Sample 2: Save a list of the top 5 queries whose average BufferLatch waits were reduced the most when comparing the intervals
--		2020-08-01->2020-08-02 and 2020-08-02->2020-08-03 into the table [dbo].[QueryVariationStore], including the queries' text
--			EXECUTE [dbo].[WaitsVariation]
--				@ReportIndex = 'dbo.WaitsVariationIndex',
--				@ReportTable = 'dbo.WaitsVariationStore',
--				@DatabaseName = 'Database00001',
--				@ResultsRowCount = 5,
--				@VariationType = 'I',
--				@HistoryStartTime = '2020-08-01',
--				@HistoryEndTime = '2020-08-02',
--				@RecentStartTime = '2020-08-02',
--				@RecentEndTime = '2020-08-03',
--				@WaitType = 'BufferLatch',
--				@Metric = 'Avg',
--				@IncludeQueryText = 1
--
--			
--
--
-- Date: 2020.10.20
-- Auth: Pablo Lozano (@sqlozano)
--
-- Date: 2021.02.28
-- Auth: Pablo Lozano (@sqlozano)
-- Changes:	Execution in SQL 2016 will thrown an error (this component was enabled first in SQL 2017)
----------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[WaitsVariation]
(
	@ServerIdentifier		SYSNAME			=	NULL,	
	@DatabaseName			SYSNAME			=	NULL,
	@ReportIndex			NVARCHAR(800)	=	NULL,
	@ReportTable			NVARCHAR(800)	=	NULL,
	@WaitType				NVARCHAR(16)	=	'Total',
	@Metric					NVARCHAR(16)	=	'Avg',
	@VariationType			NVARCHAR(1)		=	'R',
	@ResultsRowCount		INT				=	25,
	@RecentStartTime		DATETIME2		=	NULL,
	@RecentEndTime			DATETIME2		=	NULL,
	@HistoryStartTime		DATETIME2		=	NULL,
	@HistoryEndTime			DATETIME2		=	NULL,
	@IncludeQueryText		BIT				=	0,
	@ExcludeAdhoc			BIT				=	0,
	@ExcludeInternal		BIT				=	1,
	@VerboseMode			BIT				=	0,
	@TestMode				BIT				=	0,
	@ReportID				BIGINT			=	NULL	OUTPUT
)
AS
SET NOCOUNT ON

-- Get the Version # to ensure it runs SQL2017 or higher
DECLARE @Version INT =  CAST(SUBSTRING(CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')),0,CHARINDEX('.',CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')),0)) AS INT)
IF (@Version <= 13)
BEGIN
	RAISERROR(N'[dbo].[WaitsVariation] requires SQL 2017 or higher',16,1)
	RETURN -1
END

-- Check variables and set defaults - START
IF (@ServerIdentifier IS NULL)
	SET @ServerIdentifier = @@SERVERNAME

IF (@DatabaseName IS NULL) OR (@DatabaseName = '')
	SET @DatabaseName = DB_NAME()

IF (@VariationType NOT IN ('R','I'))
	SET @VariationType = 'R'

IF (@ResultsRowCount IS NULL) OR (@ResultsRowCount < 1)
	SET @ResultsRowCount = 25

IF (@RecentStartTime IS NULL) OR (@RecentEndTime IS NULL) OR (@HistoryStartTime IS NULL) OR (@HistoryEndTime IS NULL)
BEGIN
	SET @RecentEndTime	= SYSUTCDATETIME()
	SET @RecentStartTime	= DATEADD(HOUR, -1, @RecentEndTime)
	SET @HistoryEndTime	= @RecentStartTime
	SET @HistoryStartTime	= DATEADD(DAY, -30, @RecentEndTime)
END

IF	(@WaitType IS NULL)
	SET @WaitType = 'Total'
IF	(@WaitType NOT IN 
		(
			 'Total'
			,'Unknown'
			,'CPU'
			,'WorkerThread'
			,'Lock'
			,'Latch'
			,'BufferLatch'
			,'BufferIO'
			,'Compilation'
			,'SQLCLR'
			,'Mirroring'
			,'Transaction'
			,'Idle'
			,'Preemptive'
			,'ServiceBroker'
			,'TranLogIO'
			,'NetworkIO'
			,'Parallelism'
			,'Memory'
			,'UserWait'
			,'Tracing'
			,'FullTextSearch'
			,'OtherDiskIO'
			,'Replication'
			,'LogRateGovernor'
		)
	)
BEGIN
	RAISERROR('The WaitType [%s] is not valid. Valid values are:
	[Total]
	[Unknown]
	[CPU]
	[WorkerThread]
	[Lock]
	[Latch]
	[BufferLatch]
	[BufferIO]
	[Compilation]
	[SQLCLR]
	[Mirroring]
	[Transaction]
	[Idle]
	[Preemptive]
	[ServiceBroker]
	[TranLogIO]
	[NetworkIO]
	[Parallelism]
	[Memory]
	[UserWait]
	[Tracing]
	[FullTextSearch]
	[OtherDiskIO]
	[Replication]
	[LogRateGovernor]', 16, 0, @WaitType)
	RETURN
END

IF	(@Metric IS NULL)
	SET @Metric = 'Avg'
IF	(@Metric NOT IN 
		(
			 'Total'
			,'Avg'
		)
	)
BEGIN
	RAISERROR('The Metric [%s] is not valid. Valid values are:
	[Total]
	[Avg]', 16, 0, @Metric)
	RETURN
END

IF (@IncludeQueryText IS NULL)
	SET @IncludeQueryText = 1
-- Check variables and set defaults - END



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




DROP TABLE IF EXISTS #WaitsTable
CREATE TABLE #WaitsTable
(
	 [QueryID]						DECIMAL(20,2) NOT NULL
	,[ObjectID]						DECIMAL(20,2) NOT NULL
	,[SchemaName]					NVARCHAR(128) NOT NULL
	,[ObjectName]					NVARCHAR(128) NOT NULL
	,[ExecutionCount_Recent]		DECIMAL(20,2) NULL
	,[ExecutionCount_History]		DECIMAL(20,2) NULL
	,[ExecutionCount_Variation%]	DECIMAL(20,2) NULL
	,[Total_Recent]					DECIMAL(20,2) NULL
	,[Total_History]				DECIMAL(20,2) NULL
	,[Total_Variation%]				DECIMAL(20,2) NULL
	,[Unknown_Recent]				DECIMAL(20,2) NULL
	,[Unknown_History]				DECIMAL(20,2) NULL
	,[Unknown_Variation%]			DECIMAL(20,2) NULL
	,[CPU_Recent]					DECIMAL(20,2) NULL
	,[CPU_History]					DECIMAL(20,2) NULL
	,[CPU_Variation%]				DECIMAL(20,2) NULL
	,[WorkerThread_Recent]			DECIMAL(20,2) NULL
	,[WorkerThread_History]			DECIMAL(20,2) NULL
	,[WorkerThread_Variation%]		DECIMAL(20,2) NULL
	,[Lock_Recent]					DECIMAL(20,2) NULL
	,[Lock_History]					DECIMAL(20,2) NULL
	,[Lock_Variation%]				DECIMAL(20,2) NULL
	,[Latch_Recent]					DECIMAL(20,2) NULL
	,[Latch_History]				DECIMAL(20,2) NULL
	,[Latch_Variation%]				DECIMAL(20,2) NULL
	,[BufferLatch_Recent]			DECIMAL(20,2) NULL
	,[BufferLatch_History]			DECIMAL(20,2) NULL
	,[BufferLatch_Variation%]		DECIMAL(20,2) NULL
	,[BufferIO_Recent]				DECIMAL(20,2) NULL
	,[BufferIO_History]				DECIMAL(20,2) NULL
	,[BufferIO_Variation%]			DECIMAL(20,2) NULL
	,[Compilation_Recent]			DECIMAL(20,2) NULL
	,[Compilation_History]			DECIMAL(20,2) NULL
	,[Compilation_Variation%]		DECIMAL(20,2) NULL
	,[SQLCLR_Recent]				DECIMAL(20,2) NULL
	,[SQLCLR_History]				DECIMAL(20,2) NULL
	,[SQLCLR_Variation%]			DECIMAL(20,2) NULL
	,[Mirroring_Recent]				DECIMAL(20,2) NULL
	,[Mirroring_History]			DECIMAL(20,2) NULL
	,[Mirroring_Variation%]			DECIMAL(20,2) NULL
	,[Transaction_Recent]			DECIMAL(20,2) NULL
	,[Transaction_History]			DECIMAL(20,2) NULL
	,[Transaction_Variation%]		DECIMAL(20,2) NULL
	,[Idle_Recent]					DECIMAL(20,2) NULL
	,[Idle_History]					DECIMAL(20,2) NULL
	,[Idle_Variation%]				DECIMAL(20,2) NULL
	,[Preemptive_Recent]			DECIMAL(20,2) NULL
	,[Preemptive_History]			DECIMAL(20,2) NULL
	,[Preemptive_Variation%]		DECIMAL(20,2) NULL
	,[ServiceBroker_Recent]			DECIMAL(20,2) NULL
	,[ServiceBroker_History]		DECIMAL(20,2) NULL
	,[ServiceBroker_Variation%]		DECIMAL(20,2) NULL
	,[TranLogIO_Recent]				DECIMAL(20,2) NULL
	,[TranLogIO_History]			DECIMAL(20,2) NULL
	,[TranLogIO_Variation%]			DECIMAL(20,2) NULL
	,[NetworkIO_Recent]				DECIMAL(20,2) NULL
	,[NetworkIO_History]			DECIMAL(20,2) NULL
	,[NetworkIO_Variation%]			DECIMAL(20,2) NULL
	,[Parallelism_Recent]			DECIMAL(20,2) NULL
	,[Parallelism_History]			DECIMAL(20,2) NULL
	,[Parallelism_Variation%]		DECIMAL(20,2) NULL
	,[Memory_Recent]				DECIMAL(20,2) NULL
	,[Memory_History]				DECIMAL(20,2) NULL
	,[Memory_Variation%]			DECIMAL(20,2) NULL
	,[UserWait_Recent]				DECIMAL(20,2) NULL
	,[UserWait_History]				DECIMAL(20,2) NULL
	,[UserWait_Variation%]			DECIMAL(20,2) NULL
	,[Tracing_Recent]				DECIMAL(20,2) NULL
	,[Tracing_History]				DECIMAL(20,2) NULL
	,[Tracing_Variation%]			DECIMAL(20,2) NULL
	,[FullTextSearch_Recent]		DECIMAL(20,2) NULL
	,[FullTextSearch_History]		DECIMAL(20,2) NULL
	,[FullTextSearch_Variation%]	DECIMAL(20,2) NULL
	,[OtherDiskIO_Recent]			DECIMAL(20,2) NULL
	,[OtherDiskIO_History]			DECIMAL(20,2) NULL
	,[OtherDiskIO_Variation%]		DECIMAL(20,2) NULL
	,[Replication_Recent]			DECIMAL(20,2) NULL
	,[Replication_History]			DECIMAL(20,2) NULL
	,[Replication_Variation%]		DECIMAL(20,2) NULL
	,[LogRateGovernor_Recent]		DECIMAL(20,2) NULL
	,[LogRateGovernor_History]		DECIMAL(20,2) NULL
	,[LogRateGovernor_Variation%]	DECIMAL(20,2) NULL
	,[QueryText]					VARBINARY(MAX) NULL
)

DECLARE @SqlCmdLoadTemp NVARCHAR(MAX) =
';WITH [hist]
AS
(
SELECT
	 [QueryID]
	,[ObjectID]
	,[ExecutionCount]	=	SUM(ISNULL([ExecutionCount],0))
	,[Total]			=	CAST(SUM(ISNULL([Unknown],0)) + SUM(ISNULL([CPU],0)) + SUM(ISNULL([Worker Thread],0)) + SUM(ISNULL([Lock],0)) + SUM(ISNULL([Latch],0)) + SUM(ISNULL([Buffer Latch],0)) + SUM(ISNULL([Buffer IO],0)) + SUM(ISNULL([Compilation],0)) + SUM(ISNULL([SQL CLR],0)) + SUM(ISNULL([Mirroring],0)) + SUM(ISNULL([Transaction],0)) 	+ SUM(ISNULL([Idle],0)) + SUM(ISNULL([Preemptive],0)) + SUM(ISNULL([Service Broker],0)) + SUM(ISNULL([Tran Log IO],0)) + SUM(ISNULL([Network IO],0)) + SUM(ISNULL([Parallelism],0)) + SUM(ISNULL([Memory],0)) + SUM(ISNULL([User Wait],0)) + SUM(ISNULL([Tracing],0)) + SUM(ISNULL([Full Text Search],0)) + SUM(ISNULL([Other Disk IO],0)) + SUM(ISNULL([Replication],0)) + SUM(ISNULL([Log Rate Governor],0)) AS DECIMAL(20,2)) {@Metric}
	,[Unknown]			=	CAST(SUM(ISNULL([Unknown]			, 0))	AS DECIMAL(20,2))	{@Metric}
	,[CPU]				=	CAST(SUM(ISNULL([CPU]				, 0))	AS DECIMAL(20,2))	{@Metric}
	,[WorkerThread]		=	CAST(SUM(ISNULL([Worker Thread]		, 0))	AS DECIMAL(20,2))	{@Metric}
	,[Lock]				=	CAST(SUM(ISNULL([Lock]				, 0))	AS DECIMAL(20,2))	{@Metric}
	,[Latch]			=	CAST(SUM(ISNULL([Latch]				, 0))	AS DECIMAL(20,2))	{@Metric}
	,[BufferLatch]		=	CAST(SUM(ISNULL([Buffer Latch]		, 0))	AS DECIMAL(20,2))	{@Metric}
	,[BufferIO]			=	CAST(SUM(ISNULL([Buffer IO]			, 0))	AS DECIMAL(20,2))	{@Metric}
	,[Compilation]		=	CAST(SUM(ISNULL([Compilation]		, 0))	AS DECIMAL(20,2))	{@Metric}
	,[SQLCLR]			=	CAST(SUM(ISNULL([SQL CLR]			, 0))	AS DECIMAL(20,2))	{@Metric}
	,[Mirroring]		=	CAST(SUM(ISNULL([Mirroring]			, 0))	AS DECIMAL(20,2))	{@Metric}
	,[Transaction]		=	CAST(SUM(ISNULL([Transaction]		, 0))	AS DECIMAL(20,2))	{@Metric}
	,[Idle]				=	CAST(SUM(ISNULL([Idle]				, 0))	AS DECIMAL(20,2))	{@Metric}
	,[Preemptive]		=	CAST(SUM(ISNULL([Preemptive]		, 0))	AS DECIMAL(20,2))	{@Metric}
	,[ServiceBroker]	=	CAST(SUM(ISNULL([Service Broker]	, 0))	AS DECIMAL(20,2))	{@Metric}
	,[TranLogIO]		=	CAST(SUM(ISNULL([Tran Log IO]		, 0))	AS DECIMAL(20,2))	{@Metric}
	,[NetworkIO]		=	CAST(SUM(ISNULL([Network IO]		, 0))	AS DECIMAL(20,2))	{@Metric}
	,[Parallelism]		=	CAST(SUM(ISNULL([Parallelism]		, 0))	AS DECIMAL(20,2))	{@Metric}
	,[Memory]			=	CAST(SUM(ISNULL([Memory]			, 0))	AS DECIMAL(20,2))	{@Metric}
	,[UserWait]			=	CAST(SUM(ISNULL([User Wait]			, 0))	AS DECIMAL(20,2))	{@Metric}
	,[Tracing]			=	CAST(SUM(ISNULL([Tracing]			, 0))	AS DECIMAL(20,2))	{@Metric}
	,[FullTextSearch]	=	CAST(SUM(ISNULL([Full Text Search]	, 0))	AS DECIMAL(20,2))	{@Metric}
	,[OtherDiskIO]		=	CAST(SUM(ISNULL([Other Disk IO]		, 0))	AS DECIMAL(20,2))	{@Metric}
	,[Replication]		=	CAST(SUM(ISNULL([Replication]		, 0))	AS DECIMAL(20,2))	{@Metric}
	,[LogRateGovernor]	=	CAST(SUM(ISNULL([Log Rate Governor]	, 0))	AS DECIMAL(20,2))	{@Metric}

FROM
(
	SELECT
		 [qsp].[query_id] AS [QueryID]
		,ISNULL([qsq].[object_id],0) AS [ObjectID]
		,SUM([qsrs].[count_executions]) as [ExecutionCount]
		,[qsws].[wait_category_desc]
		,SUM([qsws].[total_query_wait_time_ms]) as [total_query_wait_time_ms]
	FROM [{@DatabaseName}].[sys].[query_store_wait_stats] [qsws]
	INNER JOIN [{@DatabaseName}].[sys].[query_store_runtime_stats] [qsrs]
	ON [qsws].[runtime_stats_interval_id] = [qsrs].[runtime_stats_interval_id]
	AND [qsws].[plan_id] = [qsrs].[plan_id]
	INNER JOIN [{@DatabaseName}].[sys].[query_store_plan] [qsp]
	ON [qsws].[plan_id] = [qsp].[plan_id]
	INNER JOIN [{@DatabaseName}].[sys].[query_store_query] [qsq]
	ON [qsp].[query_id] = [qsq].[query_id]
	INNER JOIN [{@DatabaseName}].[sys].[query_store_runtime_stats_interval] [qsrsi]
	ON [qsws].[runtime_stats_interval_id] = [qsrsi].[runtime_stats_interval_id]
	WHERE 
	(
		([qsrs].[first_execution_time] >= ''{@HistoryStartTime}'' AND [qsrs].[last_execution_time] < ''{@HistoryEndTime}'')
    OR	([qsrs].[first_execution_time] <= ''{@HistoryStartTime}'' AND [qsrs].[last_execution_time] > ''{@HistoryStartTime}'')
    OR	([qsrs].[first_execution_time] <= ''{@HistoryEndTime}''   AND [qsrs].[last_execution_time] > ''{@HistoryEndTime}'')
	)
	{@ExcludeAdhoc}
	{@ExcludeInternal}
	GROUP BY
		 [qsp].[query_id]
		,[qsq].[object_id]
		,[qsws].[wait_category_desc]
) AS [SourceTable]
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
GROUP BY 
	 [QueryID]
	,[ObjectID]
) 
,[recent]
AS
(
SELECT
	 [QueryID]
	,[ObjectID]
	,[ExecutionCount]	=	SUM(ISNULL([ExecutionCount],0))
	,[Total]			=	CAST(SUM(ISNULL([Unknown],0)) + SUM(ISNULL([CPU],0)) + SUM(ISNULL([Worker Thread],0)) + SUM(ISNULL([Lock],0)) + SUM(ISNULL([Latch],0)) + SUM(ISNULL([Buffer Latch],0)) + SUM(ISNULL([Buffer IO],0)) + SUM(ISNULL([Compilation],0)) + SUM(ISNULL([SQL CLR],0)) + SUM(ISNULL([Mirroring],0)) + SUM(ISNULL([Transaction],0)) 	+ SUM(ISNULL([Idle],0)) + SUM(ISNULL([Preemptive],0)) + SUM(ISNULL([Service Broker],0)) + SUM(ISNULL([Tran Log IO],0)) + SUM(ISNULL([Network IO],0)) + SUM(ISNULL([Parallelism],0)) + SUM(ISNULL([Memory],0)) + SUM(ISNULL([User Wait],0)) + SUM(ISNULL([Tracing],0)) + SUM(ISNULL([Full Text Search],0)) + SUM(ISNULL([Other Disk IO],0)) + SUM(ISNULL([Replication],0)) + SUM(ISNULL([Log Rate Governor],0)) AS DECIMAL(20,2)) {@Metric}
	,[Unknown]			=	CAST(SUM(ISNULL([Unknown]			, 0))	AS DECIMAL(20,2))	{@Metric}
	,[CPU]				=	CAST(SUM(ISNULL([CPU]				, 0))	AS DECIMAL(20,2))	{@Metric}
	,[WorkerThread]		=	CAST(SUM(ISNULL([Worker Thread]		, 0))	AS DECIMAL(20,2))	{@Metric}
	,[Lock]				=	CAST(SUM(ISNULL([Lock]				, 0))	AS DECIMAL(20,2))	{@Metric}
	,[Latch]			=	CAST(SUM(ISNULL([Latch]				, 0))	AS DECIMAL(20,2))	{@Metric}
	,[BufferLatch]		=	CAST(SUM(ISNULL([Buffer Latch]		, 0))	AS DECIMAL(20,2))	{@Metric}
	,[BufferIO]			=	CAST(SUM(ISNULL([Buffer IO]			, 0))	AS DECIMAL(20,2))	{@Metric}
	,[Compilation]		=	CAST(SUM(ISNULL([Compilation]		, 0))	AS DECIMAL(20,2))	{@Metric}
	,[SQLCLR]			=	CAST(SUM(ISNULL([SQL CLR]			, 0))	AS DECIMAL(20,2))	{@Metric}
	,[Mirroring]		=	CAST(SUM(ISNULL([Mirroring]			, 0))	AS DECIMAL(20,2))	{@Metric}
	,[Transaction]		=	CAST(SUM(ISNULL([Transaction]		, 0))	AS DECIMAL(20,2))	{@Metric}
	,[Idle]				=	CAST(SUM(ISNULL([Idle]				, 0))	AS DECIMAL(20,2))	{@Metric}
	,[Preemptive]		=	CAST(SUM(ISNULL([Preemptive]		, 0))	AS DECIMAL(20,2))	{@Metric}
	,[ServiceBroker]	=	CAST(SUM(ISNULL([Service Broker]	, 0))	AS DECIMAL(20,2))	{@Metric}
	,[TranLogIO]		=	CAST(SUM(ISNULL([Tran Log IO]		, 0))	AS DECIMAL(20,2))	{@Metric}
	,[NetworkIO]		=	CAST(SUM(ISNULL([Network IO]		, 0))	AS DECIMAL(20,2))	{@Metric}
	,[Parallelism]		=	CAST(SUM(ISNULL([Parallelism]		, 0))	AS DECIMAL(20,2))	{@Metric}
	,[Memory]			=	CAST(SUM(ISNULL([Memory]			, 0))	AS DECIMAL(20,2))	{@Metric}
	,[UserWait]			=	CAST(SUM(ISNULL([User Wait]			, 0))	AS DECIMAL(20,2))	{@Metric}
	,[Tracing]			=	CAST(SUM(ISNULL([Tracing]			, 0))	AS DECIMAL(20,2))	{@Metric}
	,[FullTextSearch]	=	CAST(SUM(ISNULL([Full Text Search]	, 0))	AS DECIMAL(20,2))	{@Metric}
	,[OtherDiskIO]		=	CAST(SUM(ISNULL([Other Disk IO]		, 0))	AS DECIMAL(20,2))	{@Metric}
	,[Replication]		=	CAST(SUM(ISNULL([Replication]		, 0))	AS DECIMAL(20,2))	{@Metric}
	,[LogRateGovernor]	=	CAST(SUM(ISNULL([Log Rate Governor]	, 0))	AS DECIMAL(20,2))	{@Metric}
FROM
(
	SELECT
		 [qsp].[query_id] AS [QueryID]
		,ISNULL([qsq].[object_id],0) AS [ObjectID]
		,SUM([qsrs].[count_executions]) as [ExecutionCount]
		,[qsws].[wait_category_desc]
		,SUM([qsws].[total_query_wait_time_ms]) as [total_query_wait_time_ms]
	FROM [{@DatabaseName}].[sys].[query_store_wait_stats] [qsws]
	INNER JOIN [{@DatabaseName}].[sys].[query_store_runtime_stats] [qsrs]
	ON [qsws].[runtime_stats_interval_id] = [qsrs].[runtime_stats_interval_id]
	AND [qsws].[plan_id] = [qsrs].[plan_id]
	INNER JOIN [{@DatabaseName}].[sys].[query_store_plan] [qsp]
	ON [qsws].[plan_id] = [qsp].[plan_id]
	INNER JOIN [{@DatabaseName}].[sys].[query_store_query] [qsq]
	ON [qsp].[query_id] = [qsq].[query_id]
	INNER JOIN [{@DatabaseName}].[sys].[query_store_runtime_stats_interval] [qsrsi]
	ON [qsws].[runtime_stats_interval_id] = [qsrsi].[runtime_stats_interval_id]
	WHERE 
	(
		([qsrs].[first_execution_time] >= ''{@RecentStartTime}'' AND [qsrs].[last_execution_time] < ''{@RecentEndTime}'')
    OR	([qsrs].[first_execution_time] <= ''{@RecentStartTime}'' AND [qsrs].[last_execution_time] > ''{@RecentStartTime}'')
    OR	([qsrs].[first_execution_time] <= ''{@RecentEndTime}''   AND [qsrs].[last_execution_time] > ''{@RecentEndTime}'')
	)
	{@ExcludeAdhoc}
	{@ExcludeInternal}
	GROUP BY
		 [qsp].[query_id]
		,[qsq].[object_id]
		,[qsws].[wait_category_desc]
) AS [SourceTable]
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
GROUP BY 
	 [QueryID]
	,[ObjectID]
) 
,[results]
AS
(
SELECT
	 [QueryID]						=	[recent].[QueryID]
	,[ObjectID]						=	[recent].[ObjectID]
	,[ExecutionCount_Recent]		=	[recent].[ExecutionCount]
	,[ExecutionCount_History]		=	[hist].[ExecutionCount]
	,[ExecutionCount_Variation%]	=	CASE WHEN [recent].[ExecutionCount] = 0 THEN 0 WHEN [hist].[ExecutionCount] = 0 THEN [recent].[ExecutionCount]  ELSE ROUND(CONVERT(DECIMAL(20,2), [recent].[ExecutionCount]-[hist].[ExecutionCount])/NULLIF([hist].[ExecutionCount],0)*100.0, 2) END
	,[Total_History]				=	[hist].[Total]
	,[Total_Recent]					=	[recent].[Total]
	,[Total_Variation%]				=	CASE WHEN [recent].[Total] = 0 THEN 0 WHEN [hist].[Total] = 0 THEN [recent].[Total]  ELSE ROUND(CONVERT(DECIMAL(20,2), [recent].[Total]-[hist].[Total])/NULLIF([hist].[Total],0)*100.0, 2) END
	,[Unknown_History]				=	[hist].[Unknown]
	,[Unknown_Recent]				=	[recent].[Unknown]
	,[Unknown_Variation%]			=	CASE WHEN [recent].[Unknown] = 0 THEN 0 WHEN [hist].[Unknown] = 0 THEN [recent].[Unknown]  ELSE ROUND(CONVERT(DECIMAL(20,2), [recent].[Unknown]-[hist].[Unknown])/NULLIF([hist].[Unknown],0)*100.0, 2) END
	,[CPU_History]					=	[hist].[CPU]
	,[CPU_Recent]					=	[recent].[CPU]
	,[CPU_Variation%]				=	CASE WHEN [recent].[CPU] = 0 THEN 0 WHEN [hist].[CPU] = 0 THEN [recent].[CPU]  ELSE ROUND(CONVERT(DECIMAL(20,2), [recent].[CPU]-[hist].[CPU])/NULLIF([hist].[CPU],0)*100.0, 2) END
	,[WorkerThread_History]			=	[hist].[WorkerThread]
	,[WorkerThread_Recent]			=	[recent].[WorkerThread]
	,[WorkerThread_Variation%]		=	CASE WHEN [recent].[WorkerThread] = 0 THEN 0 WHEN [hist].[WorkerThread] = 0 THEN [recent].[WorkerThread]  ELSE ROUND(CONVERT(DECIMAL(20,2), [recent].[WorkerThread]-[hist].[WorkerThread])/NULLIF([hist].[WorkerThread],0)*100.0, 2) END
	,[Lock_History]					=	[hist].[Lock]
	,[Lock_Recent]					=	[recent].[Lock]
	,[Lock_Variation%]				=	CASE WHEN [recent].[Lock] = 0 THEN 0 WHEN [hist].[Lock] = 0 THEN [recent].[Lock]  ELSE ROUND(CONVERT(DECIMAL(20,2), [recent].[Lock]-[hist].[Lock])/NULLIF([hist].[Lock],0)*100.0, 2) END
	,[Latch_History]				=	[hist].[Latch]
	,[Latch_Recent]					=	[recent].[Latch]
	,[Latch_Variation%]				=	CASE WHEN [recent].[Latch] = 0 THEN 0 WHEN [hist].[Latch] = 0 THEN [recent].[Latch]  ELSE ROUND(CONVERT(DECIMAL(20,2), [recent].[Latch]-[hist].[Latch])/NULLIF([hist].[Latch],0)*100.0, 2) END
	,[BufferLatch_History]			=	[hist].[BufferLatch]
	,[BufferLatch_Recent]			=	[recent].[BufferLatch]
	,[BufferLatch_Variation%]		=	CASE WHEN [recent].[BufferLatch] = 0 THEN 0 WHEN [hist].[BufferLatch] = 0 THEN [recent].[BufferLatch]  ELSE ROUND(CONVERT(DECIMAL(20,2), [recent].[BufferLatch]-[hist].[BufferLatch])/NULLIF([hist].[BufferLatch],0)*100.0, 2) END
	,[BufferIO_History]				=	[hist].[BufferIO]
	,[BufferIO_Recent]				=	[recent].[BufferIO]
	,[BufferIO_Variation%]			=	CASE WHEN [recent].[BufferIO] = 0 THEN 0 WHEN [hist].[BufferIO] = 0 THEN [recent].[BufferIO]  ELSE ROUND(CONVERT(DECIMAL(20,2), [recent].[BufferIO]-[hist].[BufferIO])/NULLIF([hist].[BufferIO],0)*100.0, 2) END
	,[Compilation_History]			=	[hist].[Compilation]
	,[Compilation_Recent]			=	[recent].[Compilation]
	,[Compilation_Variation%]		=	CASE WHEN [recent].[Compilation] = 0 THEN 0 WHEN [hist].[Compilation] = 0 THEN [recent].[Compilation]  ELSE ROUND(CONVERT(DECIMAL(20,2), [recent].[Compilation]-[hist].[Compilation])/NULLIF([hist].[Compilation],0)*100.0, 2) END
	,[SQLCLR_History]				=	[hist].[SQLCLR]
	,[SQLCLR_Recent]				=	[recent].[SQLCLR]
	,[SQLCLR_Variation%]			=	CASE WHEN [recent].[SQLCLR] = 0 THEN 0 WHEN [hist].[SQLCLR] = 0 THEN [recent].[SQLCLR]  ELSE ROUND(CONVERT(DECIMAL(20,2), [recent].[SQLCLR]-[hist].[SQLCLR])/NULLIF([hist].[SQLCLR],0)*100.0, 2) END
	,[Mirroring_History]			=	[hist].[Mirroring]
	,[Mirroring_Recent]				=	[recent].[Mirroring]
	,[Mirroring_Variation%]			=	CASE WHEN [recent].[Mirroring] = 0 THEN 0 WHEN [hist].[Mirroring] = 0 THEN [recent].[Mirroring]  ELSE ROUND(CONVERT(DECIMAL(20,2), [recent].[Mirroring]-[hist].[Mirroring])/NULLIF([hist].[Mirroring],0)*100.0, 2) END
	,[Transaction_History]			=	[hist].[Transaction]
	,[Transaction_Recent]			=	[recent].[Transaction]
	,[Transaction_Variation%]		=	CASE WHEN [recent].[Transaction] = 0 THEN 0 WHEN [hist].[Transaction] = 0 THEN [recent].[Transaction]  ELSE ROUND(CONVERT(DECIMAL(20,2), [recent].[Transaction]-[hist].[Transaction])/NULLIF([hist].[Transaction],0)*100.0, 2) END
	,[Idle_History]					=	[hist].[Idle]
	,[Idle_Recent]					=	[recent].[Idle]
	,[Idle_Variation%]				=	CASE WHEN [recent].[Idle] = 0 THEN 0 WHEN [hist].[Idle] = 0 THEN [recent].[Idle]  ELSE ROUND(CONVERT(DECIMAL(20,2), [recent].[Idle]-[hist].[Idle])/NULLIF([hist].[Idle],0)*100.0, 2) END
	,[Preemptive_History]			=	[hist].[Preemptive]
	,[Preemptive_Recent]			=	[recent].[Preemptive]
	,[Preemptive_Variation%]		=	CASE WHEN [recent].[Preemptive] = 0 THEN 0 WHEN [hist].[Preemptive] = 0 THEN [recent].[Preemptive]  ELSE ROUND(CONVERT(DECIMAL(20,2), [recent].[Preemptive]-[hist].[Preemptive])/NULLIF([hist].[Preemptive],0)*100.0, 2) END
	,[ServiceBroker_History]		=	[hist].[ServiceBroker]
	,[ServiceBroker_Recent]			=	[recent].[ServiceBroker]
	,[ServiceBroker_Variation%]		=	CASE WHEN [recent].[ServiceBroker] = 0 THEN 0 WHEN [hist].[ServiceBroker] = 0 THEN [recent].[ServiceBroker]  ELSE ROUND(CONVERT(DECIMAL(20,2), [recent].[ServiceBroker]-[hist].[ServiceBroker])/NULLIF([hist].[ServiceBroker],0)*100.0, 2) END
	,[TranLogIO_History]			=	[hist].[TranLogIO]
	,[TranLogIO_Recent]				=	[recent].[TranLogIO]
	,[TranLogIO_Variation%]			=	CASE WHEN [recent].[TranLogIO] = 0 THEN 0 WHEN [hist].[TranLogIO] = 0 THEN [recent].[TranLogIO]  ELSE ROUND(CONVERT(DECIMAL(20,2), [recent].[TranLogIO]-[hist].[TranLogIO])/NULLIF([hist].[TranLogIO],0)*100.0, 2) END
	,[NetworkIO_History]			=	[hist].[NetworkIO]
	,[NetworkIO_Recent]				=	[recent].[NetworkIO]
	,[NetworkIO_Variation%]			=	CASE WHEN [recent].[NetworkIO] = 0 THEN 0 WHEN [hist].[NetworkIO] = 0 THEN [recent].[NetworkIO]  ELSE ROUND(CONVERT(DECIMAL(20,2), [recent].[NetworkIO]-[hist].[NetworkIO])/NULLIF([hist].[NetworkIO],0)*100.0, 2) END
	,[Parallelism_History]			=	[hist].[Parallelism]
	,[Parallelism_Recent]			=	[recent].[Parallelism]
	,[Parallelism_Variation%]		=	CASE WHEN [recent].[Parallelism] = 0 THEN 0 WHEN [hist].[Parallelism] = 0 THEN [recent].[Parallelism]  ELSE ROUND(CONVERT(DECIMAL(20,2), [recent].[Parallelism]-[hist].[Parallelism])/NULLIF([hist].[Parallelism],0)*100.0, 2) END
	,[Memory_History]				=	[hist].[Memory]
	,[Memory_Recent]				=	[recent].[Memory]
	,[Memory_Variation%]			=	CASE WHEN [recent].[Memory] = 0 THEN 0 WHEN [hist].[Memory] = 0 THEN [recent].[Memory]  ELSE ROUND(CONVERT(DECIMAL(20,2), [recent].[Memory]-[hist].[Memory])/NULLIF([hist].[Memory],0)*100.0, 2) END
	,[UserWait_History]				=	[hist].[UserWait]
	,[UserWait_Recent]				=	[recent].[UserWait]
	,[UserWait_Variation%]			=	CASE WHEN [recent].[UserWait] = 0 THEN 0 WHEN [hist].[UserWait] = 0 THEN [recent].[UserWait]  ELSE ROUND(CONVERT(DECIMAL(20,2), [recent].[UserWait]-[hist].[UserWait])/NULLIF([hist].[UserWait],0)*100.0, 2) END
	,[Tracing_History]				=	[hist].[Tracing]
	,[Tracing_Recent]				=	[recent].[Tracing]
	,[Tracing_Variation%]			=	CASE WHEN [recent].[Tracing] = 0 THEN 0 WHEN [hist].[Tracing] = 0 THEN [recent].[Tracing]  ELSE ROUND(CONVERT(DECIMAL(20,2), [recent].[Tracing]-[hist].[Tracing])/NULLIF([hist].[Tracing],0)*100.0, 2) END
	,[FullTextSearch_History]		=	[hist].[FullTextSearch]
	,[FullTextSearch_Recent]		=	[recent].[FullTextSearch]
	,[FullTextSearch_Variation%]	=	CASE WHEN [recent].[FullTextSearch] = 0 THEN 0 WHEN [hist].[FullTextSearch] = 0 THEN [recent].[FullTextSearch]  ELSE ROUND(CONVERT(DECIMAL(20,2), [recent].[FullTextSearch]-[hist].[FullTextSearch])/NULLIF([hist].[FullTextSearch],0)*100.0, 2) END
	,[OtherDiskIO_History]			=	[hist].[OtherDiskIO]
	,[OtherDiskIO_Recent]			=	[recent].[OtherDiskIO]
	,[OtherDiskIO_Variation%]		=	CASE WHEN [recent].[OtherDiskIO] = 0 THEN 0 WHEN [hist].[OtherDiskIO] = 0 THEN [recent].[OtherDiskIO]  ELSE ROUND(CONVERT(DECIMAL(20,2), [recent].[OtherDiskIO]-[hist].[OtherDiskIO])/NULLIF([hist].[OtherDiskIO],0)*100.0, 2) END
	,[Replication_History]			=	[hist].[Replication]
	,[Replication_Recent]			=	[recent].[Replication]
	,[Replication_Variation%]		=	CASE WHEN [recent].[Replication] = 0 THEN 0 WHEN [hist].[Replication] = 0 THEN [recent].[Replication]  ELSE ROUND(CONVERT(DECIMAL(20,2), [recent].[Replication]-[hist].[Replication])/NULLIF([hist].[Replication],0)*100.0, 2) END
	,[LogRateGovernor_History]		=	[hist].[LogRateGovernor]	
	,[LogRateGovernor_Recent]		=	[recent].[LogRateGovernor]
	,[LogRateGovernor_Variation%]	=	CASE WHEN [recent].[LogRateGovernor] = 0 THEN 0 WHEN [hist].[LogRateGovernor] = 0 THEN [recent].[LogRateGovernor]  ELSE ROUND(CONVERT(DECIMAL(20,2), [recent].[LogRateGovernor]-[hist].[LogRateGovernor])/NULLIF([hist].[LogRateGovernor],0)*100.0, 2) END
FROM [hist]
INNER JOIN [recent]
ON [hist].[QueryID] = [recent].[QueryID]
)
INSERT INTO #WaitsTable
SELECT TOP ({@ResultsRowCount})
	 [results].[QueryID]	
	,[ObjectID]		=	ISNULL([objs].[ObjectID], 0)
	,[SchemaName]	=	ISNULL([objs].[SchemaName], '''')
	,[ObjectName]	=	ISNULL([objs].[ObjectName], '''')
	,[results].[ExecutionCount_History]	
	,[results].[ExecutionCount_Recent]	
	,[results].[ExecutionCount_Variation%]	
	,[results].[Total_History]			
	,[results].[Total_Recent]				
	,[results].[Total_Variation%]			
	,[results].[Unknown_History]			
	,[results].[Unknown_Recent]			
	,[results].[Unknown_Variation%]		
	,[results].[CPU_History]			
	,[results].[CPU_Recent]				
	,[results].[CPU_Variation%]				
	,[results].[WorkerThread_History]	
	,[results].[WorkerThread_Recent]	
	,[results].[WorkerThread_Variation%]		
	,[results].[Lock_History]				
	,[results].[Lock_Recent]			
	,[results].[Lock_Variation%]			
	,[results].[Latch_History]			
	,[results].[Latch_Recent]				
	,[results].[Latch_Variation%]			
	,[results].[BufferLatch_History]		
	,[results].[BufferLatch_Recent]		
	,[results].[BufferLatch_Variation%]		
	,[results].[BufferIO_History]		
	,[results].[BufferIO_Recent]		
	,[results].[BufferIO_Variation%]		
	,[results].[Compilation_History]		
	,[results].[Compilation_Recent]		
	,[results].[Compilation_Variation%]	
	,[results].[SQLCLR_History]			
	,[results].[SQLCLR_Recent]			
	,[results].[SQLCLR_Variation%]			
	,[results].[Mirroring_History]		
	,[results].[Mirroring_Recent]			
	,[results].[Mirroring_Variation%]		
	,[results].[Transaction_History]		
	,[results].[Transaction_Recent]		
	,[results].[Transaction_Variation%]	
	,[results].[Idle_History]			
	,[results].[Idle_Recent]				
	,[results].[Idle_Variation%]			
	,[results].[Preemptive_History]		
	,[results].[Preemptive_Recent]		
	,[results].[Preemptive_Variation%]		
	,[results].[ServiceBroker_History]	
	,[results].[ServiceBroker_Recent]		
	,[results].[ServiceBroker_Variation%]	
	,[results].[TranLogIO_History]		
	,[results].[TranLogIO_Recent]			
	,[results].[TranLogIO_Variation%]		
	,[results].[NetworkIO_History]		
	,[results].[NetworkIO_Recent]			
	,[results].[NetworkIO_Variation%]		
	,[results].[Parallelism_History]		
	,[results].[Parallelism_Recent]		
	,[results].[Parallelism_Variation%]	
	,[results].[Memory_History]			
	,[results].[Memory_Recent]			
	,[results].[Memory_Variation%]			
	,[results].[UserWait_History]			
	,[results].[UserWait_Recent]			
	,[results].[UserWait_Variation%]		
	,[results].[Tracing_History]			
	,[results].[Tracing_Recent]			
	,[results].[Tracing_Variation%]		
	,[results].[FullTextSearch_History]	
	,[results].[FullTextSearch_Recent]	
	,[results].[FullTextSearch_Variation%]	
	,[results].[OtherDiskIO_History]		
	,[results].[OtherDiskIO_Recent]		
	,[results].[OtherDiskIO_Variation%]	
	,[results].[Replication_History]	
	,[results].[Replication_Recent]		
	,[results].[Replication_Variation%]	
	,[results].[LogRateGovernor_History]
	,[results].[LogRateGovernor_Recent]	
	,[results].[LogRateGovernor_Variation%]
	,[QueryText]	=	CASE
							WHEN {@IncludeQueryText} = 1 THEN COMPRESS([qsqt].[query_sql_text])
							ELSE NULL
						END
FROM [results]
INNER JOIN [{@DatabaseName}].[sys].[query_store_query] [qsq]
ON [qsq].[query_id] = [results].[QueryID]
LEFT JOIN 
(
SELECT 
	[sc].[name]  AS [SchemaName],
	[obs].[name] AS [ObjectName],
	[obs].[object_id] AS [ObjectID]
 FROM [{@DatabaseName}].[sys].[objects] [obs]
 INNER JOIN [{@DatabaseName}].[sys].[schemas] [sc]
 ON [obs].[schema_id] = [sc].[schema_id]
) AS [objs] ON [results].[ObjectID] = [objs].[ObjectID]
INNER JOIN [{@DatabaseName}].[sys].[query_store_query_text] [qsqt]
ON [qsq].[query_text_id] = [qsqt].[query_text_id]
WHERE [{@WaitType}_Variation%] IS NOT NULL
AND [{@WaitType}_Variation%] {@Zero} 0
ORDER BY [{@WaitType}_Variation%] {@ASCDESC}'


SET @SqlCmdLoadTemp = REPLACE(@SqlCmdLoadTemp,	'{@DatabaseName}',			@DatabaseName)
SET @SqlCmdLoadTemp = REPLACE(@SqlCmdLoadTemp,	'{@HistoryStartTime}',		CAST(@HistoryStartTime AS NVARCHAR(34)) )
SET @SqlCmdLoadTemp = REPLACE(@SqlCmdLoadTemp,	'{@HistoryEndTime}',		CAST(@HistoryEndTime AS NVARCHAR(34)) )
SET @SqlCmdLoadTemp = REPLACE(@SqlCmdLoadTemp,	'{@RecentStartTime}',		CAST(@RecentStartTime AS NVARCHAR(34)) )
SET @SqlCmdLoadTemp = REPLACE(@SqlCmdLoadTemp,	'{@RecentEndTime}',			CAST(@RecentEndTime AS NVARCHAR(34)) )
SET @SqlCmdLoadTemp = REPLACE(@SqlCmdLoadTemp,	'{@ResultsRowCount}',		CAST(@ResultsRowCount AS NVARCHAR(8)))
SET @SqlCmdLoadTemp = REPLACE(@SqlCmdLoadTemp,	'{@IncludeQueryText} ',		CAST(@IncludeQueryText AS NVARCHAR(1)))

-- Based on @ExcludeAdhoc, exclude Adhoc queries from the analysis - START
IF (@ExcludeAdhoc = 0)
BEGIN
	SET @SqlCmdLoadTemp = REPLACE(@SqlCmdLoadTemp, '{@ExcludeAdhoc}',		'')	
END
IF (@ExcludeAdhoc = 1)
BEGIN
	SET @SqlCmdLoadTemp = REPLACE(@SqlCmdLoadTemp, '{@ExcludeAdhoc}',		'AND ([qsq].[object_id] <> 0)')
END
-- Based on @ExcludeAdhoc, exclude Adhoc queries from the analysis - END

-- Based on @ExcludeInternal, exclude internal queries from the analysis - START
IF (@ExcludeInternal = 0)
BEGIN
	SET @SqlCmdLoadTemp = REPLACE(@SqlCmdLoadTemp, '{@ExcludeInternal}',	'')	
END
IF (@ExcludeInternal = 1)
BEGIN
	SET @SqlCmdLoadTemp = REPLACE(@SqlCmdLoadTemp, '{@ExcludeInternal}',	'AND ([qsq].[is_internal_query] = 0)')	
END
-- Based on @ExcludeInternal, exclude internal queries from the analysis - END

-- Based on @WaitType, define column to order the results on - START
SET @SqlCmdLoadTemp = REPLACE(@SqlCmdLoadTemp,	'{@WaitType}',				@WaitType)
-- Based on @WaitType, define column to order the results on - END

-- Based on @Metric, modify calculations performed - START
IF (@Metric = 'Total')
	SET @SqlCmdLoadTemp = REPLACE(@SqlCmdLoadTemp,	'{@Metric}',			'')
IF (@Metric = 'Avg')
	SET @SqlCmdLoadTemp = REPLACE(@SqlCmdLoadTemp,	'{@Metric}',			' / SUM(ISNULL([ExecutionCount],0))')
-- Based on @Metric, modify calculations performed - END

-- Based on @VariationType, adapt results' ordering - START
IF (@VariationType = 'R')
BEGIN
	SET @SqlCmdLoadTemp = REPLACE(@SqlCmdLoadTemp, '{@Zero}',				'>')
	SET @SqlCmdLoadTemp = REPLACE(@SqlCmdLoadTemp, '{@ASCDESC}',			'DESC')
END
IF (@VariationType = 'I')
BEGIN
	SET @SqlCmdLoadTemp = REPLACE(@SqlCmdLoadTemp, '{@Zero}',				'<')
	SET @SqlCmdLoadTemp = REPLACE(@SqlCmdLoadTemp, '{@ASCDESC}',			'ASC')
END
-- Based on @VariationType, adapt results' ordering - END


IF (@VerboseMode = 1 )	PRINT	(@SqlCmdLoadTemp)
IF (@TestMode = 0)		EXEC	(@SqlCmdLoadTemp)


-- Output to user - START
IF (@ReportTable IS NULL) OR (@ReportTable = '') OR (@ReportIndex IS NULL) OR (@ReportIndex = '')
BEGIN
	DECLARE @SqlCmd2User NVARCHAR(MAX) = 'SELECT * FROM #WaitsTable ORDER BY [{@WaitType}_Variation%] {@ASCDESC}'
	SET @SqlCmd2User = REPLACE(@SqlCmd2User,	'{@WaitType}',				@WaitType)
	IF (@VariationType = 'R')
	BEGIN
		SET @SqlCmd2User = REPLACE(@SqlCmd2User, '{@ASCDESC}',			'DESC')
	END
	
	IF (@VariationType = 'I')
	BEGIN
		SET @SqlCmd2User = REPLACE(@SqlCmd2User, '{@ASCDESC}',			'ASC')
	END

	IF (@VerboseMode = 1 )	PRINT	(@SqlCmd2User)
	IF (@TestMode = 0)		EXEC	(@SqlCmd2User)
END
-- Output to user - END



-- Output to table - START
IF (@ReportTable IS NOT NULL) AND (@ReportTable <> '') AND (@ReportIndex IS NOT NULL) AND (@ReportIndex <> '')
BEGIN
	-- Log report entry in [dbo].[WaitsVariationIndex] - START
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
			''{@WaitType}''			AS [WaitType],
			''{@Metric}''			AS [Metric],
			''{@VariationType}''	AS [VariationType],
			{@ResultsRowCount}		AS [ResultsRowCount],
			''{@RecentStartTime}''	AS [RecentStartTime],
			''{@RecentEndTime}''	AS [RecentEndTime],
			''{@HistoryStartTime}''	AS [HistoryStartTime],
			''{@HistoryEndTime}''	AS [HistoryEndTime],
			{@IncludeQueryText}		AS [IncludeQueryText],
			{@ExcludeAdhoc}			AS [ExcludeAdhoc],
			{@ExcludeInternal}		AS [ExcludeInternal]
		FOR XML PATH(''WaitsVariationParameters''), ROOT(''Root'')
		)	AS [Parameters]'

	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@ReportIndex}',		@ReportIndex)
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@ServerIdentifier}',	@ServerIdentifier)
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@DatabaseName}',		@DatabaseName)
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@WaitType}',			@WaitType)
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@Metric}',			@Metric)
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@VariationType}',	@VariationType)
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@ResultsRowCount}',	CAST(@ResultsRowCount AS NVARCHAR(20)))
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@RecentStartTime}',	CAST(@RecentStartTime AS NVARCHAR(34)))
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@RecentEndTime}',	CAST(@RecentEndTime AS NVARCHAR(34)))
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@HistoryStartTime}',	CAST(@HistoryStartTime AS NVARCHAR(34)))
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@HistoryEndTime}',	CAST(@HistoryEndTime AS NVARCHAR(34)))
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@IncludeQueryText}',	CAST(@IncludeQueryText AS NVARCHAR(1)))
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@ExcludeAdhoc}',		CAST(@ExcludeAdhoc AS NVARCHAR(1)))
	SET @SqlCmdIndex = REPLACE(@SqlCmdIndex, '{@ExcludeInternal}',	CAST(@ExcludeInternal AS NVARCHAR(1)))

	IF (@VerboseMode = 1)	PRINT	(@SqlCmdIndex)
	IF (@TestMode = 0)		EXEC	(@SqlCmdIndex)

	SET @ReportID = IDENT_CURRENT(@ReportIndex)
	-- Log report entry in [dbo].[WaitsVariationIndex] - END

	-- Log report data in [dbo].[WaitsVariationStore] - START
	DECLARE @SqlCmd2Table NVARCHAR(MAX) =
	'INSERT INTO {@ReportTable}
	SELECT
		{@ReportID}
		,*
	FROM #WaitsTable'
	SET @SqlCmd2Table = REPLACE(@SqlCmd2Table, '{@ReportTable}',		@ReportTable) 
	SET @SqlCmd2Table = REPLACE(@SqlCmd2Table, '{@ReportID}',			@ReportID) 

	IF (@VerboseMode = 1)	PRINT	(@SqlCmd2Table)
	IF (@TestMode = 0)		EXEC	(@SqlCmd2Table)
	-- Log report data in [dbo].[WaitsVariationStore] - END
END
DROP TABLE IF EXISTS #WaitsTable