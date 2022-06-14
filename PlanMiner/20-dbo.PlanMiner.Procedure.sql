----------------------------------------------------------------------------------
-- Procedure Name: [dbo].[PlanMiner]
--
-- Desc: Analyzes the execution plans for each subquery of the selected Plan
--
--
-- Parameters:
--	INPUT
--		@InstanceIdentifier					-	SYSNAME
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
--		@PlanMinerTable_PlanList			-	NVARCHAR(800)
--			Table to stores the list of plans analyzed, along with a copy of the plan itself
--			See [dbo].[PlanMiner_PlanList]
--			[Default: '[dbo].[PlanMiner_PlanList]' ]
--
--		@PlanMinerTable_Statements			-	NVARCHAR(800)
--			Table to stores the statements that are included in the execution plan
--			If not provided, this information won't be stored
--			See [dbo].[PlanMiner_Statements]
--			[Default: '[dbo].[PlanMiner_Statements]' ]
--
--		@PlanMinerTable_MissingIndexes		-	NVARCHAR(800)
--			Table to store the details of the indexes the SQL engine consideres could improve its performance
--			If not provided, this information won't be stored
--			See [dbo].[PlanMiner_MissingIndexes]
--			[Default: '[dbo].[PlanMiner_MissingIndexes]' ]
--
--		@PlanMinerTable_UnmatchedIndexes	-	NVARCHAR(800)
--			Table to store the information about the filtered indexes not used due to the parameters in the WHERE clause not matching those in the indexes
--			If not provided, this information won't be stored
--			See [dbo].[PlanMiner_UnmatchedIndexes]
--			[Default: '[dbo].[PlanMiner_UnmatchedIndexes]' ]
--
--		@PlanMinerTable_Nodes				-	NVARCHAR(800)
--			Table to store the details of each node (operation) of the execution plan
--			If not provided, this information won't be stored
--			See [dbo].[PlanMiner_Nodes]
--			[Default: '[dbo].[PlanMiner_Nodes]' ]
--
--		@PlanMinerTable_Cursors				-	NVARCHAR(800)
--			Table to store the information about the cursor found in the execution plan (when applicable)
--			If not provided, this information won't be stored
--			See [dbo].[PlanMiner_Cursors]
--			[Default: '[dbo].[PlanMiner_Cursors]' ]
--
--		@PlanMinerTable_IndexOperations		-	NVARCHAR(800)
--			Table to store the information about the index operations (scan, seek, update, delete...) performed
--			If not provided, this information won't be stored
--			See [dbo].[PlanMiner_IndexOperations]
--			[Default: '[dbo].[PlanMiner_IndexOperations]' ]
--
--		@PlanMinerTable_Columns				-	NVARCHAR(800)
--			Table to stores the list of columns accessed with a certain execution plan on each of its operations (nodes)
--			If not provided, this information won't be stored
--			See [dbo].[PlanMiner_Columns]
--			[Default: '[dbo].[PlanMiner_Columns]' ]
--
--		@PlanMinerTable_Statistics			-	NVARCHAR(800)
--			Table to store the list of statistics used by the SQL Engine to elaborate this execution plan
--			If not provided, this information won't be stored
--			See [dbo].[PlanMiner_Statistics]
--			[Default: '[dbo].[PlanMiner_Statistics]' ]
--
--		@VerboseMode				-	BIT
--			Flag to enable/disable Verbose messages
--			[Default: 0]
--
--	OUTPUT
--		@ReturnMessage					-	NVARCHAR(MAX)
--			Message explaining the output of the procedure's execution
--		@ReturnCode						-	INT
--			<0 : Error performing the analysis
--			>=0 : Analysis completed successfully
--
-- Sample execution: all of them will store the details extracted from each plan in the default tables
--
--		*** Mine details of execution plan found in the SQL Server cache
--
--	DECLARE @PlanMinerID	BIGINT
--	EXECUTE [dbo].[PlanMiner]
--	 @InstanceIdentifier 	= 	'LocalServer01'
--	,@PlanHandle 			= 	0x0500060079E8D66530DEE7A80102000001000000000000000000000000000000000000000000000000000000
--	,@PlanMinerID 			= @PlanMinerID OUTPUT
--
--
--
-- 		*** Mine details of execution plan stored in Query Store
--
--	DECLARE @PlanMinerID	BIGINT
--	EXECUTE [dbo].[PlanMiner]
--	 @InstanceIdentifier 	= 	'LocalServer01
--	,@DatabaseName			= 	'TargetDB'
--	,@PlanID				= 	368
--	,@PlanMinerID 			= 	@PlanMinerID OUTPUT
--
--
--
--		*** Execution plan from file
--
--	DECLARE @PlanMinerID	BIGINT
--	EXECUTE [dbo].[PlanMiner]
--	 @PlanFile				= 	'C:\Temp\Plan01.xml'
--	,@PlanMinerID 			= 	@PlanMinerID OUTPUT
--
--
--
--		*** Access extracted data
--
--	SELECT * FROM [dbo].[vPlanMiner_PlanList]			WHERE [PlanMinerID] = @PlanMinerID
--	SELECT * FROM [dbo].[vPlanMiner_Statements]			WHERE [PlanMinerID] = @PlanMinerID
--	SELECT * FROM [dbo].[PlanMiner_MissingIndexes]		WHERE [PlanMinerID] = @PlanMinerID
--	SELECT * FROM [dbo].[PlanMiner_UnmatchedIndexes]	WHERE [PlanMinerID] = @PlanMinerID
--	SELECT * FROM [dbo].[PlanMiner_Nodes]				WHERE [PlanMinerID] = @PlanMinerID
--	SELECT * FROM [dbo].[PlanMiner_Cursors]				WHERE [PlanMinerID] = @PlanMinerID
--	SELECT * FROM [dbo].[PlanMiner_IndexOperations]		WHERE [PlanMinerID] = @PlanMinerID
--	SELECT * FROM [dbo].[PlanMiner_Columns]				WHERE [PlanMinerID] = @PlanMinerID
--	SELECT * FROM [dbo].[PlanMiner_Statistics]			WHERE [PlanMinerID] = @PlanMinerID
--
--
-- Date: 2021.05.08
-- Auth: Pablo Lozano (@sqlozano)
--
-- Date: 2022.06.14
-- Auth: Pablo Lozano (@sqlozano)
-- Added flag for KeyLoopup operations
----------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE [dbo].[PlanMiner]
(
	 @InstanceIdentifier				SYSNAME			=	NULL
	,@DatabaseName						SYSNAME			=	NULL
	,@PlanID							BIGINT 			=	NULL
	,@PlanHandle						VARBINARY(64)	=	NULL
	,@PlanFile							NVARCHAR(MAX)	=	NULL
	,@PlanMinerTable_PlanList			NVARCHAR(800)	=	'[dbo].[PlanMiner_PlanList]'
	,@PlanMinerTable_Statements			NVARCHAR(800)	=	'[dbo].[PlanMiner_Statements]'
	,@PlanMinerTable_MissingIndexes		NVARCHAR(800)	=	'[dbo].[PlanMiner_MissingIndexes]'
	,@PlanMinerTable_UnmatchedIndexes	NVARCHAR(800)	=	'[dbo].[PlanMiner_UnmatchedIndexes]'
	,@PlanMinerTable_Nodes				NVARCHAR(800)	=	'[dbo].[PlanMiner_Nodes]'
	,@PlanMinerTable_Cursors			NVARCHAR(800)	=	'[dbo].[PlanMiner_Cursors]'
	,@PlanMinerTable_IndexOperations	NVARCHAR(800)	=	'[dbo].[PlanMiner_IndexOperations]'
	,@PlanMinerTable_Columns			NVARCHAR(800)	=	'[dbo].[PlanMiner_Columns]'
	,@PlanMinerTable_Statistics			NVARCHAR(800)	=	'[dbo].[PlanMiner_Statistics]'

	,@VerboseMode			BIT = 0

	,@PlanMinerID			BIGINT			=	NULL	OUTPUT
)
AS
BEGIN
SET NOCOUNT ON

