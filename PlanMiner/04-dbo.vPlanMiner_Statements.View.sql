----------------------------------------------------------------------------------
-- View Name: [dbo].[vPlanMiner_Statements]
--
-- Desc: This view is built on top of [dbo].[vPlanMiner_Statements] to extract the statements' text uncompressed
--
-- Columns:
--		[PlanMinerID]			BIGINT			NOT NULL
--			Unique identifier of the mined plan
--
--		[StatementID]			INT				NOT NULL
--			Unique identifier of the statement within the execution plan
--
--		[StatementCategory]		NVARCHAR(128)	NULL
--			Type of category (Simple, Conditional, Cursor...)
--
--		[StatementType]		NVARCHAR(128)		NULL
--			Type of statement (CREATE TABLE, SELECT, ASSIGN...)
--
--		[StatementText]		NVARCHAR(MAX)		NULL
--			Actual statement (compressed)	
--
-- Notes:
--		
--
-- Date: 2021.mm.dd
-- Auth: Pablo Lozano (@sqlozano)
--
----------------------------------------------------------------------------------
CREATE OR ALTER VIEW [dbo].[vPlanMiner_Statements]
AS
SELECT
	 [PlanMinerID]
	,[StatementID]
	,[StatementCategory]
	,[StatementType]
	,CAST(DECOMPRESS([CompressedText]) AS NVARCHAR(MAX)) AS [StatementText]
FROM [dbo].[PlanMiner_Statements]