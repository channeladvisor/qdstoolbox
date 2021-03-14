----------------------------------------------------------------------------------
-- Procedure Name: [dbo].[PlanMiner_FromQDS]
--
-- Desc: Analyzes the execution plans for each subquery of the selected Plan
--
--
-- Parameters:
--	INPUT
--		@ServerIdentifier					-	SYSNAME
--			Identifier assigned to the server
--			[Default: @@SERVERNAME]
--
--		@DatabaseName						-	SYSNAME
--			Name of the database whose plan is being mined for information
--			[Default: DB_NAME()]
--
--		@PlanID								-	BIGINT
--			Identifier of the plan this information has been mined out
--			[Default: NULL]
--
--		@PlanMinerTable_Columns				-	NVARCHAR(800)
--			Table to stores the list of columns accessed with a certain execution plan on each of its operations (nodes)
--			See [dbo].[PlanMiner_Columns]
--			[Default: NULL]
--
--		@PlanMinerTable_Cursors				-	NVARCHAR(800)
--			Table to store the information about the cursor found in the execution plan (when applicable)
--			See [dbo].[PlanMiner_Cursors]
--			[Default: NULL]
--
--		@PlanMinerTable_IndexOperations		-	NVARCHAR(800)
--			Table to store the information about the index operations (scan, seek, update, delete...) performed
--			See [dbo].[PlanMiner_IndexOperations]
--			[Default: NULL]
--
--		@PlanMinerTable_MissingIndexes		-	NVARCHAR(800)
--			Table to store the details of the indexes the SQL engine consideres could improve its performance
--			See [dbo].[PlanMiner_MissingIndexes]
--			[Default: NULL]
--
--		@PlanMinerTable_UnmatchedIndexes	-	NVARCHAR(800)
--			Table to store the information about the filtered indexes not used due to the parameters in the WHERE clause not matching those in the indexes
--			See [dbo].[PlanMiner_UnmatchedIndexes]
--			[Default: NULL]
--
--		@PlanMinerTable_Statistics			-	NVARCHAR(800)
--			Table to store the list of statistics used by the SQL Engine to elaborate this execution plan
--			See [dbo].[PlanMiner_Statistics]
--			[Default: NULL]
--
--		@PlanMinerTable_Nodes				-	NVARCHAR(800)
--			Table to store the details of each node (operation) of the execution plan
--			See [dbo].[PlanMiner_Nodes]
--			[Default: NULL]
--
--
--		@VerboseMode				-	BIT
--			Flag to enable/disable Verbose messages
--			[Default: 0]
--		@TestMode					-	BIT
--			Flag to enable/disable Test mode
--			[Default: 0]
--		
--	OUTPUT
--		@ReturnMessage					-	NVARCHAR(MAX)
--			Message explaining the output of the procedure's execution
--		@ReturnCode						-	INT
--			<0 : Error performing the analysis
--			>=0 : Analysis completed successfully
----------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE [dbo].[PlanMiner_FromQDS]
(
	 @ServerIdentifier					SYSNAME			=	NULL
	,@DatabaseName						SYSNAME			=	NULL
	,@PlanID							BIGINT 			=	NULL
	,@PlanMinerTable_Columns			NVARCHAR(800)	=	NULL
	,@PlanMinerTable_Cursors			NVARCHAR(800)	=	NULL
	,@PlanMinerTable_IndexOperations	NVARCHAR(800)	=	NULL
	,@PlanMinerTable_MissingIndexes		NVARCHAR(800)	=	NULL
	,@PlanMinerTable_UnmatchedIndexes	NVARCHAR(800)	=	NULL
	,@PlanMinerTable_Statistics			NVARCHAR(800)	=	NULL
	,@PlanMinerTable_Nodes				NVARCHAR(800)	=	NULL

	,@Overwrite				BIT = 0
	,@VerboseMode			BIT = 0
	,@TestMode				BIT = 0

	,@ReturnMessage			NVARCHAR(MAX)	=	NULL	OUTPUT	
	,@ReturnCode			INT				=	NULL	OUTPUT
)
AS
BEGIN
SET NOCOUNT ON

-- Check variables and set defaults - START
IF (@ServerIdentifier IS NULL)
	SET @ServerIdentifier = @@SERVERNAME

IF (@DatabaseName IS NULL) OR (@DatabaseName = '')
	SET @DatabaseName = DB_NAME()

IF (@PlanMinerTable_Columns			 = '')
	SET @PlanMinerTable_Columns				= NULL
IF (@PlanMinerTable_Cursors			 = '')
	SET @PlanMinerTable_Cursors				= NULL
IF (@PlanMinerTable_IndexOperations	 = '')
	SET @PlanMinerTable_IndexOperations		= NULL
IF (@PlanMinerTable_MissingIndexes	 = '')
	SET @PlanMinerTable_MissingIndexes		= NULL
IF (@PlanMinerTable_UnmatchedIndexes = '')
	SET @PlanMinerTable_UnmatchedIndexes	= NULL
IF (@PlanMinerTable_Statistics		 = '')
	SET @PlanMinerTable_Statistics			= NULL
IF (@PlanMinerTable_Nodes			 = '')
	SET @PlanMinerTable_Nodes				= NULL
-- Check variables and set defaults - END

-- Verify selected PlanID - START
DROP TABLE IF EXISTS #CheckExistingPlanIDTable
CREATE TABLE #CheckExistingPlanIDTable
(
	 [PlanID]	BIGINT
	,[PlanXML]	NVARCHAR(MAX)
)

