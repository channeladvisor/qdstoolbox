----------------------------------------------------------------------------------
-- View Name: [dbo].[vQDSCacheCleanupIndex]
--
-- Desc: This view is built on top of [dbo].[QDSCacheCleanupIndex] to extract the entry parameters used by the executions of [dbo].[QDSCacheCleanup]
--
-- Columns:
--		[ReportID]				BIGINT			NOT NULL
--			Unique Identifier for the execution (operations not logged to table have no ReportID)
--
--		[ReportDate]			DATETIME2		NOT NULL
--			UTC Date of the execution's start
--
--		[ServerIdentifier]		SYSNAME			NOT NULL
--			Identifier of the server, so if this data is centralized reports originated on each server can be properly identified
--
--		[DatabaseName]			SYSNAME			NOT NULL
--			Name of the database this operation was executed against
--
--		[QueryType]				NVARCHAR(16)	NOT	NULL
--			Type of query for which the following metrics are referred
--
--		[QueryCount]			BIGINT				NULL
--			Number of queries of the [QueryType] found to be deleted
--
--		[PlanCount]				BIGINT				NULL	
--			Number of plans belonging to queries of the [QueryType] found to be deleted
--
--		[QueryTextKBs]			BIGINT				NULL
--			Size of the query texts belonging to queries of the [QueryType] found to be deleted
--
--		[PlanXMLKBs]			BIGINT				NULL
--			Size of the execution plans belonging to queries of the [QueryType] found to be deleted
--
--		[RunStatsKBs]			BIGINT				NULL
--			Size of the query runtime stats generated for the plans belonging to queries of the [QueryType] found to be deleted
--
--		[WaitStatsKBs]			BIGINT				NULL
--			Size of the query wait stats generated for the plans belonging to queries of the [QueryType] found to be deleted
--
--		[CleanupParameters]		XML					NULL
--			List of parameters used to invoke the execution of [dbo].[QDSCacheCleanup]
--
--		[TestMode]				BIT				NOT NULL
--			Flag to enable/disable the Test mode, which generates the report but doesn't clean any Query Store data
--
--		[CleanAdhocStale]		BIT				NOT NULL
--			Flag to clean queries that:
--				Are ad-hoc queries (don't belong any object)
--				Haven't been executed at least @MinExecutionCount times
--				Haven't been executed in the last @Retention hours
--
--		[CleanStale]			BIT				NOT NULL
--			Flag to clean queries that:
--				Queries belonging an object and ad-hoc ones (don't belong any object)
--				Haven't been executed at least @MinExecutionCount times
--				Haven't been executed in the last @Retention hours
--
--		[Retention]				BIT				NOT NULL
--				Hours since the last execution of the query
--
--		[MinExecutionCount]		BIT				NOT NULL
--				Minimum number of executions NOT delete the query. If @MinExecutionCount = 0, ALL queries will be flagged for deletion
--
--		[CleanOrphan]			BIT				NOT NULL
--				Flag to clean queries associated with deleted objects
--
--		[CleanInternal]			BIT				NOT NULL
--				Flag to clean queries identified as internal ones by QDS (UPDATE STATISTICS, INDEX REBUILD....)
--
--		[CleanStatsOnly]		BIT				NOT NULL
--				Flag to clean only the statistics of the queries flagged to be deleted, but not the queries, execution plans or query texts themselves
--
-- Date: 2020.10.22
-- Auth: Pablo Lozano (@sqlozano)
--
----------------------------------------------------------------------------------

CREATE OR ALTER VIEW [dbo].[vQDSCacheCleanupIndex]
AS
SELECT
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
	,[TestMode]	
	,[CleanupParameters].value('(/Root/CleanupParameters/CleanAdhocStale)[1]','BIT')	AS [CleanAdhocStale]
	,[CleanupParameters].value('(/Root/CleanupParameters/CleanStale)[1]','BIT')			AS [CleanStale]
	,[CleanupParameters].value('(/Root/CleanupParameters/Retention)[1]','BIT')			AS [Retention]
	,[CleanupParameters].value('(/Root/CleanupParameters/MinExecutionCount)[1]','BIT')	AS [MinExecutionCount]
	,[CleanupParameters].value('(/Root/CleanupParameters/CleanOrphan)[1]','BIT')		AS [CleanOrphan]
	,[CleanupParameters].value('(/Root/CleanupParameters/CleanInternal)[1]','BIT')		AS [CleanInternal]
	,[CleanupParameters].value('(/Root/CleanupParameters/CleanStatsOnly)[1]','BIT')		AS [CleanStatsOnly]
FROM [dbo].[QDSCacheCleanupIndex]