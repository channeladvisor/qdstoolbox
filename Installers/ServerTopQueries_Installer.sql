DECLARE @Version INT =  CAST(SUBSTRING(CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')),0,CHARINDEX('.',CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')),0)) AS INT)


DECLARE @Measurement		NVARCHAR(32)
DECLARE @MeasurementList	TABLE
(
	[Measurement]	NVARCHAR(32)
)
INSERT INTO @MeasurementList VALUES ('duration')
INSERT INTO @MeasurementList VALUES ('cpu_time')
INSERT INTO @MeasurementList VALUES ('logical_io_reads')
INSERT INTO @MeasurementList VALUES ('logical_io_writes')
INSERT INTO @MeasurementList VALUES ('physical_io_reads')
INSERT INTO @MeasurementList VALUES ('clr_time')
INSERT INTO @MeasurementList VALUES ('query_used_memory')
INSERT INTO @MeasurementList VALUES ('log_bytes_used')
INSERT INTO @MeasurementList VALUES ('tempdb_space_used')

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
	IF((@Version >= 13) AND @Measurement NOT IN ('log_bytes_used','tempdb_space_used'))

	BEGIN
		EXECUTE [dbo].[ServerTopQueries]
			 @DatabaseName		=	'QDSToolBox'
			,@ReportIndex		=	NULL
			,@ReportTable		=	NULL
			,@StartTime			=	'2021-03-01'
			,@EndTime			=	'2021-03-08'
			,@Top				=	1
			,@Measurement		=	@Measurement
			,@IncludeQueryText	=	1
			,@ExcludeAdhoc		=	0
			,@ExcludeInternal	=	0

		EXECUTE [dbo].[ServerTopQueries]
			 @DatabaseName		=	'QDSToolBox'
			,@ReportIndex		=	'[dbo].[ServerTopQueriesIndex]'
			,@ReportTable		=	'[dbo].[ServerTopQueriesStore]'
			,@StartTime			=	'2021-03-01'
			,@EndTime			=	'2021-03-08'
			,@Top				=	1
			,@Measurement		=	@Measurement
			,@IncludeQueryText	=	1
			,@ExcludeAdhoc		=	0
			,@ExcludeInternal	=	0	
			,@ReportID			=	@ReportID OUTPUT
	END
	INSERT INTO @ReportList VALUES (@ReportID)
	FETCH NEXT FROM [Measurement_Cursor] INTO @Measurement
END

CLOSE [Measurement_Cursor]
DEALLOCATE [Measurement_Cursor]

DELETE [i] 
FROM [dbo].[ServerTopQueriesIndex] [i]
INNER JOIN @ReportList [r]
ON [i].[ReportID] = [r].[ReportID]

DELETE [s] 
FROM [dbo].[ServerTopQueriesStore] [s]
INNER JOIN @ReportList [r]
ON [s].[ReportID] = [r].[ReportID]