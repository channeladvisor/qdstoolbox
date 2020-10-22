----------------------------------------------------------------------------------
-- Table Name: [dbo].[ServerTopQueriesIndex]
--
-- Desc: This table is used by the procedure [dbo].[ServerTopQueries] to store its entry parameters
--
-- Columns:
--		[ReportID]				BIGINT			NOT NULL
--			Unique Identifier for the execution (operations not logged to table have no ReportID)
--
--		[ReportDate]			DATETIME2		NOT NULL
--			UTC Date of the execution's start
--
--		[ServerIdentifier]		SYSNAME			NOT NULL
--			Identifier of the server, so if this data is centralized reports originated on each server can be properly identified
--
--		[DatabaseName]			SYSNAME			NOT NULL
--			Name of the database this operation was executed against
--
--		[Parameters]		XML					NULL
--			List of parameters used to invoke the execution of [dbo].[QueryVariation]
--
--
-- Date: 2020.10.22
-- Auth: Pablo Lozano (@sqlozano)
--
----------------------------------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ServerTopQueriesIndex') )
BEGIN
	CREATE TABLE [dbo].[ServerTopQueriesIndex]
	(
		 [ReportID]				BIGINT	IDENTITY(1,1)
		,[CaptureDate]			DATETIME2		NOT NULL
		,[ServerIdentifier]		SYSNAME			NOT NULL
		,[DatabaseName]			SYSNAME			NOT NULL
		,[Parameters]			XML				NOT NULL
	)
	ALTER TABLE [dbo].[ServerTopQueriesIndex]
	ADD CONSTRAINT [PK_ServerTopQueriesIndex] PRIMARY KEY CLUSTERED
	(
		 [ReportID]	
	)
END