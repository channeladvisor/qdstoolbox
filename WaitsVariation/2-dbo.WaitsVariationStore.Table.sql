----------------------------------------------------------------------------------
-- Table Name: [dbo].[WaitsVariationStore]
--
-- Desc: This table is used by the procedure [dbo].[WaitsVariation] to store the details of the Waits Variations identified
--			Description of the wait categories can be found here:
--			https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-query-store-wait-stats-transact-sql?view=sql-server-ver15#wait-categories-mapping-table
--
-- Columns:
--		[ReportID]						BIGINT			NOT NULL
--			Unique Identifier for the execution (operations not logged to table have no ReportID)
--
--		[QueryID]						BIGINT			NOT NULL
--			Query Identifier of the query with a wait variation
--
--		[ObjectID]						BIGINT			NOT NULL
--			Object Identifier the [QueryID] is part of (if any)
--
--		[SchemaName]					SYSNAME				NULL
--			Name of the schema of the object the [QueryID] is part of (if any)
--
--		[ObjectName]					SYSNAME				NULL
--			Name of the object the [QueryID] is part of (if any)
--
--		[ExecutionCount_Recent]			DECIMAL(20,2)		NULL
--			Number of executions of the [QueryID] in the period of time identified as "Recent"
--
--		[ExecutionCount_History]		DECIMAL(20,2)		NULL
--			Number of executions of the [QueryID] in the period of time identified as "History"
--
--		[ExecutionCount_Variation%]		DECIMAL(20,2)		NULL
--			Variation (in %) in the number of executions between the period of times identified as "History" and "Recent"
--
--		[Total_Recent]					DECIMAL(20,2)		NULL
--			Total wait time of the [QueryID] in the period of time identified as "Recent" (in microseconds)
--
--		[Total_History]					DECIMAL(20,2)		NULL
--			Total wait time of the [QueryID] in the period of time identified as "History" (in microseconds)
--
--		[Total_Variation%]				DECIMAL(20,2)		NULL
--			Variation (in %) in the Total wait time between the period of times identified as "History" and "Recent"
--
--		[Unknown_Recent]				DECIMAL(20,2)		NULL
--			Total Unknown wait time of the [QueryID] in the period of time identified as "Recent" (in microseconds)
--
--		[Unknown_History]				DECIMAL(20,2)		NULL
--			Total Unknown wait time of the [QueryID] in the period of time identified as "History" (in microseconds)
--
--		[Unknown_Variation%]			DECIMAL(20,2)		NULL
--			Variation (in %) in the Unknown wait time between the period of times identified as "History" and "Recent"
--
--		[CPU_Recent]					DECIMAL(20,2)		NULL
--			Total CPU wait time of the [QueryID] in the period of time identified as "Recent" (in microseconds)
--
--		[CPU_History]					DECIMAL(20,2)		NULL
--			Total CPU wait time of the [QueryID] in the period of time identified as "History" (in microseconds)
--
--		[CPU_Variation%]				DECIMAL(20,2)		NULL
--			Variation (in %) in the CPU wait time between the period of times identified as "History" and "Recent"
--
--		[WorkerThread_Recent]			DECIMAL(20,2)		NULL
--			Worker Thread wait time of the [QueryID] in the period of time identified as "Recent" (in microseconds)
--
--		[WorkerThread_History]			DECIMAL(20,2)		NULL
--			 Worker Thread wait time of the [QueryID] in the period of time identified as "History" (in microseconds)
--
--		[WorkerThread_Variation%]		DECIMAL(20,2)		NULL
--			Variation (in %) in the Worker Thread wait time between the period of times identified as "History" and "Recent"
--
--		[Lock_Recent]					DECIMAL(20,2)		NULL
--			Lock wait time of the [QueryID] in the period of time identified as "Recent" (in microseconds)
--
--		[Lock_History]					DECIMAL(20,2)		NULL
--			Lock wait time of the [QueryID] in the period of time identified as "History" (in microseconds)
--
--		[Lock_Variation%]				DECIMAL(20,2)		NULL
--			Variation (in %) in the Lock wait time between the period of times identified as "History" and "Recent"
--
--		[Latch_Recent]					DECIMAL(20,2)		NULL
--			Latch wait time of the [QueryID] in the period of time identified as "Recent" (in microseconds)
--
--		[Latch_History]					DECIMAL(20,2)		NULL
--			Latch wait time of the [QueryID] in the period of time identified as "History" (in microseconds)
--
--		[Latch_Variation%]				DECIMAL(20,2)		NULL
--			Variation (in %) in the Latch wait time between the period of times identified as "History" and "Recent"
--
--		[BufferLatch_Recent]			DECIMAL(20,2)		NULL
--			Buffer Latch wait time of the [QueryID] in the period of time identified as "Recent" (in microseconds)
--
--		[BufferLatch_History]			DECIMAL(20,2)		NULL
--			Buffer Latch wait time of the [QueryID] in the period of time identified as "History" (in microseconds)
--
--		[BufferLatch_Variation%]		DECIMAL(20,2)		NULL
--			Variation (in %) in the Buffer Latch wait time between the period of times identified as "History" and "Recent"
--
--		[BufferIO_Recent]				DECIMAL(20,2)		NULL
--			Buffer IO wait time of the [QueryID] in the period of time identified as "Recent" (in microseconds)
--
--		[BufferIO_History]				DECIMAL(20,2)		NULL
--			 Buffer IO wait time of the [QueryID] in the period of time identified as "History" (in microseconds)
--
--		[BufferIO_Variation%]			DECIMAL(20,2)		NULL
--			Variation (in %) in the Buffer IO wait time between the period of times identified as "History" and "Recent"
--
--		[Compilation_Recent]			DECIMAL(20,2)		NULL
--			Compilation wait time of the [QueryID] in the period of time identified as "Recent" (in microseconds)
--
--		[Compilation_History]			DECIMAL(20,2)		NULL
--			Compilation wait time of the [QueryID] in the period of time identified as "History" (in microseconds)
--
--		[Compilation_Variation%]		DECIMAL(20,2)		NULL
--			Variation (in %) in the Compilation wait time between the period of times identified as "History" and "Recent"
--
--		[SQLCLR_Recent]					DECIMAL(20,2)		NULL
--			SQL CLR wait time of the [QueryID] in the period of time identified as "Recent" (in microseconds)
--
--		[SQLCLR_History]				DECIMAL(20,2)		NULL
--			SQL CLR wait time of the [QueryID] in the period of time identified as "History" (in microseconds)
--
--		[SQLCLR_Variation%]				DECIMAL(20,2)		NULL
--			Variation (in %) in the SQL CLR wait time between the period of times identified as "History" and "Recent"
--
--		[Mirroring_Recent]				DECIMAL(20,2)		NULL
--			Mirroring wait time of the [QueryID] in the period of time identified as "Recent" (in microseconds)
--
--		[Mirroring_History]				DECIMAL(20,2)		NULL
--			Mirroring wait time of the [QueryID] in the period of time identified as "History" (in microseconds)
--
--		[Mirroring_Variation%]			DECIMAL(20,2)		NULL
--			Variation (in %) in the Mirroring wait time between the period of times identified as "History" and "Recent"
--
--		[Transaction_Recent]			DECIMAL(20,2)		NULL
--			Transaction wait time of the [QueryID] in the period of time identified as "Recent" (in microseconds)
--
--		[Transaction_History]			DECIMAL(20,2)		NULL
--			Transaction wait time of the [QueryID] in the period of time identified as "History" (in microseconds)
--
--		[Transaction_Variation%]		DECIMAL(20,2)		NULL
--			Variation (in %) in the Transaction wait time between the period of times identified as "History" and "Recent"
--
--		[Idle_Recent]					DECIMAL(20,2)		NULL
--			Idle wait time of the [QueryID] in the period of time identified as "Recent" (in microseconds)
--
--		[Idle_History]					DECIMAL(20,2)		NULL
--			Idle wait time of the [QueryID] in the period of time identified as "History" (in microseconds)
--
--		[Idle_Variation%]				DECIMAL(20,2)		NULL
--			Variation (in %) in the Idle wait time between the period of times identified as "History" and "Recent"
--
--		[Preemptive_Recent]				DECIMAL(20,2)		NULL
--			Preemptive wait time of the [QueryID] in the period of time identified as "Recent" (in microseconds)
--
--		[Preemptive_History]			DECIMAL(20,2)		NULL
--			Preemptive wait time of the [QueryID] in the period of time identified as "History" (in microseconds)
--
--		[Preemptive_Variation%]			DECIMAL(20,2)		NULL
--			Variation (in %) in the Preemptive wait time between the period of times identified as "History" and "Recent"
--
--		[ServiceBroker_Recent]			DECIMAL(20,2)		NULL
--			Service Broker wait time of the [QueryID] in the period of time identified as "Recent" (in microseconds)
--
--		[ServiceBroker_History]			DECIMAL(20,2)		NULL
--			Service Broker wait time of the [QueryID] in the period of time identified as "History" (in microseconds)
--
--		[ServiceBroker_Variation%]		DECIMAL(20,2)		NULL
--			Variation (in %) in the Service Broker wait time between the period of times identified as "History" and "Recent"
--
--		[TranLogIO_Recent]				DECIMAL(20,2)		NULL
--			Transaction Log IO wait time of the [QueryID] in the period of time identified as "Recent" (in microseconds)
--
--		[TranLogIO_History]				DECIMAL(20,2)		NULL
--			Transaction LOG IO wait time of the [QueryID] in the period of time identified as "History" (in microseconds)
--
--		[TranLogIO_Variation%]			DECIMAL(20,2)		NULL
--			Variation (in %) in the Transaction Log IO wait time between the period of times identified as "History" and "Recent"
--
--		[NetworkIO_Recent]				DECIMAL(20,2)		NULL
--			Network IO wait time of the [QueryID] in the period of time identified as "Recent" (in microseconds)
--
--		[NetworkIO_History]				DECIMAL(20,2)		NULL
--			Network IO wait time of the [QueryID] in the period of time identified as "History" (in microseconds)
--
--		[NetworkIO_Variation%]			DECIMAL(20,2)		NULL
--			Variation (in %) in the Network IO wait time between the period of times identified as "History" and "Recent"
--
--		[Parallelism_Recent]			DECIMAL(20,2)		NULL
--			Parallelism wait time of the [QueryID] in the period of time identified as "Recent" (in microseconds)
--
--		[Parallelism_History]			DECIMAL(20,2)		NULL
--			Parallelism wait time of the [QueryID] in the period of time identified as "History" (in microseconds)
---
--		[Parallelism_Variation%]		DECIMAL(20,2)		NULL
--			Variation (in %) in the Parallelism wait time between the period of times identified as "History" and "Recent"
--
--		[Memory_Recent]					DECIMAL(20,2)		NULL
--			Memory wait time of the [QueryID] in the period of time identified as "Recent" (in microseconds)
--
--		[Memory_History]				DECIMAL(20,2)		NULL
--			Memory wait time of the [QueryID] in the period of time identified as "History" (in microseconds)
--
--		[Memory_Variation%]				DECIMAL(20,2)		NULL
--			Variation (in %) in the Memory wait time between the period of times identified as "History" and "Recent"
--
--		[UserWait_Recent]				DECIMAL(20,2)		NULL
--			User wait time of the [QueryID] in the period of time identified as "Recent" (in microseconds)
--
--		[UserWait_History]				DECIMAL(20,2)		NULL
--			User wait time of the [QueryID] in the period of time identified as "History" (in microseconds)
--
--		[UserWait_Variation%]			DECIMAL(20,2)		NULL
--			Variation (in %) in the User wait time between the period of times identified as "History" and "Recent"
--
--		[Tracing_Recent]				DECIMAL(20,2)		NULL
--			Tracing wait time of the [QueryID] in the period of time identified as "Recent" (in microseconds)
--
--		[Tracing_History]				DECIMAL(20,2)		NULL
--			Tracing wait time of the [QueryID] in the period of time identified as "History" (in microseconds)
--
--		[Tracing_Variation%]			DECIMAL(20,2)		NULL
--			Variation (in %) in the Tracing wait time between the period of times identified as "History" and "Recent"
--
--		[FullTextSearch_Recent]			DECIMAL(20,2)		NULL
--			FullTextSearch wait time of the [QueryID] in the period of time identified as "Recent" (in microseconds)
--
--		[FullTextSearch_History]		DECIMAL(20,2)		NULL
--			FullTextSearch wait time of the [QueryID] in the period of time identified as "History" (in microseconds)
--
--		[FullTextSearch_Variation%]		DECIMAL(20,2)		NULL
--			Variation (in %) in the FullTextSearch wait time between the period of times identified as "History" and "Recent"
--
--		[OtherDiskIO_Recent]			DECIMAL(20,2)		NULL
--			Other Disk IO wait time of the [QueryID] in the period of time identified as "Recent" (in microseconds)
--
--		[OtherDiskIO_History]			DECIMAL(20,2)		NULL
--			Other Disk IO wait time of the [QueryID] in the period of time identified as "History" (in microseconds)
--
--		[OtherDiskIO_Variation%]		DECIMAL(20,2)		NULL
--			Variation (in %) in the Other Disk IO wait time between the period of times identified as "History" and "Recent"
--
--		[Replication_Recent]			DECIMAL(20,2)		NULL
--			Replication wait time of the [QueryID] in the period of time identified as "Recent" (in microseconds)
--
--		[Replication_History]			DECIMAL(20,2)		NULL
--			Replication wait time of the [QueryID] in the period of time identified as "History" (in microseconds)
--
--		[Replication_Variation%]		DECIMAL(20,2)		NULL
--			Variation (in %) in the Replication wait time between the period of times identified as "History" and "Recent"
--
--		[LogRateGovernor_Recent]		DECIMAL(20,2)		NULL
--			Log Rate Governor wait time of the [QueryID] in the period of time identified as "Recent" (in microseconds)
--
--		[LogRateGovernor_History]		DECIMAL(20,2)		NULL
--			Log Rate Governor wait time of the [QueryID] in the period of time identified as "History" (in microseconds)
--
--		[LogRateGovernor_Variation%]	DECIMAL(20,2)		NULL
--			Variation (in %) in the Log Rate Governor wait time between the period of times identified as "History" and "Recent"
--
--		[QuerySqlText]					VARBINARY(MAX)	    NULL
--			Query text of the [QueryID] (compressed)
--
-- Date: 2020.10.22
-- Auth: Pablo Lozano (@sqlozano)
--
----------------------------------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.WaitsVariationStore') )
BEGIN
	CREATE TABLE [dbo].[WaitsVariationStore]
	(
		 [ReportID]						BIGINT			NOT NULL
		,[QueryID]						BIGINT			NOT NULL
		,[ObjectID]						BIGINT			NOT NULL
		,[SchemaName]					NVARCHAR(128)	NOT NULL
		,[ObjectName]					NVARCHAR(128)	NOT NULL
		,[ExecutionCount_Recent]		DECIMAL(20,2)		NULL
		,[ExecutionCount_History]		DECIMAL(20,2)		NULL
		,[ExecutionCount_Variation%]	DECIMAL(20,2)		NULL
		,[Total_Recent]					DECIMAL(20,2)		NULL
		,[Total_History]				DECIMAL(20,2)		NULL
		,[Total_Variation%]				DECIMAL(20,2)		NULL
		,[Unknown_Recent]				DECIMAL(20,2)		NULL
		,[Unknown_History]				DECIMAL(20,2)		NULL
		,[Unknown_Variation%]			DECIMAL(20,2)		NULL
		,[CPU_Recent]					DECIMAL(20,2)		NULL
		,[CPU_History]					DECIMAL(20,2)		NULL
		,[CPU_Variation%]				DECIMAL(20,2)		NULL
		,[WorkerThread_Recent]			DECIMAL(20,2)		NULL
		,[WorkerThread_History]			DECIMAL(20,2)		NULL
		,[WorkerThread_Variation%]		DECIMAL(20,2)		NULL
		,[Lock_Recent]					DECIMAL(20,2)		NULL
		,[Lock_History]					DECIMAL(20,2)		NULL
		,[Lock_Variation%]				DECIMAL(20,2)		NULL
		,[Latch_Recent]					DECIMAL(20,2)		NULL
		,[Latch_History]				DECIMAL(20,2)		NULL
		,[Latch_Variation%]				DECIMAL(20,2)		NULL
		,[BufferLatch_Recent]			DECIMAL(20,2)		NULL
		,[BufferLatch_History]			DECIMAL(20,2)		NULL
		,[BufferLatch_Variation%]		DECIMAL(20,2)		NULL
		,[BufferIO_Recent]				DECIMAL(20,2)		NULL
		,[BufferIO_History]				DECIMAL(20,2)		NULL
		,[BufferIO_Variation%]			DECIMAL(20,2)		NULL
		,[Compilation_Recent]			DECIMAL(20,2)		NULL
		,[Compilation_History]			DECIMAL(20,2)		NULL
		,[Compilation_Variation%]		DECIMAL(20,2)		NULL
		,[SQLCLR_Recent]				DECIMAL(20,2)		NULL
		,[SQLCLR_History]				DECIMAL(20,2)		NULL
		,[SQLCLR_Variation%]			DECIMAL(20,2)		NULL
		,[Mirroring_Recent]				DECIMAL(20,2)		NULL
		,[Mirroring_History]			DECIMAL(20,2)		NULL
		,[Mirroring_Variation%]			DECIMAL(20,2)		NULL
		,[Transaction_Recent]			DECIMAL(20,2)		NULL
		,[Transaction_History]			DECIMAL(20,2)		NULL
		,[Transaction_Variation%]		DECIMAL(20,2)		NULL
		,[Idle_Recent]					DECIMAL(20,2)		NULL
		,[Idle_History]					DECIMAL(20,2)		NULL
		,[Idle_Variation%]				DECIMAL(20,2)		NULL
		,[Preemptive_Recent]			DECIMAL(20,2)		NULL
		,[Preemptive_History]			DECIMAL(20,2)		NULL
		,[Preemptive_Variation%]		DECIMAL(20,2)		NULL
		,[ServiceBroker_Recent]			DECIMAL(20,2)		NULL
		,[ServiceBroker_History]		DECIMAL(20,2)		NULL
		,[ServiceBroker_Variation%]		DECIMAL(20,2)		NULL
		,[TranLogIO_Recent]				DECIMAL(20,2)		NULL
		,[TranLogIO_History]			DECIMAL(20,2)		NULL
		,[TranLogIO_Variation%]			DECIMAL(20,2)		NULL
		,[NetworkIO_Recent]				DECIMAL(20,2)		NULL
		,[NetworkIO_History]			DECIMAL(20,2)		NULL
		,[NetworkIO_Variation%]			DECIMAL(20,2)		NULL
		,[Parallelism_Recent]			DECIMAL(20,2)		NULL
		,[Parallelism_History]			DECIMAL(20,2)		NULL
		,[Parallelism_Variation%]		DECIMAL(20,2)		NULL
		,[Memory_Recent]				DECIMAL(20,2)		NULL
		,[Memory_History]				DECIMAL(20,2)		NULL
		,[Memory_Variation%]			DECIMAL(20,2)		NULL
		,[UserWait_Recent]				DECIMAL(20,2)		NULL
		,[UserWait_History]				DECIMAL(20,2)		NULL
		,[UserWait_Variation%]			DECIMAL(20,2)		NULL
		,[Tracing_Recent]				DECIMAL(20,2)		NULL
		,[Tracing_History]				DECIMAL(20,2)		NULL
		,[Tracing_Variation%]			DECIMAL(20,2)		NULL
		,[FullTextSearch_Recent]		DECIMAL(20,2)		NULL
		,[FullTextSearch_History]		DECIMAL(20,2)		NULL
		,[FullTextSearch_Variation%]	DECIMAL(20,2)		NULL
		,[OtherDiskIO_Recent]			DECIMAL(20,2)		NULL
		,[OtherDiskIO_History]			DECIMAL(20,2)		NULL
		,[OtherDiskIO_Variation%]		DECIMAL(20,2)		NULL
		,[Replication_Recent]			DECIMAL(20,2)		NULL
		,[Replication_History]			DECIMAL(20,2)		NULL
		,[Replication_Variation%]		DECIMAL(20,2)		NULL
		,[LogRateGovernor_Recent]		DECIMAL(20,2)		NULL
		,[LogRateGovernor_History]		DECIMAL(20,2)		NULL
		,[LogRateGovernor_Variation%]	DECIMAL(20,2)		NULL
		,[QueryText]					VARBINARY(MAX)	NULL
	)
	ALTER TABLE [dbo].[WaitsVariationStore]
	ADD CONSTRAINT [PK_WaitsVariationStore] PRIMARY KEY CLUSTERED
	(
		  [ReportID]	ASC
		 ,[QueryID]		ASC
	)
END