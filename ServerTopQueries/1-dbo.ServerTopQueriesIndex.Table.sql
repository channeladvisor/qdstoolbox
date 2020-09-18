IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ServerTopQueriesIndex') )
BEGIN
	CREATE TABLE [dbo].[ServerTopQueriesIndex]
	(
		[ReportID]				BIGINT	IDENTITY(1,1),
		[CaptureDate]			DATETIME2		NOT NULL,
		[ServerIdentifier]		SYSNAME			NOT NULL,
		[DatabaseName]			SYSNAME			NOT NULL,
		[Parameters]			XML				NOT NULL
	)
	ALTER TABLE [dbo].[ServerTopQueriesIndex]
	ADD CONSTRAINT [PK_ServerTopQueriesIndex] PRIMARY KEY CLUSTERED
	(
		 [ReportID]	
	)
END