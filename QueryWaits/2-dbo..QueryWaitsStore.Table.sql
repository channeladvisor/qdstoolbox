IF NOT EXISTS (SELECT 1 FROM [sys].[objects] WHERE [object_id] = OBJECT_ID('dbo.QueryWaitsStore') )
BEGIN
	CREATE TABLE [dbo].[QueryWaitsStore]
	(
		 [ReportID]				BIGINT			NOT NULL
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
	)  ON [Tables] WITH (DATA_COMPRESSION = PAGE)
	ALTER TABLE [dbo].[QueryWaitsStore]
	ADD CONSTRAINT [PK_QueryWaitsStore] PRIMARY KEY CLUSTERED
	(
		  [ReportID]	ASC
		 ,[StartTime]	ASC
		 ,[PlanID]		ASC
		 ,[QueryID]		ASC
	)  WITH (DATA_COMPRESSION = PAGE) ON [Indexes]
END