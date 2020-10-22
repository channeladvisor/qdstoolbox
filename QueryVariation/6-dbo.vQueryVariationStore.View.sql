----------------------------------------------------------------------------------
-- View Name: [dbo].[vQueryVariationIndex]
--
-- Desc: This view is built on top of [dbo].[QueryVariationIndex] to extract the entry parameters used by the executions of [dbo].[QueryVariation]
--
-- Columns:
--		[ReportID]				BIGINT			NOT NULL
--			Unique Identifier for the execution (operations not logged to table have no ReportID)
--
--		[QueryID]				BIGINT			NOT NULL
--			Query Identifier of the query with a query variation
--
--		[ObjectID]				BIGINT			NOT NULL
--			Object Identifier the [QueryID] is part of (if any)
--
--		[SchemaName]			SYSNAME			    NULL
--			Name of the schema of the object the [QueryID] is part of (if any)
--
--		[ObjectName]			SYSNAME			    NULL
--			Name of the objectthe [QueryID] is part of (if any)
--
--		[Measurement]			NVARCHAR(32)	NOT NULL
--			Measurement to analyze the variation from (CPU, Duration, Log...)
--
--		[Metric]				NVARCHAR(16)	NOT NULL
--			Metric to analyze the [Measurement] on (Avg, Total, Max...)
--
--		[Unit]					NVARCHAR(32)	NOT NULL
--			Unit the measurement & metric is specified (microseconds, %, KBs...)
--
--		[MeasurementChange]		FLOAT			NOT NULL
--			Amount of measurement
--
--		[MeasurementRecent]		FLOAT			NOT NULL
--			Value of the measurement in the Recent time period
--
--		[MeasurementHist]		FLOAT			NOT NULL
--			Value of the measurement in the History time period
--
--		[ExecutionCountRecent]	BIGINT			NOT NULL
--			Number of executions of the [QueryID] executed in the Recent time period
--
--		[ExecutionCountHist]	BIGINT			NOT NULL
--			Number of executions of the [QueryID] executed in the History time period
--
--		[NumPlans]				INT				NOT NULL
--			Number of different execution plans found for the [QueryID]
--
--		[QuerySqlText]			NVARCHAR(MAX)	    NULL
--			Query text of the [QueryID]
--
-- Date: 2020.10.22
-- Auth: Pablo Lozano (@sqlozano)
--
----------------------------------------------------------------------------------

CREATE OR ALTER VIEW [dbo].[vQueryVariationStore]
AS
SELECT
	 [qvs].[ReportID]			
	,[qvs].[QueryID]			
	,[qvs].[ObjectID]			
	,[qvs].[SchemaName]			
	,[qvs].[ObjectName]			
	,[ma].[Measurement]			
	,[ma].[Metric]				
	,[ma].[Unit]				
	,[qvs].[MeasurementChange]	
	,[qvs].[MeasurementRecent]	
	,[qvs].[MeasurementHist]	
	,[qvs].[ExecutionCountRecent]
	,[qvs].[ExecutionCountHist]	
	,[qvs].[NumPlans]			
	,CAST(DECOMPRESS([qvs].[QuerySqlText]) AS NVARCHAR(MAX))	AS [QuerySqlText]
FROM [dbo].[QueryVariationStore] [qvs]
INNER JOIN [dbo].[vQueryVariationIndex] [qvi]
ON [qvs].[ReportID] = [qvi].[ReportID]
INNER JOIN [dbo].[QDSMetricArchive] [ma]
ON [qvi].[Measurement] = [ma].[Measurement]
AND [qvi].[Metric] = [ma].[Metric]