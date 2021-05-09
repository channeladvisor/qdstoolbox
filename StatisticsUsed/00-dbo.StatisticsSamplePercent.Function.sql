---------------------------------------------------------------------------------
-- Function Name: [dbo].[StatisticsSamplePercent]
--
-- Desc: This function returns a sample rate for the statistics update based on current rowcount & sample rate of the statistic
--
-- Parameters:
--	INPUT
--		@RowsTotal			BIGINT
--			Number of rows in the statistics
--			[Default: None]
--
--		@RowsSampledPercent		BIGINT
--			Percentage of rows used in the last calculation of the statistics
--			[Default: None]
--
-- Notes:
--		This is a sample function and in no way should be taken into your environment without proper testing
--		Feel free to ignore this function and modify the logic in [dbo].[StatisticsUsed] accordingly
--		
--
-- Date: 2021.05.08
-- Auth: Pablo Lozano (@sqlozano)
----------------------------------------------------------------------------------

CREATE OR ALTER FUNCTION [dbo].[StatisticsSamplePercent]
(
	 @RowsTotal				BIGINT
	,@RowsSampledPercent	DECIMAL(16,2)
)
RETURNS INT
AS
BEGIN
	-- If the previous sample rate was > 75, upscale it to 100
	IF (@RowsSampledPercent > 75) RETURN 100
	-- Sample values: addapt them based on your metrics and experience with your own data
	RETURN
		CASE
			-- Small tables:		100 % sample
			WHEN @RowsTotal    <       1000000					THEN 100
			-- Medium tables:		 50% sample or the same current sample (when it is higher than 50%)
			WHEN @RowsTotal BETWEEN    1000000 AND  9999999		THEN IIF(@RowsSampledPercent > 50, CAST(@RowsSampledPercent AS INT), 50)
			-- Large tables:		 20% sample or the same current sample (when it is higher than 20%)
			WHEN @RowsTotal BETWEEN   10000000 AND 99999999		THEN IIF(@RowsSampledPercent > 20, CAST(@RowsSampledPercent AS INT), 20)
			-- Very large tables:	  5% sample or the same current sample (when it is higher than  5%)
			WHEN @RowsTotal    >     100000000					THEN IIF(@RowsSampledPercent >  5, CAST(@RowsSampledPercent AS INT), 5)
		END
END