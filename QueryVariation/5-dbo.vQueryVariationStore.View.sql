CREATE OR ALTER VIEW [dbo].[vQueryVariationStore]
AS
SELECT
	[qvi].[ReportID]				,
	[qvi].[CaptureDate]				,
	[qvi].[ServerIdentifier]		,
	[qvi].[DatabaseName]			,
	[qvi].[Measurement]				,
	[qvi].[Metric]					,
	[qvi].[VariationType]			,
	[qvs].[QueryID]					,
	[qvs].[ObjectID]				,
	[qvs].[SchemaName]				,
	[qvs].[ObjectName]				,
	[qvs].[MeasurementChange]		,
	[qvs].[MeasurementRecent]		,
	[qvs].[MeasurementHist]			,
	[qvs].[ExecutionCountRecent]	,
	[qvs].[ExecutionCountHist]		,
	[qvs].[NumPlans]				,
	CAST(DECOMPRESS([qvs].[QuerySqlText]) AS NVARCHAR(MAX))	AS [QuerySqlText]
FROM [dbo].[QueryVariationIndex] [qvi]
INNER JOIN [dbo].[QueryVariationStore] [qvs]
ON [qvi].[ReportID] = [qvs].[ReportID]