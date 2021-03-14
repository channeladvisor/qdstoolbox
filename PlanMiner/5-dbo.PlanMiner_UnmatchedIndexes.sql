----------------------------------------------------------------------------------
-- Table Name: [dbo].[PlanMiner_UnmatchedIndexes]
--
-- Desc: This table contains information about the filtered indexes not used due to the parameters in the WHERE clause
--			not matching those in the indexes
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
--			Name of the database where the unmatched index is found
--
--		[SchemaName]			NVARCHAR(128)	NULL
--			Name of the schema where the unmatched index is found
--
--		[TableName]				NVARCHAR(128)	NULL
--			Name of the table where the unmatched index is found
--
--		[UnmatchedIndexName]	NVARCHAR(128)	NULL
--			Name of the index not used due to it not matching the specific parameters used in the WHERE clause
--
-- Date: 2021.mm.dd
-- Auth: Pablo Lozano (@sqlozano)
--
----------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[PlanMiner_UnmatchedIndexes]
CREATE TABLE [dbo].[PlanMiner_UnmatchedIndexes]
(
	 [ServerIdentifier]		SYSNAME			NOT NULL
	,[DatabaseName]			SYSNAME			NOT NULL
	,[PlanID]				BIGINT			NOT NULL
	,[DatabaseNamePlan]		NVARCHAR(128)	NULL
	,[SchemaName]			NVARCHAR(128)	NULL
	,[TableName]			NVARCHAR(128)	NULL
	,[UnmatchedIndexName]	NVARCHAR(128)	NULL
)
CREATE CLUSTERED INDEX [CIX_PlanMiner_UnmatchedIndexes] ON [dbo].[PlanMiner_UnmatchedIndexes]
(
	 [ServerIdentifier]	ASC
	,[DatabaseName]		ASC
	,[PlanID]			ASC
)
