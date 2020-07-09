SET NOCOUNT ON
DROP TABLE IF EXISTS [dbo].[QDSMetricArchive]
CREATE TABLE [dbo].[QDSMetricArchive]
(
	[Measurement]		VARCHAR(32)	NOT NULL, -- CPU, Duration...
	[Metric]			VARCHAR(16)	NOT NULL, -- Total, Max...
	[SubQuery01]		NVARCHAR(MAX) NOT NULL,
	[SubQuery02]		NVARCHAR(MAX) NOT NULL,
	[SubQuery03]		NVARCHAR(MAX) NOT NULL,
	[SubQuery04]		NVARCHAR(MAX) NOT NULL
)
GO
ALTER TABLE [dbo].[QDSMetricArchive] ADD CONSTRAINT [PK_QDSMetricArchive] PRIMARY KEY CLUSTERED ([Measurement] ASC, [Metric] ASC) WITH (DATA_COMPRESSION = PAGE)
GO

-- CLR.Avg - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'CLR', 
'Avg',
'ROUND(CONVERT(FLOAT, SUM(rs.avg_clr_time*rs.count_executions))/NULLIF(SUM(rs.count_executions), 0)*0.001,2) avg_clr_time,',
'results.clr_time_regr_perc_recent clr_time_regr_perc_recent,
		results.avg_clr_time_recent avg_clr_time_recent,
		results.avg_clr_time_hist avg_clr_time_hist,',
'ROUND(CONVERT(FLOAT, recent.avg_clr_time-hist.avg_clr_time)/NULLIF(hist.avg_clr_time,0)*100.0, 2) clr_time_regr_perc_recent,
		ROUND(recent.avg_clr_time, 2) avg_clr_time_recent,
		ROUND(hist.avg_clr_time, 2) avg_clr_time_hist,',
'clr_time_regr_perc_recent'
)
-- CLR.Avg - END

-- CLR.Max - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'CLR', 
'Max',
'ROUND(CONVERT(FLOAT, MAX(rs.max_clr_time))*0.001,2) max_clr_time,',
'results.clr_time_regr_perc_recent clr_time_regr_perc_recent,
		results.max_clr_time_recent max_clr_time_recent,
		results.max_clr_time_hist max_clr_time_hist,',
'ROUND(CONVERT(FLOAT, recent.max_clr_time-hist.max_clr_time)/NULLIF(hist.max_clr_time,0)*100.0, 2) clr_time_regr_perc_recent,
		ROUND(recent.max_clr_time, 2) max_clr_time_recent,
		ROUND(hist.max_clr_time, 2) max_clr_time_hist,',
'clr_time_regr_perc_recent'
)
-- CLR.Max - END

-- CLR.Min - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'CLR', 
'Min',
'ROUND(CONVERT(FLOAT, MIN(rs.min_clr_time))*0.001,2) min_clr_time,',
'results.clr_time_regr_perc_recent clr_time_regr_perc_recent,
		results.min_clr_time_recent min_clr_time_recent,
		results.min_clr_time_hist min_clr_time_hist,',
'ROUND(CONVERT(FLOAT, recent.min_clr_time-hist.min_clr_time)/NULLIF(hist.min_clr_time,0)*100.0, 2) clr_time_regr_perc_recent,
		ROUND(recent.min_clr_time, 2) min_clr_time_recent,
		ROUND(hist.min_clr_time, 2) min_clr_time_hist,',
'clr_time_regr_perc_recent'
)
-- CLR.Min - END

-- CLR.StdDev - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'CLR', 
'StdDev',
'ROUND(CONVERT(FLOAT, SQRT( SUM(rs.stdev_clr_time*rs.stdev_clr_time*rs.count_executions)/NULLIF(SUM(rs.count_executions), 0)))*0.001,2) stdev_clr_time,',
'results.clr_time_regr_perc_recent clr_time_regr_perc_recent,
		results.stdev_clr_time_recent min_clr_time_recent,
		results.stdev_clr_time_hist min_clr_time_hist,',
'ROUND(CONVERT(FLOAT, recent.stdev_clr_time-hist.stdev_clr_time)/NULLIF(hist.stdev_clr_time,0)*100.0, 2) clr_time_regr_perc_recent,
		ROUND(recent.stdev_clr_time, 2) stdev_clr_time_recent,
		ROUND(hist.stdev_clr_time, 2) stdev_clr_time_hist,',
'clr_time_regr_perc_recent'
)
-- CLR.StdDev - END

-- CLR.Total - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'CLR', 
'Total',
'ROUND(CONVERT(FLOAT, SUM(rs.avg_clr_time*rs.count_executions))*0.001,2) total_clr_time,',
'results.additional_clr_time_workload additional_clr_time_workload,
		results.total_clr_time_recent total_clr_time_recent,
		results.total_clr_time_hist total_clr_time_hist,',
'ROUND(CONVERT(FLOAT, recent.total_clr_time/recent.count_executions-hist.total_clr_time/hist.count_executions)*(recent.count_executions), 2) additional_clr_time_workload,
		ROUND(recent.total_clr_time, 2) total_clr_time_recent,
		ROUND(hist.total_clr_time, 2) total_clr_time_hist,',
'additional_clr_time_workload'
)
-- CLR.Total - END


-- CPU.Avg - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'CPU', 
'Avg',
'ROUND(CONVERT(FLOAT, SUM(rs.avg_cpu_time*rs.count_executions))/NULLIF(SUM(rs.count_executions), 0)*0.001,2) avg_cpu_time,',
'results.cpu_time_regr_perc_recent cpu_time_regr_perc_recent,
		results.avg_cpu_time_recent avg_cpu_time_recent,
		results.avg_cpu_time_hist avg_cpu_time_hist,',
'ROUND(CONVERT(FLOAT, recent.avg_cpu_time-hist.avg_cpu_time)/NULLIF(hist.avg_cpu_time,0)*100.0, 2) cpu_time_regr_perc_recent,
		ROUND(recent.avg_cpu_time, 2) avg_cpu_time_recent,
		ROUND(hist.avg_cpu_time, 2) avg_cpu_time_hist,',
'cpu_time_regr_perc_recent'
)
-- CPU.Avg - END


-- CPU.Max - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'CPU', 
'Max',
'ROUND(CONVERT(FLOAT, MAX(rs.max_cpu_time))*0.001,2) max_cpu_time,',
'results.cpu_time_regr_perc_recent cpu_time_regr_perc_recent,
		results.max_cpu_time_recent max_cpu_time_recent,
		results.max_cpu_time_hist max_cpu_time_hist,',
