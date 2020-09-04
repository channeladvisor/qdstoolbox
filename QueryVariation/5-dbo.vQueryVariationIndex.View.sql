CREATE OR ALTER VIEW [dbo].[vQueryVariationIndex]
AS
SELECT
	[ReportID],		
	[CaptureDate],
	[ServerIdentifier],
	[DatabaseName],
	q.n.value('Measurement[1]',			'NVARCHAR(32)')		AS [Measurement],  
	q.n.value('Metric[1]',				'NVARCHAR(16)')		AS [Metric],  
	q.n.value('VariationType[1]',		'NVARCHAR(1)')		AS [VariationType],  
	q.n.value('ResultsRowCount[1]',		'INT')				AS [ResultsRowCount],  
	q.n.value('RecentStartTime[1]',		'DATETIME2')		AS [RecentStartTime],  
	q.n.value('RecentEndTime[1]',		'DATETIME2')		AS [RecentEndTime],  
	q.n.value('HistoryStartTime[1]',	'DATETIME2')		AS [HistoryStartTime],  
	q.n.value('HistoryEndTime[1]',		'DATETIME2')		AS [HistoryEndTime],  
	q.n.value('MinExecCount[1]',		'INT')				AS [MinExecCount],  
	q.n.value('MinPlanCount[1]',		'INT')				AS [MinPlanCount],  
	q.n.value('MaxPlanCount[1]',		'INT')				AS [MaxPlanCount],  
	q.n.value('IncludeQueryText[1]',	'BIT')				AS [IncludeQueryText],  
	q.n.value('ExcludeAdhoc[1]',		'BIT')				AS [ExcludeAdhoc],  
	q.n.value('ExcludeInternal[1]',		'BIT')				AS [ExcludeInternal]
FROM [dbo].[QueryVariationIndex] [qvi]
CROSS APPLY [qvi].[Parameters].nodes('/Root/QueryVariationParameters') AS q(n)

GO