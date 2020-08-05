DROP TABLE IF EXISTS [dbo].[ServerTopQueriesStore]
CREATE TABLE [dbo].[ServerTopQueriesStore]
(
	[ReportID]				BIGINT			NOT NULL,
	[DatabaseName]			SYSNAME			NOT NULL,
	[PlanID]				BIGINT			NOT NULL,
	[QueryID]				BIGINT			NOT NULL,
	[QueryTextID]			BIGINT			NOT NULL,
	[ObjectID]				BIGINT			NOT NULL,
	[SchemaName]			SYSNAME			    NULL,
	[ObjectName]			SYSNAME			    NULL,
	[ExecutionTypeDesc]		NVARCHAR(120)	NOT NULL,
	[ExecutionCount]		BIGINT			NOT NULL,
	[Duration]				BIGINT			NOT NULL,
	[CPU]					BIGINT			NOT NULL,
	[LogicalIOReads]		BIGINT			NOT NULL,
	[LogicalIOWrites]		BIGINT			NOT NULL,
	[PhysicalIOReads]		BIGINT			NOT NULL,
	[CLR]					BIGINT			NOT NULL,
	[Memory]				BIGINT			NOT NULL,
	[LogBytes]				BIGINT			NOT NULL,
	[TempDBSpace]			BIGINT			NOT NULL,
	[QuerySqlText]			VARBINARY(MAX)	    NULL
)
ALTER TABLE [dbo].[ServerTopQueriesStore]
ADD CONSTRAINT [PK_ServerTopQueriesStore] PRIMARY KEY CLUSTERED
(
	 [ReportID] ASC,
	 [DatabaseName] ASC,
	 [PlanID] ASC,
	 [ExecutionTypeDesc] ASC
)