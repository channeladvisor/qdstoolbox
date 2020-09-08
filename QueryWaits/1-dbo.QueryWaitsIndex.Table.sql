IF NOT EXISTS (SELECT 1 FROM [sys].[objects] WHERE [object_id] = OBJECT_ID('dbo.QueryWaitsIndex') )
BEGIN
	CREATE TABLE [dbo].[QueryWaitsIndex]
	(
		[ReportID]				BIGINT	IDENTITY(1,1),
		[CaptureDate]			DATETIME2		NOT NULL,
		[ServerIdentifier]		SYSNAME			NOT NULL,
		[DatabaseName]			SYSNAME			NOT NULL,
		[ObjectID]				BIGINT			NOT NULL,
		[SchemaName]			NVARCHAR(128)	NOT NULL,
		[ObjectName]			NVARCHAR(128)	NOT NULL,
		[QueryTextID]			BIGINT			NOT NULL,
		[QueryText]				VARBINARY(MAX)	NULL,
		[Parameters]			XML				NOT NULL,
	) ON [Tables] WITH (DATA_COMPRESSION = PAGE) 
	ALTER TABLE [dbo].[QueryWaitsIndex]
	ADD CONSTRAINT [PK_QueryWaitsIndex] PRIMARY KEY CLUSTERED
	(
		 [ReportID]	
	) WITH (DATA_COMPRESSION = PAGE) ON [Indexes]
END