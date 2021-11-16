----------------------------------------------------------------------------------
-- Table Name: [dbo].[PlanMiner_Columns]
--
-- Desc: This table contains information about the cursor found in the execution plan
--
-- Columns:
--		[PlanMinerID]			BIGINT			NOT NULL
--			Unique identifier of the mined plan
--
--		[StatementID]			INT				NOT NULL
--			Identifier of the statement within the plan the cursor is used in
--			
--		[CursorName]			NVARCHAR(128)	NULL
--			Name of the cursor
---
--		[CursorActualType]		NVARCHAR(128)	NULL
--			Type of cursor generated
--
--		[CursorRequestedType]	NVARCHAR(128)	NULL
--			Type of cursor requested by the query
--
--		[CursorConcurrency]		NVARCHAR(128)	NULL
--			Concurrency of the cursor
--
--		[ForwardOnly]			BIT				NULL
--			Flag to indicate whether the cursor was FORWARD_ONLY
--
-- Date: 2021.05.08
-- Auth: Pablo Lozano (@sqlozano)
--
-- Date: 2021.11.16
-- Auth: Pablo Lozano (@sqlozano)
-- Note: Added [StatementID] column missing in the table definition
--			https://github.com/channeladvisor/qdstoolbox/issues/23
----------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[PlanMiner_Cursors]
CREATE TABLE [dbo].[PlanMiner_Cursors]
(
	 [PlanMinerID]			BIGINT			NOT NULL
	,[StatementID]			INT				NOT NULL
	,[CursorName]			NVARCHAR(128)	NULL
	,[CursorActualType]		NVARCHAR(128)	NULL
	,[CursorRequestedType]	NVARCHAR(128)	NULL
	,[CursorConcurrency]	NVARCHAR(128)	NULL
	,[ForwardOnly]			BIT				NULL
)
ALTER TABLE [dbo].[PlanMiner_Cursors] ADD CONSTRAINT [PK_PlanMiner_Cursors] PRIMARY KEY CLUSTERED 
(
	 [PlanMinerID]	ASC
)