CREATE OR ALTER VIEW [dbo].[vQueryVariationStore]
AS
SELECT
	[CaptureDate]			,
	[ServerName]			,
	[DatabaseName]			,
	[Measurement]			,
	[Metric]				,
	[VariationType]			,
	[QueryID]				,
	[ObjectID]				,
	[SchemaName]			,
	[ObjectName]			,
	[MeasurementChange]		,
	[MeasurementRecent]		,
	[MeasurementHist]		,
	[ExecutionCountRecent]	,
	[ExecutionCountHist]	,
	[NumPlans]				,
	CAST(DECOMPRESS([QuerySqlText]) AS NVARCHAR(MAX))	AS [QuerySqlText]
FROM [dbo].[QueryVariationStore]