DROP TABLE IF EXISTS [dbo].[QueryVariationIndex]
CREATE TABLE [dbo].[QueryVariationIndex]
(
	[ReportID]				BIGINT	IDENTITY(1,1),
	[CaptureDate]			DATETIME2		NOT NULL,
	[ServerIdentifier]		SYSNAME			NOT NULL,
	[DatabaseName]			SYSNAME			NOT NULL,
	[Measurement]			VARCHAR(32)		NOT NULL,
	[Metric]				VARCHAR(16)		NOT NULL,
	[VariationType]			VARCHAR(1)		NOT NULL,
	[RecentStartTime]		DATETIME2		NOT NULL,
	[RecentEndTime]			DATETIME2		NOT NULL,
	[HistoryStartTime]		DATETIME2		NOT NULL,
	[HistoryEndTime]		DATETIME2		NOT NULL
)
ALTER TABLE [dbo].[QueryVariationIndex]
ADD CONSTRAINT [PK_QueryVariationIndex] PRIMARY KEY CLUSTERED
(
	 [ReportID]	
)