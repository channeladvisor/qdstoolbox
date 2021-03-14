----------------------------------------------------------------------------------
-- Table Name: [dbo].[PlanMiner_Statistics]
--
-- Desc: This table contains the list of statistics used by the SQL Engine to elaborate this execution plan
--
-- Columns:
--		[ServerIdentifier]		SYSNAME			NOT NULL
--			Identifier of the server, so if this data is centralized reports originated on each server can be properly identified
--
--		[DatabaseName]			SYSNAME			NOT NULL
--			Name of the database this plan's information has been mined out
--
--		[PlanID]				BIGINT			NOT NULL
--			Identifier of the plan this information has been mined out
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
-- Date: 2021.mm.dd
-- Auth: Pablo Lozano (@sqlozano)
--
----------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[PlanMiner_Statistics]
CREATE TABLE [dbo].[PlanMiner_Statistics]
(
	 [ServerIdentifier]		SYSNAME			NOT NULL
	,[DatabaseName]			SYSNAME			NOT NULL
	,[PlanID]				BIGINT			NOT NULL
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
	 [ServerIdentifier]		ASC
	,[DatabaseName]			ASC
	,[PlanID]				ASC
)
CREATE NONCLUSTERED INDEX [NCIX_PlanMiner_Statistics] ON [dbo].[PlanMiner_Statistics]
(
	 [ServerIdentifier]	ASC
	,[DatabaseName]		ASC
	,[PlanID]			ASC
	,[DatabaseNamePlan]	ASC
	,[SchemaName]		ASC
	,[TableName]		ASC
)