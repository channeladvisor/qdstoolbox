----------------------------------------------------------------------------------
-- Table Name: [dbo].[QueryWaitsIndex]
--
-- Desc: This table is used by the procedure [dbo].[QueryWaits] to store its entry parameters
--
-- Columns:
--		[ReportID]				BIGINT			NOT NULL
--			Unique Identifier for the execution (operations not logged to table have no ReportID)
--
--		[ReportDate]			DATETIME2		NOT NULL
--			UTC Date of the execution's start
--
--		[InstanceIdentifier]	SYSNAME			NOT NULL
--			Identifier of the instance, so if this data is centralized reports originated on each instance can be properly identified
--
--		[DatabaseName]			SYSNAME			NOT NULL
--			Name of the database this operation was executed against
--
--		[ObjectID]				BIGINT			NOT NULL
--			Identifier of the object (if any) whose wait times are being analyzed
--
--		[SchemaName]			NVARCHAR(128)	NOT NULL
--			Name of the schema of the object (if any) whose wait times are being analyzed
--
--		[ObjectName]			NVARCHAR(128)	NOT NULL
--			Name of the object (if any) whose wait times are being analyzed
--
--		[QueryTextID]			BIGINT			NOT NULL
--			Identifier of the Query Text (when only one is being analyzed) whose wait times are being analyzed
--
--		[QueryText]				VARBINARY(MAX)	NULL
--			Compressed Query Text (when only one is being analyzed) whose wait times are being analyzed
--
--		[Parameters]			XML				NOT NULL
--			List of parameters used to invoke the execution of [dbo].[QueryWaits]
--
-- Date: 2020.10.22
-- Auth: Pablo Lozano (@sqlozano)
--
-- Date: 2021.04.04
-- Auth: Pablo Lozano (@sqlozano)
--			Replaced "server" references to the more accurate term "instance"
--			Script now drops & recreates the table
----------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[QueryWaitsIndex]
CREATE TABLE [dbo].[QueryWaitsIndex]
(
	[ReportID]				BIGINT	IDENTITY(1,1),
	[CaptureDate]			DATETIME2		NOT NULL,
	[InstanceIdentifier]	SYSNAME			NOT NULL,
	[DatabaseName]			SYSNAME			NOT NULL,
	[ObjectID]				BIGINT			NOT NULL,
	[SchemaName]			NVARCHAR(128)	NOT NULL,
	[ObjectName]			NVARCHAR(128)	NOT NULL,
	[QueryTextID]			BIGINT			NOT NULL,
	[QueryText]				VARBINARY(MAX)	NULL,
	[Parameters]			XML				NOT NULL,
) 
ALTER TABLE [dbo].[QueryWaitsIndex]
ADD CONSTRAINT [PK_QueryWaitsIndex] PRIMARY KEY CLUSTERED
(
	 [ReportID]	
)