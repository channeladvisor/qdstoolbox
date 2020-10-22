----------------------------------------------------------------------------------
-- View Name: [dbo].[vQueryWaitsStore]
--
-- Desc: This view is built on top of [dbo].[QueryWaitsStore] to extract the metrics obtained by the execution of [dbo].[QueryWaits]
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
--		[QueryText]				NVARCHAR(MAX)	NULL
--			Query Text of the corresponding [QueryTextID] (when included)
--
-- Date: 2020.10.22
-- Auth: Pablo Lozano (@sqlozano)
--
----------------------------------------------------------------------------------

CREATE OR ALTER VIEW [dbo].[vQueryWaitsStore]
AS
SELECT
	 [wdi].[ReportID]				
	,[wds].[PlanID]				
	,[wds].[QueryID]				
	,[wds].[QueryTextID]			
	,[wds].[StartTime]			
	,[wds].[EndTime]				
	,[wds].[DifferentPlansUsed]	
	,[wds].[DifferentQueriesUsed]	
	,[wds].[Total_Duration]		
	,[wds].[Total_CPUTime]		
	,[wds].[Total_CLRTime]		
	,[wds].[Total_Wait]			
	,[wds].[Wait_CPU]				
	,[wds].[Wait_WorkerThread]	
	,[wds].[Wait_Lock]			
	,[wds].[Wait_Latch]			
	,[wds].[Wait_BufferLatch]		
	,[wds].[Wait_BufferIO]		
	,[wds].[Wait_Compilation]		
	,[wds].[Wait_SQLCLR]			
	,[wds].[Wait_Mirroring]		
	,[wds].[Wait_Transaction]		
	,[wds].[Wait_Idle]			
	,[wds].[Wait_Preemptive]		
	,[wds].[Wait_ServiceBroker]	
	,[wds].[Wait_TranLogIO]		
	,[wds].[Wait_NetworkIO]		
	,[wds].[Wait_Parallelism]		
	,[wds].[Wait_Memory]			
	,[wds].[Wait_UserWait]		
	,[wds].[Wait_Tracing]			
	,[wds].[Wait_FullTextSearch]	
	,[wds].[Wait_OtherDiskIO]		
	,[wds].[Wait_Replication]		
	,[wds].[Wait_LogRateGovernor]	
	,CAST(DECOMPRESS([wdi].[QueryText]) AS NVARCHAR(MAX))	AS [QueryText]
FROM [dbo].[QueryWaitsStore] [wds]
INNER JOIN [dbo].[QueryWaitsIndex] [wdi]
ON [wds].[ReportID] = [wdi].[ReportID]