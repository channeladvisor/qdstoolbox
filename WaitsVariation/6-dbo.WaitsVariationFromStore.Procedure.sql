----------------------------------------------------------------------------------
-- Procedure Name: [dbo].[WaitsVariationFromStore]
--
-- Desc: This script accesses previously stored reports based on query variation, returning only the significant columns based on the parameters
--		used to initially generate the report.
--
--
-- Parameters:
--	INPUT
--		@ReportID					BIGINT			--	Identifier of the report whose data is being queried
--
--		@VerboseMode				BIT				--	Flag to determine whether the T-SQL commands that compose this report will be returned to the user.
--														[Default: 0]
--
--		@TestMode					BIT				--	Flag to determine whether the actual T-SQL commands that generate the report will be executed.
--														[Default:0]
--
--			
-- Date: 2020.10.22
-- Auth: Pablo Lozano (@sqlozano)
--
----------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE [dbo].[WaitsVariationFromStore]
(
	 @ReportID		BIGINT
	,@VerboseMode	BIT		=	0
	,@TestMode		BIT		=	0
)
AS
BEGIN
SET NOCOUNT ON

-- Verify the @ReportID provided is a valid one - START
IF (@ReportID IS NULL)
BEGIN
	RAISERROR('NULL is a non valid value for the ReportID.', 16, 0)
	RETURN
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[WaitsVariationIndex] WHERE [ReportID] = @ReportID)
BEGIN
	DECLARE @r NVARCHAR(20) = CAST(@ReportID AS NVARCHAR(20))
	RAISERROR('The ReportID [%s] does not exist.', 16, 0, @r)
	RETURN
END
-- Verify the @ReportID provided is a valid one - END


-- Gather parameters used to generate the Report in order to prepare the output - START
DECLARE @WaitType NVARCHAR(16)
DECLARE @VariationType NVARCHAR(1)
DECLARE @IncludeQueryText BIT
SELECT
	 @WaitType			= [WaitType]
	,@VariationType		= [VariationType]
	,@IncludeQueryText 	= [IncludeQueryText]
FROM [dbo].[vWaitsVariationIndex] WHERE [ReportID] = @ReportID
-- Gather parameters used to generate the Report in order to prepare the output - END

-- Build query to return the output to the user - START
DECLARE @SqlCmdIndex NVARCHAR(MAX) = 
'SELECT
	 [wvi].[InstanceIdentifier]
	,[wvi].[DatabaseName]
	,[wvi].[WaitType]
	,[wvi].[Metric]
	,[wvi].[VariationType]
	,[wvi].[HistoryStartTime]
	,[wvi].[HistoryEndTime]
	,[wvi].[RecentStartTime]
	,[wvi].[RecentEndTime]
	,[wvi].[ExcludeAdhoc]
	,[wvi].[ExcludeInternal]
	,[wvi].[IncludeQueryText]
FROM 
[dbo].[vWaitsVariationIndex] [wvi]
WHERE [wvi].[ReportID] = {@ReportID}'
SET @SqlCmdIndex = REPLACE(@SqlCmdIndex,	'{@ReportID}',		CAST(@ReportID AS NVARCHAR(20)))

IF (@VerboseMode = 1)	PRINT	(@SqlCmdIndex)
IF (@TestMode = 0)		EXEC	(@SqlCmdIndex)

DECLARE @SqlCmdStore NVARCHAR(MAX) =
'SELECT
	 [wvs].[ObjectID]
	,[wvs].[SchemaName]
	,[wvs].[ObjectName]
	,[wvs].[ExecutionCount_History]
	,[wvs].[ExecutionCount_Recent]
	,[wvs].[ExecutionCount_Variation%]
	,[wvs].[{@WaitType}_History]
	,[wvs].[{@WaitType}_Recent]
	,[wvs].[{@WaitType}_Variation%]
	{@IncludeQueryText},[wvs].[QueryText]
FROM [dbo].[vWaitsVariationStore] [wvs]
WHERE [wvs].[ReportID] = {@ReportID}
ORDER BY [{@WaitType}_Variation%] {@ASCDESC}'

	SET @SqlCmdStore = REPLACE(@SqlCmdStore,	'{@ReportID}',		CAST(@ReportID AS NVARCHAR(20)))

	-- Select appropriate columns based on the @WaitType selected - START
	SET @SqlCmdStore = REPLACE(@SqlCmdStore,	'{@WaitType}',		@WaitType)
	-- Select appropriate columns based on the @WaitType selected - END

	-- Modify results' ordering based on @VariationType - START
	IF (@VariationType = 'R')
		SET @SqlCmdStore = REPLACE(@SqlCmdStore, '{@ASCDESC}',			'DESC')
	IF (@VariationType = 'I')
		SET @SqlCmdStore = REPLACE(@SqlCmdStore, '{@ASCDESC}',			'ASC')
	-- Modify results' ordering based on @VariationType - END

	-- Include / Exclude Query Text based on @IncludeQueryText - START
	IF (@IncludeQueryText = 0)
		SET @SqlCmdStore = REPLACE(@SqlCmdStore, '{@IncludeQueryText}',	'--')
	IF (@IncludeQueryText = 1)
		SET @SqlCmdStore = REPLACE(@SqlCmdStore, '{@IncludeQueryText}',	'')
	-- Include / Exclude Query Text based on @IncludeQueryText - END

-- Build query to return the output to the user - END

IF (@VerboseMode = 1)	PRINT	(@SqlCmdStore)
IF (@TestMode = 0)		EXEC	(@SqlCmdStore)

END