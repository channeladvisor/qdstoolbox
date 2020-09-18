DROP TABLE IF EXISTS [dbo].[QDSMetricArchive]
CREATE TABLE [dbo].[QDSMetricArchive]
(
	[Measurement]		NVARCHAR(32)	NOT NULL, -- CPU, Duration...
	[Metric]			NVARCHAR(16)	NOT NULL, -- Total, max...
	[Unit]				NVARCHAR(32)	NOT NULL, -- ms, kbs....
	[SubQuery01]		NVARCHAR(MAX)	NOT NULL,
	[SubQuery02]		NVARCHAR(MAX)	NOT NULL,
	[SubQuery03]		NVARCHAR(MAX)	NOT NULL,
	[SubQuery04]		NVARCHAR(MAX)	NOT NULL
)
GO
ALTER TABLE [dbo].[QDSMetricArchive] ADD CONSTRAINT [PK_QDSMetricArchive] PRIMARY KEY CLUSTERED ([Measurement] ASC, [Metric] ASC)
GO

-- CLR.Avg - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'CLR', 
'Avg',
'탎',
'ROUND(CONVERT(FLOAT, SUM([qsrs].[avg_clr_time]*[qsrs].[count_executions]))/NULLIF(SUM([qsrs].[count_executions]), 0),2) [avg_clr_time],',
'[results].[clr_time_regr_perc_recent] [CLR_Avg_Variation_%],
		[results].[avg_clr_time_recent] [CLR_Avg_Recent_Microseconds],
		[results].[avg_clr_time_hist] [CLR_Avg_History_Microseconds],',
'ROUND(CONVERT(FLOAT, [recent].[avg_clr_time]-[hist].[avg_clr_time])/NULLIF([hist].[avg_clr_time],0)*100.0, 2) [clr_time_regr_perc_recent],
		ROUND([recent].[avg_clr_time], 2) [avg_clr_time_recent],
		ROUND([hist].[avg_clr_time], 2) [avg_clr_time_hist],',
'[clr_time_regr_perc_recent]'
)
-- CLR.Avg - END

-- CLR.Max - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'CLR', 
'Max',
'탎',
'ROUND(CONVERT(FLOAT, MAX([qsrs].[max_clr_time])),2) [max_clr_time],',
'[results].[clr_time_regr_perc_recent] [CLR_Max_Variation_%],
		[results].[max_clr_time_recent] [CLR_Max_Recent_Microseconds],
		[results].[max_clr_time_hist] [CLR_Max_History_Microseconds],',
'ROUND(CONVERT(FLOAT, [recent].[max_clr_time]-[hist].[max_clr_time])/NULLIF([hist].[max_clr_time],0)*100.0, 2) [clr_time_regr_perc_recent],
		ROUND([recent].[max_clr_time], 2) [max_clr_time_recent],
		ROUND([hist].[max_clr_time], 2) [max_clr_time_hist],',
'[clr_time_regr_perc_recent]'
)
-- CLR.Max - END

-- CLR.Min - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'CLR', 
'Min',
'탎',
'ROUND(CONVERT(FLOAT, MIN([qsrs].[min_clr_time])),2) [min_clr_time],',
'[results].[clr_time_regr_perc_recent] [CLR_Min_Variation_%],
		[results].[min_clr_time_recent] [CLR_Min_Recent_Microseconds],
		[results].[min_clr_time_hist] [CLR_Min_History_Microseconds],',
'ROUND(CONVERT(FLOAT, [recent].[min_clr_time]-[hist].[min_clr_time])/NULLIF([hist].[min_clr_time],0)*100.0, 2) [clr_time_regr_perc_recent],
		ROUND([recent].[min_clr_time], 2) [min_clr_time_recent],
		ROUND([hist].[min_clr_time], 2) [min_clr_time_hist],',
'[clr_time_regr_perc_recent]'
)
-- CLR.Min - END

-- CLR.StdDev - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'CLR', 
'StdDev',
'탎',
'ROUND(CONVERT(FLOAT, SQRT( SUM([qsrs].[stdev_clr_time]*[qsrs].[stdev_clr_time]*[qsrs].[count_executions])/NULLIF(SUM([qsrs].[count_executions]), 0))),2) [stdev_clr_time],',
'[results].[clr_time_regr_perc_recent] [CLR_StdDev_Variation_%],
		[results].[stdev_clr_time_recent] [CLR_StdDev_Recent_Microseconds],
		[results].[stdev_clr_time_hist] [CLR_StdDev_History_Microseconds],',
'ROUND(CONVERT(FLOAT, [recent].[stdev_clr_time]-[hist].[stdev_clr_time])/NULLIF([hist].[stdev_clr_time],0)*100.0, 2) [clr_time_regr_perc_recent],
		ROUND([recent].[stdev_clr_time], 2) [stdev_clr_time_recent],
		ROUND([hist].[stdev_clr_time], 2) [stdev_clr_time_hist],',
'[clr_time_regr_perc_recent]'
)
-- CLR.StdDev - END

-- CLR.Total - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'CLR', 
'Total',
'탎',
'ROUND(CONVERT(FLOAT, SUM([qsrs].[avg_clr_time]*[qsrs].[count_executions])),2) [total_clr_time],',
'[results].[clr_time_regr_perc_recent] [CLR_Total_Variation_%],
		[results].[total_clr_time_recent] [CLR_Total_Recent_Microseconds],
		[results].[total_clr_time_hist] [CLR_Total_History_Microseconds],',
--'ROUND(CONVERT(FLOAT, [recent].[total_clr_time]-[hist].[total_clr_time])/NULLIF([hist].[total_clr_time],0)*100.0, 2) [additional_clr_time_workload],
'ROUND(CONVERT(FLOAT, ([recent].[total_clr_time]-[hist].[total_clr_time])/IIF([hist].[total_clr_time]>0, [hist].[total_clr_time], 1))*100.0, 2) [clr_time_regr_perc_recent],
		ROUND([recent].[total_clr_time], 2) [total_clr_time_recent],
		ROUND([hist].[total_clr_time], 2) [total_clr_time_hist],',
'[clr_time_regr_perc_recent]'
)
-- CLR.Total - END


-- CPU.Avg - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'CPU', 
'Avg',
'탎',
'ROUND(CONVERT(FLOAT, SUM([qsrs].[avg_cpu_time]*[qsrs].[count_executions]))/NULLIF(SUM([qsrs].[count_executions]), 0),2) [avg_cpu_time],',
'[results].[cpu_time_regr_perc_recent] [CPU_Avg_Variation_%],
		[results].[avg_cpu_time_recent] [CPU_Avg_Recent_Microseconds],
		[results].[avg_cpu_time_hist] [CPU_Avg_History_Microseconds],',
'ROUND(CONVERT(FLOAT, [recent].[avg_cpu_time]-[hist].[avg_cpu_time])/NULLIF([hist].[avg_cpu_time],0)*100.0, 2) [cpu_time_regr_perc_recent],
		ROUND([recent].[avg_cpu_time], 2) [avg_cpu_time_recent],
		ROUND([hist].[avg_cpu_time], 2) [avg_cpu_time_hist],',
'[cpu_time_regr_perc_recent]'
)
-- CPU.Avg - END


-- CPU.Max - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'CPU', 
'Max',
'탎',
'ROUND(CONVERT(FLOAT, MAX([qsrs].[max_cpu_time])),2) [max_cpu_time],',
'[results].[cpu_time_regr_perc_recent] [CPU_Max_Variation_%],
		[results].[max_cpu_time_recent] [CPU_Max_Recent_Microseconds],
		[results].[max_cpu_time_hist] [CPU_Max_History_Microseconds],',
