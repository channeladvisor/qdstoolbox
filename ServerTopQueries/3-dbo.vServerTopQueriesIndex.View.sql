CREATE OR ALTER VIEW [dbo].[vServerTopQueriesIndex]
AS
SELECT
	[ReportID],		
	[CaptureDate],
	[ServerIdentifier],
	[DatabaseName],
	q.n.value('StartTime[1]',			'DATETIME2')		AS [StartTime],  
	q.n.value('EndTime[1]',				'DATETIME2')		AS [EndTime],  
	q.n.value('Top[1]',					'INT')				AS [Top],  
	q.n.value('Measurement[1]',			'NVARCHAR(32)')		AS [Measurement],  
	q.n.value('IncludeQueryText[1]',	'BIT')				AS [IncludeQueryText],  
	q.n.value('ExcludeAdhoc[1]',		'BIT')				AS [ExcludeAdhoc],  
	q.n.value('ExcludeInternal[1]',		'BIT')				AS [ExcludeInternal]
FROM [dbo].[ServerTopQueriesIndex] [stqi]
CROSS APPLY [stqi].[Parameters].nodes('/Root/ServerTopQueriesParameters') AS q(n)
GO