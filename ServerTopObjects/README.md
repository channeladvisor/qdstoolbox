# ServerTopObjects
This tool provides uses the runtime stats for each database on the server to get a list of the TOP XX objects on each database, ordered by any of the measurements Query Store keeps track off (totals).
\
Can optionally include ad hoc queries aggregated under a "virtual" object
\
(SQL 2016 does not support @Measurement = 'log_bytes_used' / 'tempdb_space_used')
\
Due to the wait Dynamic SQL and EXEC / EXECUTE / sp_executesql commands are executed, these cannot be captured as part of the object that invoked them and will fall under the "ad hoc" virtual object
## Use cases and examples
### Objects with a high CPU consumption (results in microseconds)
Get a list of objects (top 10 per database), aggregating all exit results of the objects
```
EXECUTE [dbo].[ServerTopObjects]
	 @Measurement 		= 	'cpu_time'
	,@Top 			= 	10
	,@AggregateAll		=	1
```
### Objects with a high CPU consumption (results in microseconds) and their corresponding subqueries (subqueries ordered by cpu_time too)
Get a list of objects (top 10 per database), aggregating all exit results of the objects
```
EXECUTE [dbo].[ServerTopObjects]
	 @Measurement 		= 	'cpu_time'
	,@Top 			= 	10
	,@AggregateAll		=	1
	,@IncludeObjectQueryIDs	=	1
```
### Objects with a high CPU consumption (results in percentage)
Get a list of objects (top 10 per database), aggregating all exit results of the objects
The measurements, rather than be measured in their corresponding units (microseconds, 8 KB pages, or log bytes), will be returned in a 0 to 100000 range
This is done rather than returning a DECIMAL value so that the BIGINT measurement columns in the [dbo].[ServerTopObjects] table can be reused.
```
EXECUTE [dbo].[ServerTopObjects]
	 @Measurement 		= 	'cpu_time'
	,@Top 			= 	10
	,@AggregateAll		=	1
```
### Objects / Ad hoc queries with highest TempDB usage for a given database
Store a list with the top 50 objects (or aggregation of all adhoc queries) with the highest TempDB usage for the database TargetDB,
```
EXECUTE [dbo].[ServerTopObjects]
	 @DatabaseName		=	'TargetDB'
	,@ReportIndex		=	'dbo.ServerTopObjectsIndex'
	,@ReportTable		=	'dbo.ServerTopObjectsStore'
	,@Measurement 		= 	'tempdb_space_used'
	,@Top 			= 	50
	,@AggregateAll		=	1
	,@IncludeAdhocQueries	=	0
```

## Suggested uses
### High CPU analysis
Execute it to capture highest CPU consumer objects after a certain threshold has been reach to analyze what was the cause being a period of high activity on the server even when it occurred out of office hours.
### Compare adhoc & objects
Compare the CPU / duration usage of ad hoc queries when converting such queries into SPs to refactor the code and identify the heaviest to focus on