'ROUND(CONVERT(FLOAT, [recent].[max_cpu_time]-[hist].[max_cpu_time])/NULLIF([hist].[max_cpu_time],0)*100.0, 2) [cpu_time_regr_perc_recent],
		ROUND([recent].[max_cpu_time], 2) [max_cpu_time_recent],
		ROUND([hist].[max_cpu_time], 2) [max_cpu_time_hist],',
'[cpu_time_regr_perc_recent]'
)
-- CPU.Max - END


-- CPU.Min - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'CPU', 
'Min',
'탎',
'ROUND(CONVERT(FLOAT, MIN([qsrs].[min_cpu_time])),2) [min_cpu_time],',
'[results].[cpu_time_regr_perc_recent] [CPU_Min_Variation_%],
		[results].[min_cpu_time_recent] [CPU_Min_Recent_Microseconds],
		[results].[min_cpu_time_hist] [CPU_Min_History_Microseconds],',
'ROUND(CONVERT(FLOAT, [recent].[min_cpu_time]-[hist].[min_cpu_time])/NULLIF([hist].[min_cpu_time],0)*100.0, 2) [cpu_time_regr_perc_recent],
		ROUND([recent].[min_cpu_time], 2) [min_cpu_time_recent],
		ROUND([hist].[min_cpu_time], 2) [min_cpu_time_hist],',
'[cpu_time_regr_perc_recent]'
)
-- CPU.Min - END


-- CPU.StdDev - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'CPU', 
'StdDev',
'탎',
'ROUND(CONVERT(FLOAT, SQRT( SUM([qsrs].[stdev_cpu_time]*[qsrs].[stdev_cpu_time]*[qsrs].[count_executions])/NULLIF(SUM([qsrs].[count_executions]), 0))),2) [stdev_cpu_time],',
'[results].[cpu_time_regr_perc_recent] [CPU_StdDev_Variation_%],
		[results].[stdev_cpu_time_recent] [CPU_StdDev_Recent_Microseconds],
		[results].[stdev_cpu_time_hist] [CPU_StdDev_History_Microseconds],',
'ROUND(CONVERT(FLOAT, [recent].[stdev_cpu_time]-[hist].[stdev_cpu_time])/NULLIF([hist].[stdev_cpu_time],0)*100.0, 2) [cpu_time_regr_perc_recent],
		ROUND([recent].[stdev_cpu_time], 2) [stdev_cpu_time_recent],
		ROUND([hist].[stdev_cpu_time], 2) [stdev_cpu_time_hist],',
'[cpu_time_regr_perc_recent]'
)
-- CPU.StdDev - END


-- CPU.Total - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'CPU', 
'Total',
'탎',
'ROUND(CONVERT(FLOAT, SUM([qsrs].[avg_cpu_time]*[qsrs].[count_executions])),2) [total_cpu_time],',
'[results].[cpu_time_regr_perc_recent] [CPU_Total_Variation_%],
		[results].[total_cpu_time_recent] [CPU_Total_Recent_Microseconds],
		[results].[total_cpu_time_hist] [CPU_Total_History_Microseconds],',
--'ROUND(CONVERT(FLOAT, [recent].[total_cpu_time]/[recent].[count_executions]-[hist].[total_cpu_time]/[hist].[count_executions])*([recent].[count_executions]), 2) [additional_cpu_time_workload],
'ROUND(CONVERT(FLOAT, ([recent].[total_cpu_time]-[hist].[total_cpu_time])/IIF([hist].[total_cpu_time]>0, [hist].[total_cpu_time], 1))*100.0, 2) [cpu_time_regr_perc_recent],
		ROUND([recent].[total_cpu_time], 2) [total_cpu_time_recent],
		ROUND([hist].[total_cpu_time], 2) [total_cpu_time_hist],',
'[cpu_time_regr_perc_recent]'
)
-- CPU.Total - END


-- DOP.Avg - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'DOP', 
'Avg',
'Degree of Parallelism',
'ROUND(CONVERT(FLOAT, SUM([qsrs].[avg_dop]*[qsrs].[count_executions]))/NULLIF(SUM([qsrs].[count_executions]), 0)*1,0) [avg_dop],',
'[results].[dop_regr_perc_recent] [DOP_Avg_Variation_%],
		[results].[avg_dop_recent] [DOP_Avg_Recent],
		[results].[avg_dop_hist] [DOP_Avg_History],',
'ROUND(CONVERT(FLOAT, [recent].[avg_dop]-[hist].[avg_dop])/NULLIF([hist].[avg_dop],0)*100.0, 2) [dop_regr_perc_recent],
		ROUND([recent].[avg_dop], 2) [avg_dop_recent],
		ROUND([hist].[avg_dop], 2) [avg_dop_hist],',
'[dop_regr_perc_recent]'
)
-- DOP.Avg - END


-- DOP.Max - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'DOP', 
'Max',
'Degree of Parallelism',
'ROUND(CONVERT(FLOAT, MAX([qsrs].[max_dop]))*1,2) [max_dop],',
'[results].[dop_regr_perc_recent] [DOP_Max_Variation_%],
		[results].[max_dop_recent] [DOP_Max_Recent],
		[results].[max_dop_hist] [DOP_Max_History],',
'ROUND(CONVERT(FLOAT, [recent].[max_dop]-[hist].[max_dop])/NULLIF([hist].[max_dop],0)*100.0, 2) [dop_regr_perc_recent],
		ROUND([recent].[max_dop], 2) [max_dop_recent],
		ROUND([hist].[max_dop], 2) [max_dop_hist],',
'[dop_regr_perc_recent]'
)
-- DOP.Max - END

-- DOP.Min - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'DOP', 
'Min',
'Degree of Parallelism',
'ROUND(CONVERT(FLOAT, MIN([qsrs].[min_dop]))*1,2) [min_dop],',
'[results].[dop_regr_perc_recent] [DOP_Min_Variation_%],
		[results].[min_dop_recent] [DOP_Min_Recent],
		[results].[min_dop_hist] [DOP_Min_History],',
'ROUND(CONVERT(FLOAT, [recent].[min_dop]-[hist].[min_dop])/NULLIF([hist].[min_dop],0)*100.0, 2) [dop_regr_perc_recent],
		ROUND([recent].[min_dop], 2) [min_dop_recent],
		ROUND([hist].[min_dop], 2) [min_dop_hist],',
'[dop_regr_perc_recent]'
)
-- DOP.Min - END


-- DOP.StdDev - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'DOP', 
'StdDev',
'Degree of Parallelism',
'ROUND(CONVERT(FLOAT, SQRT( SUM([qsrs].[stdev_dop]*[qsrs].[stdev_dop]*[qsrs].[count_executions])/NULLIF(SUM([qsrs].[count_executions]), 0)))*1,2) [stdev_dop],',
'[results].[dop_regr_perc_recent] [DOP_StdDev_Variation_%],
		[results].[stdev_dop_recent] [DOP_StdDev_Recent],
		[results].[stdev_dop_hist] [DOP_StdDev_History],',
'ROUND(CONVERT(FLOAT, [recent].[stdev_dop]-[hist].[stdev_dop])/NULLIF([hist].[stdev_dop],0)*100.0, 2) [dop_regr_perc_recent],
		ROUND([recent].[stdev_dop], 2) [stdev_dop_recent],
		ROUND([hist].[stdev_dop], 2) [stdev_dop_hist],',
'[dop_regr_perc_recent]'
)
-- DOP.StdDev - END


-- DOP.Total - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'DOP', 
'Total',
'Degree of Parallelism',
'ROUND(CONVERT(FLOAT, SUM([qsrs].[avg_dop]*[qsrs].[count_executions]))*1,2) [total_dop],',
'[results].[dop_regr_perc_recent] [DOP_Total_Variation_%],
		[results].[total_dop_recent] [DOP_Total_Recent],
		[results].[total_dop_hist] [DOP_Total_History],',
