CREATE OR ALTER VIEW [dbo].[vQueryVariationStore]
AS
SELECT
	[qvs].[ReportID]				,
	[qvs].[QueryID]					,
	[qvs].[ObjectID]				,
	[qvs].[SchemaName]				,
	[qvs].[ObjectName]				,
	[ma].[Measurement]				,
	[ma].[Metric]					,
	[ma].[Unit]						,
	[qvs].[MeasurementChange]		,
	[qvs].[MeasurementRecent]		,
	[qvs].[MeasurementHist]			,
	[qvs].[ExecutionCountRecent]	,
	[qvs].[ExecutionCountHist]		,
	[qvs].[NumPlans]				,
	CAST(DECOMPRESS([qvs].[QuerySqlText]) AS NVARCHAR(MAX))	AS [QuerySqlText]
FROM [dbo].[QueryVariationStore] [qvs]
INNER JOIN [dbo].[vQueryVariationIndex] [qvi]
ON [qvs].[ReportID] = [qvi].[ReportID]
INNER JOIN [dbo].[QDSMetricArchive] [ma]
ON [qvi].[Measurement] = [ma].[Measurement]
AND [qvi].[Metric] = [ma].[Metric]