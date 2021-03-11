EXECUTE [dbo].[QDSCacheCleanup]
	 @DatabaseName			= 'QDSToolBox'
	,@CleanAdhocStale		= 1
	,@CleanStale			= 1
	,@Retention				= 24
	,@MinExecutionCount		= 2
	,@CleanOrphan			= 1
	,@CleanInternal			= 1
	,@ReportAsTable			= 1
	,@ReportDetailsAsTable	= 1
	,@TestMode				= 1
GO

EXECUTE [dbo].[QDSCacheCleanup]
	 @DatabaseName			= 'QDSToolBox'
	,@CleanAdhocStale		= 1
	,@CleanStale			= 1
	,@Retention				= 24
	,@MinExecutionCount		= 2
	,@CleanOrphan			= 1
	,@CleanInternal			= 1
	,@ReportAsText			= 1
	,@TestMode				= 1
GO

DECLARE @ReportID INT
EXECUTE [dbo].[QDSCacheCleanup]
	 @DatabaseName				= 'QDSToolBox'
	,@CleanAdhocStale			=	1
	,@CleanStale				=	1
	,@Retention					=	24
	,@MinExecutionCount			=	2
	,@CleanOrphan				=	1
	,@CleanInternal				=	1
	,@ReportIndexOutputTable	=	'[dbo].[QDSCacheCleanupIndex]'
	,@ReportDetailsOutputTable	=	'[dbo].[QDSCacheCleanupDetails]'
	,@TestMode					=	1
	,@ReportID					=	@ReportID OUTPUT

SELECT * FROM [dbo].[QDSCacheCleanupIndex]		WHERE [ReportID] = @ReportID
SELECT * FROM [dbo].[QDSCacheCleanupDetails]	WHERE [ReportID] = @ReportID

SELECT * FROM [dbo].[vQDSCacheCleanupIndex]		WHERE [ReportID] = @ReportID
SELECT * FROM [dbo].[vQDSCacheCleanupDetails]	WHERE [ReportID] = @ReportID
GO