--'ROUND(CONVERT(FLOAT, [recent].[total_dop]/[recent].[count_executions]-[hist].[total_dop]/[hist].[count_executions])*([recent].[count_executions]), 2) [additional_dop_workload],
'ROUND(CONVERT(FLOAT, ([recent].[total_dop]-[hist].[total_dop])/IIF([hist].[total_dop]>0, [hist].[total_dop], 1))*100.0, 2) [dop_regr_perc_recent],
		ROUND([recent].[total_dop], 2) [total_dop_recent],
		ROUND([hist].[total_dop], 2) [total_dop_hist],',
'[dop_regr_perc_recent]'
)
-- DOP.Total - END


-- Duration.Avg - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Duration', 
'Avg',
'탎',
'ROUND(CONVERT(FLOAT, SUM([qsrs].[avg_duration]*[qsrs].[count_executions]))/NULLIF(SUM([qsrs].[count_executions]), 0),2) [avg_duration],',
'[results].[duration_regr_perc_recent] [Duration_Avg_Variation_%],
		[results].[avg_duration_recent] [Duration_Avg_Recent_Microseconds],
		[results].[avg_duration_hist] [Duration_Avg_History_Microseconds],',
'ROUND(CONVERT(FLOAT, [recent].[avg_duration]-[hist].[avg_duration])/NULLIF([hist].[avg_duration],0)*100.0, 2) [duration_regr_perc_recent],
		ROUND([recent].[avg_duration], 2) [avg_duration_recent],
		ROUND([hist].[avg_duration], 2) [avg_duration_hist],',
'duration_regr_perc_recent'
)
-- Duration.Avg - END


-- Duration.Max - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Duration', 
'Max',
'탎',
'ROUND(CONVERT(FLOAT, MAX([qsrs].[max_duration])),2) [max_duration],',
'[results].[duration_regr_perc_recent] [Duration_Max_Variation_%],
		[results].[max_duration_recent] [Duration_Max_Recent_Microseconds],
		[results].[max_duration_hist] [Duration_Max_History_Microseconds],',
'ROUND(CONVERT(FLOAT, [recent].[max_duration]-[hist].[max_duration])/NULLIF([hist].[max_duration],0)*100.0, 2) [duration_regr_perc_recent],
		ROUND([recent].[max_duration], 2) [max_duration_recent],
		ROUND([hist].[max_duration], 2) [max_duration_hist],',
'[duration_regr_perc_recent]'
)
-- Duration.Max - END


-- Duration.Min - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Duration', 
'Min',
'탎',
'ROUND(CONVERT(FLOAT, MIN([qsrs].[min_duration])),2) [min_duration],',
'[results].[duration_regr_perc_recent] [Duration_Min_Variation_%],
		[results].[min_duration_recent] [Duration_Min_Recent_Microseconds],
		[results].[min_duration_hist] [Duration_Min_History_Microseconds],',
'ROUND(CONVERT(FLOAT, [recent].[min_duration]-[hist].[min_duration])/NULLIF([hist].[min_duration],0)*100.0, 2) [duration_regr_perc_recent],
		ROUND([recent].[min_duration], 2) [min_duration_recent],
		ROUND([hist].[min_duration], 2) [min_duration_hist],',
'[duration_regr_perc_recent]'
)
-- Duration.Min - END


-- Duration.StdDev - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Duration', 
'StdDev',
'탎',
'ROUND(CONVERT(FLOAT, SQRT( SUM([qsrs].[stdev_duration]*[qsrs].[stdev_duration]*[qsrs].[count_executions])/NULLIF(SUM([qsrs].[count_executions]), 0))),2) [stdev_duration],',
'[results].[duration_regr_perc_recent] [Duration_StdDev_Variation_%],
		[results].[stdev_duration_recent] [Duration_StdDev_Recent_Microseconds],
		[results].[stdev_duration_hist] [Duration_StdDev_History_Microseconds],',
'ROUND(CONVERT(FLOAT, [recent].[stdev_duration]-[hist].[stdev_duration])/NULLIF([hist].[stdev_duration],0)*100.0, 2) [duration_regr_perc_recent],
		ROUND([recent].[stdev_duration], 2) [stdev_duration_recent],
		ROUND([hist].[stdev_duration], 2) [stdev_duration_hist],',
'[duration_regr_perc_recent]'
)
-- Duration.StdDev - END


-- Duration.Total - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Duration', 
'Total',
'탎',
'ROUND(CONVERT(FLOAT, SUM([qsrs].[avg_duration]*[qsrs].[count_executions])),2) [total_duration],',
'[results].[duration_regr_perc_recent] [Duration_Total_Variation_%],
		[results].[total_duration_recent] [Duration_Total_Recent_Microseconds],
		[results].[total_duration_hist] [Duration_Total_History_Microseconds],',
--'ROUND(CONVERT(FLOAT, [recent].[total_duration]/[recent].[count_executions]-[hist].[total_duration]/[hist].[count_executions])*([recent].[count_executions]), 2) [additional_duration_workload],
'ROUND(CONVERT(FLOAT, ([recent].[total_duration]-[hist].[total_duration])/IIF([hist].[total_duration]>0, [hist].[total_duration], 1))*100.0, 2) [duration_regr_perc_recent],
		ROUND([recent].[total_duration], 2) [total_duration_recent],
		ROUND([hist].[total_duration], 2) [total_duration_hist],',
'[duration_regr_perc_recent]'
)
-- Duration.Total - END


-- Log.Avg - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Log', 
'Avg',
'Bytes',
'ROUND(CONVERT(FLOAT, SUM([qsrs].[avg_log_bytes_used]*[qsrs].[count_executions]))/NULLIF(SUM([qsrs].[count_executions]), 0)*1024,2) [avg_log_bytes_used],',
'[results].[avg_log_bytes_used_regr_perc_recent] [Log_Avg_Variation_%],
		[results].[avg_log_bytes_used_recent] [Log_Avg_Recent_Bytes],
		[results].[avg_log_bytes_used_hist] [Log_Avg_History_Bytes],',
'ROUND(CONVERT(FLOAT, [recent].[avg_log_bytes_used]-[hist].[avg_log_bytes_used])/NULLIF([hist].[avg_log_bytes_used],0)*100.0, 2) [avg_log_bytes_used_regr_perc_recent],
		ROUND([recent].[avg_log_bytes_used], 2) [avg_log_bytes_used_recent],
		ROUND([hist].[avg_log_bytes_used], 2) [avg_log_bytes_used_hist],',
'[avg_log_bytes_used_regr_perc_recent]'
)
-- Log.Avg - END


-- Log.Max - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Log', 
'Max',
'Bytes',
'ROUND(CONVERT(FLOAT, MAX([qsrs].[max_log_bytes_used]))*1024,2) [max_log_bytes_used],',
'[results].[log_bytes_used_regr_perc_recent] [Log_Max_Variation_%],
		[results].[max_log_bytes_used_recent] [Log_Max_Recent_Bytes],
		[results].[max_log_bytes_used_hist] [Log_Max_History_Bytes],',
'ROUND(CONVERT(FLOAT, [recent].[max_log_bytes_used]-[hist].[max_log_bytes_used])/NULLIF([hist].[max_log_bytes_used],0)*100.0, 2) [log_bytes_used_regr_perc_recent],
		ROUND([recent].[max_log_bytes_used], 2) [max_log_bytes_used_recent],
		ROUND([hist].[max_log_bytes_used], 2) [max_log_bytes_used_hist],',
'[log_bytes_used_regr_perc_recent]'
)
-- Log.Max - END


-- Log.Min - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Log', 
'Min',
'Bytes',
'ROUND(CONVERT(FLOAT, MIN([qsrs].[min_log_bytes_used]))*1024,2) [min_log_bytes_used],',
'[results].[log_bytes_used_regr_perc_recent] [Log_Min_Variation_%],
		[results].[min_log_bytes_used_recent] [Log_Min_Recent_Bytes],
		[results].[min_log_bytes_used_hist] [Log_Min_History_Bytes],',
