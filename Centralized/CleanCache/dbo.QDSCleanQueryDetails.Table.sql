CREATE TABLE [dbo].[QDSCleanQueryDetails]
(
	[ExecutionTime]		DATETIMEOFFSET(7)	NOT	NULL,
	[ServerName]		SYSNAME				NOT	NULL,
	[DatabaseName]		SYSNAME				NOT	NULL,
	[QueryType]			NVARCHAR(16)		NOT NULL,
	[ObjectName]		NVARCHAR(260)			NULL,
	[QueryId]			BIGINT				NOT NULL,
	[LastExecutionTime] DATETIMEOFFSET(7)		NULL,
	[ExecutionCount]	BIGINT					NULL,
	[QueryText]			VARBINARY(MAX)			NULL,
	[CleanupParameters]		XML					NULL
)
ALTER TABLE [dbo].[QDSCleanQueryDetails]
ADD CONSTRAINT [PK_QDSCleanQueryDetails] PRIMARY KEY CLUSTERED 
(
	 [ExecutionTime]	ASC
	,[ServerName]       ASC
	,[DatabaseName]	    ASC
	,[QueryType]        ASC
	,[QueryID]			ASC
)