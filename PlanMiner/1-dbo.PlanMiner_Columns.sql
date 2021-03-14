----------------------------------------------------------------------------------
-- Table Name: [dbo].[PlanMiner_Columns]
--
-- Desc: This table contains the list of columns accessed with a certain execution plan on each of its operations (nodes)
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
--		[NodeID]				INT				NOT NULL
--			Node of the execution plan the columns are accessed in
--
--		[DatabaseNamePlan]		NVARCHAR(128)	NULL
--			Name of the database the accessed column belongs to (when applicable)
--
--		[SchemaName]			NVARCHAR(128)	NULL
--			Name of the schema the accessed column belongs to (when applicable)
--
--		[TableName]				NVARCHAR(128)	NULL
--			Name of the table the accessed column belongs to (when applicable)
--
--		[ColumnName]			NVARCHAR(128)	NULL
--			Name of the column accessed
--
-- Notes:
--		When using table variables, [SchemaName] and [TableName] will contain NULL values
--
-- Date: 2021.mm.dd
-- Auth: Pablo Lozano (@sqlozano)
--
----------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[PlanMiner_Columns]
CREATE TABLE [dbo].[PlanMiner_Columns]
(
	 [ServerIdentifier]	SYSNAME			NOT NULL
	,[DatabaseName]		SYSNAME			NOT NULL
	,[PlanID]			BIGINT			NOT NULL
	,[NodeID]			INT				NOT NULL
	,[DatabaseNamePlan]	NVARCHAR(128)	NULL
	,[SchemaName]		NVARCHAR(128)	NULL
	,[TableName]		NVARCHAR(128)	NULL
	,[ColumnName]		NVARCHAR(128)	NOT NULL
)
CREATE CLUSTERED INDEX [CIX_PlanMiner_Columns] ON [dbo].[PlanMiner_Columns]
(
	 [ServerIdentifier]	ASC
	,[DatabaseName]		ASC
	,[PlanID]			ASC
	,[NodeID]			ASC
)