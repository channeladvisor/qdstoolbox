----------------------------------------------------------------------------------
-- Table Name: [dbo].[PlanMiner_Nodes]
--
-- Desc: This table contains the details of each node (operation) of the execution plan
--
-- Columns:
--		[PlanMinerID]			BIGINT			NOT NULL
--			Unique identifier of the mined plan
--			
--		[CursorOperationType]			NVARCHAR(16)	NOT NULL
--			Type of cursor operation being executed (when applicable)
--
--		[NodeID]						INT				NOT NULL
--			Identifier of the node of the execution plan whose details are described
--
--		[Depth]							INT				NOT NULL
--			Depth of the node in the complete plan
--
--		[PhysicalOp]					NVARCHAR(128)	NOT NULL
--			Physical operation performed in the node
--
--		[LogicalOp]						NVARCHAR(128)	NOT NULL
--			Logical operation performed in the node
--
--		[EstimateRows]					FLOAT			NOT NULL
--			Estimated rows accessed in the node (read/write)
--
--		[EstimatedRowsRead]				FLOAT			NULL
--			Estimated rows read in the node (when applicable)
--
--		[EstimateIO]					FLOAT			NOT NULL
--			Estimated IO cost of the node's activity
--
--		[EstimateCPU]					FLOAT			NOT NULL
--			Estimated CPU cost of the node's activity
--
--		[AvgRowSize]					FLOAT			NOT NULL
--			Average size of the row accessed in the node's activity (when applicable)
--
--		[EstimatedTotalSubtreeCost]		FLOAT			NOT NULL
--			Estimated total cost of this node's subtree
--
--		[TableCardinality]				FLOAT			NULL
--			Cardinality of the table accessed in this node's activity (when applicable)
--
--		[Parallel]						BIT			NULL
--			Flag to indicate whether this node's activity was performed in parallel
--
--		[EstimateRebinds]				FLOAT			NOT NULL
--			Estimated rebinds to be executed in this node's activity (when applicable)
--
--		[EstimateRewinds]				FLOAT			NOT NULL
--			Estimated rewinds to be executed in this node's activity (when applicable)
--
--		[EstimatedExecutionMode]		NVARCHAR(128)	NOT NULL
--			Estimated execution mode used for this node's activity
--
--
-- Date: 2021.mm.dd
-- Auth: Pablo Lozano (@sqlozano)
--
----------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[PlanMiner_Nodes]
CREATE TABLE [dbo].[PlanMiner_Nodes]
(
	 [PlanMinerID]					BIGINT			NOT NULL
	,[CursorOperationType]			NVARCHAR(16)	NOT NULL
	,[NodeID]						INT				NOT NULL
	,[Depth]						INT				NOT NULL
	,[PhysicalOp]					NVARCHAR(128)	NOT NULL
	,[LogicalOp]					NVARCHAR(128)	NOT NULL
	,[EstimateRows]					FLOAT			NOT NULL
	,[EstimatedRowsRead]			FLOAT			NULL
	,[EstimateIO]					FLOAT			NOT NULL
	,[EstimateCPU]					FLOAT			NOT NULL
	,[AvgRowSize]					FLOAT			NOT NULL
	,[EstimatedTotalSubtreeCost]	FLOAT			NOT NULL
	,[TableCardinality]				FLOAT			NULL
	,[Parallel]						FLOAT			NOT NULL
	,[EstimateRebinds]				FLOAT			NOT NULL
	,[EstimateRewinds]				FLOAT			NOT NULL
	,[EstimatedExecutionMode]		NVARCHAR(128)	NOT NULL
)
ALTER TABLE [dbo].[PlanMiner_Nodes] ADD CONSTRAINT [PK_PlanMiner_Nodes] PRIMARY KEY CLUSTERED 
(
	 [PlanMinerID]	ASC
	,[NodeID]		ASC
)