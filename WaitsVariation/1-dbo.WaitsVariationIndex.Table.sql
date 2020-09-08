IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.WaitsVariationIndex') )
BEGIN
	CREATE TABLE [dbo].[WaitsVariationIndex]
	(
		[ReportID]				BIGINT	IDENTITY(1,1),
		[CaptureDate]			DATETIME2		NOT NULL,
		[ServerIdentifier]		SYSNAME			NOT NULL,
		[DatabaseName]			SYSNAME			NOT NULL,
		[Parameters]			XML				NOT NULL
	)
	ALTER TABLE [dbo].[WaitsVariationIndex]
	ADD CONSTRAINT [PK_WaitsVariationIndex] PRIMARY KEY CLUSTERED
	(
		 [ReportID]	
	)
END