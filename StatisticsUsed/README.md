# StatisticsUsed
Based on the execution plans information stored in Query Store, given
-a single Query ID
-a list of Query IDs
-an Object Name
this tool analyzes all the statistics involved in the generation of its plans, and generates the necessary UPDATE STATISTICS commands with customizable sample rates.

---
## Use cases and examples
### Statistics for specific Query ID
Analyze the execution plans used by the specificed Query ID, highlighting the statistics with a modification rate higher than 10% and not updated in the last 24 hours:
``` 
EXECUTE [dbo].[StatisticsUsed]
	 @DatabaseName		=	'TargetDB'
	,@QueryID		=	32131
	,@ExpirationThreshold	=	1400
	,@ModificationThreshold	=	10
```
### Statistics for list of Query IDs
Analyze the execution plans used by any of the list of Query IDs provided, highlighting the statistics with a modification rate higher than 25% and not updated in the last 60 minutes:
``` 
EXECUTE [dbo].[StatisticsUsed]
	 @DatabaseName		=	'TargetDB'
	,@QueryIDList		=	'32131,3214,32133'
	,@ExpirationThreshold	=	60
	,@ModificationThreshold	=	25
```
### Statistics for object
Analyze the execution plans used by the specified pbject, highlighting the statistics with a modification rate higher than 5% and not updated in the last 5 hours and ensuring the new sample rate calculated will be persisted:
``` 
EXECUTE [dbo].[StatisticsUsed]
	 @DatabaseName		=	'TargetDB'
	,@ObjectName		=	'dbo.Procedure'
	,@ExpirationThreshold	=	300
	,@ModificationThreshold	=	5
	,@PersistSamplePercent	=	1
```
---
## Suggested uses
### "Unforceable" queries
SQL server can't force certain plans (like those using unnamed indexes in temp tables or table variables): even though the command won't return an error, SQL Server won't honor it. Updating the statistics can help SQL Engine opt for a better plan.
### Autofix regressed queries
When combined with [dbo].[QueryVariation], it can be used to help SQL Engine choose a better plan for those queries whose performance has deteriorated due to a plan change.
### Programatically update stats
By loading the commands into a table and looping through them with a cursor, it is possible to execute regular stats update for selected queries or objects
```
SET NOCOUNT ON
DROP TABLE IF EXISTS #Stats
CREATE TABLE #Stats
(
	 [DatabaseName]			NVARCHAR(128)
	,[SchemaName]			NVARCHAR(128)
	,[TableName]			NVARCHAR(128)
	,[StatisticsName]		NVARCHAR(128)
	,[RowsTotal]			BIGINT
	,[RowsSampled]			BIGINT
	,[RowsSampled%]			DECIMAL(16,2)
	,[RowsModified]			BIGINT
	,[RowsModified%]		DECIMAL(16,2)
	,[StatisticsLastUpdated]	DATETIME2
	,[Excluded]			NVARCHAR(128)
	,[UpdateStatsCommand]		NVARCHAR(MAX)
)
INSERT INTO #Stats
EXECUTE [dbo].[StatisticsUsed]
	 @DatabaseName		=	'TargetDB'
	,@ObjectName		=	'dbo.ProblematicProcedure01'
	,@ExpirationThreshold	=	1400
	,@ModificationThreshold	=	10


DECLARE @UpdateStatsCommand	NVARCHAR(MAX)
DECLARE [StatsCursor] CURSOR LOCAL FAST_FORWARD READ_ONLY
FOR
SELECT [UpdateStatsCommand] FROM #Stats

OPEN [StatsCursor]
FETCH NEXT FROM [StatsCursor] INTO @UpdateStatsCommand
WHILE (@@fetch_status >= 0)
BEGIN
	PRINT   (@UpdateStatsCommand)
	EXECUTE (@UpdateStatsCommand)
	FETCH NEXT FROM [StatsCursor] INTO  @UpdateStatsCommand
END

CLOSE [StatsCursor]
DEALLOCATE [StatsCursor]

DROP TABLE IF EXISTS #Stats```