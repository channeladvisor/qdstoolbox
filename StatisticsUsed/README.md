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
	 @DatabaseName	=	'TargetDB'
	,@QueryID	=	32131
	,@ExpirationThreshold	=	1400
	,@ModificationThreshold	=	10
```
### Statistics for list of Query IDs
Analyze the execution plans used by any of the list of Query IDs provided, highlighting the statistics with a modification rate higher than 25% and not updated in the last 60 minutes:
``` 
EXECUTE [dbo].[StatisticsUsed]
	 @DatabaseName	=	'TargetDB'
	,@QueryIDList	=	'32131,3214,32133'
	,@ExpirationThreshold	=	60
	,@ModificationThreshold	=	25
```
### Statistics for object
Analyze the execution plans used by the specified pbject, highlighting the statistics with a modification rate higher than 5% and not updated in the last 5 hours and ensuring the new sample rate calculated will be persisted:
``` 
EXECUTE [dbo].[StatisticsUsed]
	 @DatabaseName	=	'TargetDB'
	,@ObjectName	=	'dbo.Procedure'
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
