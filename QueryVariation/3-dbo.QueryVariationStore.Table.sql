DROP TABLE IF EXISTS [dbo].[QueryVariationStore]
CREATE TABLE [dbo].[QueryVariationStore]
(
	[CaptureDate]			DATETIME2		NOT NULL,
	[ServerName]			SYSNAME			NOT NULL,
	[DatabaseName]			SYSNAME			NOT NULL,
	[Measurement]			VARCHAR(32)		NOT NULL,
	[Metric]				VARCHAR(16)		NOT NULL,
	[VariationType]			VARCHAR(1)		NOT NULL,
	[QueryID]				BIGINT			NOT NULL,
	[ObjectID]				BIGINT			NOT NULL,
	[SchemaName]			SYSNAME			    NULL,
	[ObjectName]			SYSNAME			    NULL,
	[MeasurementChange]		FLOAT			NOT NULL,
	[MeasurementRecent]		FLOAT			NOT NULL,
	[MeasurementHist]		FLOAT			NOT NULL,
	[ExecutionCountRecent]	BIGINT			NOT NULL,
	[ExecutionCountHist]	BIGINT			NOT NULL,
	[NumPlans]				INT				NOT NULL,
	[QuerySqlText]			VARBINARY(MAX)	    NULL
)
ALTER TABLE [dbo].[QueryVariationStore]
ADD CONSTRAINT [PK_QueryVariationStore] PRIMARY KEY CLUSTERED
(
	 [CaptureDate]
	,[ServerName]
	,[DatabaseName]
	,[Measurement]
	,[Metric]	
	,[QueryID]	
)