'ROUND(CONVERT(FLOAT, [recent].[min_log_bytes_used]-[hist].[min_log_bytes_used])/NULLIF([hist].[min_log_bytes_used],0)*100.0, 2) [log_bytes_used_regr_perc_recent],
		ROUND([recent].[min_log_bytes_used], 2) [min_log_bytes_used_recent],
		ROUND([hist].[min_log_bytes_used], 2) [min_log_bytes_used_hist],',
'[log_bytes_used_regr_perc_recent]'
)
-- Log.Min - END


-- Log.StdDev - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Log', 
'StdDev',
'Bytes',
'ROUND(CONVERT(FLOAT, SQRT( SUM([qsrs].[stdev_log_bytes_used]*[qsrs].[stdev_log_bytes_used]*[qsrs].[count_executions])/NULLIF(SUM([qsrs].[count_executions]), 0)))*1024,2) [stdev_log_bytes_used],',
'[results].[log_bytes_used_regr_perc_recent] [Log_StdDev_Variation_%],
		[results].[stdev_log_bytes_used_recent] [Log_StdDev_Recent_Bytes],
		[results].[stdev_log_bytes_used_hist] [Log_StdDev_History_Bytes],',
'ROUND(CONVERT(FLOAT, [recent].[stdev_log_bytes_used]-[hist].[stdev_log_bytes_used])/NULLIF([hist].[stdev_log_bytes_used],0)*100.0, 2) [log_bytes_used_regr_perc_recent],
		ROUND([recent].[stdev_log_bytes_used], 2) [stdev_log_bytes_used_recent],
		ROUND([hist].[stdev_log_bytes_used], 2) [stdev_log_bytes_used_hist],',
'[log_bytes_used_regr_perc_recent]'
)
-- Log.StdDev - END


-- Log.Total - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Log', 
'Total',
'Bytes',
'ROUND(CONVERT(FLOAT, SUM([qsrs].[avg_log_bytes_used]*[qsrs].[count_executions]))*1024,2) [total_log_bytes_used],',
'[results].[log_bytes_used_regr_perc_recent] [Log_Total_Variation_%],
		[results].[total_log_bytes_used_recent] [Log_Total_Recent_Bytes],
		[results].[total_log_bytes_used_hist] [Log_Total_History_Bytes],',
--'ROUND(CONVERT(FLOAT, [recent].[total_log_bytes_used]/[recent].[count_executions]-[hist].[total_log_bytes_used]/[hist].[count_executions])*([recent].[count_executions]), 2) [additional_log_bytes_used_workload],
'ROUND(CONVERT(FLOAT, ([recent].[total_log_bytes_used]-[hist].[total_log_bytes_used])/IIF([hist].[total_log_bytes_used]>0, [hist].[total_log_bytes_used], 1))*100.0, 2) [log_bytes_used_regr_perc_recent],
		ROUND([recent].[total_log_bytes_used], 2) [total_log_bytes_used_recent],
		ROUND([hist].[total_log_bytes_used], 2) [total_log_bytes_used_hist],',
'[log_bytes_used_regr_perc_recent]'
)
-- Log.Total - END


-- LogicalIOReads.Avg - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'LogicalIOReads', 
'Avg',
'8 KB pages',
'ROUND(CONVERT(FLOAT, SUM([qsrs].[avg_logical_io_reads]*[qsrs].[count_executions]))/NULLIF(SUM([qsrs].[count_executions]), 0)*8,2) [avg_logical_io_reads],',
'[results].[logical_io_reads_regr_perc_recent] [LogicalIOReads_Avg_Variation_%],
		[results].[avg_logical_io_reads_recent] [LogicalIOReads_Avg_Recent_8KBPages],
		[results].[avg_logical_io_reads_hist] [LogicalIOReads_Avg_History_8KBPages],',
'ROUND(CONVERT(FLOAT, [recent].[avg_logical_io_reads]-[hist].[avg_logical_io_reads])/NULLIF([hist].[avg_logical_io_reads],0)*100.0, 2) [logical_io_reads_regr_perc_recent],
		ROUND([recent].[avg_logical_io_reads], 2) [avg_logical_io_reads_recent],
		ROUND([hist].[avg_logical_io_reads], 2) [avg_logical_io_reads_hist],',
'[logical_io_reads_regr_perc_recent]'
)
-- LogicalIOReads.Avg - END


-- LogicalIOReads.Max - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'LogicalIOReads', 
'Max',
'8 KB pages',
'ROUND(CONVERT(FLOAT, MAX([qsrs].[max_logical_io_reads]))*8,2) [max_logical_io_reads],',
'[results].[logical_io_reads_regr_perc_recent] [LogicalIOReads_Max_Variation_%],
		[results].[max_logical_io_reads_recent] [LogicalIOReads_Max_Recent_8KBPages],
		[results].[max_logical_io_reads_hist] [LogicalIOReads_Max_History_8KBPages],',
'ROUND(CONVERT(FLOAT, [recent].[max_logical_io_reads]-[hist].[max_logical_io_reads])/NULLIF([hist].[max_logical_io_reads],0)*100.0, 2) [logical_io_reads_regr_perc_recent],
		ROUND([recent].[max_logical_io_reads], 2) [max_logical_io_reads_recent],
		ROUND([hist].[max_logical_io_reads], 2) [max_logical_io_reads_hist],',
'[logical_io_reads_regr_perc_recent]'
)
-- LogicalIOReads.Max - END


-- LogicalIOReads.Min - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'LogicalIOReads', 
'Min',
'8 KB pages',
'ROUND(CONVERT(FLOAT, MIN([qsrs].[min_logical_io_reads]))*8,2) [min_logical_io_reads],',
'[results].[logical_io_reads_regr_perc_recent] [LogicalIOReads_Min_Variation_%],
		[results].[min_logical_io_reads_recent] [LogicalIOReads_Min_Recent_8KBPages],
		[results].[min_logical_io_reads_hist] [LogicalIOReads_Min_History_8KBPages],',
'ROUND(CONVERT(FLOAT, [recent].[min_logical_io_reads]-[hist].[min_logical_io_reads])/NULLIF([hist].[min_logical_io_reads],0)*100.0, 2) [logical_io_reads_regr_perc_recent],
		ROUND([recent].[min_logical_io_reads], 2) [min_logical_io_reads_recent],
		ROUND([hist].[min_logical_io_reads], 2) [min_logical_io_reads_hist],',
'[logical_io_reads_regr_perc_recent]'
)
-- LogicalIOReads.Min - END


-- LogicalIOReads.StdDev - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'LogicalIOReads', 
'StdDev',
'8 KB pages',
'ROUND(CONVERT(FLOAT, SQRT( SUM([qsrs].[stdev_logical_io_reads]*[qsrs].[stdev_logical_io_reads]*[qsrs].[count_executions])/NULLIF(SUM([qsrs].[count_executions]), 0)))*8,2) [stdev_logical_io_reads],',
'[results].[logical_io_reads_regr_perc_recent] [LogicalIOReads_StdDev_Variation_%],
		[results].[stdev_logical_io_reads_recent] [LogicalIOReads_StdDev_Recent_8KBPages],
		[results].[stdev_logical_io_reads_hist] [LogicalIOReads_StdDev_History_8KBPages],',
'ROUND(CONVERT(FLOAT, [recent].[stdev_logical_io_reads]-[hist].[stdev_logical_io_reads])/NULLIF([hist].[stdev_logical_io_reads],0)*100.0, 2) [logical_io_reads_regr_perc_recent],
		ROUND([recent].[stdev_logical_io_reads], 2) [stdev_logical_io_reads_recent],
		ROUND([hist].[stdev_logical_io_reads], 2) [stdev_logical_io_reads_hist],',
'[logical_io_reads_regr_perc_recent]'
)
-- LogicalIOReads.StdDev - END


