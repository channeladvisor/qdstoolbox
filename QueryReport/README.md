# QueryReport
This procedure allows access to the information stored in both sys.query_store_runtime_stats and sys.query_store_wait_stats
This information is extracted and aggregated at different levels:
-Time interval: aggregating the data at the runtime_stats_interval_id level, or between @StartTime and @EndTime
-Object/Query/Plan: since Query Store gathers statistics per plan, this information can be presented at the plan, query or object level

In addition to the statistics, this procedure can be used to extrain information:
-The query texts
-The execution plan
-The object definition
Depending on the input parameters and flags provided

---
## Use cases and examples
Get the runtime statistics of every query part of the [Db01].[Sche].[Obj01] between '2021-01-01 00:00' and '2021-01-07 00:00' detailed at the query level for each interval set for the [Db01] query store interval, with averages based on the # of executions of each query
```
EXECUTE [dbo].[QueryReport]
	 @DatabaseName		=	'Db01'
	,@ObjectName		=	'[Sch01].[Obj01]'
	,@StartTime		=	'2021-01-01 00:00'
	,@EndTime		=	'2021-01-07 00:00'
	,@IntervalReports	=	1
	,@QueryAggregation	=	1
	,@Averages		=	1
	,@RuntimeStats		=	1
```

Get the wait statistics of the plan ID 1234 on database [Db02] aggregated for the whole interval between '2021-06-01 00:00' and '2021-06-01 06:00' obtaining both the average waits and total waits in separate reports
```
EXECUTE [dbo].[QueryReport]
	 @DatabaseName		=	'Db02'
	,@PlanID		=	1234
	,@StartTime		=	'2021-06-01 00:00'
	,@EndTime		=	'2021-06-01 06:00'
	,@AggregatedReports	=	1
	,@PlanAggregation	=	1
	,@Averages		=	1
	,@Totals		=	1
	,@WaitStats		=	1
```

Get both the runtime wait statistics of two query IDs (1534 and 3342) on database [Db03] aggregated for the whole interval between '2021-06-01 00:00' and '2021-06-03 00:00' obtaining average runtime & wait stats in a single combined report
```
EXECUTE [dbo].[QueryReport]
	 @DatabaseName		=	'Db03'
	,@QueryIDList		=	'1534,3342'
	,@StartTime		=	'2021-06-01 00:00'
	,@EndTime		=	'2021-06-03 00:00'
	,@AggregatedReports	=	1
	,@QueryAggregation	=	1
	,@Averages		=	1
	,@RuntimeStats		=	1
	,@WaitStats		=	1
```

---
## Suggested uses
### Post Code change analysis
Given an SP recently modified, obtain a list of QueryID that take part of the procedure [Sch02].[Obj02] on database [DB04]
```
EXECUTE [dbo].[QDSCacheCleanup]
	 @DatabaseName		=	'DB04'
	,@ObjectName		=	'[Sch01].[Obj02]
	,@QueryDetails		=	1
```
Once identified the specific QueryIDs (8001 and 9001) updated whose changes are to be monitored
```
EXECUTE [dbo].[QueryReport]
	 @DatabaseName		=	'Db04'
	,@QueryIDList		=	'8001,9001'
	,@StartTime		=	'2021-07-01 00:00'
	,@EndTime		=	'2021-09-01 00:00'
	,@AggregatedReports	=	1
	,@QueryAggregation	=	1
	,@Averages		=	1
	,@RuntimeStats		=	1
	,@PlanDetails		=	1
```
In addition to comparing the runtime stats of both versions of the sub query, the plans used by both versions of the query will be returned for comparison of the last 2 months of data, aggregated for the two months;
this results in 2 lines, one for each QueryID, indicating when the change took place and the average metrics 

### Correlate WaitStats & Increased duration
Since the SSMS GUI has separate sections for information extracted from sys.query_store_runtime_stats and sys.query_store_wait_stats, it is difficult to correlate increases in a query's duration with increase in waits
Combining both can provide some hindsight on what kind of blocking may have caused a deviation in the query duration despite no plan regression
```
EXECUTE [dbo].[QueryReport]
	 @DatabaseName		=	'Db05'
	,@PlanID		=	4454
	,@StartTime		=	'2021-07-01 00:00'
	,@EndTime		=	'2021-08-01 00:00'
	,@IntervalReports	=	1
	,@PlanAggregation	=	1
	,@Averages		=	1
	,@RuntimeStats		=	1
	,@WaitStats		=	1
```