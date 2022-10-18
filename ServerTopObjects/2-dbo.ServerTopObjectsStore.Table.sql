----------------------------------------------------------------------------------
-- Table Name: [dbo].[ServerTopObjectsStore]
--
-- Desc: This table is used by the procedure [dbo].[ServerTopObjects] to store the details returned by the execution of [dbo].[ServerTopObjects]
--
--		[ReportID]				BIGINT			NOT NULL
--			Unique Identifier for the execution (operations not logged to table have no ReportID)
--
--		[DatabaseName]			SYSNAME			NOT NULL
--			Name of the databse the information of the following columns has been extracted from
--
--		[ObjectID]				BIGINT			NOT NULL
--			Identifier of the object associated to the corresponding [QueryID] (if any)
--
--		[SchemaName]			SYSNAME			    NULL
--			Name of the schema of the object associated to the corresponding [QueryID] (if any)
--
--		[ObjectName]			SYSNAME			    NULL
--			Name of the object associated to the corresponding [QueryID] (if any)
--
--		[ExecutionTypeDesc]		NVARCHAR(120)	NOT NULL
--			Description of the execution type (Regular, Aborted, Exception)
--
--		[EstimatedExecutionCount]		BIGINT			NOT NULL
--			Estimate of the number of executions of the corresponding [ObjectID] and with the same [ExecutionTypeDes], based on the max number of subqueries executed
--
--		[Duration]				BIGINT			NOT NULL
--			Total duration of all executions of the corresponding [ObjectID] in microseconds
--
--		[CPU]					BIGINT			NOT NULL
--			Total CPU time of all executions of the corresponding [ObjectID] in microseconds
--
--		[LogicalIOReads]		BIGINT			NOT NULL
--			Total Logical IO reads of all executions of the corresponding [ObjectID] in 8 KB pages
--
--		[LogicalIOWrites]		BIGINT			NOT NULL
--			Total Logical IO Writes of all executions of the corresponding [ObjectID] in 8 KB pages
--
--		[PhysicalIOReads]		BIGINT			NOT NULL
--			Total Physical IO Reads of all executions of the corresponding [ObjectID] in 8 KB pages
--
--		[CLR]					BIGINT			NOT NULL
--			Total CLR time of all executions of the corresponding [ObjectID] in microseconds
--
--		[Memory]				BIGINT			NOT NULL
--			Total Memory usage of all executions of the corresponding [ObjectID] in 8 KB pages
--
--		[LogBytes]				BIGINT				NULL
--			Total Log bytes usage of all executions of the corresponding [ObjectID] in Bytes
--			NULL for SQL 2016 (the metric is not registered in this version)
--
--		[TempDBSpace]			BIGINT				NULL
--			Total TempDB space usage of all executions of the corresponding [ObjectID] in 8 KB pages
--			NULL for SQL 2016 (the metric is not registered in this version)
--
--
-- Date: 2022.10.18
-- Auth: Pablo Lozano (@sqlozano)
-- Desc: Created based on [dbo].[ServerTopQueriesStore]
----------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[ServerTopObjectsStore]
CREATE TABLE [dbo].[ServerTopObjectsStore]
(
	 [ReportID]					BIGINT			NOT NULL
	,[DatabaseName]				SYSNAME			NOT NULL
	,[ObjectID]					BIGINT			NOT NULL
	,[SchemaName]				SYSNAME			NOT NULL
	,[ObjectName]				SYSNAME			NOT NULL
	,[ExecutionTypeDesc]		NVARCHAR(120)	NOT NULL
	,[EstimatedExecutionCount]	BIGINT			NOT NULL
	,[Duration]					BIGINT			NOT NULL
	,[CPU]						BIGINT			NOT NULL
	,[LogicalIOReads]			BIGINT			NOT NULL
	,[LogicalIOWrites]			BIGINT			NOT NULL
	,[PhysicalIOReads]			BIGINT			NOT NULL
	,[CLR]						BIGINT			NOT NULL
	,[Memory]					BIGINT			NOT NULL
	,[LogBytes]					BIGINT				NULL
	,[TempDBSpace]				BIGINT				NULL
)
ALTER TABLE [dbo].[ServerTopObjectsStore]
ADD CONSTRAINT [PK_ServerTopObjectsStore] PRIMARY KEY CLUSTERED
(
	  [ReportID]			ASC
	 ,[DatabaseName]		ASC
	 ,[SchemaName]			ASC
	 ,[ObjectName]			ASC
	 ,[ExecutionTypeDesc]	ASC
)