USE [DBA]
GO
DROP TABLE IF EXISTS [DBE].[WaitAnalysisIndex]
CREATE TABLE [DBE].[WaitAnalysisIndex]
(
	[ReportID]				BIGINT	IDENTITY(1,1),
	[CaptureDate]			DATETIME2		NOT NULL,
	[ServerIdentifier]		SYSNAME			NOT NULL,
	[DatabaseName]			SYSNAME			NOT NULL,
	[StartTime]				DATETIME2		NOT NULL,
	[EndTime]				DATETIME2		NOT NULL
)
ALTER TABLE [DBE].[WaitAnalysisIndex]
ADD CONSTRAINT [PK_WaitAnalysisIndex] PRIMARY KEY CLUSTERED
(
	 [ReportID]	
)
GO