# QueryWaits
This tool analyzes the wait status for a given Object / Query / Plan, and returns the data along with the runtime times (CPU, CLR and Duration) to provide an overview on how long the Object / Query / Plan takes to complete, and how much of that time can be attributed to actual execution, waits on resources...

---
## Use cases and examples
### Object level waits
Get the waits impacting a particular object's execution during a given period
```
EXECUTE dbo.QueryWaits
	 @DatabaseName	=	'TargetDB'
	,@ObjectName 	=	'Schema.Object'
	,@StartTime		=	'2020-01-01'
	,@EndTime		=	'2020-02-01'
```
### Query level waits
Get the waits impacting a particular query's execution during a given period
```
EXECUTE dbo.QueryWaits
	 @DatabaseName	=	'TargetDB'
	,@QueryID 		=	15648
	,@StartTime		=	'2020-01-07 09:00'
	,@EndTime		=	'2020-01-07 11:00'
```

### Plan level waits
Get the waits impacting a particular plan's execution during a given period, storing it into SQL tables along with the Query Text
```
EXECUTE dbo.QueryWaits
	 @DatabaseName		=	'TargetDB'
	,@PlanID 			=	14865
	,@StartTime			=	'2020-01-07 09:00'
	,@EndTime			=	'2020-01-07 11:00'
	,@ReportIndex		=	'dbo.QueryWaitsIndex'
	,@ReportTable		= 	'dbo.QueryWaitsStore'
	,@IncludeQueryText	=	1
```