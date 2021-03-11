SET NOCOUNT ON
DECLARE @Version INT =  CAST(SUBSTRING(CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')),0,CHARINDEX('.',CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')),0)) AS INT)

DECLARE [Executions] CURSOR LOCAL READ_ONLY FAST_FORWARD
FOR
SELECT [Measurement], [Metric] FROM [dbo].[QDSMetricArchive]

DECLARE @Measurement	NVARCHAR(32)
DECLARE @Metric			NVARCHAR(16)
DECLARE @ReportID		INT
DECLARE @Reports		TABLE
(
	[ReportID]	INT
)

OPEN [Executions]
FETCH NEXT FROM [Executions] INTO @Measurement, @Metric

WHILE(@@FETCH_STATUS = 0)
BEGIN
	IF(
		(@Version >= 14)
		OR
		((@Version = 13) AND @Measurement NOT IN ('Log','TempDB'))
	)
	BEGIN
		EXECUTE [dbo].[QueryVariation]
			 @DatabaseName		=	'QDSToolBox'
			,@Measurement		=	@Measurement
			,@Metric			=	@Metric
			,@VariationType		=	'R'
			,@ResultsRowCount	=	1
			,@RecentStartTime	=	'2021-03-01'
			,@RecentEndTime		=	'2021-03-06'
			,@HistoryStartTime	=	'2021-03-06'
			,@HistoryEndTime	=	'2021-03-07'
			,@MinExecCount		=	1
			,@MinPlanCount		=	1
			,@MaxPlanCount		=	10
			,@IncludeQueryText	=	0
			,@ExcludeAdhoc		=	0
			,@ExcludeInternal	=	0
	
		EXECUTE [dbo].[QueryVariation]
			 @DatabaseName		=	'QDSToolBox'
			,@ReportIndex		=	'[dbo].[QueryVariationIndex]'
			,@ReportTable		=	'[dbo].[QueryVariationStore]'
			,@Measurement		=	@Measurement
			,@Metric			=	@Metric
			,@VariationType		=	'R'
			,@ResultsRowCount	=	1
			,@RecentStartTime	=	'2021-03-01'
			,@RecentEndTime		=	'2021-03-06'
			,@HistoryStartTime	=	'2021-03-06'
			,@HistoryEndTime	=	'2021-03-07'
			,@MinExecCount		=	1
			,@MinPlanCount		=	1
			,@MaxPlanCount		=	10
			,@IncludeQueryText	=	0
			,@ExcludeAdhoc		=	0
			,@ExcludeInternal	=	0
			,@ReportID			=	@ReportID OUTPUT
	END
	INSERT INTO @Reports VALUES (@ReportID)
	FETCH NEXT FROM [Executions] INTO @Measurement, @Metric
END

CLOSE [Executions]
DEALLOCATE [Executions]

DELETE [i] 
FROM [dbo].[QueryVariationIndex] [i]
INNER JOIN @Reports [r]
ON [i].[ReportID] = [r].[ReportID]

DELETE [s] 
FROM [dbo].[QueryVariationStore] [s]
INNER JOIN @Reports [r]
ON [s].[ReportID] = [r].[ReportID]