'ROUND(CONVERT(FLOAT, recent.max_cpu_time-hist.max_cpu_time)/NULLIF(hist.max_cpu_time,0)*100.0, 2) cpu_time_regr_perc_recent,
		ROUND(recent.max_cpu_time, 2) max_cpu_time_recent,
		ROUND(hist.max_cpu_time, 2) max_cpu_time_hist,',
'cpu_time_regr_perc_recent'
)
-- CPU.Max - END


-- CPU.Min - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'CPU', 
'Min',
'ROUND(CONVERT(FLOAT, MIN(rs.min_cpu_time))*0.001,2) min_cpu_time,',
'results.cpu_time_regr_perc_recent cpu_time_regr_perc_recent,
		results.min_cpu_time_recent min_cpu_time_recent,
		results.min_cpu_time_hist min_cpu_time_hist,',
'ROUND(CONVERT(FLOAT, recent.min_cpu_time-hist.min_cpu_time)/NULLIF(hist.min_cpu_time,0)*100.0, 2) cpu_time_regr_perc_recent,
		ROUND(recent.min_cpu_time, 2) min_cpu_time_recent,
		ROUND(hist.min_cpu_time, 2) min_cpu_time_hist,',
'cpu_time_regr_perc_recent'
)
-- CPU.Min - END


-- CPU.StdDev - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'CPU', 
'StdDev',
'ROUND(CONVERT(FLOAT, SQRT( SUM(rs.stdev_cpu_time*rs.stdev_cpu_time*rs.count_executions)/NULLIF(SUM(rs.count_executions), 0)))*0.001,2) stdev_cpu_time,',
'results.cpu_time_regr_perc_recent cpu_time_regr_perc_recent,
		results.stdev_cpu_time_recent min_cpu_time_recent,
		results.stdev_cpu_time_hist min_cpu_time_hist,',
'ROUND(CONVERT(FLOAT, recent.stdev_cpu_time-hist.stdev_cpu_time)/NULLIF(hist.stdev_cpu_time,0)*100.0, 2) cpu_time_regr_perc_recent,
		ROUND(recent.stdev_cpu_time, 2) stdev_cpu_time_recent,
		ROUND(hist.stdev_cpu_time, 2) stdev_cpu_time_hist,',
'cpu_time_regr_perc_recent'
)
-- CPU.StdDev - END


-- CPU.Total - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'CPU', 
'Total',
'ROUND(CONVERT(FLOAT, SUM(rs.avg_cpu_time*rs.count_executions))*0.001,2) total_cpu_time,',
'results.additional_cpu_time_workload additional_cpu_time_workload,
		results.total_cpu_time_recent total_cpu_time_recent,
		results.total_cpu_time_hist total_cpu_time_hist,',
'ROUND(CONVERT(FLOAT, recent.total_cpu_time/recent.count_executions-hist.total_cpu_time/hist.count_executions)*(recent.count_executions), 2) additional_cpu_time_workload,
		ROUND(recent.total_cpu_time, 2) total_cpu_time_recent,
		ROUND(hist.total_cpu_time, 2) total_cpu_time_hist,',
'additional_cpu_time_workload'
)
-- CPU.Total - END


-- DOP.Avg - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'DOP', 
'Avg',
'ROUND(CONVERT(float, SUM(rs.avg_dop*rs.count_executions))/NULLIF(SUM(rs.count_executions), 0)*1,0) avg_dop,',
'results.dop_regr_perc_recent dop_regr_perc_recent,
		results.avg_dop_recent avg_dop_recent,
		results.avg_dop_hist avg_dop_hist,',
'ROUND(CONVERT(float, recent.avg_dop-hist.avg_dop)/NULLIF(hist.avg_dop,0)*100.0, 2) dop_regr_perc_recent,
		ROUND(recent.avg_dop, 2) avg_dop_recent,
		ROUND(hist.avg_dop, 2) avg_dop_hist,',
'dop_regr_perc_recent'
)
-- DOP.Avg - END


-- DOP.Max - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'DOP', 
'Max',
'ROUND(CONVERT(FLOAT, MAX(rs.max_dop))*1,2) max_dop,',
'results.dop_regr_perc_recent dop_regr_perc_recent,
		results.max_dop_recent max_dop_recent,
		results.max_dop_hist max_dop_hist,',
'ROUND(CONVERT(FLOAT, recent.max_dop-hist.max_dop)/NULLIF(hist.max_dop,0)*100.0, 2) dop_regr_perc_recent,
		ROUND(recent.max_dop, 2) max_dop_recent,
		ROUND(hist.max_dop, 2) max_dop_hist,',
'dop_regr_perc_recent'
)
-- DOP.Max - END

-- DOP.Min - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'DOP', 
'Min',
'ROUND(CONVERT(FLOAT, MIN(rs.min_dop))*1,2) min_dop,',
'results.dop_regr_perc_recent dop_regr_perc_recent,
		results.min_dop_recent min_dop_recent,
		results.min_dop_hist min_dop_hist,',
'ROUND(CONVERT(FLOAT, recent.min_dop-hist.min_dop)/NULLIF(hist.min_dop,0)*100.0, 2) dop_regr_perc_recent,
		ROUND(recent.min_dop, 2) min_dop_recent,
		ROUND(hist.min_dop, 2) min_dop_hist,',
'dop_regr_perc_recent'
)
-- DOP.Min - END


-- DOP.StdDev - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'DOP', 
'StdDev',
'ROUND(CONVERT(FLOAT, SQRT( SUM(rs.stdev_dop*rs.stdev_dop*rs.count_executions)/NULLIF(SUM(rs.count_executions), 0)))*1,2) stdev_dop,',
'results.dop_regr_perc_recent dop_regr_perc_recent,
		results.stdev_dop_recent min_dop_recent,
		results.stdev_dop_hist min_dop_hist,',
'ROUND(CONVERT(FLOAT, recent.stdev_dop-hist.stdev_dop)/NULLIF(hist.stdev_dop,0)*100.0, 2) dop_regr_perc_recent,
		ROUND(recent.stdev_dop, 2) stdev_dop_recent,
		ROUND(hist.stdev_dop, 2) stdev_dop_hist,',
'dop_regr_perc_recent'
)
-- DOP.StdDev - END


-- DOP.Total - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'DOP', 
'Total',
'ROUND(CONVERT(FLOAT, SUM(rs.avg_dop*rs.count_executions))*1,2) total_dop,',
'results.additional_dop_workload additional_dop_workload,
		results.total_dop_recent total_dop_recent,
		results.total_dop_hist total_dop_hist,',