-- LogicalIOReads.Total - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'LogicalIOReads', 
'Total',
'8 KB pages',
'ROUND(CONVERT(FLOAT, SUM([qsrs].[avg_logical_io_reads]*[qsrs].[count_executions]))*8,2) [total_logical_io_reads],',
'[results].[logical_io_reads_regr_perc_recent] [LogicalIOReads_Total_Variation_%],
		[results].[total_logical_io_reads_recent] [LogicalIOReads_Total_Recent_8KBPages],
		[results].[total_logical_io_reads_hist] [LogicalIOReads_Total_History_8KBPages],',
--'ROUND(CONVERT(FLOAT, [recent].[total_logical_io_reads]/[recent].[count_executions]-[hist].[total_logical_io_reads]/[hist].[count_executions])*([recent].[count_executions]), 2) [additional_logical_io_reads_workload],
'ROUND(CONVERT(FLOAT, ([recent].[total_logical_io_reads]-[hist].[total_logical_io_reads])/IIF([hist].[total_logical_io_reads]>0, [hist].[total_logical_io_reads], 1))*100.0, 2) [logical_io_reads_regr_perc_recent],
		ROUND([recent].[total_logical_io_reads], 2) [total_logical_io_reads_recent],
		ROUND([hist].[total_logical_io_reads], 2) [total_logical_io_reads_hist],',
'[logical_io_reads_regr_perc_recent]'
)
-- LogicalIOReads.Total - END


-- LogicalIOWrites.Avg - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'LogicalIOWrites', 
'Avg',
'8 KB pages',
'ROUND(CONVERT(FLOAT, SUM([qsrs].[avg_logical_io_writes]*[qsrs].[count_executions]))/NULLIF(SUM([qsrs].[count_executions]), 0)*8,2) [avg_logical_io_writes],',
'[results].[logical_io_writes_regr_perc_recent] [LogicalIOWrites_Avg_Variation_%],
		[results].[avg_logical_io_writes_recent] [LogicalIOWrites_Avg_Recent_8KBPages],
		[results].[avg_logical_io_writes_hist] [LogicalIOWrites_Avg_History_8KBPages],',
'ROUND(CONVERT(FLOAT, [recent].[avg_logical_io_writes]-[hist].[avg_logical_io_writes])/NULLIF([hist].[avg_logical_io_writes],0)*100.0, 2) [logical_io_writes_regr_perc_recent],
		ROUND([recent].[avg_logical_io_writes], 2) [avg_logical_io_writes_recent],
		ROUND([hist].[avg_logical_io_writes], 2) [avg_logical_io_writes_hist],',
'[logical_io_writes_regr_perc_recent]'
)
-- LogicalIOWrites.Avg - END


-- LogicalIOWrites.Max - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'LogicalIOWrites', 
'Max',
'8 KB pages',
'ROUND(CONVERT(FLOAT, MAX([qsrs].[max_logical_io_writes]))*8,2) [max_logical_io_writes],',
'[results].[logical_io_writes_regr_perc_recent] [LogicalIOWrites_Max_Variation_%],
		[results].[max_logical_io_writes_recent] [LogicalIOWrites_Max_Recent_8KBPages],
		[results].[max_logical_io_writes_hist] [LogicalIOWrites_Max_History_8KBPages],',
'ROUND(CONVERT(FLOAT, [recent].[max_logical_io_writes]-[hist].[max_logical_io_writes])/NULLIF([hist].[max_logical_io_writes],0)*100.0, 2) [logical_io_writes_regr_perc_recent],
		ROUND([recent].[max_logical_io_writes], 2) [max_logical_io_writes_recent],
		ROUND([hist].[max_logical_io_writes], 2) [max_logical_io_writes_hist],',
'[logical_io_writes_regr_perc_recent]'
)
-- LogicalIOWrites.Max - END


-- LogicalIOWrites.Min - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'LogicalIOWrites', 
'Min',
'8 KB pages',
'ROUND(CONVERT(FLOAT, MIN([qsrs].[min_logical_io_writes]))*8,2) [min_logical_io_writes],',
'[results].[logical_io_writes_regr_perc_recent] [LogicalIOWrites_Min_Variation_%],
		[results].[min_logical_io_writes_recent] [LogicalIOWrites_Min_Recent_8KBPages],
		[results].[min_logical_io_writes_hist] [LogicalIOWrites_Min_History_8KBPages],',
'ROUND(CONVERT(FLOAT, [recent].[min_logical_io_writes]-[hist].[min_logical_io_writes])/NULLIF([hist].[min_logical_io_writes],0)*100.0, 2) [logical_io_writes_regr_perc_recent],
		ROUND([recent].[min_logical_io_writes], 2) [min_logical_io_writes_recent],
		ROUND([hist].[min_logical_io_writes], 2) [min_logical_io_writes_hist],',
'[logical_io_writes_regr_perc_recent]'
)
-- LogicalIOWrites.Min - END


-- LogicalIOWrites.StdDev - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'LogicalIOWrites', 
'StdDev',
'8 KB pages',
'ROUND(CONVERT(FLOAT, SQRT( SUM([qsrs].[stdev_logical_io_writes]*[qsrs].[stdev_logical_io_writes]*[qsrs].[count_executions])/NULLIF(SUM([qsrs].[count_executions]), 0)))*8,2) [stdev_logical_io_writes],',
'[results].[logical_io_writes_regr_perc_recent] [LogicalIOWrites_StdDev_Variation_%],
		[results].[stdev_logical_io_writes_recent] [LogicalIOWrites_StdDev_Recent_8KBPages],
		[results].[stdev_logical_io_writes_hist] [LogicalIOWrites_StdDev_History_8KBPages],',
'ROUND(CONVERT(FLOAT, [recent].[stdev_logical_io_writes]-[hist].[stdev_logical_io_writes])/NULLIF([hist].[stdev_logical_io_writes],0)*100.0, 2) [logical_io_writes_regr_perc_recent],
		ROUND([recent].[stdev_logical_io_writes], 2) [stdev_logical_io_writes_recent],
		ROUND([hist].[stdev_logical_io_writes], 2) [stdev_logical_io_writes_hist],',
'[logical_io_writes_regr_perc_recent]'
)
-- LogicalIOWrites.StdDev - END


-- LogicalIOWrites.Total - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'LogicalIOWrites', 
'Total',
'8 KB pages',
'ROUND(CONVERT(FLOAT, SUM([qsrs].[avg_logical_io_writes]*[qsrs].[count_executions]))*8,2) [total_logical_io_writes],',
'[results].[logical_io_writes_regr_perc_recent] [LogicalIOWrites_Total_Variation_%],
		[results].[total_logical_io_writes_recent] [LogicalIOWrites_Total_Recent_8KBPages],
		[results].[total_logical_io_writes_hist] [LogicalIOWrites_Total_History_8KBPages],',
--'ROUND(CONVERT(FLOAT, [recent].[total_logical_io_writes]/[recent].[count_executions]-[hist].[total_logical_io_writes]/[hist].[count_executions])*([recent].[count_executions]), 2) [additional_logical_io_writes_workload],
'ROUND(CONVERT(FLOAT, ([recent].[total_logical_io_writes]-[hist].[total_logical_io_writes])/IIF([hist].[total_logical_io_writes]>0, [hist].[total_logical_io_writes], 1))*100.0, 2) [logical_io_writes_regr_perc_recent],
		ROUND([recent].[total_logical_io_writes], 2) [total_logical_io_writes_recent],
		ROUND([hist].[total_logical_io_writes], 2) [total_logical_io_writes_hist],',
'[logical_io_writes_regr_perc_recent]'
)
-- LogicalIOWrites.Total - END