-- Check variables and set defaults - START
IF (@InstanceIdentifier IS NULL)
	SET @InstanceIdentifier = @@SERVERNAME

IF (@DatabaseName IS NULL) OR (@DatabaseName = '')
	SET @DatabaseName = DB_NAME()

IF (@PlanMinerTable_Statements		 = '')
	SET @PlanMinerTable_Statements			= NULL
IF (@PlanMinerTable_MissingIndexes	 = '')
	SET @PlanMinerTable_MissingIndexes		= NULL
IF (@PlanMinerTable_UnmatchedIndexes = '')
	SET @PlanMinerTable_UnmatchedIndexes	= NULL
IF (@PlanMinerTable_Nodes			 = '')
	SET @PlanMinerTable_Nodes				= NULL
IF (@PlanMinerTable_Cursors			 = '')
	SET @PlanMinerTable_Cursors				= NULL
IF (@PlanMinerTable_IndexOperations	 = '')
	SET @PlanMinerTable_IndexOperations		= NULL
IF (@PlanMinerTable_Columns			 = '')
	SET @PlanMinerTable_Columns				= NULL
IF (@PlanMinerTable_Statistics		 = '')
	SET @PlanMinerTable_Statistics			= NULL
-- Check variables and set defaults - END



-- Verify one and only one source has been selected for the execution plan - START
IF (@PlanFile IS NULL) AND (@PlanHandle IS NULL) AND (@PlanID IS NULL)
BEGIN
	RAISERROR('No valid source for the execution plan has been provided', 0, 1)
	RETURN
END

IF (
		( (@PlanFile	IS NOT NULL)	AND (@PlanHandle	IS NOT NULL))
		OR
		( (@PlanFile	IS NOT NULL)	AND (@PlanID		IS NOT NULL) )
		OR
		( (@PlanID		IS NOT NULL)	AND (@PlanHandle	IS NOT NULL) )
	)
BEGIN
	RAISERROR('More than one source for the execution plan has been provided', 0, 1)
	RETURN
END

DECLARE @MiningType	NVARCHAR(128)
IF (@PlanFile IS NOT NULL)
	SET @MiningType = 'File'
IF (@PlanHandle IS NOT NULL)
	SET @MiningType = 'PlanHandle'
IF (@PlanID IS NOT NULL)
	SET @MiningType = 'QueryStore'
-- Verify one and only one source has been selected for the execution plan - END



