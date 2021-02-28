SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

----------------------------------------------------------------------------------
-- View Name: [dbo].[query_store_wait_stats_pivoted]
--
-- Desc: This view pivots the contents of the sys.query_store_wait_stats into columns, adding the average wait stats metric to it
--
--
-- Date: 2020.10.22
-- Auth: Pablo Lozano (@sqlozano)
--
-- Date: 2021.02.28
-- Auth: Pablo Lozano (@sqlozano)
-- Changes:	This view is not compatible with SQL 2016 (no wait stats captured before SQL 2017), so this script will raise an error
----------------------------------------------------------------------------------

-- Get the Version # to ensure it runs SQL2016 or higher
DECLARE @Version INT =  CAST(SUBSTRING(CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')),0,CHARINDEX('.',CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')),0)) AS INT)
IF (@Version < 14)
BEGIN
	RAISERROR('[dbo].[query_store_wait_stats_pivoted] requires SQL 2017 or higher',16,1)
END
ELSE
BEGIN
DECLARE @CreateView NVARCHAR(MAX) = 
'CREATE OR ALTER VIEW [dbo].[query_store_wait_stats_pivoted]
AS
SELECT 
	 [runtime_stats_interval_id]
	,[plan_id]
	,[count_executions]
	,ISNULL([Unknown],0)  AS [Total_Unknown]
	,ISNULL(ROUND(CONVERT(float,[Unknown]*1.00/[count_executions]),2) , 0)  AS [Average_Unknown]
	,ISNULL([CPU],0)  AS [Total_CPU]
	,ISNULL(ROUND(CONVERT(float,[CPU]*1.00/[count_executions]),2) , 0)  AS [Average_CPU]
	,ISNULL([Worker Thread],0)  AS [Total_WorkerThread]
	,ISNULL(ROUND(CONVERT(float,[Worker Thread]*1.00/[count_executions]),2) , 0)  AS [Average_WorkerThread]
	,ISNULL([Lock],0)  AS [Total_Lock]
	,ISNULL(ROUND(CONVERT(float,[Lock]*1.00/[count_executions]),2) , 0)  AS [Average_Lock]
	,ISNULL([Latch],0)  AS [Total_Latch]
	,ISNULL(ROUND(CONVERT(float,[Latch]*1.00/[count_executions]),2) , 0)  AS [Average_Latch]
	,ISNULL([Buffer Latch],0)  AS [Total_BufferLatch]
	,ISNULL(ROUND(CONVERT(float,[Buffer Latch]*1.00/[count_executions]),2) , 0)  AS [Average_BufferLatch]
	,ISNULL([Buffer IO],0)  AS [Total_BufferIO]
	,ISNULL(ROUND(CONVERT(float,[Buffer IO]*1.00/[count_executions]),2) , 0)  AS [Average_BufferIO]
	,ISNULL([Compilation],0)  AS [Total_Compilation]
	,ISNULL(ROUND(CONVERT(float,[Compilation]*1.00/[count_executions]),2) , 0)  AS [Average_Compilation]
	,ISNULL([SQL CLR],0)  AS [Total_SQLCLR]
	,ISNULL(ROUND(CONVERT(float,[SQL CLR]*1.00/[count_executions]),2) , 0)  AS [Average_SQLCLR]
	,ISNULL([Mirroring],0)  AS [Total_Mirroring]
	,ISNULL(ROUND(CONVERT(float,[Mirroring]*1.00/[count_executions]),2) , 0)  AS [Average_Mirroring]
	,ISNULL([Transaction],0)  AS [Total_Transaction]
	,ISNULL(ROUND(CONVERT(float,[Transaction]*1.00/[count_executions]),2) , 0)  AS [Average_Transaction]
	,ISNULL([Idle],0)  AS [Total_Idle]
	,ISNULL(ROUND(CONVERT(float,[Idle]*1.00/[count_executions]),2) , 0)  AS [Average_Idle]
	,ISNULL([Preemptive],0)  AS [Total_Preemptive]
	,ISNULL(ROUND(CONVERT(float,[Preemptive]*1.00/[count_executions]),2) , 0)  AS [Average_Preemptive]
	,ISNULL([Service Broker],0)  AS [Total_ServiceBroker]
	,ISNULL(ROUND(CONVERT(float,[Service Broker]*1.00/[count_executions]),2) , 0)  AS [Average_ServiceBroker]
	,ISNULL([Tran Log IO],0)  AS [Total_TranLogIO]
	,ISNULL(ROUND(CONVERT(float,[Tran Log IO]*1.00/[count_executions]),2) , 0)  AS [Average_TranLogIO]
	,ISNULL([Network IO],0)  AS [Total_NetworkIO]
	,ISNULL(ROUND(CONVERT(float,[Network IO]*1.00/[count_executions]),2) , 0)  AS [Average_NetworkIO]
	,ISNULL([Parallelism],0)  AS [Total_Parallelism]
	,ISNULL(ROUND(CONVERT(float,[Parallelism]*1.00/[count_executions]),2) , 0)  AS [Average_Parallelism]
	,ISNULL([Memory],0)  AS [Total_Memory]
	,ISNULL(ROUND(CONVERT(float,[Memory]*1.00/[count_executions]),2) , 0)  AS [Average_Memory]
	,ISNULL([User Wait],0)  AS [Total_UserWait]
	,ISNULL(ROUND(CONVERT(float,[User Wait]*1.00/[count_executions]),2) , 0)  AS [Average_UserWait]
	,ISNULL([Tracing],0)  AS [Total_Tracing]
	,ISNULL(ROUND(CONVERT(float,[Tracing]*1.00/[count_executions]),2) , 0)  AS [Average_Tracing]
	,ISNULL([Full Text Search],0)  AS [Total_FullTextSearch]
	,ISNULL(ROUND(CONVERT(float,[Full Text Search]*1.00/[count_executions]),2) , 0)  AS [Average_FullTextSearch]
	,ISNULL([Other Disk IO],0)  AS [Total_OtherDiskIO]
	,ISNULL(ROUND(CONVERT(float,[Other Disk IO]*1.00/[count_executions]),2) , 0)  AS [Average_OtherDiskIO]
	,ISNULL([Replication],0)  AS [Total_Replication]
	,ISNULL(ROUND(CONVERT(float,[Replication]*1.00/[count_executions]),2) , 0)  AS [Average_Replication]
	,ISNULL([Log Rate Governor],0)  AS [Total_LogRateGovernor]
	,ISNULL(ROUND(CONVERT(float,[Log Rate Governor]*1.00/[count_executions]),2) , 0)  AS [Average_LogRateGovernor]
