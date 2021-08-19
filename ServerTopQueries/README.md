# ServerTopQueries
This tool provides uses the runtime stats for each database on the server to get a list of the TOP XX queries on each database, ordered by any of the measurements Query Store keeps track off (totals).
\
(SQL 2016 does not support @Measurement = 'log_bytes_used' / 'tempdb_space_used')
## Use cases and examples
### Queries with a high CPU consumption
Get a list of queries (top 10 per database) along with their query text, aggregating all exit results of the queries
```
EXECUTE [dbo].[ServerTopQueries]
	 @Measurement 		= 	'cpu_time'
	,@Top 			= 	10
	,@AggregateAll		=	1
	,@IncludeQueryText 	= 	1
```
### Failed / cancelled queries with a high CPU consumption
Get a list of non-adhoc queries (top 10 per database) that exited with an exception (such as divide by zero) or cancelled consuming the most CPU, keeping their metrics separated
```
EXECUTE [dbo].[ServerTopQueries]
	 @Measurement 		= 	'cpu_time'
	,@Top 			= 	10
	,@ExcludeAdhoc		=	1
	,@ExcludeInternal	=	1
	,@ExecutionRegular	=	0
	,@ExecutionAborted	=	1
	,@ExecutionException	=	1
	,@AggregateAll		=	0
	,@AggregateNonRegular	=	0
```
### Queries with highest TempDB usage for a given database
Store a list with the top 50 queries with the highest TempDB usage for the database Target, along with their query text
```
EXECUTE [dbo].[ServerTopQueries]
	 @DatabaseName		=	'TargetDB'
	,@ReportIndex		=	'dbo.ServerTopQueriesIndex'
	,@ReportTable		=	'dbo.ServerTopQueriesStore'
	,@Measurement 		= 	'tempdb_space_used'
	,@Top 			= 	50
	,@AggregateAll		=	1
	,@IncludeQueryText 	= 	1
```

## Suggested uses
### High CPU analysis
Execute it to capture highest CPU consumers after a certain threshold has been reach to analyze what was the cause being a period of high activity on the server even when it occurred out of office hours.

### Archival of Query Store Data
It is possible to use this tool to aggregate the runtime statistics per hour/day/week/month... to allow some historical data to be stored without impacting the databases' Query Store space usage
```
EXECUTE [dbo].[ServerTopQueries]
	 @DatabaseName		=	'TargetDB'
	,@ReportIndex		=	'dbo.ServerTopQueriesIndex'
	,@ReportTable		=	'dbo.ServerTopQueriesStore'
	,@Top 			= 	0
	,@IncludeQueryText 	= 	0
	,@ExcludeAdhoc		=	0
	,@ExcludeInternal	=	0
	,@ExecutionRegular	=	1
	,@ExecutionAborted	=	1
	,@ExecutionException	=	1
	,@AggregateAll		=	0
	,@AggregateNonRegular	=	0
```