'ROUND(CONVERT(FLOAT, recent.total_dop/recent.count_executions-hist.total_dop/hist.count_executions)*(recent.count_executions), 2) additional_dop_workload,
		ROUND(recent.total_dop, 2) total_dop_recent,
		ROUND(hist.total_dop, 2) total_dop_hist,',
'additional_dop_workload'
)
-- DOP.Total - END


-- Duration.Avg - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Duration', 
'Avg',
'ROUND(CONVERT(float, SUM(rs.avg_duration*rs.count_executions))/NULLIF(SUM(rs.count_executions), 0)*0.001,2) avg_duration,',
'results.duration_regr_perc_recent duration_regr_perc_recent,
		results.avg_duration_recent avg_duration_recent,
		results.avg_duration_hist avg_duration_hist,',
'ROUND(CONVERT(float, recent.avg_duration-hist.avg_duration)/NULLIF(hist.avg_duration,0)*100.0, 2) duration_regr_perc_recent,
		ROUND(recent.avg_duration, 2) avg_duration_recent,
		ROUND(hist.avg_duration, 2) avg_duration_hist,',
'duration_regr_perc_recent'
)
-- Duration.Avg - END


-- Duration.Max - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Duration', 
'Max',
'ROUND(CONVERT(float, MAX(rs.max_duration))*0.001,2) max_duration,',
'results.duration_regr_perc_recent duration_regr_perc_recent,
		results.max_duration_recent max_duration_recent,
		results.max_duration_hist max_duration_hist,',
'ROUND(CONVERT(float, recent.max_duration-hist.max_duration)/NULLIF(hist.max_duration,0)*100.0, 2) duration_regr_perc_recent,
		ROUND(recent.max_duration, 2) max_duration_recent,
		ROUND(hist.max_duration, 2) max_duration_hist,',
'duration_regr_perc_recent'
)
-- Duration.Max - END


-- Duration.Min - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Duration', 
'Min',
'ROUND(CONVERT(float, MIN(rs.min_duration))*0.001,2) min_duration,',
'results.duration_regr_perc_recent duration_regr_perc_recent,
		results.min_duration_recent min_duration_recent,
		results.min_duration_hist min_duration_hist,',
'ROUND(CONVERT(float, recent.min_duration-hist.min_duration)/NULLIF(hist.min_duration,0)*100.0, 2) duration_regr_perc_recent,
		ROUND(recent.min_duration, 2) min_duration_recent,
		ROUND(hist.min_duration, 2) min_duration_hist,',
'duration_regr_perc_recent'
)
-- Duration.Min - END


-- Duration.StdDev - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Duration', 
'StdDev',
'ROUND(CONVERT(float, SQRT( SUM(rs.stdev_duration*rs.stdev_duration*rs.count_executions)/NULLIF(SUM(rs.count_executions), 0)))*0.001,2) stdev_duration,',
'results.duration_regr_perc_recent duration_regr_perc_recent,
		results.stdev_duration_recent stdev_duration_recent,
		results.stdev_duration_hist stdev_duration_hist,',
'ROUND(CONVERT(float, recent.stdev_duration-hist.stdev_duration)/NULLIF(hist.stdev_duration,0)*100.0, 2) duration_regr_perc_recent,
		ROUND(recent.stdev_duration, 2) stdev_duration_recent,
		ROUND(hist.stdev_duration, 2) stdev_duration_hist,',
'duration_regr_perc_recent'
)
-- Duration.StdDev - END


-- Duration.Total - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Duration', 
'Total',
'ROUND(CONVERT(float, SUM(rs.avg_duration*rs.count_executions))*0.001,2) total_duration,',
'results.additional_duration_workload additional_duration_workload,
		results.total_duration_recent total_duration_recent,
		results.total_duration_hist total_duration_hist,',
'ROUND(CONVERT(float, recent.total_duration/recent.count_executions-hist.total_duration/hist.count_executions)*(recent.count_executions), 2) additional_duration_workload,
		ROUND(recent.total_duration, 2) total_duration_recent,
		ROUND(hist.total_duration, 2) total_duration_hist,',
'additional_duration_workload'
)
-- Duration.Total - END


-- Log.Avg - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Log', 
'Avg',
'ROUND(CONVERT(float, SUM(rs.avg_log_bytes_used*rs.count_executions))/NULLIF(SUM(rs.count_executions), 0)*1024,2) avg_log_bytes_used,',
'results.avg_log_bytes_used_regr_perc_recent avg_log_bytes_used_regr_perc_recent,
		results.avg_log_bytes_used_recent avg_log_bytes_used_recent,
		results.avg_log_bytes_used_hist avg_log_bytes_used_hist,',
'ROUND(CONVERT(FLOAT, recent.avg_log_bytes_used-hist.avg_log_bytes_used)/NULLIF(hist.avg_log_bytes_used,0)*100.0, 2) avg_log_bytes_used_regr_perc_recent,
		ROUND(recent.avg_log_bytes_used, 2) avg_log_bytes_used_recent,
		ROUND(hist.avg_log_bytes_used, 2) avg_log_bytes_used_hist,',
'avg_log_bytes_used_regr_perc_recent'
)
-- Log.Avg - END


-- Log.Max - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Log', 
'Max',
'ROUND(CONVERT(FLOAT, MAX(rs.max_log_bytes_used))*1024,2) max_log_bytes_used,',
'results.log_bytes_used_regr_perc_recent log_bytes_used_regr_perc_recent,
		results.max_log_bytes_used_recent max_log_bytes_used_recent,
		results.max_log_bytes_used_hist max_log_bytes_used_hist,',
'ROUND(CONVERT(FLOAT, recent.max_log_bytes_used-hist.max_log_bytes_used)/NULLIF(hist.max_log_bytes_used,0)*100.0, 2) log_bytes_used_regr_perc_recent,
		ROUND(recent.max_log_bytes_used, 2) max_log_bytes_used_recent,
		ROUND(hist.max_log_bytes_used, 2) max_log_bytes_used_hist,',
'log_bytes_used_regr_perc_recent'
)
-- Log.Max - END


-- Log.Min - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Log', 
'Min',
'ROUND(CONVERT(FLOAT, MIN(rs.min_log_bytes_used))*1024,2) min_log_bytes_used,',
'results.log_bytes_used_regr_perc_recent log_bytes_used_regr_perc_recent,
		results.min_log_bytes_used_recent min_log_bytes_used_recent,
		results.min_log_bytes_used_hist min_log_bytes_used_hist,',