DECLARE @CheckExistingPlanIDSQL NVARCHAR(MAX) =
'INSERT INTO #CheckExistingPlanIDTable 
SELECT [plan_id], [query_plan]
FROM [{@DatabaseName}].[sys].[query_store_plan] 
WHERE [plan_id] = {@PlanID}'
SET @CheckExistingPlanIDSQL = REPLACE(@CheckExistingPlanIDSQL, '{@DatabaseName}', @DatabaseName)
SET @CheckExistingPlanIDSQL = REPLACE(@CheckExistingPlanIDSQL, '{@PlanID}', CAST(@PlanID AS NVARCHAR(16)))
EXECUTE (@CheckExistingPlanIDSQL)

IF NOT EXISTS(SELECT 1 FROM #CheckExistingPlanIDTable)
BEGIN
	RAISERROR('The selected PlanID does not exist for the given Database',0,1)
	RETURN
END
-- Verify selected PlanID - END

-- Check if the PlanID had been already analyzed (delete previous results if @Overwrite = 1) - START
DROP TABLE IF EXISTS #CheckAnalyzedPlanIDTable
CREATE TABLE #CheckAnalyzedPlanIDTable
(
	 [PlanID]	BIGINT
)
DECLARE @CheckAnalyzedPlanIDSQLTemplate NVARCHAR(MAX) = 
'INSERT INTO #CheckAnalyzedPlanIDTable
SELECT TOP(1) [PlanID] 
FROM {@AnalysisResults} 
WHERE [ServerIdentifier] 	= 	''{@ServerIdentifier}''
AND [DatabaseName] 			= 	''{@DatabaseName}''
AND [PlanID]				= 	{@PlanID}'
SET @CheckAnalyzedPlanIDSQLTemplate = REPLACE(@CheckAnalyzedPlanIDSQLTemplate,	'{@ServerIdentifier}', 	@ServerIdentifier)
SET @CheckAnalyzedPlanIDSQLTemplate = REPLACE(@CheckAnalyzedPlanIDSQLTemplate,	'{@DatabaseName}', 		@DatabaseName)
SET @CheckAnalyzedPlanIDSQLTemplate = REPLACE(@CheckAnalyzedPlanIDSQLTemplate,	'{@PlanID}', 			CAST(@PlanID AS NVARCHAR(16)))

IF (@VerboseMode = 1)
	PRINT (@CheckAnalyzedPlanIDSQLTemplate)

DECLARE @CheckAnalyzedPlanIDSQL NVARCHAR(MAX)

IF 	(@PlanMinerTable_Columns			IS NOT NULL)
BEGIN
	SET @CheckAnalyzedPlanIDSQL = REPLACE(@CheckAnalyzedPlanIDSQLTemplate, '{@AnalysisResults}', @PlanMinerTable_Columns)
	EXECUTE ( @CheckAnalyzedPlanIDSQL)
END
IF 	(@PlanMinerTable_Cursors			IS NOT NULL)
BEGIN
	SET @CheckAnalyzedPlanIDSQL = REPLACE(@CheckAnalyzedPlanIDSQLTemplate, '{@AnalysisResults}', @PlanMinerTable_Cursors)
	EXECUTE ( @CheckAnalyzedPlanIDSQL)
END
IF 	(@PlanMinerTable_IndexOperations	IS NOT NULL)
BEGIN
	SET @CheckAnalyzedPlanIDSQL = REPLACE(@CheckAnalyzedPlanIDSQLTemplate, '{@AnalysisResults}', @PlanMinerTable_IndexOperations)
	EXECUTE ( @CheckAnalyzedPlanIDSQL)
END
IF 	(@PlanMinerTable_MissingIndexes		IS NOT NULL)
BEGIN
	SET @CheckAnalyzedPlanIDSQL = REPLACE(@CheckAnalyzedPlanIDSQLTemplate, '{@AnalysisResults}', @PlanMinerTable_MissingIndexes)
	EXECUTE ( @CheckAnalyzedPlanIDSQL)
END
IF 	(@PlanMinerTable_UnmatchedIndexes	IS NOT NULL)
BEGIN
	SET @CheckAnalyzedPlanIDSQL = REPLACE(@CheckAnalyzedPlanIDSQLTemplate, '{@AnalysisResults}', @PlanMinerTable_UnmatchedIndexes)
	EXECUTE ( @CheckAnalyzedPlanIDSQL)
END
IF 	(@PlanMinerTable_Statistics			IS NOT NULL)
BEGIN
	SET @CheckAnalyzedPlanIDSQL = REPLACE(@CheckAnalyzedPlanIDSQLTemplate, '{@AnalysisResults}', @PlanMinerTable_Statistics)
	EXECUTE ( @CheckAnalyzedPlanIDSQL)
END
IF 	(@PlanMinerTable_Nodes				IS NOT NULL)
BEGIN
	SET @CheckAnalyzedPlanIDSQL = REPLACE(@CheckAnalyzedPlanIDSQLTemplate, '{@AnalysisResults}', @PlanMinerTable_Nodes)
	EXECUTE ( @CheckAnalyzedPlanIDSQL)
END



IF NOT EXISTS(SELECT 1 FROM #CheckExistingPlanIDTable)
BEGIN
	IF (@VerboseMode = 1)
		RAISERROR('The selected PlanID has previously been analyzed',0,1)

	IF(@Overwrite = 1)
	BEGIN
		IF (@VerboseMode = 1)
			RAISERROR('Previous results will be deleted and a new analysis will be performed',0,1)

		DECLARE @DeletePreviousAnalysisTemplate NVARCHAR(MAX) = 
		'DELETE FROM {@AnalysisResults}
		WHERE [ServerIdentifier] 	= 	''{@ServerIdentifier}''
		AND [DatabaseName] 			= 	''{@DatabaseName}''
		AND [PlanID]				= 	{@PlanID}'
		SET @DeletePreviousAnalysisTemplate = REPLACE(@DeletePreviousAnalysisTemplate,	'{@ServerIdentifier}', 	@ServerIdentifier)
		SET @DeletePreviousAnalysisTemplate = REPLACE(@DeletePreviousAnalysisTemplate,	'{@DatabaseName}', 		@DatabaseName)
		SET @DeletePreviousAnalysisTemplate = REPLACE(@DeletePreviousAnalysisTemplate,	'{@PlanID}', 			CAST(@PlanID AS NVARCHAR(16)))

		IF (@VerboseMode = 1)
			PRINT (@DeletePreviousAnalysisTemplate)

		DECLARE @DeletePreviousAnalysis NVARCHAR(MAX)
		IF 	(@PlanMinerTable_Columns			IS NOT NULL)
		BEGIN
			SET @DeletePreviousAnalysis = REPLACE(@DeletePreviousAnalysisTemplate, '{@AnalysisResults}', @PlanMinerTable_Columns)
			EXECUTE ( @DeletePreviousAnalysis)
		END
		IF 	(@PlanMinerTable_Cursors			IS NOT NULL)
		BEGIN
			SET @DeletePreviousAnalysis = REPLACE(@DeletePreviousAnalysisTemplate, '{@AnalysisResults}', @PlanMinerTable_Cursors)
			EXECUTE ( @DeletePreviousAnalysis)
		END
		IF 	(@PlanMinerTable_IndexOperations	IS NOT NULL)
		BEGIN
			SET @DeletePreviousAnalysis = REPLACE(@DeletePreviousAnalysisTemplate, '{@AnalysisResults}', @PlanMinerTable_IndexOperations)
			EXECUTE ( @DeletePreviousAnalysis)
		END
		IF 	(@PlanMinerTable_MissingIndexes		IS NOT NULL)
		BEGIN
			SET @DeletePreviousAnalysis = REPLACE(@DeletePreviousAnalysisTemplate, '{@AnalysisResults}', @PlanMinerTable_MissingIndexes)
			EXECUTE ( @DeletePreviousAnalysis)
		END
		IF 	(@PlanMinerTable_UnmatchedIndexes	IS NOT NULL)
		BEGIN
			SET @DeletePreviousAnalysis = REPLACE(@DeletePreviousAnalysisTemplate, '{@AnalysisResults}', @PlanMinerTable_UnmatchedIndexes)
			EXECUTE ( @DeletePreviousAnalysis)
		END
		IF 	(@PlanMinerTable_Statistics			IS NOT NULL)
		BEGIN
			SET @DeletePreviousAnalysis = REPLACE(@DeletePreviousAnalysisTemplate, '{@AnalysisResults}', @PlanMinerTable_Statistics)
			EXECUTE ( @DeletePreviousAnalysis)
		END
		IF 	(@PlanMinerTable_Nodes				IS NOT NULL)
		BEGIN
			SET @DeletePreviousAnalysis = REPLACE(@DeletePreviousAnalysisTemplate, '{@AnalysisResults}', @PlanMinerTable_Nodes)
			EXECUTE ( @DeletePreviousAnalysis)
		END
	END
	ELSE
		RETURN
END
DROP TABLE IF EXISTS #CheckAnalyzedPlanIDTable
-- Check if the PlanID had been already analyzed (delete previous results if @Overwrite = 1) - START


---------------------------------------------------------
-- Analysis of the Execution Plan's contents -  START  --
---------------------------------------------------------

-- Extract execution plan of @DatabaseName's sys.query_store_plan - START
DECLARE @PlanXML	NVARCHAR(MAX)
SELECT @PlanXML = [PlanXML] FROM #CheckExistingPlanIDTable
DROP TABLE IF EXISTS #CheckExistingPlanIDTable
-- Extract execution plan of @DatabaseName's sys.query_store_plan - END

SELECT @PlanXML -- ********
-- Table to contain the XML data (one line at a time) - START
DROP TABLE IF EXISTS #XMLContent
CREATE TABLE #XMLContent
(
	 [PlanID]		BIGINT
	,[LineNumber]	INT
	,[LineContent]	NVARCHAR(MAX)
)
CREATE CLUSTERED INDEX [PK_XMLContent] ON #XMLContent ([LineNumber] ASC)
-- Table to contain the XML data (one line at a time) - END


-- Temp tables to store the data before the transfer to final table - START
DROP TABLE IF EXISTS #PlanMinerTable_Columns
DROP TABLE IF EXISTS #PlanMinerTable_Cursors
DROP TABLE IF EXISTS #PlanMinerTable_IndexOperations
DROP TABLE IF EXISTS #PlanMinerTable_MissingIndexes
DROP TABLE IF EXISTS #PlanMinerTable_UnmatchedIndexes
DROP TABLE IF EXISTS #PlanMinerTable_Statistics
DROP TABLE IF EXISTS #PlanMinerTable_Nodes
CREATE TABLE #PlanMinerTable_Columns
(
	 [NodeID]				INT				NOT NULL
	,[DatabaseNameColumn]	NVARCHAR(128)	NULL
	,[SchemaName]			NVARCHAR(128)	NULL
	,[TableName]			NVARCHAR(128)	NULL
	,[ColumnName]			NVARCHAR(128)	NOT NULL
)
CREATE TABLE #PlanMinerTable_Cursors
(
	 [CursorName]			NVARCHAR(128)	NULL
	,[CursorActualType]		NVARCHAR(128)	NULL
	,[CursorRequestedType]	NVARCHAR(128)	NULL
	,[CursorConcurrency]	NVARCHAR(128)	NULL
	,[ForwardOnly]			BIT				NULL
)
CREATE TABLE #PlanMinerTable_IndexOperations
(
	 [NodeID]			INT				NOT NULL
	,[DatabaseNamePlan]	NVARCHAR(128)	NULL
	,[SchemaName]		NVARCHAR(128)	NULL
	,[TableName]		NVARCHAR(128)	NULL
	,[IndexName]		NVARCHAR(128)	NULL
	,[IndexKind]		NVARCHAR(128)	NULL
	,[LogicalOp]		NVARCHAR(128)	NULL
	,[Ordered]			BIT				NULL
	,[ForcedIndex]		BIT				NULL
	,[ForceSeek]		BIT				NULL
	,[ForceScan]		BIT				NULL
	,[NoExpandHint]		BIT				NULL
	,[Storage]			NVARCHAR(128)	NULL
)
CREATE TABLE #PlanMinerTable_MissingIndexes
(
	 [MissingIndexID]	INT				NOT NULL
	,[Impact]			FLOAT			NULL
	,[DatabaseNamePlan]	NVARCHAR(128)	NULL
	,[SchemaName]		NVARCHAR(128)	NULL
	,[TableName]		NVARCHAR(128)	NULL
	,[Usage]			NVARCHAR(128)	NULL
	,[ColumnName]		NVARCHAR(128)	NULL
)
CREATE TABLE #PlanMinerTable_UnmatchedIndexes
(
	 [DatabaseNamePlan]		NVARCHAR(128)	NULL
	,[SchemaName]			NVARCHAR(128)	NULL
	,[TableName]			NVARCHAR(128)	NULL
	,[UnmatchedIndexName]	NVARCHAR(128)	NULL
)
CREATE TABLE #PlanMinerTable_Statistics
(
	 [DatabaseNamePlan]		NVARCHAR(128)	NULL
	,[SchemaName]			NVARCHAR(128)	NULL
	,[TableName]			NVARCHAR(128)	NULL
	,[StatisticName]		NVARCHAR(128)	NULL
	,[ModificationCount]	BIGINT			NULL
	,[SamplingPercent]		FLOAT			NULL
	,[LastUpdate]			DATETIME2(7)	NULL
)
CREATE TABLE #PlanMinerTable_Nodes
(
	 [CursorOperationType]			NVARCHAR(16)	NOT NULL
	,[NodeID]						INT				NOT NULL
	,[Depth]						INT				NOT NULL
	,[PhysicalOp]					NVARCHAR(128)	NOT NULL
	,[LogicalOp]					NVARCHAR(128)	NOT NULL
	,[EstimateRows]					FLOAT			NOT NULL
	,[EstimatedRowsRead]			FLOAT			NULL
	,[EstimateIO]					FLOAT			NOT NULL
	,[EstimateCPU]					FLOAT			NOT NULL
	,[AvgRowSize]					FLOAT			NOT NULL
	,[EstimatedTotalSubtreeCost]	FLOAT			NOT NULL
	,[TableCardinality]				FLOAT			NULL
	,[Parallel]						FLOAT			NOT NULL
	,[EstimateRebinds]				FLOAT			NOT NULL
	,[EstimateRewinds]				FLOAT			NOT NULL
	,[EstimatedExecutionMode]		NVARCHAR(128)	NOT NULL
)
-- Temp tables to store the data before the transfer to final table - END



-- Variables used to loop through the execution plan - START
DECLARE @LineNumber INT = 0
DECLARE @LineStart	INT = 0
DECLARE @LineEnd	INT = 0
DECLARE	@LineText	NVARCHAR(MAX)
-- Variables used to loop through the execution plan - END


-- Loop through each line (reading XML as plain text) - START
WHILE(@LineNumber = 0 OR (@LineStart <> @LineEnd))
BEGIN
	SET @LineStart	= CHARINDEX('<', @PlanXML, @LineEnd)
	SET @LineEnd	= CHARINDEX('>', @PlanXML, @LineEnd + 1)
	SET @LineText	= SUBSTRING(@PlanXML,@LineStart, 1 + @LineEnd - @LineStart)
	-- If the line is not a tag closure, insert it into #XMLContent - START
	IF (CHARINDEX('</','_'+@LineText) = 0)
	BEGIN
		-- To reformat the line into a valid XML file, substitute closing '>' with '/>'
		INSERT INTO #XMLContent ([PlanID], [LineNumber], [LineContent])
		VALUES (@PlanID, @LineNumber, REPLACE(@LineText, '>','/>') )

		-- Move on to the next line
		SET @LineNumber = @LineNumber + 1
	END
	-- If the line is not a tag closure, insert it into #XMLContent - END

	-- Exiting a Node - START
	IF(@LineText = '</RelOp>')
	BEGIN
		-- To reformat the line into a valid XML file, substitute closing '>' with '/>'
		INSERT INTO #XMLContent ([PlanID], [LineNumber], [LineContent])
		VALUES (@PlanID, @LineNumber, '<ExitRelOp/>' )

		-- Move on to the next line
		SET @LineNumber = @LineNumber + 1
	END
	-- Exiting a Node - END
END
-- Loop through each line (reading XML as plain text) - END

SELECT * FROM #XMLContent -- *****

-- Analyze the XML lines that reference specific columns - START
DECLARE [XMLContentCursor] CURSOR LOCAL FAST_FORWARD
FOR
SELECT [LineNumber], TRY_CONVERT(XML,[LineContent])
FROM #XMLContent
ORDER BY [LineNumber] ASC

DECLARE @XMLContent	XML


-- Variable to specify the depth of the node - START
DECLARE @Depth INT = 0
-- Variable to specify the depth of the node - END

-- Variable to identify what kind of Index is being processed - START
-- Values:  ReadWrite | Missing | Unmatched
DECLARE @IndexOperation NVARCHAR(16)
-- Variable to identify what kind of Index is being processed - END

-- Variable to differentiate between regular plans and cursor plans - START
DECLARE @CursorOperationType NVARCHAR(16) = 'None'
-- Variable to differentiate between regular plans and cursor plans - END


-- Variables to temporary store the missing index details - START
DECLARE	@Impact				FLOAT
DECLARE	@DatabaseNamePlan	NVARCHAR(128)
DECLARE	@SchemaName			NVARCHAR(128)
DECLARE	@TableName			NVARCHAR(128)
DECLARE	@Usage				NVARCHAR(128)
DECLARE @MissingIndexID		INT				=	0
-- Variables to temporary store the missing index details - START


-- Variables to temporary store index operation parameters - START
DECLARE @NodeID			INT
DECLARE @Ordered		BIT
DECLARE @ForcedIndex	BIT
DECLARE @ForcedSeek		BIT
DECLARE @ForcedScan		BIT
DECLARE @NoExpandHint	BIT
DECLARE @Storage		NVARCHAR(128)
DECLARE @LogicalOp		NVARCHAR(128)
-- Variables to temporary store index operation parameters - END



OPEN [XMLContentCursor]
FETCH NEXT FROM [XMLContentCursor] INTO @LineNumber, @XMLContent
WHILE @@FETCH_STATUS = 0  
BEGIN

		-- XML line containing a cursor type - START
		IF (@XMLContent.exist('/CursorPlan') = 1)
		BEGIN
			SET @Depth = 0
			IF (@PlanMinerTable_Cursors IS NOT NULL)
				INSERT INTO #PlanMinerTable_Cursors
				SELECT 
					 [CursorName]					=	@XMLContent.value('(/CursorPlan/@CursorName)[1]',					'NVARCHAR(128)')
					,[CursorActualType]				=	@XMLContent.value('(/CursorPlan/@CursorActualType)[1]',				'NVARCHAR(128)')
					,[CursorRequestedType]			=	@XMLContent.value('(/CursorPlan/@CursorRequestedType)[1]',			'NVARCHAR(128)')
					,[CursorConcurrency]			=	@XMLContent.value('(/CursorPlan/@CursorConcurrency)[1]',			'NVARCHAR(128)')
					,[ForwardOnly]					=	CASE @XMLContent.value('(/CursorPlan/@ForwardOnly)[1]',				'BIT')
															WHEN 'true' THEN 1
															ELSE 0
														END
		END
		-- XML line containing a cursor type - END


		-- Sub-execution plan part of an cursor - START
		IF (@XMLContent.exist('/Operation') = 1)
		BEGIN
			SET @CursorOperationType = @XMLContent.value('(/Operation/@OperationType)[1]',	'NVARCHAR(16)')
		END
		-- Sub-execution plan part of an cursor - END


		-- XML line containing an operation - START
		IF (@XMLContent.exist('/RelOp') = 1)
		BEGIN
			SET @Depth = @Depth + 1
			IF (@PlanMinerTable_Nodes	 IS NOT NULL)
				INSERT INTO #PlanMinerTable_Nodes
				SELECT 
					 @CursorOperationType
					,[NodeId]						=	@XMLContent.value('(/RelOp/@NodeId)[1]',					'INT')
					,@Depth
					,[PhysicalOp]					=	@XMLContent.value('(/RelOp/@PhysicalOp)[1]',				'NVARCHAR(128)')
					,[LogicalOp]					=	@XMLContent.value('(/RelOp/@LogicalOp)[1]',					'NVARCHAR(128)')
					,[EstimateRows]					=	@XMLContent.value('(/RelOp/@EstimateRows)[1]',				'FLOAT')
					,[EstimatedRowsRead]			=	@XMLContent.value('(/RelOp/@EstimatedRowsRead)[1]',			'FLOAT')
					,[EstimateIO]					=	@XMLContent.value('(/RelOp/@EstimateIO)[1]',				'FLOAT')
					,[EstimateCPU]					=	@XMLContent.value('(/RelOp/@EstimateCPU)[1]',				'FLOAT')
					,[AvgRowSize]					=	@XMLContent.value('(/RelOp/@AvgRowSize)[1]',				'FLOAT')
					,[EstimatedTotalSubtreeCost]	=	@XMLContent.value('(/RelOp/@EstimatedTotalSubtreeCost)[1]',	'FLOAT')
					,[TableCardinality]				=	@XMLContent.value('(/RelOp/@TableCardinality)[1]',			'FLOAT')
					,[Parallel]						=	@XMLContent.value('(/RelOp/@Parallel)[1]',					'BIT')
					,[EstimateRebinds]				=	@XMLContent.value('(/RelOp/@EstimateRebinds)[1]',			'FLOAT')
					,[EstimateRewinds]				=	@XMLContent.value('(/RelOp/@EstimateRewinds)[1]',			'FLOAT')
					,[EstimatedExecutionMode]		=	@XMLContent.value('(/RelOp/@EstimatedExecutionMode)[1]',	'NVARCHAR(128)')
			SET @LogicalOp = @XMLContent.value('(/RelOp/@LogicalOp)[1]',					'NVARCHAR(128)')
			SET @NodeID = @XMLContent.value('(/RelOp/@NodeId)[1]',	'INT')
		END
		-- XML line containing an operation - END

		-- XML line exiting an operation (reducing node depth) - START
		IF (@XMLContent.exist('/ExitRelOp') = 1)
		BEGIN
			SET @Depth = @Depth - 1
		END
		-- XML line exiting an operation (reducing node depth) - END


		-- XML line containing Statistics used - START
		IF (@PlanMinerTable_Statistics IS NOT NULL)
		BEGIN
			IF (@XMLContent.exist('/StatisticsInfo') = 1)
			BEGIN
				INSERT INTO #PlanMinerTable_Statistics
				SELECT 
					 [DatabaseNamePlan]				=	REPLACE(REPLACE(@XMLContent.value('(/StatisticsInfo/@Database)[1]',				'NVARCHAR(128)'),']',''),'[','')
					,[SchemaName]					=	REPLACE(REPLACE(@XMLContent.value('(/StatisticsInfo/@Schema)[1]',				'NVARCHAR(128)'),']',''),'[','')
					,[TableName]					=	REPLACE(REPLACE(@XMLContent.value('(/StatisticsInfo/@Table)[1]',				'NVARCHAR(128)'),']',''),'[','')
					,[StatisticsName]				=	REPLACE(REPLACE(@XMLContent.value('(/StatisticsInfo/@Statistics)[1]',			'NVARCHAR(128)'),']',''),'[','')
					,[ModificationCount]			=	@XMLContent.value('(/StatisticsInfo/@ModificationCount)[1]',	'BIGINT')
					,[SamplingPercent]				=	@XMLContent.value('(/StatisticsInfo/@SamplingPercent)[1]',		'FLOAT')
					,[LastUpdate]					=	@XMLContent.value('(/StatisticsInfo/@LastUpdate)[1]',			'DATETIME2')
			END
		END
		-- XML line containing Statistics used - END



		----------------------------------
		--  Unmatched indexes  -- START --
		----------------------------------
		-- Entering an XML section regarding Unmatched Indexes (Level 1: Change @IndexOperation Flag) - START
		IF
		(
			(@XMLContent.exist('/UnmatchedIndexes') = 1)
			AND
			(@PlanMinerTable_UnmatchedIndexes IS NOT NULL)
		)
		BEGIN
			SET @IndexOperation = 'Unmatched'
		END
		-- Entering an XML section regarding Unmatched Indexes (Level 1: Change @IndexOperation Flag) - END

		-- Entering an XML section regarding Unmatched Indexes (Level 2: Unmatched Index details) - START
		IF
		( 
			(@IndexOperation = 'Unmatched') 
			AND 
			(@XMLContent.exist('/Object') = 1) 
			AND 
			(@PlanMinerTable_UnmatchedIndexes IS NOT NULL)
		)
		BEGIN
			INSERT INTO #PlanMinerTable_UnmatchedIndexes
			SELECT 
				 [DatabaseNamePlan]	=	REPLACE(REPLACE(@XMLContent.value('(/Object/@Database)[1]',		'NVARCHAR(128)'),']',''),'[','')
				,[SchemaName]		=	REPLACE(REPLACE(@XMLContent.value('(/Object/@Schema)[1]',		'NVARCHAR(128)'),']',''),'[','')
				,[TableName]		=	REPLACE(REPLACE(@XMLContent.value('(/Object/@Table)[1]',		'NVARCHAR(128)'),']',''),'[','')
				,[IndexName]		=	REPLACE(REPLACE(@XMLContent.value('(/Object/@Index)[1]',		'NVARCHAR(128)'),']',''),'[','')
		END
		-- Entering an XML section regarding Unmatched Indexes (Level 2: Unmatched Index details) - END
		----------------------------------
		--  Unmatched indexes  --  END  --
		----------------------------------


		----------------------------------
		--   Missing indexes   -- START --
		----------------------------------
		-- Entering an XML section regarding Missing Indexes (Level-1 : Estimated Impact) - START
		IF
		(
			(@XMLContent.exist('/MissingIndexGroup') = 1)
			AND
			(@PlanMinerTable_MissingIndexes IS NOT NULL)
		)
		BEGIN
			SET @IndexOperation = 'Missing'
			SELECT
					 @Impact						=	@XMLContent.value('(/MissingIndexGroup/@Impact)[1]',		'FLOAT')
		END
		-- Entering an XML section regarding Missing Indexes (Level-1 : Estimated Impact) - END

		-- Entering an XML section regarding Missing Indexes (Level-2 : Target Table) - START
		IF
		(
			(@XMLContent.exist('/MissingIndex') = 1)
			AND
			(@PlanMinerTable_MissingIndexes IS NOT NULL)
		)
		BEGIN
			SELECT 
				 @DatabaseNamePlan				=	REPLACE(REPLACE(@XMLContent.value('(/MissingIndex/@Database)[1]',			'NVARCHAR(128)'),']',''),'[','')
				,@SchemaName					=	REPLACE(REPLACE(@XMLContent.value('(/MissingIndex/@Schema)[1]',				'NVARCHAR(128)'),']',''),'[','')
				,@TableName						=	REPLACE(REPLACE(@XMLContent.value('(/MissingIndex/@Table)[1]',				'NVARCHAR(128)'),']',''),'[','')
			SET @MissingIndexID = @MissingIndexID + 1
		END
		-- Entering an XML section regarding Missing Indexes (Level-2 : Target Table) - END
		
		-- Entering an XML section regarding Missing Indexes (Level-3 : Column Usage = [In]Equality) - START
		IF
		( 
			(@IndexOperation = 'Missing') 
			AND 
			(@XMLContent.exist('/ColumnGroup') = 1 )
			AND
			(@PlanMinerTable_MissingIndexes IS NOT NULL)
		)
		BEGIN
			SELECT 
				@Usage							=	@XMLContent.value('(/ColumnGroup/@Usage)[1]',				'NVARCHAR(128)')
		END
		-- Entering an XML section regarding Missing Indexes (Level-3 : Column Usage = [In]Equality) - END

		-- Entering an XML section regarding Missing Indexes (Level-4 : Suggested Columns for the new index) - START
		IF
		( 
			(@IndexOperation = 'Missing') 
			AND 
			(@XMLContent.exist('/Column') = 1) 
			AND 
			(@PlanMinerTable_MissingIndexes IS NOT NULL) 
		)
		BEGIN
			INSERT INTO #PlanMinerTable_MissingIndexes
			SELECT 
				 @MissingIndexID
				,@Impact
				,@DatabaseNamePlan
				,@SchemaName
				,@TableName
				,@Usage
				,@XMLContent.value('(/Column/@Name)[1]',							'NVARCHAR(128)')
		END
		-- Entering an XML section regarding Missing Indexes (Level-4 : Suggested Columns for the new index) - END
		----------------------------------
		--   Missing indexes   --  END  --
		----------------------------------

		----------------------------------
		--   Scan/Seek index   -- START --
		----------------------------------
		-- Entering an XML section regarding Scan/Seek Index operations (Level-1 : Parameters for the index operation) - START
		IF 
		( 
			(
				(@XMLContent.exist('/IndexScan') = 1)
				OR
				(@XMLContent.exist('/Update') = 1)
			)
			AND
			(@PlanMinerTable_IndexOperations IS NOT NULL)
		)
		BEGIN
			SET @IndexOperation = 'ReadWrite'
			-- Temporaly store the IndexScan parameters to join them to the actal index details - START
			SELECT
				 @Ordered		=	@XMLContent.value('(/IndexScan/@Ordered)[1]',			'BIT')
				,@ForcedIndex	=	@XMLContent.value('(/IndexScan/@ForcedIndex)[1]',		'BIT')
				,@ForcedSeek	=	@XMLContent.value('(/IndexScan/@ForceSeek)[1]',			'BIT')
				,@ForcedScan	=	@XMLContent.value('(/IndexScan/@ForceScan)[1]',			'BIT')
				,@NoExpandHint	=	@XMLContent.value('(/IndexScan/@NoExpandHint)[1]',		'BIT')
				,@Storage		=	@XMLContent.value('(/IndexScan/@Storage)[1]',			'NVARCHAR(128)')			
			-- Temporaly store the IndexScan parameters to join them to the actal index details - END
		END
		-- Entering an XML section regarding Scan/Seek Index operations (Level-1 : Parameters for the index operation) - END
		
		-- Entering an XML section regarding Scan/Seek Index operations (Level-2 : Index used in the operation) - START
		IF
		( 
			(@IndexOperation = 'ReadWrite') 
			AND 
			(@XMLContent.exist('/Object') = 1) 
			AND 
			(@PlanMinerTable_IndexOperations IS NOT NULL) 
		)
		BEGIN
			INSERT INTO #PlanMinerTable_IndexOperations
			SELECT 
				 @NodeID
				,[DatabaseNamePlan]	=	REPLACE(REPLACE(@XMLContent.value('(/Object/@Database)[1]',		'NVARCHAR(128)'),']',''),'[','')
				,[SchemaName]		=	REPLACE(REPLACE(@XMLContent.value('(/Object/@Schema)[1]',		'NVARCHAR(128)'),']',''),'[','')
				,[TableName]		=	REPLACE(REPLACE(@XMLContent.value('(/Object/@Table)[1]',		'NVARCHAR(128)'),']',''),'[','')
				,[IndexName]		=	REPLACE(REPLACE(@XMLContent.value('(/Object/@Index)[1]',		'NVARCHAR(128)'),']',''),'[','')
				,[IndexKind]		=	@XMLContent.value('(/Object/@IndexKind)[1]',					'NVARCHAR(128)')
				,@LogicalOp
				,@Ordered		
				,@ForcedIndex	
				,@ForcedSeek	
				,@ForcedScan	
				,@NoExpandHint	
				,@Storage	

			-- Reset the values so they won't be carried over to ther operations that don't include those parameters - START
			SET @Ordered		= NULL
			SET @ForcedIndex	= NULL
			SET @ForcedSeek		= NULL
			SET @ForcedScan		= NULL
			SET @NoExpandHint	= NULL
			SET @Storage		= NULL
			SET @LogicalOp		= NULL
			-- Reset the values so they won't be carried over to ther operations that don't include those parameters - END
		END
		-- Entering an XML section regarding Scan/Seek Index operations (Level-2 : Index used in the operation) - END
		----------------------------------
		--   Scan/Seek index   --  END  --
		----------------------------------


		-- XML line containing a column used by an index operation - START
		IF
		( 
			(@XMLContent.exist('/ColumnReference') = 1)
			AND
			(@XMLContent.value('(/ColumnReference/@Table)[1]', 'NVARCHAR(128)') IS NOT NULL)
			AND
			(@PlanMinerTable_Columns IS NOT NULL)
		)
		BEGIN
			INSERT INTO #PlanMinerTable_Columns
			SELECT 
				 @NodeID
				,[DatabaseNamePlan]		=	REPLACE(REPLACE(@XMLContent.value('(/ColumnReference/@Database)[1]',		'NVARCHAR(128)'),']',''),'[','')
				,[SchemaName]			=	REPLACE(REPLACE(@XMLContent.value('(/ColumnReference/@Schema)[1]',			'NVARCHAR(128)'),']',''),'[','')
				,[TableName]			=	REPLACE(REPLACE(@XMLContent.value('(/ColumnReference/@Table)[1]',			'NVARCHAR(128)'),']',''),'[','')
				,[ColumnName]			=	REPLACE(REPLACE(@XMLContent.value('(/ColumnReference/@Column)[1]',			'NVARCHAR(128)'),']',''),'[','')
		END
		-- XML line containing a column - END

		-- Move on to the next entry in #XMLContent corresponding to a column - START
        FETCH NEXT FROM [XMLContentCursor] INTO @LineNumber, @XMLContent
		-- Move on to the next entry in #XMLContent corresponding to a column - END
    END

CLOSE [XMLContentCursor]
DEALLOCATE [XMLContentCursor]
-- Analyze the XML lines that reference specific columns - END



-- Load the data extracted into the definitive tables provided - START
DECLARE @LoadDataTemplate	NVARCHAR(MAX) =
'INSERT INTO {@DestinationTable}
SELECT
	 ''{@ServerIdentifier}''
	,''{@DatabaseName}''
	,{@PlanID}
	,*
FROM {@SourceTable}'
SET @LoadDataTemplate = REPLACE(@LoadDataTemplate,	'{@ServerIdentifier}',	@ServerIdentifier)
SET @LoadDataTemplate = REPLACE(@LoadDataTemplate,	'{@DatabaseName}',		@DatabaseName)
SET @LoadDataTemplate = REPLACE(@LoadDataTemplate,	'{@PlanID}',			CAST(@PlanID AS NVARCHAR(16)))

DECLARE @LoadData			NVARCHAR(MAX)

IF (@PlanMinerTable_Columns IS NOT NULL)
BEGIN
	SET @LoadData = REPLACE(@LoadDataTemplate,	'{@DestinationTable}',	@PlanMinerTable_Columns)
	SET @LoadData = REPLACE(@LoadData,			'{@SourceTable}',		'#PlanMinerTable_Columns')
	IF (@VerboseMode = 1)
		PRINT (@LoadData)
	EXECUTE (@LoadData)
END
IF (@PlanMinerTable_Cursors IS NOT NULL)
BEGIN
	SET @LoadData = REPLACE(@LoadDataTemplate,	'{@DestinationTable}',	@PlanMinerTable_Cursors)
	SET @LoadData = REPLACE(@LoadData,			'{@SourceTable}',		'#PlanMinerTable_Cursors')
	IF (@VerboseMode = 1)
		PRINT (@LoadData)
	EXECUTE (@LoadData)
END
IF (@PlanMinerTable_IndexOperations IS NOT NULL)
BEGIN
	SET @LoadData = REPLACE(@LoadDataTemplate,	'{@DestinationTable}',	@PlanMinerTable_IndexOperations)
	SET @LoadData = REPLACE(@LoadData,			'{@SourceTable}',		'#PlanMinerTable_IndexOperations')
	IF (@VerboseMode = 1)
		PRINT (@LoadData)
	EXECUTE (@LoadData)
END
IF (@PlanMinerTable_MissingIndexes IS NOT NULL)
BEGIN
	SET @LoadData = REPLACE(@LoadDataTemplate,	'{@DestinationTable}',	@PlanMinerTable_MissingIndexes)
	SET @LoadData = REPLACE(@LoadData,			'{@SourceTable}',		'#PlanMinerTable_MissingIndexes')
	IF (@VerboseMode = 1)
		PRINT (@LoadData)
	EXECUTE (@LoadData)
END
IF (@PlanMinerTable_UnmatchedIndexes IS NOT NULL)
BEGIN
	SET @LoadData = REPLACE(@LoadDataTemplate,	'{@DestinationTable}',	@PlanMinerTable_UnmatchedIndexes)
	SET @LoadData = REPLACE(@LoadData,			'{@SourceTable}',		'#PlanMinerTable_UnmatchedIndexes')
	IF (@VerboseMode = 1)
		PRINT (@LoadData)
	EXECUTE (@LoadData)
END
IF (@PlanMinerTable_Statistics IS NOT NULL)
BEGIN
	SET @LoadData = REPLACE(@LoadDataTemplate,	'{@DestinationTable}',	@PlanMinerTable_Statistics)
	SET @LoadData = REPLACE(@LoadData,			'{@SourceTable}',		'#PlanMinerTable_Statistics')
	IF (@VerboseMode = 1)
		PRINT (@LoadData)
	EXECUTE (@LoadData)
END
IF (@PlanMinerTable_Nodes IS NOT NULL)
BEGIN
	SET @LoadData = REPLACE(@LoadDataTemplate,	'{@DestinationTable}',	@PlanMinerTable_Nodes)
	SET @LoadData = REPLACE(@LoadData,			'{@SourceTable}',		'#PlanMinerTable_Nodes')
	IF (@VerboseMode = 1)
		PRINT (@LoadData)
	EXECUTE (@LoadData)
END
-- Load the data extracted into the definitive tables provided - END


-- Drop temp tables used to store the plan info during the mining process - START
DROP TABLE IF EXISTS #PlanMinerTable_Columns
DROP TABLE IF EXISTS #PlanMinerTable_Cursors
DROP TABLE IF EXISTS #PlanMinerTable_IndexOperations
DROP TABLE IF EXISTS #PlanMinerTable_MissingIndexes
DROP TABLE IF EXISTS #PlanMinerTable_UnmatchedIndexes
DROP TABLE IF EXISTS #PlanMinerTable_Statistics
DROP TABLE IF EXISTS #PlanMinerTable_Nodes
-- Drop temp tables used to store the plan info during the mining process - END



SET @ReturnMessage = 'Completed successfully'
SET @ReturnCode = 0
RETURN

END
GO

