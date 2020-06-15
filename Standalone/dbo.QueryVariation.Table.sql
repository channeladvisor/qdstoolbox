CREATE TABLE [dbo].[QueryVariation]
(
	[CaptureDate]			DATETIME2		NOT NULL,
	[ServerName]			SYSNAME			NOT NULL,
	[DatabaseName]			SYSNAME			NOT NULL,
	[Measurement]			VARCHAR(32)		NOT NULL,
	[Metric]				VARCHAR(16)		NOT NULL,
	[QueryID]				BIGINT			NOT NULL,
	[ObjectID]				BIGINT			NOT NULL,
	[SchemaName]			SYSNAME			NOT NULL,
	[ObjectName]			SYSNAME			NOT NULL,
	[MeasurementChange]		FLOAT			NOT NULL,
	[MeasurementRecent]		FLOAT			NOT NULL,
	[MeasurementHist]		FLOAT			NOT NULL,
	[ExecutionCountRecent]	BIGINT			NOT NULL,
	[ExecutionCountHist]	BIGINT			NOT NULL,
	[NumPlans]				INT				NOT NULL,
	[QuerySqlText]			VARBINARY(MAX)	NOT NULL
)
ALTER TABLE [dbo].[QueryVariation]
ADD CONSTRAINT [PK_QueryVariation] PRIMARY KEY CLUSTERED
(
	 [CaptureDate]
	,[ServerName]
	,[DatabaseName]
	,[Measurement]
	,[Metric]	
	,[QueryID]	
)