/*
	Enter values that are expected to return some data:
		@ObjectName a non-encrypted object
		@StartTime & @EndTime covering a time period when the @ObjectName was executed (as small as possible to reduce impact of the test)
*/
DECLARE @TargetDatabase	SYSNAME		=	'DatabaseName'
DECLARE @ObjectName		SYSNAME		=	'Schema.Object'
DECLARE @StartTime		DATETIME2	=	'2021-08-01 00:00'
DECLARE @EndTime		DATETIME2	=	'2021-08-02 00:00'

-- Testing the extraction of the details (no stats)
EXECUTE [dbo].[QueryReport]
	 @DatabaseName		=	@TargetDatabase
	,@ObjectName		=	@ObjectName
	,@StartTime			=	@StartTime
	,@EndTime			=	@EndTime
	,@IntervalReports	=	0
	,@AggregatedReports	=	0
	,@PlanAggregation	=	0
	,@QueryAggregation	=	0
	,@ObjectAggregation	=	0
	,@PlanDetails		=	1
	,@QueryDetails		=	1
	,@ObjectDetails		=	1
	,@Averages			=	0
	,@Totals			=	0
	,@RuntimeStats		=	0
	,@WaitStats			=	0
-- Testing the extraction of runtime stats
EXECUTE [dbo].[QueryReport]
	 @DatabaseName		=	@TargetDatabase
	,@ObjectName		=	@ObjectName
	,@StartTime			=	@StartTime
	,@EndTime			=	@EndTime
	,@IntervalReports	=	1
	,@AggregatedReports	=	1
	,@PlanAggregation	=	1
	,@QueryAggregation	=	1
	,@ObjectAggregation	=	1
	,@PlanDetails		=	0
	,@QueryDetails		=	0
	,@ObjectDetails		=	0
	,@Averages			=	1
	,@Totals			=	1
	,@RuntimeStats		=	1
	,@WaitStats			=	0
-- Testing the extraction of wait stats
EXECUTE [dbo].[QueryReport]
	 @DatabaseName		=	@TargetDatabase
	,@ObjectName		=	@ObjectName
	,@StartTime			=	@StartTime
	,@EndTime			=	@EndTime
	,@IntervalReports	=	1
	,@AggregatedReports	=	1
	,@PlanAggregation	=	1
	,@QueryAggregation	=	1
	,@ObjectAggregation	=	1
	,@PlanDetails		=	0
	,@QueryDetails		=	0
	,@ObjectDetails		=	0
	,@Averages			=	1
	,@Totals			=	1
	,@RuntimeStats		=	0
	,@WaitStats			=	1
-- Testing the extraction of both runtime and wait stats
EXECUTE [dbo].[QueryReport]
	 @DatabaseName		=	@TargetDatabase
	,@ObjectName		=	@ObjectName
	,@StartTime			=	@StartTime
	,@EndTime			=	@EndTime
	,@IntervalReports	=	1
	,@AggregatedReports	=	1
	,@PlanAggregation	=	1
	,@QueryAggregation	=	1
	,@ObjectAggregation	=	1
	,@PlanDetails		=	0
	,@QueryDetails		=	0
	,@ObjectDetails		=	0
	,@Averages			=	1
	,@Totals			=	1
	,@RuntimeStats		=	1
	,@WaitStats			=	1