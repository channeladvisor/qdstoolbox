----------------------------------------------------------------------------------
-- Table Name: [dbo].[QDSCacheCleanupIndex]
--
-- Desc: This table is used by the procedure [dbo].[QDSCacheCleanup] to store its entry parameters
--
-- Columns:
--		[ReportID]				BIGINT			NOT NULL
--			Unique Identifier for the execution (operations not logged to table have no ReportID)
--
--		[ReportDate]			DATETIME2		NOT NULL
--			UTC Date of the execution's start
--
--		[InstanceIdentifier]	SYSNAME			NOT NULL
--			Identifier of the instance, so if this data is centralized reports originated on each instance can be properly identified
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
-- Date: 2020.10.22
-- Auth: Pablo Lozano (@sqlozano)
--
-- Date: 2021.04.04
-- Auth: Pablo Lozano (@sqlozano)
--			Replaced "server" references to the more accurate term "instance"
----------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[QDSCacheCleanupIndex]
CREATE TABLE [dbo].[QDSCacheCleanupIndex]
(
	 [ReportID]				BIGINT			NOT NULL
	,[ReportDate]			DATETIME2		NOT NULL
	,[InstanceIdentifier]	SYSNAME			NOT NULL
	,[DatabaseName]			SYSNAME			NOT NULL
	,[QueryType]			NVARCHAR(16)	NOT	NULL
	,[QueryCount]			BIGINT				NULL
	,[PlanCount]			BIGINT				NULL	
	,[QueryTextKBs]			BIGINT				NULL
	,[PlanXMLKBs]			BIGINT				NULL
	,[RunStatsKBs]			BIGINT				NULL
	,[WaitStatsKBs]			BIGINT				NULL
	,[CleanupParameters]	XML					NULL
	,[TestMode]				BIT				NOT NULL
)
ALTER TABLE [dbo].[QDSCacheCleanupIndex]
ADD CONSTRAINT [PK_QDSCacheCleanupIndex] PRIMARY KEY CLUSTERED
(
	  [ReportID]	ASC
	 ,[QueryType]	ASC
)