-- Obtain the execution plan from either source - START
DROP TABLE IF EXISTS #QueryPlan
CREATE TABLE #QueryPlan
(
	[QueryPlan]	NVARCHAR(MAX)
)
DECLARE @QueryPlan NVARCHAR(MAX)

IF (@PlanHandle IS NOT NULL)
BEGIN
	INSERT INTO #QueryPlan ([QueryPlan])
	SELECT CAST([query_plan] AS NVARCHAR(MAX)) FROM [sys].[dm_exec_query_plan](@PlanHandle)  
END

IF (@PlanFile IS NOT NULL)
BEGIN
	EXECUTE ('INSERT INTO #QueryPlan([QueryPlan]) SELECT CAST(TRY_CONVERT(XML, [BulkColumn]) AS NVARCHAR(MAX)) FROM OPENROWSET (BULK '''+@PlanFile+''', SINGLE_BLOB) AS [Plan]')
END

IF (@PlanID IS NOT NULL)
BEGIN
	DECLARE @CheckExistingPlanIDSQL NVARCHAR(MAX) =
	'INSERT INTO #QueryPlan 
	SELECT [query_plan]
	FROM [{@DatabaseName}].[sys].[query_store_plan] 
	WHERE [plan_id] = {@PlanID}'
	
	SET @CheckExistingPlanIDSQL = REPLACE(@CheckExistingPlanIDSQL, '{@DatabaseName}', @DatabaseName)
	SET @CheckExistingPlanIDSQL = REPLACE(@CheckExistingPlanIDSQL, '{@PlanID}', CAST(@PlanID AS NVARCHAR(128)))
	
	IF (@VerboseMode = 1)
		PRINT (@CheckExistingPlanIDSQL)
	EXECUTE (@CheckExistingPlanIDSQL)
END

SELECT @QueryPlan = [QueryPlan] FROM #QueryPlan

IF (@QueryPlan IS NULL)
BEGIN
	RAISERROR('No execution plan could be obtained with the provided input', 0, 1)
	RETURN
END
-- Obtain the execution plan from either source - END



-- Create an entry for the mined plan - START
DROP TABLE IF EXISTS #PlanMinerID
CREATE TABLE #PlanMinerID
(
	[PlanMinerID]	BIGINT
)

DECLARE @NewPlanMinerID NVARCHAR(MAX) =
'INSERT INTO {@PlanMinerTable_PlanList}
(
	 [MiningType]		
	,[InstanceIdentifier]
	,[DatabaseName]		
	,[PlanID]			
	,[PlanFile]
)
VALUES (
	 {@MiningType}
	,{@InstanceIdentifier}
	,{@DatabaseName}
	,{@PlanID}
	,{@PlanFile}
)
INSERT INTO #PlanMinerID
(
	[PlanMinerID]
)
SELECT IDENT_CURRENT(''{@PlanMinerTable_PlanList}'')
'

SET @NewPlanMinerID	=	REPLACE(@NewPlanMinerID,	'{@PlanMinerTable_PlanList}',	@PlanMinerTable_PlanList)
SET @NewPlanMinerID	=	REPLACE(@NewPlanMinerID,	'{@MiningType}',				'''' + @MiningType + '''')
SET @NewPlanMinerID	=	REPLACE(@NewPlanMinerID,	'{@InstanceIdentifier}',		'''' + @InstanceIdentifier + '''')
SET @NewPlanMinerID	=	REPLACE(@NewPlanMinerID,	'{@DatabaseName}',				'''' + @DatabaseName + '''')
SET @NewPlanMinerID	=	REPLACE(@NewPlanMinerID,	'{@PlanID}',					COALESCE(CAST(@PlanID AS NVARCHAR(128)),			'NULL')	)
SET @NewPlanMinerID	=	REPLACE(@NewPlanMinerID,	'{@PlanFile}',					COALESCE('''' + @PlanFile +'''',				'NULL')	)

IF (@VerboseMode = 1)
	PRINT (@NewPlanMinerID)
EXECUTE (@NewPlanMinerID)

SELECT @PlanMinerID = [PlanMinerID] FROM #PlanMinerID


-- Add the Plan Handle to @PlanMinerTable_PlanList (when provided) - START
IF (@PlanHandle IS NOT NULL)
BEGIN
	DROP TABLE IF EXISTS #PlanHandle
	CREATE TABLE #PlanHandle
	(
		[PlanHandle]	VARBINARY(64)
	)
	INSERT INTO #PlanHandle ([PlanHandle]) VALUES (@PlanHandle)

	DECLARE @AddPlanHandle NVARCHAR(MAX) = 
	'UPDATE {@PlanMinerTable_PlanList}
	SET [PlanHandle] = (SELECT TOP(1) [PlanHandle] FROM #PlanHandle)
	WHERE [PlanMinerID] = {@PlanMinerID}'
	
	SET @AddPlanHandle = REPLACE(@AddPlanHandle,	'{@PlanMinerTable_PlanList}',	@PlanMinerTable_PlanList)
	SET @AddPlanHandle = REPLACE(@AddPlanHandle,	'{@PlanMinerID}',				@PlanMinerID)
	
	IF (@VerboseMode = 1)
		PRINT (@AddPlanHandle)
	EXECUTE (@AddPlanHandle)

	DROP TABLE IF EXISTS #PlanHandle
END
-- Add the Plan Handle to @PlanMinerTable_PlanList (when provided) - END


-- Add the compressed plan to @PlanMinerTable_PlanList - START
DECLARE @AddCompressedPlan NVARCHAR(MAX) = 
'UPDATE {@PlanMinerTable_PlanList}
SET [CompressedPlan] = (SELECT TOP(1) COMPRESS([QueryPlan]) FROM #QueryPlan)
WHERE [PlanMinerID] = {@PlanMinerID}'

SET @AddCompressedPlan = REPLACE(@AddCompressedPlan,	'{@PlanMinerTable_PlanList}',	@PlanMinerTable_PlanList)
SET @AddCompressedPlan = REPLACE(@AddCompressedPlan,	'{@PlanMinerID}',				@PlanMinerID)

IF (@VerboseMode = 1)
	PRINT (@AddCompressedPlan)
EXECUTE (@AddCompressedPlan)
-- Add the compressed plan to @PlanMinerTable_PlanList - END


DROP TABLE IF EXISTS #PlanMinerID
DROP TABLE IF EXISTS #QueryPlan
-- Create an entry for the mined plan - END



---------------------------------------------------------
-- Analysis of the Execution Plan's contents -  START  --
---------------------------------------------------------

-- Table to contain the XML data (one line at a time) - START
DROP TABLE IF EXISTS #XMLContent
CREATE TABLE #XMLContent
(
	 [LineNumber]	INT
	,[LineContent]	NVARCHAR(MAX)
)
CREATE CLUSTERED INDEX [PK_XMLContent] ON #XMLContent ([LineNumber] ASC)
-- Table to contain the XML data (one line at a time) - END


-- Temp tables to store the data before the transfer to final table - START
DROP TABLE IF EXISTS #PlanMinerTable_Statements
DROP TABLE IF EXISTS #PlanMinerTable_MissingIndexes
DROP TABLE IF EXISTS #PlanMinerTable_UnmatchedIndexes
DROP TABLE IF EXISTS #PlanMinerTable_Nodes
DROP TABLE IF EXISTS #PlanMinerTable_Cursors
DROP TABLE IF EXISTS #PlanMinerTable_IndexOperations
DROP TABLE IF EXISTS #PlanMinerTable_Columns
DROP TABLE IF EXISTS #PlanMinerTable_Statistics
CREATE TABLE #PlanMinerTable_Statements
(
	 [StatementID]			INT				NOT NULL
	,[StatementCategory]	NVARCHAR(128)	NOT NULL
	,[StatementType]		NVARCHAR(128)	NOT NULL
	,[CompressedText]		VARBINARY(MAX)	NULL
)
CREATE TABLE #PlanMinerTable_MissingIndexes
(
	 [StatementID]		INT				NOT NULL
	,[MissingIndexID]	INT				NOT NULL
	,[Impact]			FLOAT			NULL
	,[DatabaseNamePlan]	NVARCHAR(128)	NULL
	,[SchemaName]		NVARCHAR(128)	NULL
	,[TableName]		NVARCHAR(128)	NULL
	,[Usage]			NVARCHAR(128)	NULL
	,[ColumnName]		NVARCHAR(128)	NULL
)
CREATE TABLE #PlanMinerTable_UnmatchedIndexes
(
	 [StatementID]			INT				NOT NULL
	,[DatabaseNamePlan]		NVARCHAR(128)	NULL
	,[SchemaName]			NVARCHAR(128)	NULL
	,[TableName]			NVARCHAR(128)	NULL
	,[UnmatchedIndexName]	NVARCHAR(128)	NULL
)
CREATE TABLE #PlanMinerTable_Nodes
(
	 [StatementID]					INT				NOT NULL
	,[NodeID]						INT				NOT NULL
	,[Depth]						INT				NOT NULL
	,[CursorOperationType]			NVARCHAR(128)	NOT NULL
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
CREATE TABLE #PlanMinerTable_Cursors
(
	 [StatementID]			INT				NOT NULL
	,[CursorName]			NVARCHAR(128)	NULL
	,[CursorActualType]		NVARCHAR(128)	NULL
	,[CursorRequestedType]	NVARCHAR(128)	NULL
	,[CursorConcurrency]	NVARCHAR(128)	NULL
	,[ForwardOnly]			BIT				NULL
)
CREATE TABLE #PlanMinerTable_IndexOperations
(
	 [StatementID]			INT				NOT NULL
	,[NodeID]				INT				NOT NULL
	,[DatabaseNamePlan]		NVARCHAR(128)	NULL
	,[SchemaName]			NVARCHAR(128)	NULL
	,[TableName]			NVARCHAR(128)	NULL
	,[IndexName]			NVARCHAR(128)	NULL
	,[IndexKind]			NVARCHAR(128)	NULL
	,[LogicalOp]			NVARCHAR(128)	NULL
	,[Lookup]				BIT				NULL
	,[Ordered]				BIT				NULL
	,[ForcedIndex]			BIT				NULL
	,[ForceSeek]			BIT				NULL
	,[ForceScan]			BIT				NULL
	,[NoExpandHint]			BIT				NULL
	,[Storage]				NVARCHAR(128)	NULL
)
CREATE TABLE #PlanMinerTable_Columns
(
	 [StatementID]			INT				NOT NULL
	,[NodeID]				INT				NOT NULL
	,[DatabaseNamePlan]		NVARCHAR(128)	NULL
	,[SchemaName]			NVARCHAR(128)	NULL
	,[TableName]			NVARCHAR(128)	NULL
	,[ColumnName]			NVARCHAR(128)	NOT NULL
)
CREATE TABLE #PlanMinerTable_Statistics
(
	 [StatementID]			INT				NOT NULL
	,[DatabaseNamePlan]		NVARCHAR(128)	NULL
	,[SchemaName]			NVARCHAR(128)	NULL
	,[TableName]			NVARCHAR(128)	NULL
	,[StatisticName]		NVARCHAR(128)	NULL
	,[ModificationCount]	BIGINT			NULL
	,[SamplingPercent]		FLOAT			NULL
	,[LastUpdate]			DATETIME2(7)	NULL
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
	SET @LineStart	= CHARINDEX('<', @QueryPlan, @LineEnd)
	SET @LineEnd	= CHARINDEX('>', @QueryPlan, @LineEnd + 1)
	SET @LineText	= SUBSTRING(@QueryPlan,@LineStart, 1 + @LineEnd - @LineStart)

	-- Insert Simple Statement - START
	IF(@LineText LIKE '<StmtSimple%')
	BEGIN
		-- To reformat the line into a valid XML file, substitute closing '>' with '/>'
		INSERT INTO #XMLContent ([LineNumber], [LineContent])
		VALUES (@LineNumber, REPLACE(REPLACE(@LineText, '>','/>'), '//', '/') )

		-- Move on to the next line
		SET @LineNumber = @LineNumber + 1
		CONTINUE
	END
	-- Insert Simple Statement - END

	-- Insert Conditional Statement - START
	IF(@LineText LIKE '<StmtCond%')
	BEGIN
		-- To reformat the line into a valid XML file, substitute closing '>' with '/>'
		INSERT INTO #XMLContent ([LineNumber], [LineContent])
		VALUES (@LineNumber, REPLACE(REPLACE(@LineText, '>','/>'), '//', '/') )

		-- Move on to the next line
		SET @LineNumber = @LineNumber + 1
		CONTINUE
	END
	-- Insert Conditional Statement - END

	-- Exiting Conditional Statement - START
	IF(@LineText = '</StmtCond>')
	BEGIN
		-- Customized exit code
		INSERT INTO #XMLContent ([LineNumber], [LineContent])
		VALUES (@LineNumber, '<ExitStmtCond/>' )

		-- Move on to the next line
		SET @LineNumber = @LineNumber + 1
		CONTINUE
	END
	-- Exiting Conditional Statement - END

	-- Exiting a Node - START
	IF(@LineText = '</RelOp>')
	BEGIN
		-- Customized exit code
		INSERT INTO #XMLContent ([LineNumber], [LineContent])
		VALUES (@LineNumber, '<ExitRelOp/>' )

		-- Move on to the next line
		SET @LineNumber = @LineNumber + 1
		CONTINUE
	END
	-- Exiting a Node - END

	-- Exiting an Operation - START
	IF(@LineText = '</Operation>')
	BEGIN
		-- Customized exit code
		INSERT INTO #XMLContent ([LineNumber], [LineContent])
		VALUES (@LineNumber, '<ExitOperation/>' )

		-- Move on to the next line
		SET @LineNumber = @LineNumber + 1
		CONTINUE
	END
	-- Exiting an Operation - END



	-- If the line is not a tag closure and not a cursor closure, insert it into #XMLContent - START
	IF (
		(CHARINDEX('</','_'+@LineText) = 0)
		AND
		@LineText NOT LIKE '<CursorPlan %/>'
		)
	BEGIN
		-- To reformat the line into a valid XML file, substitute closing '>' with '/>'
		INSERT INTO #XMLContent ([LineNumber], [LineContent])
		VALUES (@LineNumber, REPLACE(REPLACE(@LineText, '>','/>'), '//', '/') )

		-- Move on to the next line
		SET @LineNumber = @LineNumber + 1
		CONTINUE
	END
	-- If the line is not a tag closure, insert it into #XMLContent - END

END
-- Loop through each line (reading XML as plain text) - END

-- Analyze the XML lines that reference specific columns - START
DECLARE [XMLContentCursor] CURSOR LOCAL FAST_FORWARD
FOR
SELECT [LineNumber], TRY_CONVERT(XML,[LineContent])
FROM #XMLContent
ORDER BY [LineNumber] ASC

DECLARE @XMLContent	XML


-- Variable to store the StatementID - START
DECLARE @StatementID	INT = 0
-- Variable to store the StatementID - END

-- Variable to store the CursorID - START
DECLARE @CursorID		INT = 0
-- Variable to store the CursorID - END


-- Variable to store the plan depth - START
DECLARE @Depth			INT = 0
-- Variable to store the plan depth - END

-- Variable to identify what kind of Index is being processed - START
-- Values:  ReadWrite | Missing | Unmatched
DECLARE @IndexOperation NVARCHAR(128)
-- Variable to identify what kind of Index is being processed - END

-- Variable to differentiate between regular plans and cursor plans - START
DECLARE @CursorOperationType NVARCHAR(128) = 'None'
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
DECLARE @Lookup			BIT
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
WHILE (@@FETCH_STATUS = 0)
BEGIN
		-- Simple statement
		IF	(@XMLContent.exist('/StmtSimple') = 1 )
		BEGIN
			SET @StatementID = @XMLContent.value('(/StmtSimple/@StatementId)[1]', 'INT')
			INSERT INTO #PlanMinerTable_Statements
			SELECT
				 @XMLContent.value('(/StmtSimple/@StatementId)[1]',					'INT')
				,'Simple'
				,@XMLContent.value('(/StmtSimple/@StatementType)[1]',				'NVARCHAR(128)')
				,COMPRESS(@XMLContent.value('(/StmtSimple/@StatementText)[1]',		'NVARCHAR(MAX)'))
			FETCH NEXT FROM [XMLContentCursor] INTO @LineNumber, @XMLContent
			CONTINUE
		END

		-- Conditional statement
		IF	(@XMLContent.exist('/StmtCond') = 1 )
		BEGIN
			SET @StatementID		= @XMLContent.value('(/StmtCond/@StatementId)[1]', 'INT')
			INSERT INTO #PlanMinerTable_Statements
			SELECT
				 @XMLContent.value('(/StmtCond/@StatementId)[1]',				'INT')
				,'Conditional'
				,@XMLContent.value('(/StmtCond/@StatementType)[1]',				'NVARCHAR(128)')
				,COMPRESS(@XMLContent.value('(/StmtCond/@StatementText)[1]',	'NVARCHAR(MAX)'))
			FETCH NEXT FROM [XMLContentCursor] INTO @LineNumber, @XMLContent
			CONTINUE
		END

		-- Cursor statement
		IF	(
				@XMLContent.exist('/StmtCursor') = 1
				AND
				@XMLContent.value('(/StmtCursor/@StatementType)[1]',	'NVARCHAR(128)') = 'DECLARE CURSOR'
			)
		BEGIN
			SET @StatementID		= @XMLContent.value('(/StmtCursor/@StatementId)[1]', 'INT')
			INSERT INTO #PlanMinerTable_Statements
			SELECT
				 @XMLContent.value('(/StmtCursor/@StatementId)[1]',					'INT')
				,'Cursor'
				,@XMLContent.value('(/StmtCursor/@StatementType)[1]',				'NVARCHAR(128)')
				,COMPRESS(@XMLContent.value('(/StmtCursor/@StatementText)[1]',		'NVARCHAR(MAX)'))
			FETCH NEXT FROM [XMLContentCursor] INTO @LineNumber, @XMLContent
			CONTINUE
		END

		-- Special FETCH statement
		IF	(
				@XMLContent.exist('/Operation') = 1
				AND
				@XMLContent.value('(/Operation/@OperationType)[1]',	'NVARCHAR(128)') = 'FetchQuery'
			)
		BEGIN
			SET @CursorOperationType = 'FetchQuery'
			INSERT INTO #PlanMinerTable_Statements
			SELECT
				 @StatementID
				,'Cursor'
				,'FetchQuery'
				,NULL
			FETCH NEXT FROM [XMLContentCursor] INTO @LineNumber, @XMLContent
			CONTINUE
		END

		-- XML line containing a cursor type - START
		IF (@XMLContent.exist('/CursorPlan') = 1)
		BEGIN
			SET @Depth = 0
			IF (@PlanMinerTable_Cursors IS NOT NULL)
				INSERT INTO #PlanMinerTable_Cursors
				SELECT 
					 @StatementID
					,[CursorName]					=	@XMLContent.value('(/CursorPlan/@CursorName)[1]',					'NVARCHAR(128)')
					,[CursorActualType]				=	@XMLContent.value('(/CursorPlan/@CursorActualType)[1]',				'NVARCHAR(128)')
					,[CursorRequestedType]			=	@XMLContent.value('(/CursorPlan/@CursorRequestedType)[1]',			'NVARCHAR(128)')
					,[CursorConcurrency]			=	@XMLContent.value('(/CursorPlan/@CursorConcurrency)[1]',			'NVARCHAR(128)')
					,[ForwardOnly]					=	CASE @XMLContent.value('(/CursorPlan/@ForwardOnly)[1]',				'BIT')
															WHEN 'true' THEN 1
															ELSE 0
														END
			FETCH NEXT FROM [XMLContentCursor] INTO @LineNumber, @XMLContent
			CONTINUE
		END
		-- XML line containing a cursor type - END

		-- Operation - START
		IF (@XMLContent.exist('/Operation') = 1)
		BEGIN
			SET @CursorOperationType = @XMLContent.value('(/Operation/@OperationType)[1]',	'NVARCHAR(128)')
			FETCH NEXT FROM [XMLContentCursor] INTO @LineNumber, @XMLContent
			CONTINUE
		END
		IF (@XMLContent.exist('/ExitOperation') = 1)
		BEGIN
			SET @CursorOperationType = 'None'
			FETCH NEXT FROM [XMLContentCursor] INTO @LineNumber, @XMLContent
			CONTINUE
		END
		-- Operation - END

	
		-- XML line containing an node - START
		IF (@XMLContent.exist('/RelOp') = 1)
		BEGIN
			SET @Depth = @Depth + 1
			IF (@PlanMinerTable_Nodes	 IS NOT NULL)
				INSERT INTO #PlanMinerTable_Nodes
				SELECT 
					 [StatementID]					=	@StatementID
					,[NodeID]						=	@XMLContent.value('(/RelOp/@NodeId)[1]',					'INT')
					,@Depth
					,@CursorOperationType
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
			SET @LogicalOp	= @XMLContent.value('(/RelOp/@LogicalOp)[1]',	'NVARCHAR(128)')
			SET @NodeID		= @XMLContent.value('(/RelOp/@NodeId)[1]',		'INT')
			FETCH NEXT FROM [XMLContentCursor] INTO @LineNumber, @XMLContent
			CONTINUE
		END
		-- XML line containing an node - END

		-- XML line exiting an node (reducing node depth) - START
		IF (@XMLContent.exist('/ExitRelOp') = 1)
		BEGIN
			SET @Depth = @Depth - 1
			FETCH NEXT FROM [XMLContentCursor] INTO @LineNumber, @XMLContent
			CONTINUE
		END
		-- XML line exiting an node (reducing node depth) - END

		-- XML line containing Statistics used - START
		IF (@PlanMinerTable_Statistics IS NOT NULL)
		BEGIN
			IF (@XMLContent.exist('/StatisticsInfo') = 1)
			BEGIN
				INSERT INTO #PlanMinerTable_Statistics
				SELECT 
					 @StatementID
					,[DatabaseNamePlan]				=	REPLACE(REPLACE(@XMLContent.value('(/StatisticsInfo/@Database)[1]',		'NVARCHAR(128)'),']',''),'[','')
					,[SchemaName]					=	REPLACE(REPLACE(@XMLContent.value('(/StatisticsInfo/@Schema)[1]',		'NVARCHAR(128)'),']',''),'[','')
					,[TableName]					=	REPLACE(REPLACE(@XMLContent.value('(/StatisticsInfo/@Table)[1]',		'NVARCHAR(128)'),']',''),'[','')
					,[StatisticsName]				=	REPLACE(REPLACE(@XMLContent.value('(/StatisticsInfo/@Statistics)[1]',	'NVARCHAR(128)'),']',''),'[','')
					,[ModificationCount]			=	@XMLContent.value('(/StatisticsInfo/@ModificationCount)[1]',			'BIGINT')
					,[SamplingPercent]				=	@XMLContent.value('(/StatisticsInfo/@SamplingPercent)[1]',				'FLOAT')
					,[LastUpdate]					=	@XMLContent.value('(/StatisticsInfo/@LastUpdate)[1]',					'DATETIME2')
				FETCH NEXT FROM [XMLContentCursor] INTO @LineNumber, @XMLContent
				CONTINUE
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
			FETCH NEXT FROM [XMLContentCursor] INTO @LineNumber, @XMLContent
			CONTINUE
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
				 @StatementID
				,[DatabaseNamePlan]	=	REPLACE(REPLACE(@XMLContent.value('(/Object/@Database)[1]',		'NVARCHAR(128)'),']',''),'[','')
				,[SchemaName]		=	REPLACE(REPLACE(@XMLContent.value('(/Object/@Schema)[1]',		'NVARCHAR(128)'),']',''),'[','')
				,[TableName]		=	REPLACE(REPLACE(@XMLContent.value('(/Object/@Table)[1]',		'NVARCHAR(128)'),']',''),'[','')
				,[IndexName]		=	REPLACE(REPLACE(@XMLContent.value('(/Object/@Index)[1]',		'NVARCHAR(128)'),']',''),'[','')
			FETCH NEXT FROM [XMLContentCursor] INTO @LineNumber, @XMLContent
			CONTINUE
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
			FETCH NEXT FROM [XMLContentCursor] INTO @LineNumber, @XMLContent
			CONTINUE
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
			FETCH NEXT FROM [XMLContentCursor] INTO @LineNumber, @XMLContent
			CONTINUE
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
			FETCH NEXT FROM [XMLContentCursor] INTO @LineNumber, @XMLContent
			CONTINUE
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
				 @StatementID
				,@MissingIndexID
				,@Impact
				,@DatabaseNamePlan
				,@SchemaName
				,@TableName
				,@Usage
				,@XMLContent.value('(/Column/@Name)[1]',							'NVARCHAR(128)')
			FETCH NEXT FROM [XMLContentCursor] INTO @LineNumber, @XMLContent
			CONTINUE
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
			-- Temporaly store the IndexScan parameters to join them to the actual index details - START
			SELECT
				 @Lookup		=	COALESCE(@XMLContent.value('(/IndexScan/@Lookup)[1]',	'BIT'),0)
				,@Ordered		=	@XMLContent.value('(/IndexScan/@Ordered)[1]',			'BIT')
				,@ForcedIndex	=	@XMLContent.value('(/IndexScan/@ForcedIndex)[1]',		'BIT')
				,@ForcedSeek	=	@XMLContent.value('(/IndexScan/@ForceSeek)[1]',			'BIT')
				,@ForcedScan	=	@XMLContent.value('(/IndexScan/@ForceScan)[1]',			'BIT')
				,@NoExpandHint	=	@XMLContent.value('(/IndexScan/@NoExpandHint)[1]',		'BIT')
				,@Storage		=	@XMLContent.value('(/IndexScan/@Storage)[1]',			'NVARCHAR(128)')			
			-- Temporaly store the IndexScan parameters to join them to the actual index details - END
			FETCH NEXT FROM [XMLContentCursor] INTO @LineNumber, @XMLContent
			CONTINUE
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
				 @StatementID
				,@NodeID
				,[DatabaseNamePlan]	=	REPLACE(REPLACE(@XMLContent.value('(/Object/@Database)[1]',		'NVARCHAR(128)'),']',''),'[','')
				,[SchemaName]		=	REPLACE(REPLACE(@XMLContent.value('(/Object/@Schema)[1]',		'NVARCHAR(128)'),']',''),'[','')
				,[TableName]		=	REPLACE(REPLACE(@XMLContent.value('(/Object/@Table)[1]',		'NVARCHAR(128)'),']',''),'[','')
				,[IndexName]		=	REPLACE(REPLACE(@XMLContent.value('(/Object/@Index)[1]',		'NVARCHAR(128)'),']',''),'[','')
				,[IndexKind]		=	@XMLContent.value('(/Object/@IndexKind)[1]',					'NVARCHAR(128)')
				,@LogicalOp
				,@Lookup
				,@Ordered		
				,@ForcedIndex	
				,@ForcedSeek	
				,@ForcedScan	
				,@NoExpandHint	
				,@Storage	

			-- Reset the values so they won't be carried over to ther operations that don't include those parameters - START
			SET @Lookup			= NULL
			SET @Ordered		= NULL
			SET @ForcedIndex	= NULL
			SET @ForcedSeek		= NULL
			SET @ForcedScan		= NULL
			SET @NoExpandHint	= NULL
			SET @Storage		= NULL
			SET @LogicalOp		= NULL
			-- Reset the values so they won't be carried over to ther operations that don't include those parameters - END
			FETCH NEXT FROM [XMLContentCursor] INTO @LineNumber, @XMLContent
			CONTINUE
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
				 @StatementID
				,@NodeID
				,[DatabaseNamePlan]		=	REPLACE(REPLACE(@XMLContent.value('(/ColumnReference/@Database)[1]',		'NVARCHAR(128)'),']',''),'[','')
				,[SchemaName]			=	REPLACE(REPLACE(@XMLContent.value('(/ColumnReference/@Schema)[1]',			'NVARCHAR(128)'),']',''),'[','')
				,[TableName]			=	REPLACE(REPLACE(@XMLContent.value('(/ColumnReference/@Table)[1]',			'NVARCHAR(128)'),']',''),'[','')
				,[ColumnName]			=	REPLACE(REPLACE(@XMLContent.value('(/ColumnReference/@Column)[1]',			'NVARCHAR(128)'),']',''),'[','')
			FETCH NEXT FROM [XMLContentCursor] INTO @LineNumber, @XMLContent
			CONTINUE
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
	 {@PlanMinerID}
	,*
FROM {@SourceTable}'
SET @LoadDataTemplate = REPLACE(@LoadDataTemplate,	'{@InstanceIdentifier}',	@InstanceIdentifier)
SET @LoadDataTemplate = REPLACE(@LoadDataTemplate,	'{@DatabaseName}',		@DatabaseName)
SET @LoadDataTemplate = REPLACE(@LoadDataTemplate,	'{@PlanMinerID}',		CAST(@PlanMinerID AS NVARCHAR(128)))

DECLARE @LoadData			NVARCHAR(MAX)

IF (@PlanMinerTable_Statements IS NOT NULL)
BEGIN
	SET @LoadData = REPLACE(@LoadDataTemplate,	'{@DestinationTable}',	@PlanMinerTable_Statements)
	SET @LoadData = REPLACE(@LoadData,			'{@SourceTable}',		'#PlanMinerTable_Statements')
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
IF (@PlanMinerTable_Nodes IS NOT NULL)
BEGIN
	SET @LoadData = REPLACE(@LoadDataTemplate,	'{@DestinationTable}',	@PlanMinerTable_Nodes)
	SET @LoadData = REPLACE(@LoadData,			'{@SourceTable}',		'#PlanMinerTable_Nodes')
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
IF (@PlanMinerTable_Columns IS NOT NULL)
BEGIN
	SET @LoadData = REPLACE(@LoadDataTemplate,	'{@DestinationTable}',	@PlanMinerTable_Columns)
	SET @LoadData = REPLACE(@LoadData,			'{@SourceTable}',		'#PlanMinerTable_Columns')
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
-- Load the data extracted into the definitive tables provided - END


-- Drop temp tables used to store the plan info during the mining process - START
DROP TABLE IF EXISTS #PlanMinerTable_Statements
DROP TABLE IF EXISTS #PlanMinerTable_MissingIndexes
DROP TABLE IF EXISTS #PlanMinerTable_UnmatchedIndexes
DROP TABLE IF EXISTS #PlanMinerTable_Nodes
DROP TABLE IF EXISTS #PlanMinerTable_Cursors
DROP TABLE IF EXISTS #PlanMinerTable_IndexOperations
DROP TABLE IF EXISTS #PlanMinerTable_Columns
DROP TABLE IF EXISTS #PlanMinerTable_Statistics
-- Drop temp tables used to store the plan info during the mining process - END

DROP TABLE IF EXISTS #XMLContent


RETURN

END
GO
