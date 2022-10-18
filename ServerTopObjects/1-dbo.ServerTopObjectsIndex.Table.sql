----------------------------------------------------------------------------------
-- Table Name: [dbo].[ServerTopObjectsIndex]
--
-- Desc: This table is used by the procedure [dbo].[ServerTopObjects] to store its entry parameters
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
--			List of parameters used to invoke the execution of [dbo].[ServerTopObjects]
--
--
-- Date: 2022.10.18
-- Auth: Pablo Lozano (@sqlozano)
-- Desc: Created based on [dbo].[ServerTopQueriesIndex]
----------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[ServerTopObjectsIndex]
CREATE TABLE [dbo].[ServerTopObjectsIndex]
(
	 [ReportID]				BIGINT	IDENTITY(1,1)
	,[CaptureDate]			DATETIME2		NOT NULL
	,[ServerIdentifier]		SYSNAME			NOT NULL
	,[DatabaseName]			SYSNAME			NOT NULL
	,[Parameters]			XML				NOT NULL
)
ALTER TABLE [dbo].[ServerTopObjectsIndex]
ADD CONSTRAINT [PK_ServerTopObjectsIndex] PRIMARY KEY CLUSTERED
(
	 [ReportID]	
)