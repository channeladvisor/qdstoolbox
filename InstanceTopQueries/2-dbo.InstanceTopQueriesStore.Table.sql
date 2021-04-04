----------------------------------------------------------------------------------
-- Table Name: [dbo].[InstanceTopQueriesStore]
--
-- Desc: This table is used by the procedure [dbo].[InstanceTopQueries] to store the details returned by the execution of [dbo].[InstanceTopQueries]
--
--		[ReportID]				BIGINT			NOT NULL
--			Unique Identifier for the execution (operations not logged to table have no ReportID)
--
--		[DatabaseName]			SYSNAME			NOT NULL
--			Name of the databse the information of the following columns has been extracted from
--
--		[PlanID]				BIGINT			NOT NULL
--			Identifier of the execution plan the following columns are associated to
--
--		[QueryID]				BIGINT			NOT NULL
--			Identifier of the query the [PlanID] is associated to
--
--		[QueryTextID]			BIGINT			NOT NULL
--			Identifier of the Query Text belonging to the corresponding [QueryID]
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
--		[ExecutionCount]		BIGINT			NOT NULL
--			Number of executions of the corresponding [PlanID] and with the same [ExecutionTypeDes]
--
--		[Duration]				BIGINT			NOT NULL
--			Total duration of all executions of the corresponding [PlanID] in microseconds
--
--		[CPU]					BIGINT			NOT NULL
--			Total CPU time of all executions of the corresponding [PlanID] in microseconds
--
--		[LogicalIOReads]		BIGINT			NOT NULL
--			Total Logical IO reads of all executions of the corresponding [PlanID] in 8 KB pages
--
--		[LogicalIOWrites]		BIGINT			NOT NULL
--			Total Logical IO Writes of all executions of the corresponding [PlanID] in 8 KB pages
--
--		[PhysicalIOReads]		BIGINT			NOT NULL
--			Total Physical IO Reads of all executions of the corresponding [PlanID] in 8 KB pages
--
--		[CLR]					BIGINT			NOT NULL
--			Total CLR time of all executions of the corresponding [PlanID] in microseconds
--
--		[Memory]				BIGINT			NOT NULL
--			Total Memory usage of all executions of the corresponding [PlanID] in 8 KB pages
--
--		[LogBytes]				BIGINT				NULL
--			Total Log bytes usage of all executions of the corresponding [PlanID] in Bytes
--			NULL for SQL 2016 (the metric is not registered in this version)
--
--		[TempDBSpace]			BIGINT				NULL
--			Total TempDB space usage of all executions of the corresponding [PlanID] in 8 KB pages
--			NULL for SQL 2016 (the metric is not registered in this version)
--
--		[QuerySqlText]			VARBINARY(MAX)	    NULL
--			Query Text (compressed) corresponding to the [PlanID]
--
-- Date: 2020.10.22
-- Auth: Pablo Lozano (@sqlozano)
--
-- Auth: Pablo Lozano (@sqlozano)
-- Changes:	[LogBytes] and [TempDBSpace] metrics allow NULLs to allow compatibility with SQL 2016 (which did not include this features)
----------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[InstanceTopQueriesStore]
CREATE TABLE [dbo].[InstanceTopQueriesStore]
(
	 [ReportID]				BIGINT			NOT NULL
	,[DatabaseName]			SYSNAME			NOT NULL
	,[PlanID]				BIGINT			NOT NULL
	,[QueryID]				BIGINT			NOT NULL
	,[QueryTextID]			BIGINT			NOT NULL
	,[ObjectID]				BIGINT			NOT NULL
	,[SchemaName]			SYSNAME			    NULL
	,[ObjectName]			SYSNAME			    NULL
	,[ExecutionTypeDesc]	NVARCHAR(120)	NOT NULL
	,[ExecutionCount]		BIGINT			NOT NULL
	,[Duration]				BIGINT			NOT NULL
	,[CPU]					BIGINT			NOT NULL
	,[LogicalIOReads]		BIGINT			NOT NULL
	,[LogicalIOWrites]		BIGINT			NOT NULL
	,[PhysicalIOReads]		BIGINT			NOT NULL
	,[CLR]					BIGINT			NOT NULL
	,[Memory]				BIGINT			NOT NULL
	,[LogBytes]				BIGINT				NULL
	,[TempDBSpace]			BIGINT				NULL
	,[QuerySqlText]			VARBINARY(MAX)	    NULL
)

ALTER TABLE [dbo].[InstanceTopQueriesStore]
ADD CONSTRAINT [PK_InstanceTopQueriesStore] PRIMARY KEY CLUSTERED
(
	  [ReportID]			ASC
	 ,[DatabaseName]		ASC
	 ,[PlanID]				ASC
	 ,[ExecutionTypeDesc]	ASC
)