-- MaxMemory.Avg - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'MaxMemory', 
'Avg',
'8 KB pages',
'ROUND(CONVERT(FLOAT, SUM([qsrs].[avg_query_max_used_memory]*[qsrs].[count_executions]))/NULLIF(SUM([qsrs].[count_executions]), 0)*8,2) [avg_query_max_used_memory],',
'[results].[query_max_used_memory_regr_perc_recent] [MaxMemory_Avg_Variation_%],
		[results].[avg_query_max_used_memory_recent] [MaxMemory_Avg_Recent_8KBPages],
		[results].[avg_query_max_used_memory_hist] [MaxMemory_Avg_History_8KBPages],',
'ROUND(CONVERT(FLOAT, [recent].[avg_query_max_used_memory]-[hist].[avg_query_max_used_memory])/NULLIF([hist].[avg_query_max_used_memory],0)*100.0, 2) [query_max_used_memory_regr_perc_recent],
		ROUND([recent].[avg_query_max_used_memory], 2) [avg_query_max_used_memory_recent],
		ROUND([hist].[avg_query_max_used_memory], 2) [avg_query_max_used_memory_hist],',
'[query_max_used_memory_regr_perc_recent]'
)
-- MaxMemory.Avg - END


-- MaxMemory.Max - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'MaxMemory', 
'Max',
'8 KB pages',
'ROUND(CONVERT(FLOAT, MAX([qsrs].[max_query_max_used_memory]))*8,2) [max_query_max_used_memory],',
'[results].[query_max_used_memory_regr_perc_recent] [MaxMemory_Max_Variation_%],
		[results].[max_query_max_used_memory_recent] [MaxMemory_Max_Recent_8KBPages],
		[results].[max_query_max_used_memory_hist] [MaxMemory_Max_History_8KBPages],',
'ROUND(CONVERT(FLOAT, [recent].[max_query_max_used_memory]-[hist].[max_query_max_used_memory])/NULLIF([hist].[max_query_max_used_memory],0)*100.0, 2) [query_max_used_memory_regr_perc_recent],
		ROUND([recent].[max_query_max_used_memory], 2) [max_query_max_used_memory_recent],
		ROUND([hist].[max_query_max_used_memory], 2) [max_query_max_used_memory_hist],',
'[query_max_used_memory_regr_perc_recent]'
)
-- MaxMemory.Max - END


-- MaxMemory.Min - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'MaxMemory', 
'Min',
'8 KB pages',
'ROUND(CONVERT(FLOAT, MIN([qsrs].[min_query_max_used_memory]))*8,2) [min_query_max_used_memory],',
'[results].[query_max_used_memory_regr_perc_recent] [MaxMemory_Min_Variation_%],
		[results].[min_query_max_used_memory_recent] [MaxMemory_Min_Recent_8KBPages],
		[results].[min_query_max_used_memory_hist] [MaxMemory_Min_History_8KBPages],',
'ROUND(CONVERT(FLOAT, [recent].[min_query_max_used_memory]-[hist].[min_query_max_used_memory])/NULLIF([hist].[min_query_max_used_memory],0)*100.0, 2) [query_max_used_memory_regr_perc_recent],
		ROUND([recent].[min_query_max_used_memory], 2) [min_query_max_used_memory_recent],
		ROUND([hist].[min_query_max_used_memory], 2) [min_query_max_used_memory_hist],',
'[query_max_used_memory_regr_perc_recent]'
)
-- MaxMemory.Min - END


-- MaxMemory.StdDev - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'MaxMemory', 
'StdDev',
'8 KB pages',
'ROUND(CONVERT(FLOAT, SQRT( SUM([qsrs].[stdev_query_max_used_memory]*[qsrs].[stdev_query_max_used_memory]*[qsrs].[count_executions])/NULLIF(SUM([qsrs].[count_executions]), 0)))*8,2) [stdev_query_max_used_memory],',
'[results].[query_max_used_memory_regr_perc_recent] [MaxMemory_StdDev_Variation_%],
		[results].[stdev_query_max_used_memory_recent] [MaxMemory_StdDev_Recent_8KBPages],
		[results].[stdev_query_max_used_memory_hist] [MaxMemory_StdDev_History_8KBPages],',
'ROUND(CONVERT(FLOAT, [recent].[stdev_query_max_used_memory]-[hist].[stdev_query_max_used_memory])/NULLIF([hist].[stdev_query_max_used_memory],0)*100.0, 2) [query_max_used_memory_regr_perc_recent],
		ROUND([recent].[stdev_query_max_used_memory], 2) [stdev_query_max_used_memory_recent],
		ROUND([hist].[stdev_query_max_used_memory], 2) [stdev_query_max_used_memory_hist],',
'[query_max_used_memory_regr_perc_recent]'
)
-- MaxMemory.StdDev - END


-- MaxMemory.Total - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'MaxMemory', 
'Total',
'8 KB pages',
'ROUND(CONVERT(FLOAT, SUM([qsrs].[avg_query_max_used_memory]*[qsrs].[count_executions]))*8,2) [total_query_max_used_memory],',
'[results].[query_max_used_memory_regr_perc_recent] [MaxMemory_Max_Variation_%],
		[results].[total_query_max_used_memory_recent] [MaxMemory_Max_Recent_8KBPages],
		[results].[total_query_max_used_memory_hist] [MaxMemory_Max_History_8KBPages],',
--'ROUND(CONVERT(FLOAT, [recent].[total_query_max_used_memory]/[recent].[count_executions]-[hist].[total_query_max_used_memory]/[hist].[count_executions])*([recent].[count_executions]), 2) [additional_query_max_used_memory_workload],
'ROUND(CONVERT(FLOAT, ([recent].[total_query_max_used_memory]-[hist].[total_query_max_used_memory])/IIF([hist].[total_query_max_used_memory]>0, [hist].[total_query_max_used_memory], 1))*100.0, 2) [query_max_used_memory_regr_perc_recent],
		ROUND([recent].[total_query_max_used_memory], 2) [total_query_max_used_memory_recent],
		ROUND([hist].[total_query_max_used_memory], 2) [total_query_max_used_memory_hist],',
'[query_max_used_memory_regr_perc_recent]'
)
-- MaxMemory.Total - END


-- PhysicalIOReads.Avg - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'PhysicalIOReads', 
'Avg',
'8 KB pages',
'ROUND(CONVERT(FLOAT, SUM([qsrs].[avg_physical_io_reads]*[qsrs].[count_executions]))/NULLIF(SUM([qsrs].[count_executions]), 0)*8,2) [avg_physical_io_reads],',
'[results].[physical_io_reads_regr_perc_recent] [PhysicalIOReads_Avg_Variation_%],
		[results].[avg_physical_io_reads_recent] [PhysicalIOReads_Avg_Recent_8KBPages],
		[results].[avg_physical_io_reads_hist] [PhysicalIOReads_Avg_History_8KBPages],',
'ROUND(CONVERT(FLOAT, [recent].[avg_physical_io_reads]-[hist].[avg_physical_io_reads])/NULLIF([hist].[avg_physical_io_reads],0)*100.0, 2) [physical_io_reads_regr_perc_recent],
		ROUND([recent].[avg_physical_io_reads], 2) [avg_physical_io_reads_recent],
		ROUND([hist].[avg_physical_io_reads], 2) [avg_physical_io_reads_hist],',
'[physical_io_reads_regr_perc_recent]'
)
-- PhysicalIOReads.Avg - END


-- PhysicalIOReads.Max - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'PhysicalIOReads', 
'Max',
'8 KB pages',
'ROUND(CONVERT(FLOAT, MAX([qsrs].[max_physical_io_reads]))*8,2) [max_physical_io_reads],',
'[results].[physical_io_reads_regr_perc_recent] [PhysicalIOReads_Max_Variation_%],
		[results].[max_physical_io_reads_recent] [PhysicalIOReads_Max_Recent_8KBPages],
		[results].[max_physical_io_reads_hist] [PhysicalIOReads_Max_History_8KBPages],',
