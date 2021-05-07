----------------------------------------------------------------------------------
-- View Name: [dbo].[vPlanMiner_PlanList]
--
-- Desc: This view is build on top of [dbo].[PlanMiner_PlanList] to extract the index of the execution plans processed by [dbo].[PlanMiner]
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
--		[ExecutionPlan]			XML				NULL
--			Plan mined, decompressed and presented in XML format
--
-- Notes:
--		
--
-- Date: 2021.mm.dd
-- Auth: Pablo Lozano (@sqlozano)
--
----------------------------------------------------------------------------------
CREATE OR ALTER VIEW [dbo].[vPlanMiner_PlanList]
AS
SELECT
	 [PlanMinerID]
	,[MiningType]
	,[InstanceIdentifier]
	,[DatabaseName]
	,[PlanID]
	,[PlanHandle]
	,[PlanFile]
	,TRY_CONVERT(XML, DECOMPRESS([CompressedPlan])) AS [ExecutionPlan]
FROM [dbo].[PlanMiner_PlanList]