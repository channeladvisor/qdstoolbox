CREATE OR ALTER VIEW [dbo].[vWaitsVariationIndex]
AS
SELECT
	[ReportID],		
	[CaptureDate],
	[ServerIdentifier],
	[DatabaseName],
	q.n.value('WaitType[1]',			'NVARCHAR(16)')		AS [WaitType],  
	q.n.value('Metric[1]',				'NVARCHAR(16)')		AS [Metric],  
	q.n.value('VariationType[1]',		'NVARCHAR(1)')		AS [VariationType],
	q.n.value('RecentStartTime[1]',		'DATETIME2')		AS [RecentStartTime],  
	q.n.value('RecentEndTime[1]',		'DATETIME2')		AS [RecentEndTime],  
	q.n.value('HistoryStartTime[1]',	'DATETIME2')		AS [HistoryStartTime],  
	q.n.value('HistoryEndTime[1]',		'DATETIME2')		AS [HistoryEndTime],  
	q.n.value('IncludeQueryText[1]',	'BIT')				AS [IncludeQueryText],  
	q.n.value('ExcludeAdhoc[1]',		'BIT')				AS [ExcludeAdhoc],  
	q.n.value('ExcludeInternal[1]',		'BIT')				AS [ExcludeInternal]
FROM [dbo].[WaitsVariationIndex] [wvi]
CROSS APPLY [wvi].[Parameters].nodes('/Root/WaitsVariationParameters') AS q(n)
GO