'ROUND(CONVERT(FLOAT, [recent].[max_physical_io_reads]-[hist].[max_physical_io_reads])/NULLIF([hist].[max_physical_io_reads],0)*100.0, 2) [physical_io_reads_regr_perc_recent],
		ROUND([recent].[max_physical_io_reads], 2) [max_physical_io_reads_recent],
		ROUND([hist].[max_physical_io_reads], 2) [max_physical_io_reads_hist],',
'[physical_io_reads_regr_perc_recent]'
)
-- PhysicalIOReads.Max - END


-- PhysicalIOReads.Min - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'PhysicalIOReads', 
'Min',
'8 KB pages',
'ROUND(CONVERT(FLOAT, MIN([qsrs].[min_physical_io_reads]))*8,2) [min_physical_io_reads],',
'[results].[physical_io_reads_regr_perc_recent] [PhysicalIOReads_Min_Variation_%],
		[results].[min_physical_io_reads_recent] [PhysicalIOReads_Min_Recent_8KBPages],
		[results].[min_physical_io_reads_hist] [PhysicalIOReads_Min_History_8KBPages],',
'ROUND(CONVERT(FLOAT, [recent].[min_physical_io_reads]-[hist].[min_physical_io_reads])/NULLIF([hist].[min_physical_io_reads],0)*100.0, 2) [physical_io_reads_regr_perc_recent],
		ROUND([recent].[min_physical_io_reads], 2) [min_physical_io_reads_recent],
		ROUND([hist].[min_physical_io_reads], 2) [min_physical_io_reads_hist],',
'[physical_io_reads_regr_perc_recent]'
)
-- PhysicalIOReads.Min - END


-- PhysicalIOReads.StdDev - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'PhysicalIOReads', 
'StdDev',
'8 KB pages',
'ROUND(CONVERT(FLOAT, SQRT( SUM([qsrs].[stdev_physical_io_reads]*[qsrs].[stdev_physical_io_reads]*[qsrs].[count_executions])/NULLIF(SUM([qsrs].[count_executions]), 0)))*8,2) [stdev_physical_io_reads],',
'[results].[physical_io_reads_regr_perc_recent] [PhysicalIOReads_StdDev_Variation_%],
		[results].[stdev_physical_io_reads_recent] [PhysicalIOReads_StdDev_Recent_8KBPages],
		[results].[stdev_physical_io_reads_hist] [PhysicalIOReads_StdDev_History_8KBPages],',
'ROUND(CONVERT(FLOAT, [recent].[stdev_physical_io_reads]-[hist].[stdev_physical_io_reads])/NULLIF([hist].[stdev_physical_io_reads],0)*100.0, 2) [physical_io_reads_regr_perc_recent],
		ROUND([recent].[stdev_physical_io_reads], 2) [stdev_physical_io_reads_recent],
		ROUND([hist].[stdev_physical_io_reads], 2) [stdev_physical_io_reads_hist],',
'[physical_io_reads_regr_perc_recent]'
)
-- PhysicalIOReads.StdDev - END


-- PhysicalIOReads.Total - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'PhysicalIOReads', 
'Total',
'8 KB pages',
'ROUND(CONVERT(FLOAT, SUM([qsrs].[avg_physical_io_reads]*[qsrs].[count_executions]))*8,2) [total_physical_io_reads],',
'[results].[physical_io_reads_regr_perc_recent] [PhysicalIOReads_Total_Variation_%],
		[results].[total_physical_io_reads_recent] [PhysicalIOReads_Total_Recent_8KBPages],
		[results].[total_physical_io_reads_hist] [PhysicalIOReads_Total_History_8KBPages],',
--'ROUND(CONVERT(FLOAT, [recent].[total_physical_io_reads]/[recent].[count_executions]-[hist].[total_physical_io_reads]/[hist].[count_executions])*([recent].[count_executions]), 2) [additional_physical_io_reads_workload],
'ROUND(CONVERT(FLOAT, ([recent].[total_physical_io_reads]-[hist].[total_physical_io_reads])/IIF([hist].[total_physical_io_reads]>0, [hist].[total_physical_io_reads], 1))*100.0, 2) [physical_io_reads_regr_perc_recent],
		ROUND([recent].[total_physical_io_reads], 2) [total_physical_io_reads_recent],
		ROUND([hist].[total_physical_io_reads], 2) [total_physical_io_reads_hist],',
'[physical_io_reads_regr_perc_recent]'
)
-- PhysicalIOReads.Total - END


-- Rowcount.Avg - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Rowcount', 
'Avg',
'Rows',
'ROUND(CONVERT(FLOAT, SUM([qsrs].[avg_rowcount]*[qsrs].[count_executions]))/NULLIF(SUM([qsrs].[count_executions]), 0)*1,0) [avg_rowcount],',
'[results].[rowcount_regr_perc_recent] [Rowcount_Avg_Variation_%],
		[results].[avg_rowcount_recent] [Rowcount_Avg_Recent],
		[results].[avg_rowcount_hist] [Rowcount_Avg_History],',
'ROUND(CONVERT(FLOAT, [recent].[avg_rowcount]-[hist].[avg_rowcount])/NULLIF([hist].[avg_rowcount],0)*100.0, 2) [rowcount_regr_perc_recent],
		ROUND([recent].[avg_rowcount], 2) [avg_rowcount_recent],
		ROUND([hist].[avg_rowcount], 2) [avg_rowcount_hist],',
'[rowcount_regr_perc_recent]'
)
-- Rowcount.Avg - END


-- Rowcount.Max - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Rowcount', 
'Max',
'Rows',
'ROUND(CONVERT(FLOAT, MAX([qsrs].[max_rowcount]))*1,2) [max_rowcount],',
'[results].[rowcount_regr_perc_recent] [Rowcount_Max_Variation_%],
		[results].[max_rowcount_recent] [Rowcount_Max_Recent],
		[results].[max_rowcount_hist] [Rowcount_Max_History],',
'ROUND(CONVERT(FLOAT, [recent].[max_rowcount]-[hist].[max_rowcount])/NULLIF([hist].[max_rowcount],0)*100.0, 2) [rowcount_regr_perc_recent],
		ROUND([recent].[max_rowcount], 2) [max_rowcount_recent],
		ROUND([hist].[max_rowcount], 2) [max_rowcount_hist],',
'[rowcount_regr_perc_recent]'
)
-- Rowcount.Max - END


-- Rowcount.Min - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Rowcount', 
'Min',
'Rows',
'ROUND(CONVERT(FLOAT, MIN([qsrs].[min_rowcount]))*1,2) [min_rowcount],',
'[results].[rowcount_regr_perc_recent] [Rowcount_Min_Variation_%],
		[results].[min_rowcount_recent] [Rowcount_Min_Recent],
		[results].[min_rowcount_hist] [Rowcount_Min_History],',
'ROUND(CONVERT(FLOAT, [recent].[min_rowcount]-[hist].[min_rowcount])/NULLIF([hist].[min_rowcount],0)*100.0, 2) [rowcount_regr_perc_recent],
		ROUND([recent].[min_rowcount], 2) [min_rowcount_recent],
		ROUND([hist].[min_rowcount], 2) [min_rowcount_hist],',
'[rowcount_regr_perc_recent]'
)
-- Rowcount.Min - END


-- Rowcount.StdDev - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Rowcount', 
'StdDev',
'Rows',
'ROUND(CONVERT(FLOAT, SQRT( SUM([qsrs].[stdev_rowcount]*[qsrs].[stdev_rowcount]*[qsrs].[count_executions])/NULLIF(SUM([qsrs].[count_executions]), 0)))*1,2) [stdev_rowcount],',
'[results].[rowcount_regr_perc_recent] [Rowcount_StdDev_Variation_%],
		[results].[stdev_rowcount_recent] [Rowcount_StdDev_Recent],
		[results].[stdev_rowcount_hist] [Rowcount_StdDev_History],',