FROM
(
	SELECT
		 [qsws].[runtime_stats_interval_id]
		,[qsws].[plan_id]
		,[qsrs].[count_executions]
		,[qsws].[wait_category_desc]
		,[qsws].[total_query_wait_time_ms]
	FROM [sys].[query_store_wait_stats] [qsws]
	INNER JOIN [sys].[query_store_runtime_stats] [qsrs]
	ON [qsws].[runtime_stats_interval_id] = [qsrs].[runtime_stats_interval_id]
	AND [qsws].[plan_id] = [qsrs].[plan_id]
) as [SourceTable]
PIVOT (
	SUM([total_query_wait_time_ms])
	FOR [wait_category_desc] IN 
	(
		 [Unknown]
		,[CPU]
		,[Worker Thread]
		,[Lock]
		,[Latch]
		,[Buffer Latch]
		,[Buffer IO]
		,[Compilation]
		,[SQL CLR]
		,[Mirroring]
		,[Transaction]
		,[Idle]
		,[Preemptive]
		,[Service Broker]
		,[Tran Log IO]
		,[Network IO]
		,[Parallelism]
		,[Memory]
		,[User Wait]
		,[Tracing]
		,[Full Text Search]
		,[Other Disk IO]
		,[Replication]
		,[Log Rate Governor]
	)
	)
	AS [PivotTable]'

EXECUTE (@CreateView)
END