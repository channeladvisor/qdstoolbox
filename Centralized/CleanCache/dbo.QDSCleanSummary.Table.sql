CREATE TABLE [dbo].[QDSCleanSummary]
(
	[ExecutionTime]		DATETIMEOFFSET(7)	NOT	NULL,
	[ServerName]		SYSNAME				NOT	NULL,
	[DatabaseName]		SYSNAME				NOT	NULL,
	[QueryType]			NVARCHAR(16)		NOT	NULL,
	[QueryCount]		BIGINT					NULL,
	[PlanCount]			BIGINT					NULL,	
	[QueryTextKBs]		BIGINT					NULL,
	[PlanXMLKBs]		BIGINT					NULL,
	[RunStatsKBs]		BIGINT					NULL,
	[WaitStatsKBs]		BIGINT					NULL,
	[CleanupParameters]		XML						NULL
)
ALTER TABLE [dbo].[QDSCleanSummary]
ADD CONSTRAINT [PK_QDSCleanSummary] PRIMARY KEY CLUSTERED 
(
	 [ExecutionTime]	ASC
	,[ServerName]       ASC
	,[DatabaseName]	    ASC
	,[QueryType]        ASC
)