DROP TABLE IF EXISTS [dbo].[QDSCacheCleanupIndex]
CREATE TABLE [dbo].[QDSCacheCleanupIndex]
(
	[ReportID]				BIGINT			NOT NULL,
	[ReportDate]			DATETIME2		NOT NULL,
	[ServerIdentifier]		SYSNAME			NOT NULL,
	[DatabaseName]			SYSNAME			NOT NULL,
	[QueryType]				NVARCHAR(16)	NOT	NULL,
	[QueryCount]			BIGINT				NULL,
	[PlanCount]				BIGINT				NULL,	
	[QueryTextKBs]			BIGINT				NULL,
	[PlanXMLKBs]			BIGINT				NULL,
	[RunStatsKBs]			BIGINT				NULL,
	[WaitStatsKBs]			BIGINT				NULL,
	[CleanupParameters]		XML					NULL,
	[TestMode]				BIT				NOT NULL
)
ALTER TABLE [dbo].[QDSCacheCleanupIndex]
ADD CONSTRAINT [PK_QDSCacheCleanupIndex] PRIMARY KEY CLUSTERED
(
	 [ReportID] ASC,
	 [QueryType] ASC
)