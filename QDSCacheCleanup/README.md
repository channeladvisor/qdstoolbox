# QDSCacheClean
This tool uses the SPs <b>sp_query_store_remove_query</b>, <b>sp_query_store_remove_plan</b> and <b>sp_query_store_reset_exec_stats</b> to delete stored data for specific queries and or plans, which can be adapted using multiple parameters to perform different types of cleanups, as for example:

- Delete plans/queries and/or not used in the last XX hours.
- Delete plans/queries not part of an object (stored procedure/function/trigger...) not used in the last XX hours.
- Delete information regarding internal queries (such as statistics update, index maintenance operations)
- Delete information regarding queries that formed part of a no longer existing object (orphan queries)

In addition to the cleanup operation, the tool can be used to analyze the impact of its execution, by running it on Test Mode and logging the information of the clean cache operation (either as a test, or as an actual execution) into persisted tables for analysis.\
\
It can be executed in a Test mode to only return the impact executing it would have. both in Test mode or when executed to perform the actual QDS cache clean operations, the operations's can return an output in different formats:
- Returned in a readable format (as text).
- Returned in the form of 1/2 tables (depending on whether the summary of the report of a detailed report is requested).
- Stored into 1/2 SQL tables (depending on whether the summary of the report of a detailed report is requested).
- Not returned at all.
---
## Use cases and examples
Analyze the impact executing the report would have, results returned in two tables (with different degrees of details) back to the user:
```
EXECUTE [dbo].[QDSCacheCleanup]
	@DatabaseName 			=	'TargetDB',
	@ReportAsTable 			=	1,
	@ReportDetailsAsTable 		=	1,
	@TestMode			=	1
```

Deletes the stats for all existing queries but not the actual plans, queries, or texts
```
EXECUTE [dbo].[QDSCacheCleanup]
	@DatabaseName 			=	'TargetDB',
	@Retention 			=	0,
	@CleanStatsOnly			=	1
```

Delete internal and adhoc queries along with their execution stats
```
EXECUTE [dbo].[QDSCacheCleanup]
	@DatabaseName			=	'TargetDB',
	@CleanAdhocStale 		=	1,
	@Retention			=	1,
	@CleanInternal			=	1
```

Perform a default-valued cleanup and record the results
```
EXECUTE [dbo].[QDSCacheCleanup]
	@DatabaseName				=	'TargetDB',
	@ReportIndexOutputTable 	= 	'dbo.QDSCacheCleanupIndex',
	@ReportDetailsOutputTable 	= 	'dbo.QDSCacheCleanupDetails'

```

---
## Suggested uses
### Removal of non SPs & Functions code

Databases whose code is all included in functions, procedures, triggers... deleting adhoc and internal queries may reduce space requirements whilst the performance data retained can still be used for performance analysis.
### Post Code change cleanup
After code changes that involve dropping objects, orphan queries will no longer be used and the space they occupy can be freed.
### Prevention of auto cleanup
When the space usage is close to 90% of the total Query Store max usage, this tool can be used to try and reduce its occupation, preventing the size-based cleanup.