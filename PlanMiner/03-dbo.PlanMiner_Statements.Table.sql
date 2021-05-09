----------------------------------------------------------------------------------
-- Table Name: [dbo].[PlanMiner_Statements]
--
-- Desc: This table contains information regarding the statements included in the mined plan
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
--		[CompressedText]		VARBINARY(MAX)	NULL
--			Actual statement (compressed)	
--
-- Notes:
--		
--
-- Date: 2021.05.08
-- Auth: Pablo Lozano (@sqlozano)
--
----------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[PlanMiner_Statements]
CREATE TABLE [dbo].[PlanMiner_Statements]
(
	 [PlanMinerID]			BIGINT			NOT NULL
	,[StatementID]			INT				NOT NULL
	,[StatementCategory]	NVARCHAR(128)	NOT NULL
	,[StatementType]		NVARCHAR(128)	NOT NULL
	,[CompressedText]		VARBINARY(MAX)	NULL
)
CREATE CLUSTERED INDEX [CIX_PlanMiner_Statements] ON [dbo].[PlanMiner_Statements]
(
	 [PlanMinerID]	ASC
	,[StatementID]	ASC
)