'ROUND(CONVERT(FLOAT, recent.min_log_bytes_used-hist.min_log_bytes_used)/NULLIF(hist.min_log_bytes_used,0)*100.0, 2) log_bytes_used_regr_perc_recent,
		ROUND(recent.min_log_bytes_used, 2) min_log_bytes_used_recent,
		ROUND(hist.min_log_bytes_used, 2) min_log_bytes_used_hist,',
'log_bytes_used_regr_perc_recent'
)
-- Log.Min - END


-- Log.StdDev - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Log', 
'StdDev',
'ROUND(CONVERT(FLOAT, SQRT( SUM(rs.stdev_log_bytes_used*rs.stdev_log_bytes_used*rs.count_executions)/NULLIF(SUM(rs.count_executions), 0)))*1024,2) stdev_log_bytes_used,',
'results.log_bytes_used_regr_perc_recent log_bytes_used_regr_perc_recent,
		results.stdev_log_bytes_used_recent min_log_bytes_used_recent,
		results.stdev_log_bytes_used_hist min_log_bytes_used_hist,',
'ROUND(CONVERT(FLOAT, recent.stdev_log_bytes_used-hist.stdev_log_bytes_used)/NULLIF(hist.stdev_log_bytes_used,0)*100.0, 2) log_bytes_used_regr_perc_recent,
		ROUND(recent.stdev_log_bytes_used, 2) stdev_log_bytes_used_recent,
		ROUND(hist.stdev_log_bytes_used, 2) stdev_log_bytes_used_hist,',
'log_bytes_used_regr_perc_recent'
)
-- Log.StdDev - END


-- Log.Total - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Log', 
'Total',
'ROUND(CONVERT(FLOAT, SUM(rs.avg_log_bytes_used*rs.count_executions))*1024,2) total_log_bytes_used,',
'results.additional_log_bytes_used_workload additional_log_bytes_used_workload,
		results.total_log_bytes_used_recent total_log_bytes_used_recent,
		results.total_log_bytes_used_hist total_log_bytes_used_hist,',
'ROUND(CONVERT(FLOAT, recent.total_log_bytes_used/recent.count_executions-hist.total_log_bytes_used/hist.count_executions)*(recent.count_executions), 2) additional_log_bytes_used_workload,
		ROUND(recent.total_log_bytes_used, 2) total_log_bytes_used_recent,
		ROUND(hist.total_log_bytes_used, 2) total_log_bytes_used_hist,',
'additional_log_bytes_used_workload'
)
-- Log.Total - END


-- LogicalIOReads.Avg - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'LogicalIOReads', 
'Avg',
'ROUND(CONVERT(FLOAT, SUM(rs.avg_logical_io_reads*rs.count_executions))/NULLIF(SUM(rs.count_executions), 0)*8,2) avg_logical_io_reads,',
'results.logical_io_reads_regr_perc_recent logical_io_reads_regr_perc_recent,
		results.avg_logical_io_reads_recent avg_logical_io_reads_recent,
		results.avg_logical_io_reads_hist avg_logical_io_reads_hist,',
'ROUND(CONVERT(FLOAT, recent.avg_logical_io_reads-hist.avg_logical_io_reads)/NULLIF(hist.avg_logical_io_reads,0)*100.0, 2) logical_io_reads_regr_perc_recent,
		ROUND(recent.avg_logical_io_reads, 2) avg_logical_io_reads_recent,
		ROUND(hist.avg_logical_io_reads, 2) avg_logical_io_reads_hist,',
'logical_io_reads_regr_perc_recent'
)
-- LogicalIOReads.Avg - END


-- LogicalIOReads.Max - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'LogicalIOReads', 
'Max',
'ROUND(CONVERT(FLOAT, MAX(rs.max_logical_io_reads))*8,2) max_logical_io_reads,',
'results.logical_io_reads_regr_perc_recent logical_io_reads_regr_perc_recent,
		results.max_logical_io_reads_recent max_logical_io_reads_recent,
		results.max_logical_io_reads_hist max_logical_io_reads_hist,',
'ROUND(CONVERT(FLOAT, recent.max_logical_io_reads-hist.max_logical_io_reads)/NULLIF(hist.max_logical_io_reads,0)*100.0, 2) logical_io_reads_regr_perc_recent,
		ROUND(recent.max_logical_io_reads, 2) max_logical_io_reads_recent,
		ROUND(hist.max_logical_io_reads, 2) max_logical_io_reads_hist,',
'logical_io_reads_regr_perc_recent'
)
-- LogicalIOReads.Max - END


-- LogicalIOReads.Min - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'LogicalIOReads', 
'Min',
'ROUND(CONVERT(FLOAT, MIN(rs.min_logical_io_reads))*8,2) min_logical_io_reads,',
'results.logical_io_reads_regr_perc_recent logical_io_reads_regr_perc_recent,
		results.min_logical_io_reads_recent min_logical_io_reads_recent,
		results.min_logical_io_reads_hist min_logical_io_reads_hist,',
'ROUND(CONVERT(FLOAT, recent.min_logical_io_reads-hist.min_logical_io_reads)/NULLIF(hist.min_logical_io_reads,0)*100.0, 2) logical_io_reads_regr_perc_recent,
		ROUND(recent.min_logical_io_reads, 2) min_logical_io_reads_recent,
		ROUND(hist.min_logical_io_reads, 2) min_logical_io_reads_hist,',
'logical_io_reads_regr_perc_recent'
)
-- LogicalIOReads.Min - END


-- LogicalIOReads.StdDev - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'LogicalIOReads', 
'StdDev',
'ROUND(CONVERT(FLOAT, SQRT( SUM(rs.stdev_logical_io_reads*rs.stdev_logical_io_reads*rs.count_executions)/NULLIF(SUM(rs.count_executions), 0)))*8,2) stdev_logical_io_reads,',
'results.logical_io_reads_regr_perc_recent logical_io_reads_regr_perc_recent,
		results.stdev_logical_io_reads_recent min_logical_io_reads_recent,
		results.stdev_logical_io_reads_hist min_logical_io_reads_hist,',
'ROUND(CONVERT(FLOAT, recent.stdev_logical_io_reads-hist.stdev_logical_io_reads)/NULLIF(hist.stdev_logical_io_reads,0)*100.0, 2) logical_io_reads_regr_perc_recent,
		ROUND(recent.stdev_logical_io_reads, 2) stdev_logical_io_reads_recent,
		ROUND(hist.stdev_logical_io_reads, 2) stdev_logical_io_reads_hist,',
