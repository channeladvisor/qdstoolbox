----------------------------------------------------------------------------------
-- View Name: [dbo].[vQueryVariationIndex]
--
-- Desc: This view is built on top of [dbo].[QueryVariationIndex] to extract the entry parameters used by the executions of [dbo].[QueryVariation]
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
--		[Measurement]			NVARCHAR(32)
--			Measurement analyzed
--
--		[Metric]				NVARCHAR(16)
--			Metric on which to analyze the [Measurement] values on
--
--		[VariationType]			NVARCHAR(1)
--			Defines whether queries whose metric indicates an improvement (I) or a regression (R)
--
--		[ResultsRowCount]		INT
--			Number of rows to return
--
--		[RecentStartTime]		DATETIME2
--			Start of the time period considered as "recent" to be compared with the "history" time period (in UTC)
--
--		[RecentEndTime]			DATETIME2
--			End of the time period considered as "recent" to be compared with the "history" time period (in UTC)
--
--		[HistoryStartTime]		DATETIME2
--			Start of the time period considered as "history" to be compared with the "recent" time period (in UTC)
--
--		[HistoryEndTime]		DATETIME2
--			End of the time period considered as "history" to be compared with the "recent" time period (in UTC)
--
--		[MinExecCount]			INT
--			Minimum number of executions in the "recent" time period to analyze the query
--
--		[MinPlanCount]			INT
--			Minimum number of different execution plans used by the query to analyze it
--
--		[MaxPlanCount]			INT
--			Maximum number of different execution plans used by the query to analyze it
--
--		[IncludeQueryText]		BIT
--			Flag to define whether the text of the query is stored
--
--		[ExcludeAdhoc]			BIT
--			Flag to define whether to ignore adhoc queries (not part of a DB object) from the analysis
--
--		[ExcludeInternal]		BIT
--			Flag to define whether to ignore internal queries (backup, index rebuild, statistics update...) from the analysis
--
-- Date: 2020.10.22
-- Auth: Pablo Lozano (@sqlozano)
--
-- Date: 2021.04.04
-- Auth: Pablo Lozano (@sqlozano)
--			Replaced "server" references to the more accurate term "instance"
----------------------------------------------------------------------------------

CREATE OR ALTER VIEW [dbo].[vQueryVariationIndex]
AS
SELECT
	 [ReportID]
	,[CaptureDate]
	,[InstanceIdentifier]
	,[DatabaseName]
	,q.n.value('Measurement[1]',		'NVARCHAR(32)')		AS [Measurement]
	,q.n.value('Metric[1]',				'NVARCHAR(16)')		AS [Metric]
	,q.n.value('VariationType[1]',		'NVARCHAR(1)')		AS [VariationType] 
	,q.n.value('ResultsRowCount[1]',	'INT')				AS [ResultsRowCount]  
	,q.n.value('RecentStartTime[1]',	'DATETIME2')		AS [RecentStartTime]
	,q.n.value('RecentEndTime[1]',		'DATETIME2')		AS [RecentEndTime]
	,q.n.value('HistoryStartTime[1]',	'DATETIME2')		AS [HistoryStartTime]
	,q.n.value('HistoryEndTime[1]',		'DATETIME2')		AS [HistoryEndTime]
	,q.n.value('MinExecCount[1]',		'INT')				AS [MinExecCount]  
	,q.n.value('MinPlanCount[1]',		'INT')				AS [MinPlanCount]  
	,q.n.value('MaxPlanCount[1]',		'INT')				AS [MaxPlanCount]
	,q.n.value('IncludeQueryText[1]',	'BIT')				AS [IncludeQueryText]
	,q.n.value('ExcludeAdhoc[1]',		'BIT')				AS [ExcludeAdhoc]
	,q.n.value('ExcludeInternal[1]',	'BIT')				AS [ExcludeInternal]
FROM [dbo].[QueryVariationIndex] [qvi]
CROSS APPLY [qvi].[Parameters].nodes('/Root/QueryVariationParameters') AS q(n)

GO