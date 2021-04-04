----------------------------------------------------------------------------------
-- View Name: [dbo].[vQueryWaitsIndex]
--
-- Desc: This view is built on top of [dbo].[QueryWaitsIndex] to extract the entry parameters used by the executions of [dbo].[QueryWaits]
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
--			Query Text (when only one is being analyzed) whose wait times are being analyzed
--
--		[FullObjectName]		NVARCHAR(256)	NOT NULL
--			Name of the Object (used as an entry parameter)
--
--		[PlanID]				BIGINT			NOT NULL
--			Identifier of the execution plan (used as an entry parameter)
--
--		[QueryID]				BIGINT			NOT NULL
--			Identifier of the query (used as an entry parameter)
--
--		[StartTime]				DATETIME2		NOT NULL
--			Start time of the interval (in UTC)
--
--		[EndTime]				DATETIME2		NOT NULL
--			Start time of the interval (in UTC)
--
--		[IncludeQueryText]		BIT				NOT NULL
--			Flag to include the query text in the report
--
-- Date: 2020.10.22
-- Auth: Pablo Lozano (@sqlozano)
--
-- Date: 2021.04.04
-- Auth: Pablo Lozano (@sqlozano)
--			Replaced "server" references to the more accurate term "instance"
--			Script now drops & recreates the table
----------------------------------------------------------------------------------

CREATE OR ALTER VIEW [dbo].[vQueryWaitsIndex]
AS
SELECT
	 [wdi].[ReportID]
	,[wdi].[CaptureDate]
	,[wdi].[InstanceIdentifier]
	,[wdi].[DatabaseName]
	,[wdi].[ObjectID]
	,[wdi].[SchemaName]
	,[wdi].[ObjectName]
	,[wdi].[QueryTextID]
	,CAST(DECOMPRESS([wdi].[QueryText]) AS NVARCHAR(MAX))		AS [QueryText]
	,[q].[n].value('ObjectName[1]',			'NVARCHAR(256)')	AS [FullObjectName]
	,[q].[n].value('PlanID[1]',				'BIGINT')			AS [PlanID] 
	,[q].[n].value('QueryID[1]',			'BIGINT')			AS [QueryID]
	,[q].[n].value('StartTime[1]',			'DATETIME2')		AS [StartTime]
	,[q].[n].value('EndTime[1]',			'DATETIME2')		AS [EndTime] 
	,[q].[n].value('IncludeQueryText[1]',	'BIT')				AS [IncludeQueryText]
FROM [dbo].[QueryWaitsIndex] [wdi]
CROSS APPLY [wdi].[Parameters].nodes('/Root/WaitDetailsParameters') AS q(n)
GO