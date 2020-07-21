DROP TABLE IF EXISTS [dbo].[QDSCleanupDetails]
CREATE TABLE [dbo].[QDSCleanupDetails]
(
	[ReportID]			BIGINT				NOT	NULL,
	[QueryType]			NVARCHAR(16)		NOT NULL,
	[ObjectName]		NVARCHAR(260)			NULL,
	[QueryID]			BIGINT				NOT NULL,
	[LastExecutionTime] DATETIMEOFFSET(7)		NULL,
	[ExecutionCount]	BIGINT					NULL,
	[QueryText]			VARBINARY(MAX)			NULL
)
ALTER TABLE [dbo].[QDSCleanupDetails]
ADD CONSTRAINT [PK_QDSCleanupDetails] PRIMARY KEY CLUSTERED 
(
	[ReportID]			ASC,
	[QueryType]        ASC,
	[QueryID]			ASC
)