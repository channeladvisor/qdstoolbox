----------------------------------------------------------------------------------
-- View Name: [dbo].[vServerTopObjectsStore]
--
-- Desc: This view is built on top of [ServerTopObjectsStore] to extract the details of the top queries identified by the execution of [dbo].[ServerTopObjects]
--
--		[ReportID]				BIGINT			NOT NULL
--			Unique Identifier for the execution (operations not logged to table have no ReportID)
--
--		[DatabaseName]			SYSNAME			NOT NULL
--			Name of the databse the information of the following columns has been extracted from
--
--		[ObjectID]				BIGINT			NOT NULL
--			Identifier of the object
--
--		[SchemaName]			SYSNAME			    NULL
--			Name of the object's schema
--
--		[ObjectName]			SYSNAME			    NULL
--			Name of the object (if any)
--
--		[ExecutionTypeDesc]		NVARCHAR(120)	NOT NULL
--			Description of the execution type (Regular, Aborted, Exception)
--
--		[EstimatedExecutionCount]		BIGINT			NOT NULL
--			Number of executions of the corresponding [ObjectID] and with the same [ExecutionTypeDes]
--
--		[Duration]				BIGINT			NOT NULL
--			Total duration of all executions of the corresponding [ObjectID] in microseconds
--
--		[CPU]					BIGINT			NOT NULL
--			Total CPU time of all executions of the corresponding [ObjectID] in microseconds
--
--		[LogicalIOReads]		BIGINT			NOT NULL
--			Total Logical IO reads of all executions of the corresponding [ObjectID] in 8 KB pages
--
--		[LogicalIOWrites]		BIGINT			NOT NULL
--			Total Logical IO Writes of all executions of the corresponding [ObjectID] in 8 KB pages
--
--		[PhysicalIOReads]		BIGINT			NOT NULL
--			Total Physical IO Reads of all executions of the corresponding [ObjectID] in 8 KB pages
--
--		[CLR]					BIGINT			NOT NULL
--			Total CLR time of all executions of the corresponding [ObjectID] in microseconds
--
--		[Memory]				BIGINT			NOT NULL
--			Total Memory usage of all executions of the corresponding [ObjectID] in 8 KB pages
--
--		[LogBytes]				BIGINT				NULL
--			Total Log bytes usage of all executions of the corresponding [ObjectID] in Bytes
--			NULL for SQL 2016 (the metric is not registered in this version)
--
--		[TempDBSpace]			BIGINT				NULL
--			Total TempDB space usage of all executions of the corresponding [ObjectID] in 8 KB pages
--			NULL for SQL 2016 (the metric is not registered in this version)
--
-- Date: 2022.10.18
-- Auth: Pablo Lozano (@sqlozano)
-- Desc: Created based on [dbo].[vServerTopObjectsStore]
----------------------------------------------------------------------------------

CREATE OR ALTER VIEW [dbo].[vServerTopObjectsStore]
AS
SELECT
	 [stoi].[ReportID]
	,[stoi].[CaptureDate]
	,[stoi].[ServerIdentifier]
	,[stoi].[Measurement]
	,[stoi].[Percentages]
	,[stos].[DatabaseName]
	,[stos].[ObjectID]
	,[stos].[SchemaName]
	,[stos].[ObjectName]
	,[stos].[ExecutionTypeDesc]
	,[stos].[EstimatedExecutionCount]
	,[stos].[Duration]
	,[stos].[CPU]
	,[stos].[LogicalIOReads]
	,[stos].[LogicalIOWrites]
	,[stos].[PhysicalIOReads]
	,[stos].[CLR]
	,[stos].[Memory]
	,[stos].[LogBytes]
	,[stos].[TempDBSpace]
FROM [dbo].[vServerTopObjectsIndex] [stoi]
INNER JOIN [dbo].[ServerTopObjectsStore] [stos]
ON [stoi].[ReportID] = [stos].[ReportID]