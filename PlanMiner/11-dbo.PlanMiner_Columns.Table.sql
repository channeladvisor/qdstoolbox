----------------------------------------------------------------------------------
-- Table Name: [dbo].[PlanMiner_Columns]
--
-- Desc: This table contains the list of columns accessed with a certain execution plan on each of its operations (nodes)
--
-- Columns:
--		[PlanMinerID]			BIGINT			NOT NULL
--			Unique identifier of the mined plan
--			
--		[StatementID]			INT				NOT NULL
--			Identifier of the statement that accessed the columns
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
-- Date: 2021.05.08
-- Auth: Pablo Lozano (@sqlozano)
--
----------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[PlanMiner_Columns]
CREATE TABLE [dbo].[PlanMiner_Columns]
(
	 [PlanMinerID]		BIGINT			NOT NULL
	,[StatementID]		INT				NOT NULL
	,[NodeID]			INT				NOT NULL
	,[DatabaseNamePlan]	NVARCHAR(128)	NULL
	,[SchemaName]		NVARCHAR(128)	NULL
	,[TableName]		NVARCHAR(128)	NULL
	,[ColumnName]		NVARCHAR(128)	NOT NULL
)
CREATE CLUSTERED INDEX [CIX_PlanMiner_Columns] ON [dbo].[PlanMiner_Columns]
(
	 [PlanMinerID]	ASC
	,[StatementID]	ASC
	,[NodeID]		ASC
)