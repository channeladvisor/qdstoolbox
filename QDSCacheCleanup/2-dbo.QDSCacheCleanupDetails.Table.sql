----------------------------------------------------------------------------------
-- Table Name: [dbo].[QDSCacheCleanupDetails]
--
-- Desc: This table is used by the procedure [dbo].[QDSCacheCleanup] to the details of the queries deleted
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
--		[QueryText]				VARBINARY(MAX)			NULL
--			Query Text corresponding to [QueryID] (compressed)
--
-- Date: 2020.10.22
-- Auth: Pablo Lozano (@sqlozano)
--
-- Date: 2021.05.08
-- Auth: Pablo Lozano (@sqlozano)
-- 		Changed script logic to drop & recreate table
----------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[QDSCacheCleanupDetails]
CREATE TABLE [dbo].[QDSCacheCleanupDetails]
(
	 [ReportID]				BIGINT				NOT	NULL
	,[QueryType]			NVARCHAR(16)		NOT NULL
	,[ObjectName]			NVARCHAR(260)			NULL
	,[QueryID]				BIGINT				NOT NULL
	,[LastExecutionTime]	DATETIMEOFFSET(7)		NULL
	,[ExecutionCount]		BIGINT					NULL
	,[QueryText]			VARBINARY(MAX)			NULL
)
ALTER TABLE [dbo].[QDSCacheCleanupDetails]
ADD CONSTRAINT [PK_QDSCacheCleanupDetails] PRIMARY KEY CLUSTERED 
(
	 [ReportID]			ASC
	,[QueryType]		ASC
	,[QueryID]			ASC
)