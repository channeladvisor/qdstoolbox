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
		 [ReportID] ASC,
		 [QueryID] ASC
	)
END