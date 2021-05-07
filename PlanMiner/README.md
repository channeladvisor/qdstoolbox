# PlanMiner
This tool extracts certaub details out of execution plans obtained from:
- Query Store (plans listed in the [sys].[query_store_plan] table).
- The SQL cache (plans returned by [sys].[dm_exec_query_plan] based on they plan_handle).
- A file containing the execution plan (in XML format).

These details include:
- Statements included in the execution plan (all details are associated to a particular statement).
- Cursors involved in the execution plan.
- Missing indexes: reports all of them, instead of only the one with the most impact as the SSMS GUI does when opening the execution plan.
- Unmatched indexes: filtered indexes that weren't used due to the WHERE clauses not being aligned with them.
- Nodes of the execution plan: as graphically represented in the SSMS view, for a table representation of the execution plan flow.
- Index operations: Indexes used and the operation performed on them, including any hints and forced indexes.
- Columns accessed: any columns accessed on the node of the execution plan for either read or write operations.
- Statistics used by the SQL Engine to generate the execution plan.


---
## Use cases and examples
### Execution plan from cache
```
EXECUTE [dbo].[PlanMiner]
 @InstanceIdentifier 			= 	'LocalServer01'
,@PlanHandle 				= 	0x0500060079E8D66530DEE7A80102000001000000000000000000000000000000000000000000000000000000
,@PlanMinerTable_PlanList		= 	'[dbo].[PlanMiner_PlanList]'
,@PlanMinerTable_Statements		= 	'[dbo].[PlanMiner_Statements]'
,@PlanMinerTable_MissingIndexes		= 	'[dbo].[PlanMiner_MissingIndexes]'
,@PlanMinerTable_UnmatchedIndexes	= 	'[dbo].[PlanMiner_UnmatchedIndexes]'
,@PlanMinerTable_Nodes			= 	'[dbo].[PlanMiner_Nodes]'
,@PlanMinerTable_Cursors		= 	'[dbo].[PlanMiner_Cursors]'
,@PlanMinerTable_IndexOperations	= 	'[dbo].[PlanMiner_IndexOperations]'
,@PlanMinerTable_Columns		= 	'[dbo].[PlanMiner_Columns]'
,@PlanMinerTable_Statistics		= 	'[dbo].[PlanMiner_Statistics]'
,@PlanMinerID = @PlanMinerID OUTPUT
```

### Execution plan from Query Store
```
EXECUTE [dbo].[PlanMiner]
 @InstanceIdentifier 			= 	'LocalServer01
,@DatabaseName				= 	'TargetDB'
,@PlanID				= 	368
,@PlanMinerTable_PlanList		= 	'[dbo].[PlanMiner_PlanList]'
,@PlanMinerTable_Statements		= 	'[dbo].[PlanMiner_Statements]'
,@PlanMinerTable_MissingIndexes		= 	'[dbo].[PlanMiner_MissingIndexes]'
,@PlanMinerTable_UnmatchedIndexes	= 	'[dbo].[PlanMiner_UnmatchedIndexes]'
,@PlanMinerTable_Nodes			= 	'[dbo].[PlanMiner_Nodes]'
,@PlanMinerTable_Cursors		= 	'[dbo].[PlanMiner_Cursors]'
,@PlanMinerTable_IndexOperations	= 	'[dbo].[PlanMiner_IndexOperations]'
,@PlanMinerTable_Columns		= 	'[dbo].[PlanMiner_Columns]'
,@PlanMinerTable_Statistics		= 	'[dbo].[PlanMiner_Statistics]'
,@PlanMinerID = @PlanMinerID OUTPUT
```

### Execution plan from file
```
EXECUTE [dbo].[PlanMiner]
 @PlanFile				= 	'C:\Temp\Plan01.xml'
,@PlanMinerTable_PlanList		= 	'[dbo].[PlanMiner_PlanList]'
,@PlanMinerTable_Statements		= 	'[dbo].[PlanMiner_Statements]'
,@PlanMinerTable_MissingIndexes		= 	'[dbo].[PlanMiner_MissingIndexes]'
,@PlanMinerTable_UnmatchedIndexes	= 	'[dbo].[PlanMiner_UnmatchedIndexes]'
,@PlanMinerTable_Nodes			= 	'[dbo].[PlanMiner_Nodes]'
,@PlanMinerTable_Cursors		= 	'[dbo].[PlanMiner_Cursors]'
,@PlanMinerTable_IndexOperations	= 	'[dbo].[PlanMiner_IndexOperations]'
,@PlanMinerTable_Columns		= 	'[dbo].[PlanMiner_Columns]'
,@PlanMinerTable_Statistics		= 	'[dbo].[PlanMiner_Statistics]'
,@PlanMinerID = @PlanMinerID OUTPUT
```

### Access extracted data
```
SELECT * FROM [dbo].[vPlanMiner_PlanList]		WHERE [PlanMinerID] = @PlanMinerID
SELECT * FROM [dbo].[vPlanMiner_Statements]		WHERE [PlanMinerID] = @PlanMinerID
SELECT * FROM [dbo].[PlanMiner_MissingIndexes]		WHERE [PlanMinerID] = @PlanMinerID
SELECT * FROM [dbo].[PlanMiner_UnmatchedIndexes]	WHERE [PlanMinerID] = @PlanMinerID
SELECT * FROM [dbo].[PlanMiner_Nodes]			WHERE [PlanMinerID] = @PlanMinerID
SELECT * FROM [dbo].[PlanMiner_Cursors]			WHERE [PlanMinerID] = @PlanMinerID
SELECT * FROM [dbo].[PlanMiner_IndexOperations]		WHERE [PlanMinerID] = @PlanMinerID
SELECT * FROM [dbo].[PlanMiner_Columns]			WHERE [PlanMinerID] = @PlanMinerID
SELECT * FROM [dbo].[PlanMiner_Statistics]		WHERE [PlanMinerID] = @PlanMinerID
```


---
## Suggested uses
### Identification of object usage
Provided Query Store is enabled and capturing all metrics, analyzing all the plans in Query Store can be used to identify what objects (tables, indexes, columns...) are used, and what queries would be the impacted if they are modified.
### Statistics usage
Understanding which statistics were used for the generation of a plan can help decide what would be the frecuency and sample rate of next UPDATE STATS command to prevent SQL server from using a less-than-optimal execution plan due to the SQL server not having sufficiently accurate information on the data.
### Impact of execution plan nodes
Having the estimate CPU & I/O on each of the execution plan's nodes can highlight operations that have a heavy impact on the query, such as Key Lookups having a high I/O impact that could be prevented by implementing one of the identified missing indexes.