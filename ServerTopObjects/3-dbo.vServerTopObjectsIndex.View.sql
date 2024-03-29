----------------------------------------------------------------------------------
-- View Name: [dbo].[vServerTopObjectsIndex]
--
-- Desc: This view is built on top of [dbo].[ServerTopObjectsIndex] to extract the entry parameters used by the executions of [dbo].[ServerTopObjects]
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
--		[StartTime]				DATETIME2		NOT NULL
--			Start time of the period being analyzed
--
--		[EndTime]				DATETIME2		NOT NULL
--			End time of the period being analyzed
--
--		[Top]					IN				NOT NULL
--			Maximum number of queries to be extracted from each database selected
--		
--		[Measurement]			NVARCHAR(32)	NOT NULL
--			Measurement to order the queries on
--
--		[Percentages]			BIT				NOT NULL
--			Flag to determine whether the values are "percentages"
--			When enabled, the [Measurement] values will go from 0 to 100000 (equivalent to 0% to 100%)
--
--		[AggregateAll]			BIT				NOT NULL
--			Flag to determine whether all query executions are aggregated
--
--		[AggregateNonRegular]	BIT				NOT NULL
--			Flag to determine whether all query executions that didn't have a "regular" exit are aggregated together
--
--		[IncludeAdhocQueryIDs]	BIT				NOT NULL
--			Flag to determine the Adhoc Queries are considered for the report
--
--		[IncludeObjectQueryIDs]	BIT				NOT NULL
--			Flag to determine whether the individual queries of the Object (or the totality of the Adhoc queries) are included in the report
--
--
-- Date: 2022.10.18
-- Auth: Pablo Lozano (@sqlozano)
-- Desc: Created based on [dbo].[vServerTopQueriesIndex]
--
-- Date: 2022.10.19
-- Auth: Pablo Lozano (@sqlozano)
-- Changes: Added missing description for the columns: [AggregateAll], [AggregateNonRegular]
--			Added columns for new parameters: [IncludeAdhocQueryIDs], [IncludeObjectQueryIDs]
----------------------------------------------------------------------------------

CREATE OR ALTER VIEW [dbo].[vServerTopObjectsIndex]
AS
SELECT
	 [ReportID]
	,[CaptureDate]
	,[ServerIdentifier]
	,[DatabaseName]
	,q.n.value('StartTime[1]',			'DATETIME2')		AS [StartTime]
	,q.n.value('EndTime[1]',			'DATETIME2')		AS [EndTime] 
	,q.n.value('Top[1]',				'INT')				AS [Top]
	,q.n.value('Measurement[1]',		'NVARCHAR(32)')		AS [Measurement]
	,q.n.value('Percentages[1]',		'BIT')				AS [Percentages]
	,q.n.value('AggregateAll[1]',		'BIT')				AS [AggregateAll]
	,q.n.value('AggregateNonRegular[1]','BIT')				AS [AggregateNonRegular]
	,q.n.value('IncludeAdhocQueryIDs[1]','BIT')				AS [IncludeAdhocQueryIDs]
	,q.n.value('IncludeObjectQueryIDs[1]','BIT')			AS [IncludeObjectQueryIDs]
FROM [dbo].[ServerTopObjectsIndex] [stoi]
CROSS APPLY [stoi].[Parameters].nodes('/Root/ServerTopObjectsParameters') AS q(n)
GO