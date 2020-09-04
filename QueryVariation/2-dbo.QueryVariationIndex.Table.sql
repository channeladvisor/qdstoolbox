IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.QueryVariationIndex') )
BEGIN
	CREATE TABLE [dbo].[QueryVariationIndex]
	(
		[ReportID]				BIGINT	IDENTITY(1,1),
		[CaptureDate]			DATETIME2		NOT NULL,
		[ServerIdentifier]		SYSNAME			NOT NULL,
		[DatabaseName]			SYSNAME			NOT NULL,
		[Parameters]			XML				NOT NULL
	)
	ALTER TABLE [dbo].[QueryVariationIndex]
	ADD CONSTRAINT [PK_QueryVariationIndex] PRIMARY KEY CLUSTERED
	(
		 [ReportID]	
	) WITH (DATA_COMPRESSION = PAGE)
END