'logical_io_reads_regr_perc_recent'
)
-- LogicalIOReads.StdDev - END


-- LogicalIOReads.Total - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'LogicalIOReads', 
'Total',
'ROUND(CONVERT(FLOAT, SUM(rs.avg_logical_io_reads*rs.count_executions))*8,2) total_logical_io_reads,',
'results.additional_logical_io_reads_workload additional_logical_io_reads_workload,
		results.total_logical_io_reads_recent total_logical_io_reads_recent,
		results.total_logical_io_reads_hist total_logical_io_reads_hist,',
'ROUND(CONVERT(FLOAT, recent.total_logical_io_reads/recent.count_executions-hist.total_logical_io_reads/hist.count_executions)*(recent.count_executions), 2) additional_logical_io_reads_workload,
		ROUND(recent.total_logical_io_reads, 2) total_logical_io_reads_recent,
		ROUND(hist.total_logical_io_reads, 2) total_logical_io_reads_hist,',
'additional_logical_io_reads_workload'
)
-- LogicalIOReads.Total - END


-- LogicalIOWrites.Avg - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'LogicalIOWrites', 
'Avg',
'ROUND(CONVERT(FLOAT, SUM(rs.avg_logical_io_writes*rs.count_executions))/NULLIF(SUM(rs.count_executions), 0)*8,2) avg_logical_io_writes,',
'results.logical_io_writes_regr_perc_recent logical_io_writes_regr_perc_recent,
		results.avg_logical_io_writes_recent avg_logical_io_writes_recent,
		results.avg_logical_io_writes_hist avg_logical_io_writes_hist,',
'ROUND(CONVERT(FLOAT, recent.avg_logical_io_writes-hist.avg_logical_io_writes)/NULLIF(hist.avg_logical_io_writes,0)*100.0, 2) logical_io_writes_regr_perc_recent,
		ROUND(recent.avg_logical_io_writes, 2) avg_logical_io_writes_recent,
		ROUND(hist.avg_logical_io_writes, 2) avg_logical_io_writes_hist,',
'logical_io_writes_regr_perc_recent'
)
-- LogicalIOWrites.Avg - END


-- LogicalIOWrites.Max - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'LogicalIOWrites', 
'Max',
'ROUND(CONVERT(FLOAT, MAX(rs.max_logical_io_writes))*8,2) max_logical_io_writes,',
'results.logical_io_writes_regr_perc_recent logical_io_writes_regr_perc_recent,
		results.max_logical_io_writes_recent max_logical_io_writes_recent,
		results.max_logical_io_writes_hist max_logical_io_writes_hist,',
'ROUND(CONVERT(FLOAT, recent.max_logical_io_writes-hist.max_logical_io_writes)/NULLIF(hist.max_logical_io_writes,0)*100.0, 2) logical_io_writes_regr_perc_recent,
		ROUND(recent.max_logical_io_writes, 2) max_logical_io_writes_recent,
		ROUND(hist.max_logical_io_writes, 2) max_logical_io_writes_hist,',
'logical_io_writes_regr_perc_recent'
)
-- LogicalIOWrites.Max - END


-- LogicalIOWrites.Min - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'LogicalIOWrites', 
'Min',
'ROUND(CONVERT(FLOAT, MIN(rs.min_logical_io_writes))*8,2) min_logical_io_writes,',
'results.logical_io_writes_regr_perc_recent logical_io_writes_regr_perc_recent,
		results.min_logical_io_writes_recent min_logical_io_writes_recent,
		results.min_logical_io_writes_hist min_logical_io_writes_hist,',
'ROUND(CONVERT(FLOAT, recent.min_logical_io_writes-hist.min_logical_io_writes)/NULLIF(hist.min_logical_io_writes,0)*100.0, 2) logical_io_writes_regr_perc_recent,
		ROUND(recent.min_logical_io_writes, 2) min_logical_io_writes_recent,
		ROUND(hist.min_logical_io_writes, 2) min_logical_io_writes_hist,',
'logical_io_writes_regr_perc_recent'
)
-- LogicalIOWrites.Min - END


-- LogicalIOWrites.StdDev - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'LogicalIOWrites', 
'StdDev',
'ROUND(CONVERT(FLOAT, SQRT( SUM(rs.stdev_logical_io_writes*rs.stdev_logical_io_writes*rs.count_executions)/NULLIF(SUM(rs.count_executions), 0)))*8,2) stdev_logical_io_writes,',
'results.logical_io_writes_regr_perc_recent logical_io_writes_regr_perc_recent,
		results.stdev_logical_io_writes_recent min_logical_io_writes_recent,
		results.stdev_logical_io_writes_hist min_logical_io_writes_hist,',
'ROUND(CONVERT(FLOAT, recent.stdev_logical_io_writes-hist.stdev_logical_io_writes)/NULLIF(hist.stdev_logical_io_writes,0)*100.0, 2) logical_io_writes_regr_perc_recent,
		ROUND(recent.stdev_logical_io_writes, 2) stdev_logical_io_writes_recent,
		ROUND(hist.stdev_logical_io_writes, 2) stdev_logical_io_writes_hist,',
'logical_io_writes_regr_perc_recent'
)
-- LogicalIOWrites.StdDev - END


-- LogicalIOWrites.Total - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'LogicalIOWrites', 
'Total',
'ROUND(CONVERT(FLOAT, SUM(rs.avg_logical_io_writes*rs.count_executions))*8,2) total_logical_io_writes,',
'results.additional_logical_io_writes_workload additional_logical_io_writes_workload,
		results.total_logical_io_writes_recent total_logical_io_writes_recent,
		results.total_logical_io_writes_hist total_logical_io_writes_hist,',
'ROUND(CONVERT(FLOAT, recent.total_logical_io_writes/recent.count_executions-hist.total_logical_io_writes/hist.count_executions)*(recent.count_executions), 2) additional_logical_io_writes_workload,
		ROUND(recent.total_logical_io_writes, 2) total_logical_io_writes_recent,
		ROUND(hist.total_logical_io_writes, 2) total_logical_io_writes_hist,',
'additional_logical_io_writes_workload'
)
-- LogicalIOWrites.Total - END


-- MaxMemory.Avg - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'MaxMemory', 
'Avg',
'ROUND(CONVERT(FLOAT, SUM(rs.avg_query_max_used_memory*rs.count_executions))/NULLIF(SUM(rs.count_executions), 0)*8,2) avg_query_max_used_memory,',
'results.query_max_used_memory_regr_perc_recent query_max_used_memory_regr_perc_recent,
		results.avg_query_max_used_memory_recent avg_query_max_used_memory_recent,
		results.avg_query_max_used_memory_hist avg_query_max_used_memory_hist,',
