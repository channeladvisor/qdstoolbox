DROP TABLE IF EXISTS [dbo].[QDSCacheCleanupDetails]
CREATE TABLE [dbo].[QDSCacheCleanupDetails]
(
	[ReportID]			BIGINT				NOT	NULL,
	[QueryType]			NVARCHAR(16)		NOT NULL,
	[ObjectName]		NVARCHAR(260)			NULL,
	[QueryID]			BIGINT				NOT NULL,
	[LastExecutionTime] DATETIMEOFFSET(7)		NULL,
	[ExecutionCount]	BIGINT					NULL,
	[QueryText]			VARBINARY(MAX)			NULL
)
ALTER TABLE [dbo].[QDSCacheCleanupDetails]
ADD CONSTRAINT [PK_QDSCacheCleanupDetails] PRIMARY KEY CLUSTERED 
(
	[ReportID]			ASC,
	[QueryType]        ASC,
	[QueryID]			ASC
)