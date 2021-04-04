----------------------------------------------------------------------------------
-- View Name: [dbo].[vWaitsVariationIndex]
--
-- Desc: This view is built on top of [dbo].[WaitsVariationIndex] to extract the entry parameters used by the executions of [dbo].[WaitsVariation]
--
-- Columns:
--		[ReportID]				BIGINT			NOT NULL
--			Unique Identifier for the execution (operations not logged to table have no ReportID)
--
--		[ReportDate]			DATETIME2		NOT NULL
--			UTC Date of the execution's start
--
--		[InstanceIdentifier]		SYSNAME			NOT NULL
--			Identifier of the identifier, so if this data is centralized reports originated on each identifier can be properly identified
--
--		[DatabaseName]			SYSNAME			NOT NULL
--			Name of the database this operation was executed against
--
--		[WaitType]				NVARCHAR(16)	NOT NULL
--			Wait Type to analyze
--
--		[Metric]				NVARCHAR(16)	NOT NULL
--			Metric on which to analyze the [WaitType] ('Total', 'Avg')
--
--		[VariationType]			NVARCHAR(1)		NOT NULL
--			Defines whether queries whose wait metrics indicates an improvement (I) or a regression (R)
--
--		[RecentStartTime]		DATETIME2		NOT NULL
--			Start of the time period considered as "recent" to be compared with the "history" time period. Must be expressed in UTC.
--
--		[RecentEndTime]			DATETIME2		NOT NULL
--			End of the time period considered as "recent" to be compared with the "history" time period. Must be expressed in UTC.
--
--		[HistoryStartTime]		DATETIME2		NOT NULL
--			Start of the time period considered as "history" to be compared with the "recent" time period. Must be expressed in UTC.
--
--		[HistoryEndTime]		DATETIME2		NOT NULL
--			End of the time period considered as "history" to be compared with the "recent" time period. Must be expressed in UTC.
--
--		[IncludeQueryText]		BIT				NOT NULL
--			Flag to define whether the text of the query will be returned
--
--		[ExcludeAdhoc]			BIT				NOT NULL
--			Flag to define whether to ignore adhoc queries (not part of a DB object) from the analysis
--
--		[ExcludeInternal]		BIT				NOT NULL
--			Flag to define whether to ignore internal queries (backup, index rebuild, statistics update...) from the analysis
--
-- Date: 2020.10.22
-- Auth: Pablo Lozano (@sqlozano)
--
-- Date: 2021.04.04
-- Auth: Pablo Lozano (@sqlozano)
--			Replaced "server" references to the more accurate term "instance"
----------------------------------------------------------------------------------
CREATE OR ALTER VIEW [dbo].[vWaitsVariationIndex]
AS
SELECT
	 [ReportID]
	,[CaptureDate]
	,[InstanceIdentifier]
	,[DatabaseName]
	,q.n.value('WaitType[1]',			'NVARCHAR(16)')		AS [WaitType]
	,q.n.value('Metric[1]',				'NVARCHAR(16)')		AS [Metric] 
	,q.n.value('VariationType[1]',		'NVARCHAR(1)')		AS [VariationType]
	,q.n.value('RecentStartTime[1]',	'DATETIME2')		AS [RecentStartTime]
	,q.n.value('RecentEndTime[1]',		'DATETIME2')		AS [RecentEndTime]
	,q.n.value('HistoryStartTime[1]',	'DATETIME2')		AS [HistoryStartTime]
	,q.n.value('HistoryEndTime[1]',		'DATETIME2')		AS [HistoryEndTime] 
	,q.n.value('IncludeQueryText[1]',	'BIT')				AS [IncludeQueryText]
	,q.n.value('ExcludeAdhoc[1]',		'BIT')				AS [ExcludeAdhoc]
	,q.n.value('ExcludeInternal[1]',	'BIT')				AS [ExcludeInternal]
FROM [dbo].[WaitsVariationIndex] [wvi]
CROSS APPLY [wvi].[Parameters].nodes('/Root/WaitsVariationParameters') AS q(n)
GO