'ROUND(CONVERT(FLOAT, recent.avg_query_max_used_memory-hist.avg_query_max_used_memory)/NULLIF(hist.avg_query_max_used_memory,0)*100.0, 2) query_max_used_memory_regr_perc_recent,
		ROUND(recent.avg_query_max_used_memory, 2) avg_query_max_used_memory_recent,
		ROUND(hist.avg_query_max_used_memory, 2) avg_query_max_used_memory_hist,',
'query_max_used_memory_regr_perc_recent'
)
-- MaxMemory.Avg - END


-- MaxMemory.Max - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'MaxMemory', 
'Max',
'ROUND(CONVERT(FLOAT, MAX(rs.max_query_max_used_memory))*8,2) max_query_max_used_memory,',
'results.query_max_used_memory_regr_perc_recent query_max_used_memory_regr_perc_recent,
		results.max_query_max_used_memory_recent max_query_max_used_memory_recent,
		results.max_query_max_used_memory_hist max_query_max_used_memory_hist,',
'ROUND(CONVERT(FLOAT, recent.max_query_max_used_memory-hist.max_query_max_used_memory)/NULLIF(hist.max_query_max_used_memory,0)*100.0, 2) query_max_used_memory_regr_perc_recent,
		ROUND(recent.max_query_max_used_memory, 2) max_query_max_used_memory_recent,
		ROUND(hist.max_query_max_used_memory, 2) max_query_max_used_memory_hist,',
'query_max_used_memory_regr_perc_recent'
)
-- MaxMemory.Max - END


-- MaxMemory.Min - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'MaxMemory', 
'Min',
'ROUND(CONVERT(FLOAT, MIN(rs.min_query_max_used_memory))*8,2) min_query_max_used_memory,',
'results.query_max_used_memory_regr_perc_recent query_max_used_memory_regr_perc_recent,
		results.min_query_max_used_memory_recent min_query_max_used_memory_recent,
		results.min_query_max_used_memory_hist min_query_max_used_memory_hist,',
'ROUND(CONVERT(FLOAT, recent.min_query_max_used_memory-hist.min_query_max_used_memory)/NULLIF(hist.min_query_max_used_memory,0)*100.0, 2) query_max_used_memory_regr_perc_recent,
		ROUND(recent.min_query_max_used_memory, 2) min_query_max_used_memory_recent,
		ROUND(hist.min_query_max_used_memory, 2) min_query_max_used_memory_hist,',
'query_max_used_memory_regr_perc_recent'
)
-- MaxMemory.Min - END


-- MaxMemory.StdDev - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'MaxMemory', 
'StdDev',
'ROUND(CONVERT(FLOAT, SQRT( SUM(rs.stdev_query_max_used_memory*rs.stdev_query_max_used_memory*rs.count_executions)/NULLIF(SUM(rs.count_executions), 0)))*8,2) stdev_query_max_used_memory,',
'results.query_max_used_memory_regr_perc_recent query_max_used_memory_regr_perc_recent,
		results.stdev_query_max_used_memory_recent min_query_max_used_memory_recent,
		results.stdev_query_max_used_memory_hist min_query_max_used_memory_hist,',
'ROUND(CONVERT(FLOAT, recent.stdev_query_max_used_memory-hist.stdev_query_max_used_memory)/NULLIF(hist.stdev_query_max_used_memory,0)*100.0, 2) query_max_used_memory_regr_perc_recent,
		ROUND(recent.stdev_query_max_used_memory, 2) stdev_query_max_used_memory_recent,
		ROUND(hist.stdev_query_max_used_memory, 2) stdev_query_max_used_memory_hist,',
'query_max_used_memory_regr_perc_recent'
)
-- MaxMemory.StdDev - END


-- MaxMemory.Total - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'MaxMemory', 
'Total',
'ROUND(CONVERT(FLOAT, SUM(rs.avg_query_max_used_memory*rs.count_executions))*8,2) total_query_max_used_memory,',
'results.additional_query_max_used_memory_workload additional_query_max_used_memory_workload,
		results.total_query_max_used_memory_recent total_query_max_used_memory_recent,
		results.total_query_max_used_memory_hist total_query_max_used_memory_hist,',
'ROUND(CONVERT(FLOAT, recent.total_query_max_used_memory/recent.count_executions-hist.total_query_max_used_memory/hist.count_executions)*(recent.count_executions), 2) additional_query_max_used_memory_workload,
		ROUND(recent.total_query_max_used_memory, 2) total_query_max_used_memory_recent,
		ROUND(hist.total_query_max_used_memory, 2) total_query_max_used_memory_hist,',
'additional_query_max_used_memory_workload'
)
-- MaxMemory.Total - END


-- PhysicalIOReads.Avg - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'PhysicalIOReads', 
'Avg',
'ROUND(CONVERT(FLOAT, SUM(rs.avg_physical_io_reads*rs.count_executions))/NULLIF(SUM(rs.count_executions), 0)*8,2) avg_physical_io_reads,',
'results.physical_io_reads_regr_perc_recent physical_io_reads_regr_perc_recent,
		results.avg_physical_io_reads_recent avg_physical_io_reads_recent,
		results.avg_physical_io_reads_hist avg_physical_io_reads_hist,',
'ROUND(CONVERT(FLOAT, recent.avg_physical_io_reads-hist.avg_physical_io_reads)/NULLIF(hist.avg_physical_io_reads,0)*100.0, 2) physical_io_reads_regr_perc_recent,
		ROUND(recent.avg_physical_io_reads, 2) avg_physical_io_reads_recent,
		ROUND(hist.avg_physical_io_reads, 2) avg_physical_io_reads_hist,',
'physical_io_reads_regr_perc_recent'
)
-- PhysicalIOReads.Avg - END


-- PhysicalIOReads.Max - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'PhysicalIOReads', 
'Max',
'ROUND(CONVERT(FLOAT, MAX(rs.max_physical_io_reads))*8,2) max_physical_io_reads,',
'results.physical_io_reads_regr_perc_recent physical_io_reads_regr_perc_recent,
		results.max_physical_io_reads_recent max_physical_io_reads_recent,
		results.max_physical_io_reads_hist max_physical_io_reads_hist,',
'ROUND(CONVERT(FLOAT, recent.max_physical_io_reads-hist.max_physical_io_reads)/NULLIF(hist.max_physical_io_reads,0)*100.0, 2) physical_io_reads_regr_perc_recent,
		ROUND(recent.max_physical_io_reads, 2) max_physical_io_reads_recent,
		ROUND(hist.max_physical_io_reads, 2) max_physical_io_reads_hist,',
