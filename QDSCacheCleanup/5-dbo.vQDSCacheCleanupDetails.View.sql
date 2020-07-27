CREATE OR ALTER VIEW [dbo].[vQDSCacheCleanupDetails]
AS
SELECT
	 [ReportID]		
	,[QueryType]		
	,[ObjectName]	
	,[QueryID]		
	,[LastExecutionTime]
	,[ExecutionCount]
	,CAST(DECOMPRESS([QueryText]) AS NVARCHAR(MAX)) AS [QueryText]
FROM [dbo].[QDSCacheCleanupDetails]