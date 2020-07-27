# QDS Tools
This is a collection of tools (comprised on a combination of views, procedures, functions...) developed using the Query Store functionality as a base to facilitate its usage and report generation.

## QDSCacheClean
This tools uses the SPs sp_query_store_remove_query, sp_query_store_remove_plan and sp_query_store_reset_exec_stats to delete stored data for specific queries/plans, which can be adapted using multiple parameters to perform different types of cleanups, as for example:

- Delete plans/queries and/or not used in the last XX hours.
- Delete plans/queries not part of an object (stored procedure/function/trigger...) not used in the last XX hours.
- Delete information regarding internal queries (such as statistics update, index maintenance operations)
- Delete information regarding queries that formed part of a no longer existing object (orphan queries)

In addition to the cleanup operation, the tool can be used to analyze the impact of its execution, but running it on Test Mode, and logging the information of the clean cache operation (either as a test, or as an actual execution) into persisted tables for analysis.\
\
It can be executed in a Test mode to only return the impact executing it would have. both in Test mode or when executed to perform the actual QDS cache clean operations, the operations's can return an output in different formats:
- Returned in a readable format (as text).
- Returned in the form of 1/2 tables (depending on whether the summary of the report of a detailed report is requested).
- Stored into 1/2 SQL tables (depending on whether the summary of the report of a detailed report is requested).
- Not returned at all.

### Use cases and examples
Analyze the impact executing the report would have, results returned in two tables (with different degrees of details) back to the user:
```
EXECUTE [dbo].[QDSCacheClean]
	@DatabaseName 			= 'TargetDB',
	@ReportAsTable 			= 1,
	@ReportDetailsAsTable 	= 1,
	@TestMode				= 1
```

Deletes the stats for all existing queries but not the actual plans, queries, or texts\
```
EXECUTE [dbo].[QDSCacheClean]
	@DatabaseName 			= 'TargetDB',
	@Retention 				= 0,
	@CleanStatsOnly			= 1
```

Delete internal and adhoc queries along with their execution stats\
```
EXECUTE [dbo].[QDSCacheClean]
	@DatabaseName			= 'TargetDB',
	@CleanAdhocStale 		= 1,
	@Retention				= 1,
	@CleanInternal			= 1
```

### Suggested uses
- Databases whose code is all included in functions, procedures, triggers... deleting adhoc and internal queries may reduce space requirements whilst the performance data retained can still be used for performance analysis.
- After code changes that involve dropping objects, orphan queries will no longer be used and the space they occupy can be freed.
- When the space usage is close to 90% of the total Query Store max usage, this tool can be used to try and reduce its occupation, preventing the size-based cleanup.

---

## QueryVariation
### What does QueryVariation do?
Analyzes metrics from two different periods and returns the queries whose performance has changed based on a number of parameters (CPU usage, duration, IO operations...) and the metric in use (average, total, max...), offering a report similar to that of Query Store's GUI as seen in SSMS.\
Allows for an analysis based on the number of different plans in use, filtering queries that have a minimum/maximum number of execution plans.\
\
It can be executed in a Test mode to only return the impact executing it would have. both in Test mode or when executed to perform the actual QDS cache clean operations, the operations's can return an output in different formats:
- Returned in a readable format (as text).
- Returned in the form of 1/2 tables (depending on whether the summary of the report of a detailed report is requested).
- Stored into 1/2 SQL tables (depending on whether the summary of the report of a detailed report is requested).
- Not returned at all.

### Use cases and examples
#### Avg CPU regression
Queries whose average CPU has regressed and used at least 2 different execution plans, when comparing the period between (2020-01-01 00:00 -> 2020-02-01 00:00) and (2020-02-01 00:00 -> 2020-02-01 01:00)\
``` 
EXECUTE [dbo].[QueryVariationReport]
	@DatabaseName		= 'Target',
	@Measurement		= 'cpu',
	@Metric				= 'avg',
	@VariationType		= 'R',
	@MinPlanCount		= 2,
	@RecentStartTime	= '2020-02-01 00:00',
	@RecentEndTime		= '2020-02-01 01:00',
	@HistoryStartTime	= '2020-01-01 00:00',
	@HistoryEndTime		= '2020-02-01 00:00'
```

#### Max duration improvement
Queries whose maximum duration has improved, when comparing the period between (2020-01-01 00:00 -> 2020-02-01 00:00) and (2020-02-01 00:00 -> 2020-02-01 01:00)\
```
EXECUTE [dbo].[QueryVariationReport]
	@DatabaseName		= 'Target',
	@Measurement		= 'duration',
	@Metric				= 'max',
	@VariationType		= 'I',
	@RecentStartTime	= '2020-02-01 00:00',
	@RecentEndTime		= '2020-02-01 01:00',
	@HistoryStartTime	= '2020-01-01 00:00',
	@HistoryEndTime		= '2020-02-01 00:00'
```


### Suggested uses
#### Hardware changes
When performing load & performance tests, allows for measuring the impact of applying changes to the SQL instance and box (such as changing the amount of CPUs of the SQL instance, its memory usage or its disks' IO performance), by looking for changes in performance of queries excluding changes caused my a modification of the execution plans used.
#### Index & statistics changes
Identify queries whose performance has changed due to changes in execution plans after performing maintenance operations (index rebuild, statistics recalculation), or creating/dropping/altering existing indexes.