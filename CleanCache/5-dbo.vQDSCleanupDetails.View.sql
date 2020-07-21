CREATE OR ALTER VIEW [dbo].[vQDSCleanupDetails]
AS
SELECT
	 [ReportID]		
	,[QueryType]		
	,[ObjectName]	
	,[QueryID]		
	,[LastExecutionTime]
	,[ExecutionCount]
	,CAST(DECOMPRESS([QueryText]) AS NVARCHAR(MAX)) AS [QueryText]
FROM [dbo].[QDSCleanupDetails]