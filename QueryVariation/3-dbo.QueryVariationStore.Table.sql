----------------------------------------------------------------------------------
-- Table Name: [dbo].[QueryVariationStore]
--
-- Desc: This table is used by the procedure [dbo].[QueryVariation] to store the details of the Query Variations identified
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
--			Name of the object the [QueryID] is part of (if any)
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
--		[QuerySqlText]			VARBINARY(MAX)	    NULL
--			Query text of the [QueryID] (compressed)
--
-- Date: 2020.10.22
-- Auth: Pablo Lozano (@sqlozano)
--
-- Date: 2021.05.08
-- Auth: Pablo Lozano (@sqlozano)
-- 		Changed script logic to drop & recreate table
----------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[QueryVariationStore]
CREATE TABLE [dbo].[QueryVariationStore]
(
	 [ReportID]					BIGINT			NOT NULL
	,[QueryID]					BIGINT			NOT NULL
	,[ObjectID]					BIGINT			NOT NULL
	,[SchemaName]				SYSNAME			    NULL
	,[ObjectName]				SYSNAME			    NULL
	,[MeasurementChange]		FLOAT			NOT NULL
	,[MeasurementRecent]		FLOAT			NOT NULL
	,[MeasurementHist]			FLOAT			NOT NULL
	,[ExecutionCountRecent]		BIGINT			NOT NULL
	,[ExecutionCountHist]		BIGINT			NOT NULL
	,[NumPlans]					INT				NOT NULL
	,[QuerySqlText]				VARBINARY(MAX)	    NULL
)	
ALTER TABLE [dbo].[QueryVariationStore]
ADD CONSTRAINT [PK_QueryVariationStore] PRIMARY KEY CLUSTERED
(
	  [ReportID]	ASC
	 ,[QueryID]		ASC
)