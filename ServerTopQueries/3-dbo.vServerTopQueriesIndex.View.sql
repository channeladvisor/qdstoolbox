----------------------------------------------------------------------------------
-- View Name: [dbo].[vServerTopQueriesIndex]
--
-- Desc: This view is built on top of [dbo].[ServerTopQueriesIndex] to extract the entry parameters used by the executions of [dbo].[ServerTopQueries]
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
--		[IncludeQueryText]		BIT				NOT NULL
--			Flag to include the Query Text in the results generated
--
--		[ExcludeAdhoc]			BIT				NOT NULL
--			Flag to exclude adhoc queries (not beloging to any database object)
--
--		[ExcludeInternal]		BIT				NOT NULL
--			Flag to exclude internal queries (UPDATE STATISTICS, INDEX REBUILD....)
--
--		[AggregateAll]			BIT				NOT NULL
--			Flag to determine whether all query executions are aggregated
--
--		[AggregateNonRegular]	BIT				NOT NULL
--			Flag to determine whether all query executions that didn't have a "regular" exit are aggregated together
--
--
-- Date: 2020.10.22
-- Auth: Pablo Lozano (@sqlozano)
--
-- Date: 2021.08.19
-- Auth: Pablo Lozano (@sqlozano)
-- Changes: Added new parameters: @ExecutionRegular, @ExecutionAborted, @ExecutionException, @AggregateAll, @AggregateNonRegular
--
-- Date: 2021.08.25
-- Auth: Pablo Lozano (@sqlozano)
-- Changes: Removed parameters: @ExecutionRegular, @ExecutionAborted, @ExecutionException after removing them from the procedure
--
-- Date: 2021.10.15
-- Auth: Pablo Lozano (@sqlozano)
-- Changes: Added parameter: @Percentages
--
-- Date: 2022.10.19
-- Auth: Pablo Lozano (@sqlozano)
-- Changes: Added missing description for the columns: [AggregateAll], [AggregateNonRegular]
----------------------------------------------------------------------------------

CREATE OR ALTER VIEW [dbo].[vServerTopQueriesIndex]
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
	,q.n.value('IncludeQueryText[1]',	'BIT')				AS [IncludeQueryText]
	,q.n.value('ExcludeAdhoc[1]',		'BIT')				AS [ExcludeAdhoc]
	,q.n.value('ExcludeInternal[1]',	'BIT')				AS [ExcludeInternal]
	,q.n.value('AggregateAll[1]',		'BIT')				AS [AggregateAll]
	,q.n.value('AggregateNonRegular[1]','BIT')				AS [AggregateNonRegular]
FROM [dbo].[ServerTopQueriesIndex] [stqi]
CROSS APPLY [stqi].[Parameters].nodes('/Root/ServerTopQueriesParameters') AS q(n)
GO