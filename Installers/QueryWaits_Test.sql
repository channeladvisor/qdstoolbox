	EXECUTE [dbo].[QueryWaits]
		 @DatabaseName		=	'QDSToolBox'
		,@ReportIndex		=	NULL
		,@ReportTable		=	NULL
		,@StartTime			=	'2021-03-01'
		,@EndTime			=	'2021-03-08'
		,@ObjectName		=	'[dbo].[QueryWaits]'
		,@PlanID			=	NULL
		,@QueryID			=	NULL
		,@IncludeQueryText	=	1

	EXECUTE [dbo].[QueryWaits]
		 @DatabaseName		=	'QDSToolBox'
		,@ReportIndex		=	NULL
		,@ReportTable		=	NULL
		,@StartTime			=	'2021-03-01'
		,@EndTime			=	'2021-03-08'
		,@ObjectName		=	NULL
		,@PlanID			=	1
		,@QueryID			=	NULL
		,@IncludeQueryText	=	1

	EXECUTE [dbo].[QueryWaits]
		 @DatabaseName		=	'QDSToolBox'
		,@ReportIndex		=	NULL
		,@ReportTable		=	NULL
		,@StartTime			=	'2021-03-01'
		,@EndTime			=	'2021-03-08'
		,@ObjectName		=	NULL
		,@PlanID			=	NULL
		,@QueryID			=	1
		,@IncludeQueryText	=	1
GO

SET NOCOUNT ON
DECLARE @ReportID INT
EXECUTE [dbo].[QueryWaits]
	 @DatabaseName		=	'QDSToolBox'
	,@ReportIndex		=	'[dbo].[QueryWaitsIndex]'
	,@ReportTable		=	'[dbo].[QueryWaitsStore]'
	,@StartTime			=	'2021-03-01'
	,@EndTime			=	'2021-03-08'
	,@ObjectName		=	'[dbo].[QueryWaits]'
	,@PlanID			=	NULL
	,@QueryID			=	NULL
	,@IncludeQueryText	=	1
	,@ReportID			=	@ReportID OUTPUT
DELETE FROM [dbo].[QueryWaitsIndex] WHERE [ReportID] = @ReportID
DELETE FROM [dbo].[QueryWaitsStore] WHERE [ReportID] = @ReportID

EXECUTE [dbo].[QueryWaits]
	 @DatabaseName		=	'QDSToolBox'
	,@ReportIndex		=	'[dbo].[QueryWaitsIndex]'
	,@ReportTable		=	'[dbo].[QueryWaitsStore]'
	,@StartTime			=	'2021-03-01'
	,@EndTime			=	'2021-03-08'
	,@ObjectName		=	NULL
	,@PlanID			=	1
	,@QueryID			=	NULL
	,@IncludeQueryText	=	1
	,@ReportID			=	@ReportID OUTPUT
DELETE FROM [dbo].[QueryWaitsIndex] WHERE [ReportID] = @ReportID
DELETE FROM [dbo].[QueryWaitsStore] WHERE [ReportID] = @ReportID

EXECUTE [dbo].[QueryWaits]
	 @DatabaseName		=	'QDSToolBox'
	,@ReportIndex		=	'[dbo].[QueryWaitsIndex]'
	,@ReportTable		=	'[dbo].[QueryWaitsStore]'
	,@StartTime			=	'2021-03-01'
	,@EndTime			=	'2021-03-08'
	,@ObjectName		=	NULL
	,@PlanID			=	NULL
	,@QueryID			=	1
	,@IncludeQueryText	=	1
	,@ReportID			=	@ReportID OUTPUT
DELETE FROM [dbo].[QueryWaitsIndex] WHERE [ReportID] = @ReportID
DELETE FROM [dbo].[QueryWaitsStore] WHERE [ReportID] = @ReportID