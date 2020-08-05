DROP TABLE IF EXISTS [dbo].[ServerTopQueriesIndex]
CREATE TABLE [dbo].[ServerTopQueriesIndex]
(
	[ReportID]				BIGINT	IDENTITY(1,1),
	[CaptureDate]			DATETIME2		NOT NULL,
	[ServerIdentifier]		SYSNAME			NOT NULL,
	[DatabaseName]			SYSNAME			NOT NULL,
	[Top]					INT				NOT NULL,
	[Measurement]			VARCHAR(32)		NOT NULL,
	[StartTime]				DATETIME2		NOT NULL,
	[EndTime]				DATETIME2		NOT NULL
)
ALTER TABLE [dbo].[ServerTopQueriesIndex]
ADD CONSTRAINT [PK_ServerTopQueriesIndex] PRIMARY KEY CLUSTERED
(
	 [ReportID]	
)