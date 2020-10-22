----------------------------------------------------------------------------------
-- View Name: [dbo].[vQDSCacheCleanupDetails]
--
-- Desc: This view is built on top of [QDSCacheCleanupDetails] to extract the details of the queries flagged for deletion by the execution of [dbo].[QDSCacheCleanup]
--
-- Columns:
--		[ReportID]				BIGINT				NOT NULL
--			Unique Identifier for the execution (operations not logged to table have no ReportID)
--
--		[QueryType]				NVARCHAR(16)		NOT	NULL
--			Type of query for which the following metrics are referred
--
--		[ObjectName]			NVARCHAR(260)			NULL
--			Name of the object (if any) which the [QueryID] is part of
--
--		[QueryID]				BIGINT				NOT NULL
--			Identifier of the query deleted
--
--		[LastExecutionTime]		DATETIMEOFFSET(7)		NULL
--			Last time (UTC time) the [QueryID] was executed
--
--		[ExecutionCount]		BIGINT					NULL
--			Number of executions of the [QueryID]
--
--		[QueryText]				NVARCHAR(MAX)			NULL
--			Query Text corresponding to [QueryID]
--
-- Date: 2020.10.22
-- Auth: Pablo Lozano (@sqlozano)
--
----------------------------------------------------------------------------------

CREATE OR ALTER VIEW [dbo].[vQDSCacheCleanupDetails]
AS
SELECT
	 [ReportID]		
	,[QueryType]		
	,[ObjectName]	
	,[QueryID]		
	,[LastExecutionTime]
	,[ExecutionCount]
	,CAST(DECOMPRESS([QueryText]) AS NVARCHAR(MAX)) AS [QueryText]
FROM [dbo].[QDSCacheCleanupDetails]