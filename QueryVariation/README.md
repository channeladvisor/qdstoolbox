# QueryVariation
Analyzes metrics from two different periods and returns the queries whose performance has changed based on a number of parameters (CPU usage, duration, IO operations...) and the metric in use (average, total, max...), offering a report similar to that of Query Store's GUI as seen in SSMS.\
Allows for an analysis based on the number of different plans in use, filtering queries that have a minimum/maximum number of execution plans.\
\
It can be executed in a Test mode to only return the impact executing it would have. both in Test mode or when executed to generate the actual report, the operations's can return an output in different formats:
- One table, containing the detailed results.
- Stored into 2 SQL tables, with one containing the parameters used (both explicitly defined and default values) and another with the detailed results.
- Not returned at all.
---
## Use cases and examples
### Avg CPU regression
Queries whose average CPU has regressed and used at least 2 different execution plans, when comparing the period between (2020-01-01 00:00 -> 2020-02-01 00:00) and (2020-02-01 00:00 -> 2020-02-01 01:00)\
``` 
EXECUTE [dbo].[QueryVariation]
	@DatabaseName		=	'Target',
	@Measurement		=	'cpu',
	@Metric			=	'avg',
	@VariationType		=	'R',
	@MinPlanCount		=	2,
	@RecentStartTime	=	'2020-02-01 00:00',
	@RecentEndTime		=	'2020-02-01 01:00',
	@HistoryStartTime	=	'2020-01-01 00:00',
	@HistoryEndTime		=	'2020-02-01 00:00'
```

### Max duration improvement
Queries whose maximum duration has improved, when comparing the period between (2020-01-01 00:00 -> 2020-02-01 00:00) and (2020-02-01 00:00 -> 2020-02-01 01:00)\
```
EXECUTE [dbo].[QueryVariation]
	@DatabaseName		=	'Target',
	@Measurement		=	'duration',
	@Metric			=	'max',
	@VariationType		=	'I',
	@RecentStartTime	=	'2020-02-01 00:00',
	@RecentEndTime		=	'2020-02-01 01:00',
	@HistoryStartTime	=	'2020-01-01 00:00',
	@HistoryEndTime		=	'2020-02-01 00:00'
```
---

## Suggested uses
This tool can be used to extract the same reports as the "Regressed Queries" SSMS GUI can, with the added functionality of storing the reports into tables for later analysis.
### Hardware changes
When performing load & performance tests, allows for measuring the impact of applying changes to the SQL instance and box (such as changing the amount of CPUs of the SQL instance, its memory usage or its disks' IO performance), by looking for changes in performance of queries excluding changes caused my a modification of the execution plans used.
### Index & statistics changes
Identify queries whose performance has changed due to changes in execution plans after performing maintenance operations (index rebuild, statistics recalculation), or creating/dropping/altering existing indexes.