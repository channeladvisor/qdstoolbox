----------------------------------------------------------------------------------
-- Table Name: [dbo].[PlanMiner_Statistics]
--
-- Desc: This table contains the list of statistics used by the SQL Engine to elaborate this execution plan
--
-- Columns:
--		[PlanMinerID]			BIGINT			NOT NULL
--			Unique identifier of the mined plan
--
--		[StatementID]			INT				NOT NULL
--			Identifier of the statement that required the analysis of this statistics
--
--		[DatabaseNamePlan]		NVARCHAR(128)	NULL
--			Name of the database the used statistics column belongs to (when applicable)
--			
--		[SchemaName]			NVARCHAR(128)	NULL
--			Name of the schema the used statistics column belongs to (when applicable)
--
--		[TableName]				NVARCHAR(128)	NULL
--			Name of the table the used statistics column belongs to (when applicable)
--
--		[ColumnName]			NVARCHAR(128)	NULL
--			Name of the column statistics used for the calculations
--
--		[ModificationCount]		BIGINT			NULL
--			Number of modified rows since the statistics were last updated
--
--		[SamplingPercent]		FLOAT			NULL
--			Percent of rows used for the sampling of the statistics in their last update
--
--		[LastUpdate]			DATETIME2(7)	NULL
--			Last time an update of the statistcs tooks place
--
-- Notes:
--		When using table variables, [SchemaName] and [TableName] will contain NULL values
--
-- Date: 2021.05.08
-- Auth: Pablo Lozano (@sqlozano)
--
----------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[PlanMiner_Statistics]
CREATE TABLE [dbo].[PlanMiner_Statistics]
(
	 [PlanMinerID]			BIGINT			NOT NULL
	,[StatementID]			INT				NOT NULL
	,[DatabaseNamePlan]		NVARCHAR(128)	NULL
	,[SchemaName]			NVARCHAR(128)	NULL
	,[TableName]			NVARCHAR(128)	NULL
	,[StatisticName]		NVARCHAR(128)	NULL
	,[ModificationCount]	BIGINT			NULL
	,[SamplingPercent]		FLOAT			NULL
	,[LastUpdate]			DATETIME2(7)	NULL
)
CREATE CLUSTERED INDEX [CIX_PlanMiner_Statistics] ON [dbo].[PlanMiner_Statistics]
(
	 [PlanMinerID]		ASC
)
CREATE NONCLUSTERED INDEX [NCIX_PlanMiner_Statistics] ON [dbo].[PlanMiner_Statistics]
(
	 [PlanMinerID]		ASC
	,[StatementID]		ASC
	,[DatabaseNamePlan]	ASC
	,[SchemaName]		ASC
	,[TableName]		ASC
)