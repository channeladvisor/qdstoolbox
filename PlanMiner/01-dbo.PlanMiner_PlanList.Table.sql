----------------------------------------------------------------------------------
-- Table Name: [dbo].[PlanMiner_PlanList]
--
-- Desc: This table contains the list plans mined, and the details on where it was mined from
--
-- Columns:
--		[PlanMinerID]			BIGINT			NOT NULL
--			Unique identifier of the mined plan
--
--		[MiningType]			NVARCHAR(16)	NULL
--			Description on where the plan was mined from:
--				QueryStore
--				Cache
--				File
--
--		[InstanceIdentifier]	SYSNAME			NULL
--			Identifier of the instance, so if this data is centralized reports originated on each server can be properly identified
--
--		[DatabaseName]			SYSNAME			NULL
--			Name of the database this plan's information has been mined out
--
--		[PlanID]				BIGINT			NULL
--			Identifier of the plan this information has been mined out
--			
--		[PlanHandle]			VARBINARY(64)	NULL
--			Handle of the plan mined
--
--		[CompressedPlan]		VARBINARY(MAX)	NULL
--			Plan mined, in a compressed format
--
-- Notes:
--		
--
-- Date: 2021.05.08
-- Auth: Pablo Lozano (@sqlozano)
--
----------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[PlanMiner_PlanList]
CREATE TABLE [dbo].[PlanMiner_PlanList]
(
	 [PlanMinerID]			BIGINT			IDENTITY(1,1)
	,[MiningType]			NVARCHAR(16)	NULL
	,[InstanceIdentifier]	SYSNAME			NULL
	,[DatabaseName]			SYSNAME			NULL
	,[PlanID]				BIGINT			NULL
	,[PlanHandle]			VARBINARY(64)	NULL
	,[PlanFile]				NVARCHAR(MAX)	NULL
	,[CompressedPlan]		VARBINARY(MAX)	NULL
)
CREATE CLUSTERED INDEX [CIX_PlanMiner_Columns] ON [dbo].[PlanMiner_PlanList]
(
	 [PlanMinerID]	ASC
)