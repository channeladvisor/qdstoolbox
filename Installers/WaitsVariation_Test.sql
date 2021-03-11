SET NOCOUNT ON
DECLARE @Version INT =  CAST(SUBSTRING(CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')),0,CHARINDEX('.',CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')),0)) AS INT)

DECLARE @Measurement		NVARCHAR(32)
DECLARE @MeasurementList	TABLE
(
	[Measurement]	NVARCHAR(32)
)
INSERT INTO @MeasurementList VALUES ('Total')
INSERT INTO @MeasurementList VALUES ('Unknown')
INSERT INTO @MeasurementList VALUES ('CPU')
INSERT INTO @MeasurementList VALUES ('WorkerThread')
INSERT INTO @MeasurementList VALUES ('Lock')
INSERT INTO @MeasurementList VALUES ('Latch')
INSERT INTO @MeasurementList VALUES ('BufferLatch')
INSERT INTO @MeasurementList VALUES ('BufferIO')
INSERT INTO @MeasurementList VALUES ('Compilation')
INSERT INTO @MeasurementList VALUES ('SQLCLR')
INSERT INTO @MeasurementList VALUES ('Mirroring')
INSERT INTO @MeasurementList VALUES ('Transaction')
INSERT INTO @MeasurementList VALUES ('Idle')
INSERT INTO @MeasurementList VALUES ('Preemptive')
INSERT INTO @MeasurementList VALUES ('ServiceBroker')
INSERT INTO @MeasurementList VALUES ('TranLogIO')
INSERT INTO @MeasurementList VALUES ('NetworkIO')
INSERT INTO @MeasurementList VALUES ('Parallelism')
INSERT INTO @MeasurementList VALUES ('Memory')
INSERT INTO @MeasurementList VALUES ('UserWait')
INSERT INTO @MeasurementList VALUES ('Tracing')
INSERT INTO @MeasurementList VALUES ('FullTextSearch')
INSERT INTO @MeasurementList VALUES ('OtherDiskIO')
INSERT INTO @MeasurementList VALUES ('Replication')
INSERT INTO @MeasurementList VALUES ('LogRateGovernor')

DECLARE @ReportID			INT
DECLARE @ReportList			TABLE
(
	[ReportID]		INT
)

DECLARE [Measurement_Cursor] CURSOR LOCAL READ_ONLY FAST_FORWARD
FOR
SELECT [Measurement] FROM @MeasurementList

OPEN [Measurement_Cursor]
FETCH NEXT FROM [Measurement_Cursor] INTO @Measurement

WHILE(@@FETCH_STATUS = 0)
BEGIN
	EXECUTE [dbo].[WaitsVariation]
		 @DatabaseName		=	'QDSToolBox'
		,@ReportIndex		=	NULL
		,@ReportTable		=	NULL
		,@WaitType			=	@Measurement
		,@Metric			=	'Total'
		,@VariationType		=	'I'
		,@ResultsRowCount	=	1
		,@RecentStartTime	=	'2021-03-07 19:00'
		,@RecentEndTime		=	'2021-03-08'
		,@HistoryStartTime	=	'2021-03-01'
		,@HistoryEndTime	=	'2021-03-07 19:00'
		,@IncludeQueryText	=	1
		,@ExcludeAdhoc		=	0
		,@ExcludeInternal	=	0
		,@VerboseMode = 1

	EXECUTE [dbo].[WaitsVariation]
		 @DatabaseName		=	'QDSToolBox'
		,@ReportIndex		=	NULL
		,@ReportTable		=	NULL
		,@WaitType			=	@Measurement
		,@Metric			=	'Avg'
		,@VariationType		=	NULL
		,@ResultsRowCount	=	1
		,@RecentStartTime	=	'2021-03-07'
		,@RecentEndTime		=	'2021-03-08'
		,@HistoryStartTime	=	'2021-03-01'
		,@HistoryEndTime	=	'2021-03-07'
		,@IncludeQueryText	=	1
		,@ExcludeAdhoc		=	0
		,@ExcludeInternal	=	0

	EXECUTE [dbo].[WaitsVariation]
		 @DatabaseName		=	'QDSToolBox'
		,@ReportIndex		=	'[dbo].[WaitsVariationIndex]'
		,@ReportTable		=	'[dbo].[WaitsVariationStore]'
		,@WaitType			=	@Measurement
		,@Metric			=	'Total'
		,@VariationType		=	NULL
		,@ResultsRowCount	=	1
		,@RecentStartTime	=	'2021-03-07'
		,@RecentEndTime		=	'2021-03-08'
		,@HistoryStartTime	=	'2021-03-01'
		,@HistoryEndTime	=	'2021-03-07'
		,@IncludeQueryText	=	1
		,@ExcludeAdhoc		=	0
		,@ExcludeInternal	=	0
		,@ReportID			=	@ReportID OUTPUT
	INSERT INTO @ReportList VALUES (@ReportID)

	EXECUTE [dbo].[WaitsVariation]
		 @DatabaseName		=	'QDSToolBox'
		,@ReportIndex		=	'[dbo].[WaitsVariationIndex]'
		,@ReportTable		=	'[dbo].[WaitsVariationStore]'
		,@WaitType			=	@Measurement
		,@Metric			=	'Avg'
		,@VariationType		=	NULL
		,@ResultsRowCount	=	1
		,@RecentStartTime	=	'2021-03-07'
		,@RecentEndTime		=	'2021-03-08'
		,@HistoryStartTime	=	'2021-03-01'
		,@HistoryEndTime	=	'2021-03-07'
		,@IncludeQueryText	=	1
		,@ExcludeAdhoc		=	0
		,@ExcludeInternal	=	0
		,@ReportID			=	@ReportID OUTPUT
	INSERT INTO @ReportList VALUES (@ReportID)

	FETCH NEXT FROM [Measurement_Cursor] INTO @Measurement
END

CLOSE [Measurement_Cursor]
DEALLOCATE [Measurement_Cursor]

DELETE [i] 
FROM [dbo].[WaitsVariationIndex] [i]
INNER JOIN @ReportList [r]
ON [i].[ReportID] = [r].[ReportID]

DELETE [s] 
FROM [dbo].[WaitsVariationStore] [s]
INNER JOIN @ReportList [r]
ON [s].[ReportID] = [r].[ReportID]