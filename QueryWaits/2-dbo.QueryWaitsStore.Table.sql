----------------------------------------------------------------------------------
-- Table Name: [dbo].[QueryWaitsStore]
--
-- Desc: This table is used by the procedure [dbo].[QueryWaits] to store the results of the report
--			Description of the wait categories can be found here:
--			https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-query-store-wait-stats-transact-sql?view=sql-server-ver15#wait-categories-mapping-table
--
-- Columns:
--		[ReportID]				BIGINT			NOT NULL
--			Unique Identifier for the execution (operations not logged to table have no ReportID)
--
--		[PlanID]				BIGINT			NOT NULL
--			Identifier of the execution plan analyzed (when only one)
--
--		[QueryID]				BIGINT			NOT NULL
--			Identifier of the query analyzed (when only one)
--
--		[QueryTextID]			BIGINT			NOT NULL
--			Identifier of the query text analyzed (when only one)
--
--		[StartTime]				DATETIME2		NOT NULL
--			Start Time of the interval whose metrics are represented in the next columns
--
--		[EndTime]				DATETIME2		NOT NULL
--			End Time of the interval whose metrics are represented in the next columns
--
--		[DifferentPlansUsed]	INT				NOT NULL
--			Number of different plans used in the interval
--
--		[DifferentQueriesUsed]	INT				NOT NULL
--			Number of different queries used in the interval
--
--		[Total_Duration]		BIGINT			NOT NULL
--			Total duration of the Object/Query/Plan in the interval
--
--		[Total_CPUTime]			BIGINT			NOT NULL
--			Total CPU time of the Object/Query/Plan in the interval
--
--		[Total_CLRTime]			BIGINT			NOT NULL
--			Total CLR time of the Object/Query/Plan in the interval
--
--		[Total_Wait]			BIGINT			NOT NULL
--			Total wait time of the Object/Query/Plan in the interval
--
--		[Wait_CPU]				BIGINT			NOT NULL
--			Total CPU wait time of the Object/Query/Plan in the interval
--
--		[Wait_WorkerThread]		BIGINT			NOT NULL
--			Total Worker Thread wait time of the Object/Query/Plan in the interval
--
--		[Wait_Lock]				BIGINT			NOT NULL
--			Total Lock wait time of the Object/Query/Plan in the interval
--
--		[Wait_Latch]			BIGINT			NOT NULL
--			Total Latch wait time of the Object/Query/Plan in the interval
--
--		[Wait_BufferLatch]		BIGINT			NOT NULL
--			Total Buffer Latch wait time of the Object/Query/Plan in the interval
--
--		[Wait_BufferIO]			BIGINT			NOT NULL
--			Total Buffer IO wait time of the Object/Query/Plan in the interval
--
--		[Wait_Compilation]		BIGINT			NOT NULL
--			Total Compilation wait time of the Object/Query/Plan in the interval
--
--		[Wait_SQLCLR]			BIGINT			NOT NULL
--			Total SQL CLR wait time of the Object/Query/Plan in the interval
--
--		[Wait_Mirroring]		BIGINT			NOT NULL
--			Total Mirroring wait time of the Object/Query/Plan in the interval
--
--		[Wait_Transaction]		BIGINT			NOT NULL
--			Total Transaction wait time of the Object/Query/Plan in the interval
--
--		[Wait_Idle]				BIGINT			NOT NULL
--			Total Idle wait time of the Object/Query/Plan in the interval
--
--		[Wait_Preemptive]		BIGINT			NOT NULL
--			Total Preemptive wait time of the Object/Query/Plan in the interval
--
--		[Wait_ServiceBroker]	BIGINT			NOT NULL
--			Total Service Broker wait time of the Object/Query/Plan in the interval
--
--		[Wait_TranLogIO]		BIGINT			NOT NULL
--			Total Transactional Log IO wait time of the Object/Query/Plan in the interval
--
--		[Wait_NetworkIO]		BIGINT			NOT NULL
--			Total Network IO wait time of the Object/Query/Plan in the interval
--
--		[Wait_Parallelism]		BIGINT			NOT NULL
--			Total Paralellism wait time of the Object/Query/Plan in the interval
--
--		[Wait_Memory]			BIGINT			NOT NULL
--			Total Memory wait time of the Object/Query/Plan in the interval
--
--		[Wait_UserWait]			BIGINT			NOT NULL
--			Total User wait time of the Object/Query/Plan in the interval
--
--		[Wait_Tracing]			BIGINT			NOT NULL
--			Total Tracing wait time of the Object/Query/Plan in the interval
--
--		[Wait_FullTextSearch]	BIGINT			NOT NULL
--			Total FullText Search wait time of the Object/Query/Plan in the interval
--
--		[Wait_OtherDiskIO]		BIGINT			NOT NULL
--			Total Other Disk IO wait time of the Object/Query/Plan in the interval
--
--		[Wait_Replication]		BIGINT			NOT NULL
--			Total Replication wait time of the Object/Query/Plan in the interval
--
--		[Wait_LogRateGovernor]	BIGINT			NOT NULL
--			Total Log Rate Governor wait time of the Object/Query/Plan in the interval
--
--
-- Date: 2020.10.22
-- Auth: Pablo Lozano (@sqlozano)
--
----------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[QueryWaitsStore]
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
)
ALTER TABLE [dbo].[QueryWaitsStore]
ADD CONSTRAINT [PK_QueryWaitsStore] PRIMARY KEY CLUSTERED
(
	  [ReportID]	ASC
	 ,[StartTime]	ASC
	 ,[PlanID]		ASC
	 ,[QueryID]		ASC
)