'physical_io_reads_regr_perc_recent'
)
-- PhysicalIOReads.Max - END


-- PhysicalIOReads.Min - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'PhysicalIOReads', 
'Min',
'ROUND(CONVERT(FLOAT, MIN(rs.min_physical_io_reads))*8,2) min_physical_io_reads,',
'results.physical_io_reads_regr_perc_recent physical_io_reads_regr_perc_recent,
		results.min_physical_io_reads_recent min_physical_io_reads_recent,
		results.min_physical_io_reads_hist min_physical_io_reads_hist,',
'ROUND(CONVERT(FLOAT, recent.min_physical_io_reads-hist.min_physical_io_reads)/NULLIF(hist.min_physical_io_reads,0)*100.0, 2) physical_io_reads_regr_perc_recent,
		ROUND(recent.min_physical_io_reads, 2) min_physical_io_reads_recent,
		ROUND(hist.min_physical_io_reads, 2) min_physical_io_reads_hist,',
'physical_io_reads_regr_perc_recent'
)
-- PhysicalIOReads.Min - END


-- PhysicalIOReads.StdDev - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'PhysicalIOReads', 
'StdDev',
'ROUND(CONVERT(FLOAT, SQRT( SUM(rs.stdev_physical_io_reads*rs.stdev_physical_io_reads*rs.count_executions)/NULLIF(SUM(rs.count_executions), 0)))*8,2) stdev_physical_io_reads,',
'results.physical_io_reads_regr_perc_recent physical_io_reads_regr_perc_recent,
		results.stdev_physical_io_reads_recent min_physical_io_reads_recent,
		results.stdev_physical_io_reads_hist min_physical_io_reads_hist,',
'ROUND(CONVERT(FLOAT, recent.stdev_physical_io_reads-hist.stdev_physical_io_reads)/NULLIF(hist.stdev_physical_io_reads,0)*100.0, 2) physical_io_reads_regr_perc_recent,
		ROUND(recent.stdev_physical_io_reads, 2) stdev_physical_io_reads_recent,
		ROUND(hist.stdev_physical_io_reads, 2) stdev_physical_io_reads_hist,',
'physical_io_reads_regr_perc_recent'
)
-- PhysicalIOReads.StdDev - END


-- PhysicalIOReads.Total - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'PhysicalIOReads', 
'Total',
'ROUND(CONVERT(FLOAT, SUM(rs.avg_physical_io_reads*rs.count_executions))*8,2) total_physical_io_reads,',
'results.additional_physical_io_reads_workload additional_physical_io_reads_workload,
		results.total_physical_io_reads_recent total_physical_io_reads_recent,
		results.total_physical_io_reads_hist total_physical_io_reads_hist,',
'ROUND(CONVERT(FLOAT, recent.total_physical_io_reads/recent.count_executions-hist.total_physical_io_reads/hist.count_executions)*(recent.count_executions), 2) additional_physical_io_reads_workload,
		ROUND(recent.total_physical_io_reads, 2) total_physical_io_reads_recent,
		ROUND(hist.total_physical_io_reads, 2) total_physical_io_reads_hist,',
'additional_physical_io_reads_workload'
)
-- PhysicalIOReads.Total - END


-- Rowcount.Avg - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Rowcount', 
'Avg',
'ROUND(CONVERT(float, SUM(rs.avg_rowcount*rs.count_executions))/NULLIF(SUM(rs.count_executions), 0)*1,0) avg_rowcount,',
'results.rowcount_regr_perc_recent rowcount_regr_perc_recent,
		results.avg_rowcount_recent avg_rowcount_recent,
		results.avg_rowcount_hist avg_rowcount_hist,',
'ROUND(CONVERT(float, recent.avg_rowcount-hist.avg_rowcount)/NULLIF(hist.avg_rowcount,0)*100.0, 2) rowcount_regr_perc_recent,
		ROUND(recent.avg_rowcount, 2) avg_rowcount_recent,
		ROUND(hist.avg_rowcount, 2) avg_rowcount_hist,',
'rowcount_regr_perc_recent'
)
-- Rowcount.Avg - END


-- Rowcount.Max - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Rowcount', 
'Max',
'ROUND(CONVERT(FLOAT, MAX(rs.max_rowcount))*1,2) max_rowcount,',
'results.rowcount_regr_perc_recent rowcount_regr_perc_recent,
		results.max_rowcount_recent max_rowcount_recent,
		results.max_rowcount_hist max_rowcount_hist,',
'ROUND(CONVERT(FLOAT, recent.max_rowcount-hist.max_rowcount)/NULLIF(hist.max_rowcount,0)*100.0, 2) rowcount_regr_perc_recent,
		ROUND(recent.max_rowcount, 2) max_rowcount_recent,
		ROUND(hist.max_rowcount, 2) max_rowcount_hist,',
'rowcount_regr_perc_recent'
)
-- Rowcount.Max - END


-- Rowcount.Min - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Rowcount', 
'Min',
'ROUND(CONVERT(FLOAT, MIN(rs.min_rowcount))*1,2) min_rowcount,',
'results.rowcount_regr_perc_recent rowcount_regr_perc_recent,
		results.min_rowcount_recent min_rowcount_recent,
		results.min_rowcount_hist min_rowcount_hist,',
'ROUND(CONVERT(FLOAT, recent.min_rowcount-hist.min_rowcount)/NULLIF(hist.min_rowcount,0)*100.0, 2) rowcount_regr_perc_recent,
		ROUND(recent.min_rowcount, 2) min_rowcount_recent,
		ROUND(hist.min_rowcount, 2) min_rowcount_hist,',
'rowcount_regr_perc_recent'
)
-- Rowcount.Min - END


-- Rowcount.StdDev - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Rowcount', 
'StdDev',
'ROUND(CONVERT(FLOAT, SQRT( SUM(rs.stdev_rowcount*rs.stdev_rowcount*rs.count_executions)/NULLIF(SUM(rs.count_executions), 0)))*1,2) stdev_rowcount,',
'results.rowcount_regr_perc_recent rowcount_regr_perc_recent,
		results.stdev_rowcount_recent min_rowcount_recent,
		results.stdev_rowcount_hist min_rowcount_hist,',
