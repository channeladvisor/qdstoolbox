----------------------------------------------------------------------------------
-- Table Name: [dbo].[PlanMiner_IndexOperations]
--
-- Desc: This table contains information about the index operations (scan, seek, update, delete...) performed in
--			an operation (node) in the execution plan mined out
--
-- Columns:
--		[PlanMinerID]			BIGINT			NOT NULL
--			Unique identifier of the mined plan
--			
--		[NodeID]				INT				NOT NULL
--			Identifier of the operation (node) this index operation takes place
--
--		[DatabaseNamePlan]		NVARCHAR(128)	NULL
--			Name of the database the index belongs to
--
--		[SchemaName]			NVARCHAR(128)	NULL
--			Name of the schema the index belongs to
--
--		[TableName]				NVARCHAR(128)	NULL
--			Name of the table the index belongs to
--
--		[IndexName]				NVARCHAR(128)	NULL
--			Name of the index used in this operation (node)
--
--		[IndexKind]				NVARCHAR(128)	NULL
--			Type of index
--
--		[Ordered]				BIT				NULL
--			Flag to define whether the index ordering
--
--		[LogicalOp]				NVARCHAR(128)	NULL
--			Local operation performed in the operation (node)
--
--		[ForcedIndex]			BIT				NULL
--			Flag to determine whether this index was forced
--
--		[ForceSeek]				BIT				NULL
--			Flag to determine whether this index operation is a forced seek one
--
--		[ForceScan]				BIT				NULL
--			Flag to determine whether this index operation is a forced scan one
--
--		[NoExpandHint]			BIT				NULL
--			Flag to determine whether the NOEXPAND hint was used
--
--		[Storage]				NVARCHAR(128)	NULL
--
-- Notes:
--		When using table variables or temp tables, [SchemaName] and [TableName] will contain NULL values
--
-- Date: 2021.mm.dd
-- Auth: Pablo Lozano (@sqlozano)
--
----------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[PlanMiner_IndexOperations]
CREATE TABLE [dbo].[PlanMiner_IndexOperations]
(
	 [PlanMinerID]			BIGINT			NOT NULL
	,[NodeID]				INT				NOT NULL
	,[DatabaseNamePlan]		NVARCHAR(128)	NULL
	,[SchemaName]			NVARCHAR(128)	NULL
	,[TableName]			NVARCHAR(128)	NULL
	,[IndexName]			NVARCHAR(128)	NULL
	,[IndexKind]			NVARCHAR(128)	NULL
	,[LogicalOp]			NVARCHAR(128)	NULL
	,[Ordered]				BIT				NULL
	,[ForcedIndex]			BIT				NULL
	,[ForceSeek]			BIT				NULL
	,[ForceScan]			BIT				NULL
	,[NoExpandHint]			BIT				NULL
	,[Storage]				NVARCHAR(128)	NULL
)
ALTER TABLE [dbo].[PlanMiner_IndexOperations] ADD CONSTRAINT [PK_PlanMiner_IndexOperations] PRIMARY KEY CLUSTERED 
(
	 [PlanMinerID]	ASC
	,[NodeID]		ASC
)