'ROUND(CONVERT(FLOAT, [recent].[stdev_rowcount]-[hist].[stdev_rowcount])/NULLIF([hist].[stdev_rowcount],0)*100.0, 2) [rowcount_regr_perc_recent],
		ROUND([recent].[stdev_rowcount], 2) [stdev_rowcount_recent],
		ROUND([hist].[stdev_rowcount], 2) [stdev_rowcount_hist],',
'[rowcount_regr_perc_recent]'
)
-- Rowcount.StdDev - END


-- Rowcount.Total - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Rowcount', 
'Total',
'Rows',
'ROUND(CONVERT(FLOAT, SUM([qsrs].[avg_rowcount]*[qsrs].[count_executions]))*1,2) [total_rowcount],',
'[results].[rowcount_regr_perc_recent] [Rowcount_Total_Variation_%],
		[results].[total_rowcount_recent] [Rowcount_Total_Recent],
		[results].[total_rowcount_hist] [Rowcount_Total_History],',
--'ROUND(CONVERT(FLOAT, [recent].[total_rowcount]/[recent].[count_executions]-[hist].[total_rowcount]/[hist].[count_executions])*([recent].[count_executions]), 2) [additional_rowcount_workload],
'ROUND(CONVERT(FLOAT, ([recent].[total_rowcount]-[hist].[total_rowcount])/IIF([hist].[total_rowcount]>0, [hist].[total_rowcount], 1))*100.0, 2) [rowcount_regr_perc_recent],
		ROUND([recent].[total_rowcount], 2) [total_rowcount_recent],
		ROUND([hist].[total_rowcount], 2) [total_rowcount_hist],',
'[rowcount_regr_perc_recent]'
)
-- Rowcount.Total - END


-- TempDB.Avg - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'TempDB', 
'Avg',
'8 KB pages',
'ROUND(CONVERT(FLOAT, SUM([qsrs].[avg_tempdb_space_used]*[qsrs].[count_executions]))/NULLIF(SUM([qsrs].[count_executions]), 0)*8,2) [avg_tempdb_space_used],',
'[results].[tempdb_space_used_regr_perc_recent] [TempDB_Avg_Variation_%],
		[results].[avg_tempdb_space_used_recent] [TempDB_Avg_Recent_8KBPages],
		[results].[avg_tempdb_space_used_hist] [TempDB_Avg_History_8KBPages],',
'ROUND(CONVERT(FLOAT, [recent].[avg_tempdb_space_used]-[hist].[avg_tempdb_space_used])/NULLIF([hist].[avg_tempdb_space_used],0)*100.0, 2) [tempdb_space_used_regr_perc_recent],
		ROUND([recent].[avg_tempdb_space_used], 2) [avg_tempdb_space_used_recent],
		ROUND([hist].[avg_tempdb_space_used], 2) [avg_tempdb_space_used_hist],',
'[tempdb_space_used_regr_perc_recent]'
)
-- TempDB.Avg - END


-- TempDB.Max - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'TempDB', 
'Max',
'8 KB pages',
'ROUND(CONVERT(FLOAT, MAX([qsrs].[max_tempdb_space_used]))*8,2) [max_tempdb_space_used],',
'[results].[tempdb_space_used_regr_perc_recent] [TempDB_Max_Variation_%],
		[results].[max_tempdb_space_used_recent] [TempDB_Max_Recent_8KBPages],
		[results].[max_tempdb_space_used_hist] [TempDB_Max_History_8KBPages],',
'ROUND(CONVERT(FLOAT, [recent].[max_tempdb_space_used]-[hist].[max_tempdb_space_used])/NULLIF([hist].[max_tempdb_space_used],0)*100.0, 2) [tempdb_space_used_regr_perc_recent],
		ROUND([recent].[max_tempdb_space_used], 2) [max_tempdb_space_used_recent],
		ROUND([hist].[max_tempdb_space_used], 2) [max_tempdb_space_used_hist],',
'[tempdb_space_used_regr_perc_recent]'
)
-- TempDB.Max - END


-- TempDB.Min - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'TempDB', 
'Min',
'8 KB pages',
'ROUND(CONVERT(FLOAT, MIN([qsrs].[min_tempdb_space_used]))*8,2) [min_tempdb_space_used],',
'[results].[tempdb_space_used_regr_perc_recent] [TempDB_Min_Variation_%],
		[results].[min_tempdb_space_used_recent] [TempDB_Min_Recent_8KBPages],
		[results].[min_tempdb_space_used_hist] [TempDB_Min_History_8KBPages],',
'ROUND(CONVERT(FLOAT, [recent].[min_tempdb_space_used]-[hist].[min_tempdb_space_used])/NULLIF([hist].[min_tempdb_space_used],0)*100.0, 2) [tempdb_space_used_regr_perc_recent],
		ROUND([recent].[min_tempdb_space_used], 2) [min_tempdb_space_used_recent],
		ROUND([hist].[min_tempdb_space_used], 2) [min_tempdb_space_used_hist],',
'[tempdb_space_used_regr_perc_recent]'
)
-- TempDB.Min - END


-- TempDB.StdDev - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'TempDB', 
'StdDev',
'8 KB pages',
'ROUND(CONVERT(FLOAT, SQRT( SUM([qsrs].[stdev_tempdb_space_used]*[qsrs].[stdev_tempdb_space_used]*[qsrs].[count_executions])/NULLIF(SUM([qsrs].[count_executions]), 0)))*8,2) [stdev_tempdb_space_used],',
'[results].[tempdb_space_used_regr_perc_recent] [TempDB_StdDev_Variation_%],
		[results].[stdev_tempdb_space_used_recent] [TempDB_StdDev_Recent_8KBPages],
		[results].[stdev_tempdb_space_used_hist] [TempDB_StdDev_History_8KBPages],',
'ROUND(CONVERT(FLOAT, [recent].[stdev_tempdb_space_used]-[hist].[stdev_tempdb_space_used])/NULLIF([hist].[stdev_tempdb_space_used],0)*100.0, 2) [tempdb_space_used_regr_perc_recent],
		ROUND([recent].[stdev_tempdb_space_used], 2) [stdev_tempdb_space_used_recent],
		ROUND([hist].[stdev_tempdb_space_used], 2) [stdev_tempdb_space_used_hist],',
'[tempdb_space_used_regr_perc_recent]'
)
-- TempDB.StdDev - END


-- TempDB.Total - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [Unit], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'TempDB', 
'Total',
'8 KB pages',
'ROUND(CONVERT(FLOAT, SUM([qsrs].[avg_tempdb_space_used]*[qsrs].[count_executions]))*8,2) [total_tempdb_space_used],',
'[results].[tempdb_space_used_regr_perc_recent] [TempDB_Total_Variation_%],
		[results].[total_tempdb_space_used_recent] [TempDB_Total_Recent_8KBPages],
		[results].[total_tempdb_space_used_hist] [TempDB_Total_History_8KBPages],',
--'ROUND(CONVERT(FLOAT, [recent].[total_tempdb_space_used]/[recent].[count_executions]-[hist].[total_tempdb_space_used]/[hist].[count_executions])*([recent].[count_executions]), 2) [additional_tempdb_space_used_workload],
'ROUND(CONVERT(FLOAT, ([recent].[total_tempdb_space_used]-[hist].[total_tempdb_space_used])/IIF([hist].[total_tempdb_space_used]>0, [hist].[total_tempdb_space_used], 1))*100.0, 2) [tempdb_space_used_regr_perc_recent],
		ROUND([recent].[total_tempdb_space_used], 2) [total_tempdb_space_used_recent],
		ROUND([hist].[total_tempdb_space_used], 2) [total_tempdb_space_used_hist],',
'[tempdb_space_used_regr_perc_recent]'
)
-- TempDB.Total - END