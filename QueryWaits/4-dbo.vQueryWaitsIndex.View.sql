USE [DBA]
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [DBE].[vQueryWaitsIndex]
AS
SELECT
	 [wdi].[ReportID]
	,[wdi].[CaptureDate]
	,[wdi].[ServerIdentifier]
	,[wdi].[DatabaseName]
	,[wdi].[ObjectID]
	,[wdi].[SchemaName]
	,[wdi].[ObjectName]
	,[wdi].[QueryTextID]
	,CAST(DECOMPRESS([wdi].[QueryText]) AS NVARCHAR(MAX)) as [QueryText]
	,[q].[n].value('ObjectName[1]',			'NVARCHAR(256)')	AS [FullObjectName]
	,[q].[n].value('PlanID[1]',				'BIGINT')			AS [PlanID] 
	,[q].[n].value('QueryID[1]',				'BIGINT')			AS [QueryID]
	,[q].[n].value('StartTime[1]',			'DATETIME2')		AS [RecentStartTime]
	,[q].[n].value('EndTime[1]',				'DATETIME2')		AS [RecentEndTime] 
	,[q].[n].value('IncludeQueryText[1]',	'BIT')				AS [IncludeQueryText]
FROM [DBE].[QueryWaitsIndex] [wdi]
CROSS APPLY [wdi].[Parameters].nodes('/Root/WaitDetailsParameters') AS q(n)
GO