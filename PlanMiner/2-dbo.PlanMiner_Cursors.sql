----------------------------------------------------------------------------------
-- Table Name: [dbo].[PlanMiner_Columns]
--
-- Desc: This table contains information about the cursor found in the execution plan
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
-- Date: 2021.mm.dd
-- Auth: Pablo Lozano (@sqlozano)
--
----------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[PlanMiner_Cursors]
CREATE TABLE [dbo].[PlanMiner_Cursors]
(
	 [ServerIdentifier]		SYSNAME			NOT NULL
	,[DatabaseName]			SYSNAME			NOT NULL
	,[PlanID]				BIGINT			NOT NULL
	,[CursorName]			NVARCHAR(128)	NULL
	,[CursorActualType]		NVARCHAR(128)	NULL
	,[CursorRequestedType]	NVARCHAR(128)	NULL
	,[CursorConcurrency]	NVARCHAR(128)	NULL
	,[ForwardOnly]			BIT				NULL
)
ALTER TABLE [dbo].[PlanMiner_Cursors] ADD CONSTRAINT [PK_PlanMiner_Cursors] PRIMARY KEY CLUSTERED 
(
	 [ServerIdentifier] ASC
	,[DatabaseName]		ASC
	,[PlanID]			ASC
)