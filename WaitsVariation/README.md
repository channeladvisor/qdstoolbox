# WaitsVariation
Similar to the QueryVariation tool, compares the Wait metrics for a given query between two different periods of time.

It can be executed in a Test mode to only return the impact executing it would have. both in Test mode or when executed to generate the actual report, the operations's can return an output in different formats:
- One table, containing the detailed results.
- Stored into 2 SQL tables, with one containing the parameters used (both explicitly defined and default values) and another with the detailed results.
- Not returned at all.

The waits measured are those captured by Query Store
https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-query-store-wait-stats-transact-sql

(Supported in SQL 2017+: for SQL 2016 the execution of the stored procedure will return an error)
---
## Use cases and examples
### Avg CPU wait improvement
Queries whose waits on CPU have decreased when comparing the periods (2020-01-01 00:00 -> 2020-02-01 00:00) and (2020-02-01 00:00 -> 2020-02-01 01:00)\
``` 
EXECUTE [dbo].[WaitsVariation]
	@DatabaseName		=	'Target',
	@WaitType			=	'CPU',
	@Metric			=	'avg',
	@VariationType		=	'I',
	@RecentStartTime	=	'2020-02-01 00:00',
	@RecentEndTime		=	'2020-02-01 01:00',
	@HistoryStartTime	=	'2020-01-01 00:00',
	@HistoryEndTime		=	'2020-02-01 00:00'
```
---
## Suggested uses
This tool can be used to extract reports similar to the "Regressed Queries" ones SSMS GUI generates, but based on wait times and with the added functionality of storing the reports into tables for later analysis.
### CPU changes
When the count of CPUs available to the SQL instance is modified, waits on CPU are expected to change and this can be used to measure its impact.
### Network changes
Making modifications on the network (such as moving the SQL instance and its clients to a separate network, setting a different network route for SQL traffic...) will impact the waits caused by network IO.
### Locking impact on the query
Changes in the locking mechanism (such as isolation level, indexing or other processes accessing the same tables the investigated query accesses to), will modify the waits on locks.