# ServerTopQueries
This tool provides uses the runtime stats for each database on the server to get a list of the TOP XX queries on each database, ordered by any of the measurements Query Store keeps track off (totals).
\
(SQL 2016 does not support @Measurement = 'log_bytes_used' / 'tempdb_space_used')
## Use cases and examples
### Queries with a high CPU consumption (results in microseconds)
Get a list of queries (top 10 per database) along with their query text, aggregating all exit results of the queries
```
EXECUTE [dbo].[ServerTopQueries]
	 @Measurement 		= 	'cpu_time'
	,@Top 			= 	10
	,@AggregateAll		=	1
	,@IncludeQueryText 	= 	1
```
### Queries with a high CPU consumption (results in percentage)
Get a list of queries (top 10 per database) along with their query text, aggregating all exit results of the queries
The measurements, rather than be measured in their corresponding units (microseconds, 8 KB pages, or log bytes), will be returned in a 0 to 100000 range
This is done rather than returning a DECIMAL value so that the BIGINT measurement columns in the [dbo].[ServerTopQueries] table can be reused.
```
EXECUTE [dbo].[ServerTopQueries]
	 @Measurement 		= 	'cpu_time'
	,@Top 			= 	10
	,@AggregateAll		=	1
	,@IncludeQueryText 	= 	1
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