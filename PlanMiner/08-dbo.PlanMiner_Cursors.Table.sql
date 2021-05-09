----------------------------------------------------------------------------------
-- Table Name: [dbo].[PlanMiner_Columns]
--
-- Desc: This table contains information about the cursor found in the execution plan
--
-- Columns:
--		[PlanMinerID]			BIGINT			NOT NULL
--			Unique identifier of the mined plan
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
----------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[PlanMiner_Cursors]
CREATE TABLE [dbo].[PlanMiner_Cursors]
(
	 [PlanMinerID]			BIGINT			NOT NULL
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