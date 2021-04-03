DECLARE @PlanMinerID BIGINT
EXECUTE [dbo].[PlanMiner]
@PlanMinerTable_PlanList			= '[dbo].[PlanMiner_PlanList]'
,@PlanMinerTable_Columns			= '[dbo].[PlanMiner_Columns]'
,@PlanMinerTable_Cursors			= '[dbo].[PlanMiner_Cursors]'
,@PlanMinerTable_IndexOperations	= '[dbo].[PlanMiner_IndexOperations]'
,@PlanMinerTable_MissingIndexes		= '[dbo].[PlanMiner_MissingIndexes]'
,@PlanMinerTable_UnmatchedIndexes	= '[dbo].[PlanMiner_UnmatchedIndexes]'
,@PlanMinerTable_Statistics			= '[dbo].[PlanMiner_Statistics]'
,@PlanMinerTable_Nodes				= '[dbo].[PlanMiner_Nodes]'
,@PlanMinerID = @PlanMinerID OUTPUT
/* Use either a QDS-based plan, a cache-based one using the plan handle, or any execution plan you have in sqlplan format */
--,@DatabaseName	=	'QDSToolBox'
--,@PlanID		=	1

--,@PlanHandle = 0x060006006E647602109F9C67FF01000001000000000000000000000000000000000000000000000000000000

--,@PlanFile = 'C:\temp\sample.sqlplan'

SELECT *, CAST(DECOMPRESS(CompressedPlan) AS xml) FROM [dbo].[PlanMiner_PlanList]	WHERE [PlanMinerID] = @PlanMinerID
SELECT * FROM [dbo].[PlanMiner_Columns]												WHERE [PlanMinerID] = @PlanMinerID
SELECT * FROM [dbo].[PlanMiner_Cursors]												WHERE [PlanMinerID] = @PlanMinerID
SELECT * FROM [dbo].[PlanMiner_IndexOperations]										WHERE [PlanMinerID] = @PlanMinerID
SELECT * FROM [dbo].[PlanMiner_MissingIndexes]										WHERE [PlanMinerID] = @PlanMinerID
SELECT * FROM [dbo].[PlanMiner_UnmatchedIndexes]									WHERE [PlanMinerID] = @PlanMinerID
SELECT * FROM [dbo].[PlanMiner_Statistics]											WHERE [PlanMinerID] = @PlanMinerID
SELECT * FROM [dbo].[PlanMiner_Nodes]												WHERE [PlanMinerID] = @PlanMinerID