'ROUND(CONVERT(FLOAT, recent.stdev_rowcount-hist.stdev_rowcount)/NULLIF(hist.stdev_rowcount,0)*100.0, 2) rowcount_regr_perc_recent,
		ROUND(recent.stdev_rowcount, 2) stdev_rowcount_recent,
		ROUND(hist.stdev_rowcount, 2) stdev_rowcount_hist,',
'rowcount_regr_perc_recent'
)
-- Rowcount.StdDev - END


-- Rowcount.Total - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'Rowcount', 
'Total',
'ROUND(CONVERT(FLOAT, SUM(rs.avg_rowcount*rs.count_executions))*1,2) total_rowcount,',
'results.additional_rowcount_workload additional_rowcount_workload,
		results.total_rowcount_recent total_rowcount_recent,
		results.total_rowcount_hist total_rowcount_hist,',
'ROUND(CONVERT(FLOAT, recent.total_rowcount/recent.count_executions-hist.total_rowcount/hist.count_executions)*(recent.count_executions), 2) additional_rowcount_workload,
		ROUND(recent.total_rowcount, 2) total_rowcount_recent,
		ROUND(hist.total_rowcount, 2) total_rowcount_hist,',
'additional_rowcount_workload'
)
-- Rowcount.Total - END


-- TempDB.Avg - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'TempDB', 
'Avg',
'ROUND(CONVERT(FLOAT, SUM(rs.avg_tempdb_space_used*rs.count_executions))/NULLIF(SUM(rs.count_executions), 0)*8,2) avg_tempdb_space_used,',
'results.tempdb_space_used_regr_perc_recent tempdb_space_used_regr_perc_recent,
		results.avg_tempdb_space_used_recent avg_tempdb_space_used_recent,
		results.avg_tempdb_space_used_hist avg_tempdb_space_used_hist,',
'ROUND(CONVERT(FLOAT, recent.avg_tempdb_space_used-hist.avg_tempdb_space_used)/NULLIF(hist.avg_tempdb_space_used,0)*100.0, 2) tempdb_space_used_regr_perc_recent,
		ROUND(recent.avg_tempdb_space_used, 2) avg_tempdb_space_used_recent,
		ROUND(hist.avg_tempdb_space_used, 2) avg_tempdb_space_used_hist,',
'tempdb_space_used_regr_perc_recent'
)
-- TempDB.Avg - END


-- TempDB.Max - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'TempDB', 
'Max',
'ROUND(CONVERT(FLOAT, MAX(rs.max_tempdb_space_used))*8,2) max_tempdb_space_used,',
'results.tempdb_space_used_regr_perc_recent tempdb_space_used_regr_perc_recent,
		results.max_tempdb_space_used_recent max_tempdb_space_used_recent,
		results.max_tempdb_space_used_hist max_tempdb_space_used_hist,',
'ROUND(CONVERT(FLOAT, recent.max_tempdb_space_used-hist.max_tempdb_space_used)/NULLIF(hist.max_tempdb_space_used,0)*100.0, 2) tempdb_space_used_regr_perc_recent,
		ROUND(recent.max_tempdb_space_used, 2) max_tempdb_space_used_recent,
		ROUND(hist.max_tempdb_space_used, 2) max_tempdb_space_used_hist,',
'tempdb_space_used_regr_perc_recent'
)
-- TempDB.Max - END


-- TempDB.Min - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'TempDB', 
'Min',
'ROUND(CONVERT(FLOAT, MIN(rs.min_tempdb_space_used))*8,2) min_tempdb_space_used,',
'results.tempdb_space_used_regr_perc_recent tempdb_space_used_regr_perc_recent,
		results.min_tempdb_space_used_recent min_tempdb_space_used_recent,
		results.min_tempdb_space_used_hist min_tempdb_space_used_hist,',
'ROUND(CONVERT(FLOAT, recent.min_tempdb_space_used-hist.min_tempdb_space_used)/NULLIF(hist.min_tempdb_space_used,0)*100.0, 2) tempdb_space_used_regr_perc_recent,
		ROUND(recent.min_tempdb_space_used, 2) min_tempdb_space_used_recent,
		ROUND(hist.min_tempdb_space_used, 2) min_tempdb_space_used_hist,',
'tempdb_space_used_regr_perc_recent'
)
-- TempDB.Min - END


-- TempDB.StdDev - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'TempDB', 
'StdDev',
'ROUND(CONVERT(FLOAT, SQRT( SUM(rs.stdev_tempdb_space_used*rs.stdev_tempdb_space_used*rs.count_executions)/NULLIF(SUM(rs.count_executions), 0)))*8,2) stdev_tempdb_space_used,',
'results.tempdb_space_used_regr_perc_recent tempdb_space_used_regr_perc_recent,
		results.stdev_tempdb_space_used_recent min_tempdb_space_used_recent,
		results.stdev_tempdb_space_used_hist min_tempdb_space_used_hist,',
'ROUND(CONVERT(FLOAT, recent.stdev_tempdb_space_used-hist.stdev_tempdb_space_used)/NULLIF(hist.stdev_tempdb_space_used,0)*100.0, 2) tempdb_space_used_regr_perc_recent,
		ROUND(recent.stdev_tempdb_space_used, 2) stdev_tempdb_space_used_recent,
		ROUND(hist.stdev_tempdb_space_used, 2) stdev_tempdb_space_used_hist,',
'tempdb_space_used_regr_perc_recent'
)
-- TempDB.StdDev - END


-- TempDB.Total - START
INSERT INTO [dbo].[QDSMetricArchive] ([Measurement], [Metric], [SubQuery01], [SubQuery02], [SubQuery03], [SubQuery04])
VALUES (
'TempDB', 
'Total',
'ROUND(CONVERT(FLOAT, SUM(rs.avg_tempdb_space_used*rs.count_executions))*8,2) total_tempdb_space_used,',
'results.additional_tempdb_space_used_workload additional_tempdb_space_used_workload,
		results.total_tempdb_space_used_recent total_tempdb_space_used_recent,
		results.total_tempdb_space_used_hist total_tempdb_space_used_hist,',
'ROUND(CONVERT(FLOAT, recent.total_tempdb_space_used/recent.count_executions-hist.total_tempdb_space_used/hist.count_executions)*(recent.count_executions), 2) additional_tempdb_space_used_workload,
		ROUND(recent.total_tempdb_space_used, 2) total_tempdb_space_used_recent,
		ROUND(hist.total_tempdb_space_used, 2) total_tempdb_space_used_hist,',
'additional_tempdb_space_used_workload'
)
-- TempDB.Total - END

SELECT 
	*
FROM [dbo].[QDSMetricArchive]
ORDER BY
	[Measurement]
	,[Metric]